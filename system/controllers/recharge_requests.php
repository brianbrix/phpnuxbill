<?php

/**
 * Recharge Requests Management Controller
 * Admin interface for viewing and processing customer recharge requests
 */

_admin();
$ui->assign('_title', Lang::T('Recharge Requests'));
$ui->assign('_system_menu', 'recharge_requests');

$action = $routes['1'];
$admin = Admin::_info();
$ui->assign('_admin', $admin);

switch ($action) {
    case 'list':
    default:
        // List all pending recharge requests
        $query = ORM::for_table('tbl_recharge_requests')
            ->where('status', 'pending')
            ->order_by_desc('requested_date');
        
        $requests = Paginator::findMany($query);
        
        $ui->assign('requests', $requests);
        $ui->display('admin/recharge_requests/list.tpl');
        break;
        
    case 'view':
        $id = $routes['2'];
        $request = ORM::for_table('tbl_recharge_requests')->find_one($id);
        
        if (!$request) {
            r2(getUrl('recharge_requests/list'), 'e', Lang::T('Request not found'));
        }
        
        // Get customer details
        $customer = ORM::for_table('tbl_customers')->find_one($request['customer_id']);
        
        // Get plan details
        $plan = ORM::for_table('tbl_plans')->find_one($request['plan_id']);
        
        $ui->assign('request', $request->as_array());
        $ui->assign('customer', $customer->as_array());
        $ui->assign('plan', $plan->as_array());
        
        $ui->display('admin/recharge_requests/view.tpl');
        break;
        
    case 'approve':
        $id = $routes['2'];
        $request = ORM::for_table('tbl_recharge_requests')->find_one($id);
        
        if (!$request) {
            r2(getUrl('recharge_requests/list'), 'e', Lang::T('Request not found'));
        }
        
        // Process the recharge
        $customer = ORM::for_table('tbl_customers')->find_one($request['customer_id']);
        $plan = ORM::for_table('tbl_plans')->find_one($request['plan_id']);

        if (!$customer || !$plan) {
            r2(getUrl('recharge_requests/view/' . $id), 'e', Lang::T('Customer or plan not found'));
        }

        // When bill_id = 0 it's a new plan request; use plan's router. Otherwise use existing bill's router.
        $bill = ($request['bill_id'] > 0) ? ORM::for_table('tbl_user_recharges')->find_one($request['bill_id']) : null;
        $router_name = ($bill && !empty($bill['routers'])) ? $bill['routers'] : $plan['routers'];

        if (Package::rechargeUser($customer['id'], $router_name, $plan['id'], 'Admin', 'Recharge Request')) {
            // Fetch the transaction just created by rechargeUser (same as admin manual recharge flow)
            $in = ORM::for_table('tbl_transactions')
                ->where('username', $customer['username'])
                ->order_by_desc('id')
                ->find_one();

            // Generate invoice PDF/record (same as admin manual recharge)
            if ($in) {
                Package::createInvoice($in);
            }

            $request->status = 'completed';
            $request->admin_id = $admin['id'];
            $request->admin_response = 'Recharged successfully by admin';
            $request->processed_date = date('Y-m-d H:i:s');
            $request->save();

            // Send invoice notification to customer
            Message::sendInvoice($customer, $in ?: null);
            Message::sendTelegram(
                "#u" . $customer['username'] . " (#id" . $customer['id'] . ") #recharge #approved\n" .
                "Plan: " . $plan['name_plan'] . "\n" .
                "Price: " . Lang::moneyFormat($plan['price']) . "\n" .
                "Admin: " . $admin['username']
            );

            _log('[' . $admin['username'] . ']: Recharge ' . $customer['username'] . ' [' . $plan['name_plan'] . '][' . Lang::moneyFormat($plan['price']) . ']', $admin['user_type'], $admin['id']);

            r2(getUrl('recharge_requests/list'), 's', Lang::T('Recharge request approved and processed'));
        } else {
            r2(getUrl('recharge_requests/view/' . $id), 'e', Lang::T('Failed to process recharge'));
        }
        break;
        
    case 'reject':
        $id = $routes['2'];
        $reason = _post('reason', _get('reason', ''));
        
        $request = ORM::for_table('tbl_recharge_requests')->find_one($id);
        
        if (!$request) {
            r2(getUrl('recharge_requests/list'), 'e', Lang::T('Request not found'));
        }
        
        $request->status = 'rejected';
        $request->admin_id = $admin['id'];
        $request->admin_response = $reason;
        $request->processed_date = date('Y-m-d H:i:s');
        $request->save();
        
        // Send notification to customer
        $customer = ORM::for_table('tbl_customers')->find_one($request['customer_id']);
        Message::sendTelegram("#u" . $customer['username'] . " (#id" . $customer['id'] . ") #recharge #rejected\n" .
            "Reason: " . $reason);
        
        _log('Admin ' . $admin['username'] . ' rejected recharge request #' . $id . ' for customer ' . $customer['username'], 'Admin', $admin['id']);
        
        r2(getUrl('recharge_requests/list'), 's', Lang::T('Recharge request rejected'));
        break;
        
    case 'history':
        // View processed recharge requests
        $query = ORM::for_table('tbl_recharge_requests')
            ->where_in('status', ['completed', 'rejected', 'approved'])
            ->order_by_desc('processed_date');
        
        $requests = Paginator::findMany($query);
        
        $ui->assign('requests', $requests);
        $ui->display('admin/recharge_requests/history.tpl');
        break;
}
