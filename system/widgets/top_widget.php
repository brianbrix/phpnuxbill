<?php


class top_widget
{
    public function getWidget()
    {
        global $ui, $current_date, $start_date;

        $iday = ORM::for_table('tbl_transactions')
            ->where('recharged_on', $current_date)
            ->where_not_equal('method', 'Customer - Balance')
            ->where_not_equal('method', 'Recharge Balance - Administrator')
            ->inner_join('tbl_customers', ['tbl_transactions.customer_id', '=', 'tbl_customers.id'])
            ->where('tbl_customers.exclude_from_stats', 0)
            ->sum('tbl_transactions.price');

        if ($iday == '') {
            $iday = '0.00';
        }
        $ui->assign('iday', $iday);

        $imonth = ORM::for_table('tbl_transactions')
            ->where_not_equal('method', 'Customer - Balance')
            ->where_not_equal('method', 'Recharge Balance - Administrator')
            ->where_gte('recharged_on', $start_date)
            ->where_lte('recharged_on', $current_date)
            ->inner_join('tbl_customers', ['tbl_transactions.customer_id', '=', 'tbl_customers.id'])
            ->where('tbl_customers.exclude_from_stats', 0)
            ->sum('tbl_transactions.price');
        if ($imonth == '') {
            $imonth = '0.00';
        }
        $ui->assign('imonth', $imonth);

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
        return $ui->fetch('widget/top_widget.tpl');
    }
}
