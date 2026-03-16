-- Add created_at field to tbl_transactions to track when the transaction was actually created
-- This is different from recharged_on/recharged_time which now track when the plan starts

ALTER TABLE `tbl_transactions` 
ADD COLUMN `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `admin_id`;

-- Create index for performance
CREATE INDEX `idx_created_at` ON `tbl_transactions` (`created_at`);

-- Update existing records to have created_at match their recharged_on/time for backward compatibility
-- This ensures existing records show correct creation dates
UPDATE `tbl_transactions` 
SET `created_at` = CONCAT(`recharged_on`, ' ', `recharged_time`) 
WHERE `created_at` = '1970-01-01 00:00:01' OR `created_at` < '2000-01-01';
