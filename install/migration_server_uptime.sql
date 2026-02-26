-- Migration: Server Uptime and Plan Extension on Recovery
-- Purpose: Track server offline periods and automatically extend customer plans when server comes back online

-- Table: tbl_offline_periods
-- Tracks when FreeRADIUS/server goes offline and comes back online
CREATE TABLE IF NOT EXISTS `tbl_offline_periods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `went_offline` datetime NOT NULL,
  `came_online` datetime NULL,
  `duration_minutes` int(11) DEFAULT 0,
  `affected_customers` int(11) DEFAULT 0,
  `plans_extended` int(11) DEFAULT 0,
  `extended` tinyint(1) DEFAULT 0,
  `extension_date` datetime NULL,
  `notes` text,
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `went_offline` (`went_offline`),
  KEY `extended` (`extended`),
  KEY `came_online` (`came_online`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Table: tbl_server_health
-- Tracks server health status for monitoring
CREATE TABLE IF NOT EXISTS `tbl_server_health` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `server_name` varchar(255) NOT NULL DEFAULT 'FreeRADIUS',
  `is_online` tinyint(1) DEFAULT 1,
  `last_check` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_online` datetime DEFAULT CURRENT_TIMESTAMP,
  `check_failures` int(11) DEFAULT 0,
  `consecutive_failures` int(11) DEFAULT 0,
  `response_time_ms` int(11),
  PRIMARY KEY (`id`),
  UNIQUE KEY `server_name` (`server_name`),
  KEY `is_online` (`is_online`),
  KEY `last_check` (`last_check`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Initialize server health entry
INSERT IGNORE INTO `tbl_server_health` (`server_name`, `is_online`, `last_check`, `last_online`)
VALUES ('FreeRADIUS', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Table: tbl_customer_offline_extensions
-- Tracks which customers have been extended for which offline periods (prevents duplicate extensions)
CREATE TABLE IF NOT EXISTS `tbl_customer_offline_extensions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `offline_period_id` int(11) NOT NULL,
  `recharge_id` int(11) NOT NULL,
  `extension_minutes` int(11) NOT NULL,
  `old_expiration` datetime NOT NULL,
  `new_expiration` datetime NOT NULL,
  `extended_by` enum('auto','manual') DEFAULT 'auto',
  `admin_id` int(11) DEFAULT NULL,
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_offline_unique` (`customer_id`, `offline_period_id`, `recharge_id`),
  KEY `customer_id` (`customer_id`),
  KEY `offline_period_id` (`offline_period_id`),
  KEY `recharge_id` (`recharge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Configuration: Auto-extension settings (stored in tbl_appconfig)
INSERT INTO `tbl_appconfig` (`setting`, `value`) VALUES 
('auto_extend_on_recovery', 'yes'),
('max_offline_extension_days', '7')
ON DUPLICATE KEY UPDATE `setting`=`setting`;

-- Create index for efficient plan extension lookups
CREATE INDEX `customer_offline_ext` ON `tbl_customer_offline_extensions` (`customer_id`, `offline_period_id`);
