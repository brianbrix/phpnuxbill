-- Migration: Add Test Account Exclusion Feature
-- Date: 2026-03-02
-- Description: Adds flag to exclude test/demo accounts from dashboard statistics and calculations

-- Add exclude_from_stats column to tbl_customers
ALTER TABLE `tbl_customers` 
ADD COLUMN `exclude_from_stats` TINYINT(1) NOT NULL DEFAULT 0 
AFTER `auto_renewal`;

-- Create index for better performance on statistics queries
CREATE INDEX `idx_exclude_from_stats` ON `tbl_customers` (`exclude_from_stats`);

-- Add comment to the column for clarity
ALTER TABLE `tbl_customers` 
MODIFY COLUMN `exclude_from_stats` TINYINT(1) NOT NULL DEFAULT 0 
COMMENT 'Exclude this user from dashboard statistics and calculations (test accounts)';
