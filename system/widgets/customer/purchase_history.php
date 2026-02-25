<?php

/**
 * Purchase History Widget
 * Displays customer's purchase/transaction history as an expandable list
 */

class purchase_history
{
    public function getWidget()
    {
        global $ui, $user;
        
        // Fetch recent transactions 
        $query = ORM::for_table('tbl_transactions')
            ->where('user_id', $user['id'])
            ->order_by_desc('id')
            ->limit(10);
        $transactions = $query->find_many();
        
        // If not found by user_id, try by username
        if (empty($transactions)) {
            $query = ORM::for_table('tbl_transactions')
                ->where('username', $user['username'])
                ->order_by_desc('id')
                ->limit(10);
            $transactions = $query->find_many();
        }
        
        // Convert to array for template
        $transactions_array = [];
        if (!empty($transactions)) {
            foreach ($transactions as $trx) {
                $transactions_array[] = $trx->as_array();
            }
        }
        
        $ui->assign('purchases', $transactions_array);
        $ui->assign('purchase_count', count($transactions_array));
        
        return $ui->fetch('widget/customers/purchase_history.tpl');
    }
}
