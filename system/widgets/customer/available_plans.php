<?php

class available_plans
{
    public function getWidget()
    {
        global $ui;

        // Get usage count per plan from purchase history
        $usageCounts = [];
        try {
            ORM::raw_execute('SELECT plan_id, COUNT(*) as cnt FROM tbl_user_recharges GROUP BY plan_id');
            $stmt = ORM::get_last_statement();
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $usageCounts[(int)$row['plan_id']] = (int)$row['cnt'];
            }
        } catch (Exception $e) {
        }

        // Get all enabled, purchasable plans
        $plansRaw = ORM::for_table('tbl_plans')
            ->where('enabled', 1)
            ->where_not_equal('type', 'Balance')
            ->order_by_asc('price')
            ->find_array();

        if (empty($plansRaw)) {
            $ui->assign('_plans', []);
            $ui->assign('_plan_badges', []);
            return $ui->fetch('widget/customers/available_plans.tpl');
        }

        foreach ($plansRaw as &$p) {
            // Usage count
            $p['usage_count'] = isset($usageCounts[(int)$p['id']]) ? $usageCounts[(int)$p['id']] : 0;

            // Normalize validity to days for comparing efficiency
            switch ($p['validity_unit']) {
                case 'Mins':   $p['validity_days'] = round($p['validity'] / 1440, 2); break;
                case 'Hrs':    $p['validity_days'] = round($p['validity'] / 24, 2); break;
                case 'Days':   $p['validity_days'] = (int)$p['validity']; break;
                case 'Months': $p['validity_days'] = (int)$p['validity'] * 30; break;
                default:       $p['validity_days'] = (int)$p['validity']; break;
            }

            // Efficiency = validity days per price unit (more days per shilling = better value)
            $price = (float)$p['price'];
            $p['efficiency_score'] = $price > 0 && $p['validity_days'] > 0
                ? round($p['validity_days'] / $price, 6)
                : 0;

            // Bandwidth speed display
            $p['speed'] = '';
            if (!empty($p['id_bw'])) {
                $bw = ORM::for_table('tbl_bandwidth')->find_one($p['id_bw']);
                if ($bw) {
                    $down = $bw['rate_down'] . $bw['rate_down_unit'];
                    $up   = $bw['rate_up'] . $bw['rate_up_unit'];
                    $p['speed'] = $down . ' ↓ / ' . $up . ' ↑';
                }
            }

            // Human-readable validity
            $p['validity_label'] = $p['validity'] . ' ' . $p['validity_unit'];

            // Data limit label
            if (!empty($p['data_limit']) && !empty($p['data_unit'])) {
                $p['data_label'] = $p['data_limit'] . ' ' . $p['data_unit'];
            } elseif ($p['typebp'] == 'Unlimited') {
                $p['data_label'] = 'Unlimited';
            } else {
                $p['data_label'] = '';
            }

            $p['badges'] = [];
        }
        unset($p);

        // Determine badges — only award each category to one plan
        $maxUsage = !empty($usageCounts) ? max(array_column($plansRaw, 'usage_count')) : 0;
        $minPrice = min(array_map(function ($p) { return (float)$p['price']; }, $plansRaw));
        $maxEff   = max(array_column($plansRaw, 'efficiency_score'));

        $badgedPopular  = false;
        $badgedCheapest = false;
        $badgedBestVal  = false;

        foreach ($plansRaw as &$p) {
            if (!$badgedPopular && $maxUsage > 0 && $p['usage_count'] == $maxUsage) {
                $p['badges'][] = ['label' => 'Most Popular', 'class' => 'badge-primary', 'icon' => '🔥'];
                $badgedPopular = true;
            }
            if (!$badgedCheapest && (float)$p['price'] == $minPrice) {
                $p['badges'][] = ['label' => 'Cheapest', 'class' => 'badge-success', 'icon' => '💰'];
                $badgedCheapest = true;
            }
            if (!$badgedBestVal && $maxEff > 0 && $p['efficiency_score'] == $maxEff) {
                $p['badges'][] = ['label' => 'Best Value', 'class' => 'badge-warning', 'icon' => '⭐'];
                $badgedBestVal = true;
            }
        }
        unset($p);

        $ui->assign('_plans', $plansRaw);
        return $ui->fetch('widget/customers/available_plans.tpl');
    }
}
