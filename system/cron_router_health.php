<?php

/**
 * Router Status Monitor Cron
 * Monitors router status from tbl_routers table and tracks offline periods
 * Run every 5 minutes via cron
 */

// Load system bootstrap
require_once dirname(__FILE__) . '/../init.php';

$health_table = 'tbl_server_health';
$offline_table = 'tbl_offline_periods';

// Get current health status record
$health = ORM::for_table($health_table)
    ->where('server_name', 'Router')
    ->find_one();

if (!$health) {
    $health = ORM::for_table($health_table)->create();
    $health->server_name = 'Router';
    $health->is_online = 1;
    $health->last_check = date('Y-m-d H:i:s');
    $health->last_online = date('Y-m-d H:i:s');
    $health->save();
}

// Check router status from database
$router_is_online = checkRouterStatus();

$current_status = $health['is_online'];
$status_changed = ($current_status != $router_is_online);

if ($router_is_online) {
    // Router is online
    if ($status_changed) {
        // Router came back online - was offline, now online
        _log('Router came back online', 'Router', 0);
        
        // Record the offline period
        $offline_record = ORM::for_table($offline_table)
            ->where_null('came_online')
            ->order_by_desc('went_offline')
            ->find_one();
        
        if ($offline_record) {
            $went_offline = strtotime($offline_record['went_offline']);
            $came_online = time();
            $duration_minutes = ceil(($came_online - $went_offline) / 60);
            
            $offline_record->came_online = date('Y-m-d H:i:s');
            $offline_record->duration_minutes = $duration_minutes;
            $offline_record->save();
            
            // Check if auto-extension is enabled
            $auto_extend_enabled = $config['auto_extend_on_recovery'] ?? 'yes';
            
            if ($auto_extend_enabled === 'yes') {
                // Queue plan extensions
                extendPlansForOfflineperiod($offline_record['id'], $duration_minutes);
            } else {
                _log('Router recovered but auto-extension is disabled. Manual extension required.', 'Router', 0);
            }
        }
        
        // Update health status
        $health->is_online = 1;
        $health->last_online = date('Y-m-d H:i:s');
        $health->consecutive_failures = 0;
        $health->save();
        
        // Send Telegram alert
        $router_info = getRouterInfo();
        Message::sendTelegram(
            "✅ *Router Back Online*\n\n" .
            "Router: " . $router_info['name'] . "\n" .
            "IP: " . $router_info['ip'] . "\n" .
            "Time: " . date('Y-m-d H:i:s')
        );
        
    } else {
        // Still online, reset failure counter
        $health->consecutive_failures = 0;
        $health->save();
    }
    
} else {
    // Router is offline (check failed)
    $health->consecutive_failures = ($health['consecutive_failures'] ?? 0) + 1;
    $health->check_failures = ($health['check_failures'] ?? 0) + 1;
    
    // Only mark as offline after 3 consecutive failures (15 minutes with 5-min checks)
    $offline_threshold = 3;
    if ($health->consecutive_failures >= $offline_threshold && $current_status != 0) {
        // Just went offline after threshold reached
        _log('Router went offline after ' . $health->consecutive_failures . ' failed checks', 'Router', 0);
        
        // Create new offline period record
        $offline = ORM::for_table($offline_table)->create();
        $offline->went_offline = date('Y-m-d H:i:s');
        $offline->save();
        
        // Send Telegram alert about outage
        $router_info = getRouterInfo();
        Message::sendTelegram(
            "⚠️ *Router Down*\n\n" .
            "Router: " . $router_info['name'] . "\n" .
            "IP: " . $router_info['ip'] . "\n" .
            "Time: " . date('Y-m-d H:i:s') . "\n\n" .
            "Monitoring active. Plans will be extended when router recovers."
        );
        
        $health->is_online = 0;
    }
    
    $health->save();
}

$health->last_check = date('Y-m-d H:i:s');
$health->save();

/**
 * Check router status from tbl_routers table
 * @return bool router is online
 */
function checkRouterStatus() {
    // Get enabled routers from database
    $routers = ORM::for_table('tbl_routers')
        ->where('enabled', 1)
        ->find_many();
    
    if (count($routers) == 0) {
        // No routers configured, assume offline
        return false;
    }
    
    // Check if any enabled router is online
    foreach ($routers as $router) {
        if ($router['status'] == 'Online') {
            return true; // At least one router is online
        }
    }
    
    // All routers are offline
    return false;
}

/**
 * Get router information for notifications
 */
function getRouterInfo() {
    $router = ORM::for_table('tbl_routers')
        ->where('enabled', 1)
        ->find_one();
    
    if ($router) {
        return [
            'name' => $router['name'],
            'ip' => $router['ip_address'],
            'status' => $router['status']
        ];
    }
    
    return [
        'name' => 'Unknown',
        'ip' => 'Unknown',
        'status' => 'Unknown'
    ];
}

/**
 * Extend all active customer plans by the offline duration
 */
function extendPlansForOfflineperiod($offline_id, $duration_minutes) {
    global $_c;
    
    // Get all active plans that are currently valid
    $plans = ORM::for_table('tbl_user_recharges')
        ->where('status', 'on')
        ->where_gt('expiration', date('Y-m-d'))
        ->find_many();
    
    $extended_count = 0;
    $skipped_count = 0;
    
    foreach ($plans as $plan) {
        // Check if this customer was already extended for this offline period
        $already_extended = ORM::for_table('tbl_customer_offline_extensions')
            ->where('customer_id', $plan['customer_id'])
            ->where('offline_period_id', $offline_id)
            ->where('recharge_id', $plan['id'])
            ->find_one();
        
        if ($already_extended) {
            $skipped_count++;
            continue; // Skip if already extended
        }
        
        // Extend expiration by offline duration
        $old_expiration_full = $plan['expiration'] . ' ' . $plan['time'];
        $old_expiration = $old_expiration_full;
        $new_expiration_datetime = strtotime($old_expiration_full) + ($duration_minutes * 60);
        $new_expiration_date = date('Y-m-d', $new_expiration_datetime);
        $new_expiration_time = date('H:i:s', $new_expiration_datetime);
        $new_expiration = $new_expiration_date . ' ' . $new_expiration_time;
        
        $plan->expiration = $new_expiration_date;
        $plan->time = $new_expiration_time;
        $plan->save();
        
        // Record extension in tracking table
        $ext_record = ORM::for_table('tbl_customer_offline_extensions')->create();
        $ext_record->customer_id = $plan['customer_id'];
        $ext_record->offline_period_id = $offline_id;
        $ext_record->recharge_id = $plan['id'];
        $ext_record->extension_minutes = $duration_minutes;
        $ext_record->old_expiration = $old_expiration;
        $ext_record->new_expiration = $new_expiration;
        $ext_record->extended_by = 'auto';
        $ext_record->admin_id = NULL;
        $ext_record->save();
        
        $extended_count++;
        
        // Log extension
        _log(
            'Plan extended by ' . $duration_minutes . ' minutes due to router downtime (Auto)',
            'RouterExtension',
            $plan['customer_id']
        );
        
        // Send inbox notification to customer
        Message::addToInbox(
            $plan['customer_id'],
            'Plan Extended - Router Downtime',
            'Your plan "' . $plan['plan_name'] . '" has been automatically extended by ' . $duration_minutes . ' minutes due to router downtime.' .
            "\n\nOld expiration: " . $old_expiration .
            "\nNew expiration: " . $new_expiration .
            "\n\nWe apologize for the inconvenience."
        );
    }
    
    // Update offline period with extension info
    $offline = ORM::for_table('tbl_offline_periods')->find_one($offline_id);
    if ($offline) {
        $offline->plans_extended = $extended_count;
        $offline->affected_customers = $extended_count;
        $offline->extended = 1;
        $offline->extension_date = date('Y-m-d H:i:s');
        if ($skipped_count > 0) {
            $offline->notes = $skipped_count . ' customers skipped (already extended)';
        }
        $offline->save();
    }
    
    // Send Telegram notification about extensions
    if ($extended_count > 0) {
        Message::sendTelegram(
            "✅ *Router Recovery - Plans Extended*\n\n" .
            "Customers Extended: " . $extended_count . "\n" .
            ($skipped_count > 0 ? "Skipped (Already Extended): " . $skipped_count . "\n" : "") .
            "Extension Duration: " . $duration_minutes . " minutes\n" .
            "Extended At: " . date('Y-m-d H:i:s')
        );
    }
}
