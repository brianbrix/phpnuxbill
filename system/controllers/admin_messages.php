<?php

/**
 * Admin Messages Controller
 * View guest messages from hotspot and other system notifications
 */

_admin();
$ui->assign('_title', Lang::T('Admin Messages'));
$ui->assign('_system_menu', 'admin_messages');

$action = $routes['1'];
$admin = Admin::_info();
$ui->assign('_admin', $admin);

switch ($action) {
    case 'list':
    default:
        // Get filter from query string
        $filter = _get('filter', 'unread');
        $ui->assign('filter', $filter);
        
        // Build query
        $query = ORM::for_table('tbl_admin_notifications');
        
        if ($filter == 'unread') {
            $query->where('status', 'unread');
        }
        // else show all
        
        $query->order_by_desc('created_date');
        
        $messages = Paginator::findMany($query);
        
        // Count unread messages
        $unread_count = ORM::for_table('tbl_admin_notifications')
            ->where('status', 'unread')
            ->count();
        
        $ui->assign('messages', $messages);
        $ui->assign('unread_count', $unread_count);
        $ui->display('admin/admin_messages/list.tpl');
        break;
        
    case 'view':
        $id = $routes['2'];
        $message = ORM::for_table('tbl_admin_notifications')->find_one($id);
        
        if (!$message) {
            r2(getUrl('admin_messages/list'), 'e', Lang::T('Message not found'));
        }
        
        // Mark as read if unread
        if ($message['status'] == 'unread') {
            $message->status = 'read';
            $message->read_date = date('Y-m-d H:i:s');
            $message->save();
        }
        
        $ui->assign('message', $message->as_array());
        $ui->display('admin/admin_messages/view.tpl');
        break;
        
    case 'mark_read':
        $id = $routes['2'];
        $message = ORM::for_table('tbl_admin_notifications')->find_one($id);
        
        if ($message) {
            $message->status = 'read';
            $message->read_date = date('Y-m-d H:i:s');
            $message->save();
        }
        
        r2(getUrl('admin_messages/list'), 's', Lang::T('Message marked as read'));
        break;
        
    case 'mark_all_read':
        ORM::for_table('tbl_admin_notifications')
            ->where('status', 'unread')
            ->find_result_set()
            ->set('status', 'read')
            ->set('read_date', date('Y-m-d H:i:s'))
            ->save();
        
        r2(getUrl('admin_messages/list'), 's', Lang::T('All messages marked as read'));
        break;
        
    case 'delete':
        $id = $routes['2'];
        $message = ORM::for_table('tbl_admin_notifications')->find_one($id);
        
        if ($message) {
            $message->delete();
            r2(getUrl('admin_messages/list'), 's', Lang::T('Message deleted'));
        } else {
            r2(getUrl('admin_messages/list'), 'e', Lang::T('Message not found'));
        }
        break;
    
    case 'check_new':
        // AJAX endpoint to check for new admin messages
        header('Content-Type: application/json');
        
        // Get the last check timestamp from session or parameter
        $last_check = isset($_SESSION['last_message_check']) ? $_SESSION['last_message_check'] : _post('last_check', date('Y-m-d H:i:s', strtotime('-1 hour')));
        
        // Get count of new messages since last check
        $new_count = ORM::for_table('tbl_admin_notifications')
            ->where('status', 'unread')
            ->where_gte('created_date', $last_check)
            ->count();
        
        // Get total unread messages
        $total_unread = ORM::for_table('tbl_admin_notifications')
            ->where('status', 'unread')
            ->count();
        
        // Get latest message details if there's a new one
        $latest_message = null;
        if ($new_count > 0) {
            $message = ORM::for_table('tbl_admin_notifications')
                ->where('status', 'unread')
                ->where_gte('created_date', $last_check)
                ->order_by_desc('created_date')
                ->find_one();
            
            if ($message) {
                $latest_message = [
                    'id' => $message['id'],
                    'type' => $message['type'],
                    'title' => $message['title'],
                    'created_date' => $message['created_date']
                ];
            }
        }
        
        // Update last check timestamp in session
        $_SESSION['last_message_check'] = date('Y-m-d H:i:s');
        
        echo json_encode([
            'status' => 'success',
            'new_count' => $new_count,
            'total_unread' => $total_unread,
            'latest_message' => $latest_message,
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        die();
}
