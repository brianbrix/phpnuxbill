<?php

/**
 * Server Health Check Cron
 * Monitors FreeRADIUS server status and tracks offline periods
 * Run every 5-10 minutes via cron
 */

// Enable error logging for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Write to stderr immediately for debugging
fwrite(STDERR, "[DEBUG] Cron starting at " . date('Y-m-d H:i:s') . "\n");

// Load system bootstrap
require_once dirname(__FILE__) . '/../init.php';

fwrite(STDERR, "[DEBUG] Bootstrap loaded successfully\n");

// Get server configuration from tbl_routers (NAS/routers table)
$router = ORM::for_table('tbl_routers')
    ->where('enabled', 1)
    ->order_by_desc('last_seen')
    ->find_one();

if ($router) {
    // Extract IP from ip_address (may include port like "10.200.200.2:8729")
    $ip_address = $router['ip_address'];
    $router_status = $router['status'] ?? 'Unknown';
    if (strpos($ip_address, ':') !== false) {
        list($radius_server, $radius_port) = explode(':', $ip_address);
        $radius_port = (int)$radius_port;
    } else {
        $radius_server = $ip_address;
        $radius_port = 1812; // Default RADIUS port
    }
    fwrite(STDERR, "[DEBUG] Using router: {$router['name']} -> $radius_server:$radius_port (status: $router_status) (from tbl_routers)\n");
} else {
    $radius_server = 'localhost';
    $radius_port = 1812;
    fwrite(STDERR, "[DEBUG] No enabled router found, using default: $radius_server:$radius_port\n");
}

$health_table = 'tbl_server_health';
$offline_table = 'tbl_offline_periods';

// Helper function to log with timestamp
function logWithTimestamp($message, $type = 'Server', $userid = 0) {
    $timestamp = date('Y-m-d H:i:s');
    _log("[$timestamp] $message", $type, $userid);
}

// Get current health status
$health = ORM::for_table($health_table)
    ->where('server_name', 'FreeRADIUS')
    ->find_one();

if (!$health) {
    $health = ORM::for_table($health_table)->create();
    $health->server_name = 'FreeRADIUS';
    $health->is_online = 1;
    $health->last_check = date('Y-m-d H:i:s');
    $health->last_online = date('Y-m-d H:i:s');
    $health->save();
}

// Check server connectivity
$server_is_online = checkRadiusServer($radius_server, $radius_port, $response_time);

$current_status = $health['is_online'];
$status_changed = ($current_status != $server_is_online);

if ($server_is_online) {
    // Server is online
    if ($status_changed) {
        // Server came back online - was offline, now online
        logWithTimestamp('FreeRADIUS Server came back online', 'Server', 0);
        
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
                logWithTimestamp('Server recovered but auto-extension is disabled. Manual extension required.', 'Server', 0);
            }
        }
        
        // Update health status
        $health->is_online = 1;
        $health->last_online = date('Y-m-d H:i:s');
        $health->consecutive_failures = 0;
        $health->save();
        
    } else {
        // Still online, reset failure counter
        $health->consecutive_failures = 0;
        $health->response_time_ms = $response_time;
        $health->save();
        
        // Log successful check with timestamp
        logWithTimestamp("FreeRADIUS Server health check passed (response time: {$response_time}ms)", 'Server', 0);
    }
    
} else {
    // Server is offline (check failed)
    $health->consecutive_failures = ($health['consecutive_failures'] ?? 0) + 1;
    $health->check_failures = ($health['check_failures'] ?? 0) + 1;
    
    // Only mark as offline after 3 consecutive failures (15 minutes with 5-min checks)
    $offline_threshold = 3;
    if ($health->consecutive_failures >= $offline_threshold && $current_status != 0) {
        // Just went offline after threshold reached
        logWithTimestamp('FreeRADIUS Server went offline after ' . $health->consecutive_failures . ' failed checks', 'Server', 0);
        
        // Create new offline period record
        $offline = ORM::for_table($offline_table)->create();
        $offline->went_offline = date('Y-m-d H:i:s');
        $offline->save();
        
        // Send Telegram alert about outage
        Message::sendTelegram(
            "⚠️ *FreeRADIUS Server Down*\n\n" .
            "Server: " . $radius_server . ":" . $radius_port . "\n" .
            "Time: " . date('Y-m-d H:i:s') . "\n\n" .
            "Monitoring active. Plans will be extended when server recovers."
        );
        
        $health->is_online = 0;
    }
    
    $health->save();
}

$health->last_check = date('Y-m-d H:i:s');
$health->save();

/**
 * Check if FreeRADIUS server is reachable
 * @return bool server is online
 */
function checkRadiusServer($host, $port, &$response_time) {
    $start = microtime(true);
    
    // Try multiple check methods
    
    // Method 1: Ping the host (most reliable for basic connectivity)
    $ping_cmd = PHP_OS_FAMILY === 'Windows' 
        ? "ping -n 1 -w 3000 " . escapeshellarg($host) 
        : "ping -c 1 -W 3 " . escapeshellarg($host) . " 2>/dev/null";
    
    $output = shell_exec($ping_cmd);
    if ($output !== null && (strpos($output, 'received') !== false || strpos($output, 'Received') !== false || strpos($output, 'bytes from') !== false || strpos($output, 'ttl') !== false)) {
        $response_time = round((microtime(true) - $start) * 1000);
        return true;
    }
    
    // Method 2: Try socket connection to RADIUS port
    if (function_exists('fsockopen')) {
        $connection = @fsockopen($host, $port, $errno, $errstr, 3);
        if ($connection) {
            fclose($connection);
            $response_time = round((microtime(true) - $start) * 1000);
            return true;
        }
    }
    
    // Method 3: Check via database - recent radius accounting entries
    global $_c;
    try {
        // Attempt to query radacct table via ORM (tests DB connectivity to radius data)
        $recent = ORM::for_table('radacct')
            ->where_gte('acctstarttime', date('Y-m-d H:i:s', strtotime('-5 minutes')))
            ->count();
        
        if ($recent > 0) {
            $response_time = round((microtime(true) - $start) * 1000);
            return true; // Server is active if we're getting recent records
        }
    } catch (Exception $e) {
        // Database check failed
    }
    
    $response_time = round((microtime(true) - $start) * 1000);
    return false;
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
            'Plan extended by ' . $duration_minutes . ' minutes due to server downtime (Auto)',
            'SystemExtension',
            $plan['customer_id']
        );
        
        // Send inbox notification to customer
        Message::addToInbox(
            $plan['customer_id'],
            'Plan Extended - Server Downtime',
            'Your plan "' . $plan['plan_name'] . '" has been automatically extended by ' . $duration_minutes . ' minutes due to server downtime.' .
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
            "✅ *Server Recovery - Plans Extended*\n\n" .
            "Customers Extended: " . $extended_count . "\n" .
            ($skipped_count > 0 ? "Skipped (Already Extended): " . $skipped_count . "\n" : "") .
            "Extension Duration: " . $duration_minutes . " minutes\n" .
            "Extended At: " . date('Y-m-d H:i:s')
        );
    }
}

fwrite(STDERR, "[DEBUG] Cron completed successfully at " . date('Y-m-d H:i:s') . "\n");
