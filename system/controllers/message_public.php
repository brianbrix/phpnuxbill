<?php

/**
 * Public message form for hotspot users (no login required)
 */

$ui->assign('_title', 'Send Message');

$action = $routes['1'];
$mac = _get('nux-mac');
$ip = _get('nux-ip');

switch ($action) {
    case 'send':
        // Show the message form
        $ui->assign('mac', htmlspecialchars($mac));
        $ui->assign('ip', htmlspecialchars($ip));
        $ui->display('message_public.tpl');
        break;

    case 'submit':
        // Process the message submission
        if ($_app_stage == 'Demo') {
            r2(getUrl('message_public/send') . '?nux-mac=' . urlencode($mac) . '&nux-ip=' . urlencode($ip), 'e', 'Demo mode - message not sent');
        }

        $sender_name = _post('sender_name');
        $sender_contact = _post('sender_contact');
        $message_text = _post('message');

        if (empty($message_text) || strlen(trim($message_text)) < 10) {
            r2(getUrl('message_public/send') . '?nux-mac=' . urlencode($mac) . '&nux-ip=' . urlencode($ip), 'e', Lang::T('Message must be at least 10 characters'));
        }

        // Save to database
        $notif = ORM::for_table('tbl_admin_notifications')->create();
        $notif->admin_id = 0; // No specific admin - all see it
        $notif->title = "Guest Message from " . ($sender_name ?: 'Hotspot User');
        $notif->message = "**Guest Message from Hotspot**\n\n" .
            "Name: " . ($sender_name ?: 'Anonymous') . "\n" .
            "Contact: " . ($sender_contact ?: 'Not provided') . "\n" .
            "MAC: " . $mac . "\n" .
            "IP: " . $ip . "\n\n" .
            "Message:\n" . $message_text;
        $notif->type = 'guest_message';
        $notif->status = 'unread';
        $notif->created_date = date('Y-m-d H:i:s');
        $notif->save();

        // Send Telegram notification to admins
        Message::sendTelegram(
            "📩 *Guest Message from Hotspot*\n\n" .
            "👤 Name: " . ($sender_name ?: 'Anonymous') . "\n" .
            "📱 Contact: " . ($sender_contact ?: 'Not provided') . "\n" .
            "🌐 MAC: `" . $mac . "`\n" .
            "🖥 IP: `" . $ip . "`\n\n" .
            "💬 Message:\n_" . substr($message_text, 0, 300) . "_"
        );

        _log('[Guest]: Message sent from MAC: ' . $mac . ', IP: ' . $ip, 'Guest', 0);

        r2(getUrl('message_public/send') . '?nux-mac=' . urlencode($mac) . '&nux-ip=' . urlencode($ip), 's', Lang::T('Message sent successfully! An admin will contact you soon.'));
        break;

    default:
        r2(getUrl('message_public/send'));
        break;
}
