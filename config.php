<?php

// Prefer X-Forwarded-Proto when behind a reverse proxy (e.g. Traefik, nginx) to avoid mixed content over HTTPS
$protocol = 'http://';
if (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && strtolower($_SERVER['HTTP_X_FORWARDED_PROTO']) === 'https') {
    $protocol = 'https://';
} elseif (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' ||
          (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] == 443)) {
    $protocol = 'https://';
}

// Check if HTTP_HOST is set, otherwise use a default value or SERVER_NAME
$host = isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : (isset($_SERVER['SERVER_NAME']) ? $_SERVER['SERVER_NAME'] : 'localhost');

$baseDir = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/\\');
$appUrl = $protocol . $host . $baseDir;

// Allow BASE_URL env (e.g. from Docker) to override the full app URL for correct HTTPS asset links
if (getenv('BASE_URL') !== false) {
    $appUrl = rtrim(getenv('BASE_URL'), '/') . $baseDir;
}
define('APP_URL', $appUrl);


$_app_stage = 'Live'; # Do not change this

$db_host    = "db"; # Database Host
$db_port    = "3306";   # Database Port. Keep it blank if you are un sure.
$db_user    = "nuxbill"; # Database Username
$db_pass    = "myrootpassword"; # Database Password
$db_name    = "nuxbill"; # Database Name

// Radius Database (used when RADIUS features are enabled)
// Adjust these if your RADIUS DB runs on a different host/user/db
$radius_host = "db";
$radius_user = "root";
$radius_pass = "myrootpassword";
$radius_name = "radius";

$config['site_url'] = 'https://hotspot.afyaquik.com/';

// Default application timezone (can still be overridden from settings)
// Set this to your primary timezone, e.g. 'Africa/Nairobi'
if (empty($config['timezone'])) {
    $config['timezone'] = getenv('APP_TIMEZONE') ?: 'Africa/Nairobi';
}

//error reporting
if($_app_stage!='Live'){
    error_reporting(E_ERROR);
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
}else{
    error_reporting(E_ERROR);
    ini_set('display_errors', 0);
    ini_set('display_startup_errors', 0);
}
