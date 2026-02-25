<?php

/**
 * Recharge Requests Management Controller
 * Admin interface for viewing and processing customer recharge requests
 */

_admin();
$ui->assign('_title', Lang::T('Recharge Requests'));
$ui->assign('_system_menu', 'recharge_requests');

$action = $routes['1'];
$admin = Admin::info();
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
        $bill = ORM::for_table('tbl_user_recharges')->find_one($request['bill_id']);
        $plan = ORM::for_table('tbl_plans')->find_one($request['plan_id']);
        
        if (Package::rechargeUser($customer['id'], $bill['routers'], $plan['id'], 'Admin', 'Recharge Request')) {
            $request->status = 'completed';
            $request->admin_id = $admin['id'];
            $request->admin_response = 'Recharged successfully by admin';
            $request->processed_date = date('Y-m-d H:i:s');
            $request->save();
            
            // Send notification to customer
            Message::sendInvoice($customer, null);
            Message::sendTelegram("#u" . $customer['username'] . " (#id" . $customer['id'] . ") #recharge #auto\n" .
                "Plan: " . $plan['name_plan'] . "\n" .
                "Price: " . Lang::moneyFormat($plan['price']) . "\n" .
                "Admin: " . $admin['username']);
            
            _log('Admin ' . $admin['username'] . ' approved recharge request #' . $id . ' for customer ' . $customer['username'], 'Admin', $admin['id']);
            
            r2(getUrl('recharge_requests/list'), 's', Lang::T('Recharge request approved and processed'));
        } else {
            r2(getUrl('recharge_requests/view/' . $id), 'e', Lang::T('Failed to process recharge'));
        }
        break;
        
    case 'reject':
        $id = $routes['2'];
        $reason = _post('reason', '');
        
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
