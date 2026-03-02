<?php

class graph_customers_insight
{
    public function getWidget()
    {
        global $CACHE_PATH,$ui;
        $u_act = ORM::for_table('tbl_user_recharges')
            ->where('status', 'on')
            ->inner_join('tbl_customers', ['tbl_user_recharges.customer_id', '=', 'tbl_customers.id'])
            ->where('tbl_customers.exclude_from_stats', 0)
            ->count();
        if (empty($u_act)) {
            $u_act = '0';
        }
        $ui->assign('u_act', $u_act);

        $u_all = ORM::for_table('tbl_user_recharges')
            ->inner_join('tbl_customers', ['tbl_user_recharges.customer_id', '=', 'tbl_customers.id'])
            ->where('tbl_customers.exclude_from_stats', 0)
            ->count();
        if (empty($u_all)) {
            $u_all = '0';
        }
        $ui->assign('u_all', $u_all);


        $c_all = ORM::for_table('tbl_customers')
            ->where('exclude_from_stats', 0)
            ->count();
        if (empty($c_all)) {
            $c_all = '0';
        }
        $ui->assign('c_all', $c_all);
        return $ui->fetch('widget/graph_customers_insight.tpl');
    }
}