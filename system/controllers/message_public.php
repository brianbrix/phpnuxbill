<?php

/**
 * Public message form for hotspot users (no login required)
 * Also allows logged-in users to send messages
 */

$ui->assign('_title', 'Send Message');

$action = $routes['1'];
$mac = _get('nux-mac');
$ip = _get('nux-ip');

// Check if user is logged in
$logged_in_user = User::_info();
$is_authenticated = !empty($logged_in_user['id']);

switch ($action) {
    case 'send':
        // Show the message form
        $ui->assign('mac', htmlspecialchars($mac));
        $ui->assign('ip', htmlspecialchars($ip));
        $ui->assign('is_authenticated', $is_authenticated);
        if ($is_authenticated) {
            $ui->assign('logged_in_user', $logged_in_user);
        }
        $ui->display('message_public.tpl');
        break;

    case 'submit':
        // Process the message submission
        if ($_app_stage == 'Demo') {
            r2(getUrl('message_public/send') . '?nux-mac=' . urlencode($mac) . '&nux-ip=' . urlencode($ip), 'e', 'Demo mode - message not sent');
        }

        $sender_name = trim(_post('sender_name', ''));
        $sender_contact = trim(_post('sender_contact', ''));
        $message_text = _post('message', '');

        if (empty($message_text) || strlen(trim($message_text)) < 10) {
            r2(getUrl('message_public/send') . '?nux-mac=' . urlencode($mac) . '&nux-ip=' . urlencode($ip), 'e', Lang::T('Message must be at least 10 characters'));
        }

        // Use authenticated user details if logged in
        if ($is_authenticated) {
            $sender_name = $logged_in_user['fullname'] ?: $logged_in_user['username'];
            $sender_contact = $logged_in_user['email'] ?: 'Not provided';
            $title = "Message from " . $logged_in_user['username'];
            $message_type = 'user_message';
            $user_type = "Authenticated User";
        } else {
            $sender_name = $sender_name ?: 'Anonymous';
            $sender_contact = $sender_contact ?: 'Not provided';
            $title = "Guest Message from " . $sender_name;
            $message_type = 'guest_message';
            $user_type = "Guest";
        }

        // Build message content
        $msg_content = "**" . $user_type . " Message from Hotspot**\n\n" .
            "Name: " . $sender_name . "\n" .
            "Contact: " . $sender_contact . "\n" .
            "MAC: " . $mac . "\n" .
            "IP: " . $ip . "\n";
        
        if ($is_authenticated) {
            $msg_content .= "Username: " . $logged_in_user['username'] . "\n";
        }
        
        $msg_content .= "\nMessage:\n" . $message_text;

        // Save to database
        $notif = ORM::for_table('tbl_admin_notifications')->create();
        $notif->admin_id = 0;
        $notif->title = $title;
        $notif->message = $msg_content;
        $notif->type = $message_type;
        $notif->status = 'unread';
        $notif->created_date = date('Y-m-d H:i:s');
        $notif->save();

        // Build Telegram message
        $telegram_msg = ($is_authenticated ? "👤 *Authenticated User Message*" : "📩 *Guest Message from Hotspot*") . "\n\n" .
            "Name: " . $sender_name . "\n" .
            "Contact: " . $sender_contact . "\n" .
            "MAC: `" . $mac . "`\n" .
            "IP: `" . $ip . "`\n";
        
        if ($is_authenticated) {
            $telegram_msg .= "Username: `" . $logged_in_user['username'] . "`\n";
        }
        
        $telegram_msg .= "\nMessage:\n_" . substr($message_text, 0, 300) . "_";

        // Send Telegram notification to admins
        Message::sendTelegram($telegram_msg);

        // Log the action
        $log_user = $is_authenticated ? $logged_in_user['username'] : 'Guest';
        $log_id = $is_authenticated ? $logged_in_user['id'] : 0;
        _log('[' . $log_user . ']: Message sent from MAC: ' . $mac . ', IP: ' . $ip, 'Message', $log_id);

        // Display success page directly
        $ui->assign('success', true);
        $ui->assign('is_authenticated', $is_authenticated);
        $ui->display('message_public_success.tpl');
        break;

    case 'success':
        // Show success message and redirect back
        $ui->assign('success', true);
        $ui->display('message_public_success.tpl');
        break;

    default:
        r2(getUrl('message_public/send'));
        break;
}
