-- Migration: Add Recharge Request System
-- This migration creates tables for recharge requests and admin notifications

-- Table: tbl_recharge_requests
-- Purpose: Store customer requests for plan recharges
CREATE TABLE IF NOT EXISTS `tbl_recharge_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `username` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `bill_id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  `plan_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `status` enum('pending','approved','rejected','completed') COLLATE utf8_unicode_ci DEFAULT 'pending',
  `admin_response` text COLLATE utf8_unicode_ci,
  `requested_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `processed_date` datetime NULL,
  `admin_id` int(11) NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `status` (`status`),
  KEY `requested_date` (`requested_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Table: tbl_admin_notifications  
-- Purpose: Store notifications for admins about various system events
CREATE TABLE IF NOT EXISTS `tbl_admin_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `type` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `related_id` int(11),
  `status` enum('unread','read') COLLATE utf8_unicode_ci DEFAULT 'unread',
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `read_date` datetime NULL,
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  KEY `status` (`status`),
  KEY `created_date` (`created_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Alter tbl_user_recharges to add is_archived column if it doesn't exist
ALTER TABLE `tbl_user_recharges` ADD COLUMN `is_archived` tinyint(1) DEFAULT 0 AFTER `status`;

-- Create index for archived plans lookup
CREATE INDEX `is_archived` ON `tbl_user_recharges` (`is_archived`, `customer_id`);
