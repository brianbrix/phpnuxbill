{if $_plans}
<div class="box box-primary box-solid">
    <div class="box-header with-border">
        <h3 class="box-title"><i class="glyphicon glyphicon-list-alt"></i> {Lang::T('Available Plans')}</h3>
    </div>
    <div class="box-body" style="padding:10px;">
        <style>
            .plan-card {
                border: 1px solid #ddd;
                border-radius: 10px;
                padding: 14px 12px;
                margin-bottom: 12px;
                background: #fff;
                box-shadow: 0 2px 6px rgba(0,0,0,0.07);
                position: relative;
                transition: box-shadow 0.2s;
            }
            .plan-card:hover { box-shadow: 0 4px 14px rgba(0,0,0,0.13); }
            .plan-card .plan-name {
                font-size: 15px;
                font-weight: 700;
                color: #333;
                margin-bottom: 4px;
            }
            .plan-card .plan-price {
                font-size: 22px;
                font-weight: 800;
                color: #1a73e8;
                margin-bottom: 6px;
            }
            .plan-card .plan-price small {
                font-size: 13px;
                font-weight: 400;
                color: #888;
            }
            .plan-price-old {
                text-decoration: line-through;
                color: #bbb;
                font-size: 13px;
                margin-left: 4px;
            }
            .plan-meta {
                font-size: 12px;
                color: #666;
                margin-bottom: 3px;
            }
            .plan-meta i { width: 14px; text-align: center; color: #1a73e8; }
            .plan-badges { margin-bottom: 6px; }
            .plan-badge {
                display: inline-block;
                font-size: 11px;
                padding: 2px 8px;
                border-radius: 20px;
                font-weight: 600;
                margin-right: 3px;
                margin-bottom: 3px;
            }
            .badge-primary { background: #1a73e8; color: #fff; }
            .badge-success { background: #28a745; color: #fff; }
            .badge-warning { background: #ffc107; color: #333; }
            .plan-buy-btn {
                display: block;
                text-align: center;
                margin-top: 10px;
                padding: 8px;
                background: #1a73e8;
                color: #fff !important;
                border-radius: 6px;
                font-weight: 600;
                font-size: 14px;
                text-decoration: none !important;
            }
            .plan-buy-btn:hover { background: #1558c0; }
            .plans-grid { display: flex; flex-wrap: wrap; margin: -6px; }
            .plans-grid .plan-col { padding: 6px; box-sizing: border-box; width: 50%; }
            @media(max-width: 480px) { .plans-grid .plan-col { width: 100%; } }
        </style>

        <div class="plans-grid">
            {foreach $_plans as $plan}
            <div class="plan-col">
                <div class="plan-card">
                    {if $plan.badges}
                    <div class="plan-badges">
                        {foreach $plan.badges as $badge}
                        <span class="plan-badge {$badge.class}">{$badge.icon} {$badge.label}</span>
                        {/foreach}
                    </div>
                    {/if}

                    <div class="plan-name">{$plan.name_plan}</div>

                    <div class="plan-price">
                        {Lang::moneyFormat($plan.price)}
                        {if $plan.price_old neq ''}<span class="plan-price-old">{Lang::moneyFormat($plan.price_old)}</span>{/if}
                    </div>

                    {if $plan.speed neq ''}
                    <div class="plan-meta">
                        <i class="glyphicon glyphicon-signal"></i> {$plan.speed}
                    </div>
                    {/if}

                    <div class="plan-meta">
                        <i class="glyphicon glyphicon-time"></i> {$plan.validity_label}
                    </div>

                    {if $plan.data_label neq ''}
                    <div class="plan-meta">
                        <i class="glyphicon glyphicon-cloud-download"></i> {$plan.data_label}
                    </div>
                    {/if}

                    <div class="plan-meta">
                        <i class="glyphicon glyphicon-tag"></i> {$plan.type} &bull; {$plan.plan_type}
                    </div>

                    <a href="{Text::url('order/package')}" class="plan-buy-btn">
                        {Lang::T('Subscribe')} &rarr;
                    </a>
                </div>
            </div>
            {/foreach}
        </div>
    </div>
</div>
{/if}
