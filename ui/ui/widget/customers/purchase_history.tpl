{* Purchase History Widget Template *}
<div class="box box-solid box-primary">
    <div class="box-header with-border">
        <h3 class="box-title">
            <i class="ion ion-ios-cart"></i> {Lang::T('Purchase History')}
            {if $purchase_count > 0}
                <span class="badge bg-primary" style="margin-left: 10px;">{$purchase_count}</span>
            {/if}
        </h3>
        <div class="box-tools pull-right">
            <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
        </div>
    </div>
    <div class="box-body" style="padding: 0;">
        {if empty($purchases)}
            <div style="padding: 20px; text-align: center; color: #888;">
                <i class="fa fa-inbox" style="font-size: 32px; margin-bottom: 10px; display: block;"></i>
                {Lang::T('No purchases yet')}
            </div>
        {else}
            <div class="list-group" style="margin: 0; border: 0;">
                {foreach $purchases as $idx => $purchase}
                    <div class="list-group-item" style="border: 1px solid #ddd; margin-bottom: 5px; border-radius: 4px;">
                        <div class="purchase-item-header" onclick="togglePurchaseDetail(event, 'purchase-{$idx}')" 
                             style="padding: 12px 15px; cursor: pointer; user-select: none; display: flex; justify-content: space-between; align-items: center;">
                            <div style="flex: 1;">
                                <div style="font-weight: 600; color: #333; margin-bottom: 4px;">
                                    {$purchase.plan_name|truncate:40}
                                </div>
                                <div style="font-size: 13px; color: #888;">
                                    <i class="fa fa-calendar"></i> {Lang::dateAndTimeFormat($purchase.recharged_on, $purchase.recharged_time)}
                                </div>
                            </div>
                            <div style="text-align: right; min-width: 120px;">
                                <div style="font-weight: 700; font-size: 16px; color: #27ae60; margin-bottom: 4px;">
                                    {Lang::moneyFormat($purchase.price)}
                                </div>
                                {if $purchase.status == 'Active'}
                                    <span class="label label-success" style="font-size: 11px;">{Lang::T('Active')}</span>
                                {elseif $purchase.status == 'Expired'}
                                    <span class="label label-danger" style="font-size: 11px;">{Lang::T('Expired')}</span>
                                {else}
                                    <span class="label label-warning" style="font-size: 11px;">{$purchase.status}</span>
                                {/if}
                            </div>
                            <div style="margin-left: 10px; min-width: 30px; text-align: center;">
                                <i id="arrow-{$idx}" class="fa fa-chevron-down" style="color: #999; transition: transform 0.3s ease;"></i>
                            </div>
                        </div>
                        
                        {* Expandable Details *}
                        <div id="purchase-{$idx}" class="purchase-details" style="display: none; padding: 15px; background-color: #f9f9f9; border-top: 1px solid #eee;">
                            <div class="row" style="margin: 0;">
                                <div class="col-sm-6" style="padding: 8px 0; margin-bottom: 10px;">
                                    <div style="font-size: 12px; color: #888; margin-bottom: 3px;">{Lang::T('Invoice')}</div>
                                    <div style="font-weight: 600; color: #333;">#{$purchase.invoice}</div>
                                </div>
                                <div class="col-sm-6" style="padding: 8px 0; margin-bottom: 10px;">
                                    <div style="font-size: 12px; color: #888; margin-bottom: 3px;">{Lang::T('Type')}</div>
                                    <div style="font-weight: 600; color: #333;">{$purchase.type}</div>
                                </div>
                                <div class="col-sm-6" style="padding: 8px 0; margin-bottom: 10px;">
                                    <div style="font-size: 12px; color: #888; margin-bottom: 3px;">{Lang::T('Created On')}</div>
                                    <div style="font-weight: 600; color: #333;">{Lang::dateAndTimeFormat($purchase.recharged_on, $purchase.recharged_time)}</div>
                                </div>
                                <div class="col-sm-6" style="padding: 8px 0; margin-bottom: 10px;">
                                    <div style="font-size: 12px; color: #888; margin-bottom: 3px;">{Lang::T('Expires On')}</div>
                                    <div style="font-weight: 600; color: #333;">{Lang::dateAndTimeFormat($purchase.expiration, $purchase.time)}</div>
                                </div>
                                <div class="col-sm-6" style="padding: 8px 0; margin-bottom: 10px;">
                                    <div style="font-size: 12px; color: #888; margin-bottom: 3px;">{Lang::T('Price')}</div>
                                    <div style="font-weight: 600; color: #27ae60; font-size: 14px;">{Lang::moneyFormat($purchase.price)}</div>
                                </div>
                                <div class="col-sm-6" style="padding: 8px 0; margin-bottom: 10px;">
                                    <div style="font-size: 12px; color: #888; margin-bottom: 3px;">{Lang::T('Method')}</div>
                                    <div style="font-weight: 600; color: #333;">{$purchase.method}</div>
                                </div>
                            </div>
                            <div style="margin-top: 12px; padding-top: 12px; border-top: 1px solid #ddd;">
                                <a href="{Text::url('voucher/invoice/')}{$purchase.id}" class="btn btn-xs btn-primary" style="margin-right: 5px;">
                                    <i class="fa fa-file-text"></i> {Lang::T('View Invoice')}
                                </a>
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
            <div style="padding: 15px; text-align: center; border-top: 1px solid #ddd;">
                <a href="{Text::url('voucher/list-activated')}" class="btn btn-default btn-sm">
                    <i class="fa fa-list-alt"></i> {Lang::T('View All Purchases')}
                </a>
            </div>
        {/if}
    </div>
</div>

<script>
function togglePurchaseDetail(event, elementId) {
    const element = document.getElementById(elementId);
    const arrow = event.currentTarget.querySelector('i[class*="chevron"]');
    
    if (element.style.display === 'none') {
        element.style.display = 'block';
        if (arrow) arrow.style.transform = 'rotate(180deg)';
    } else {
        element.style.display = 'none';
        if (arrow) arrow.style.transform = 'rotate(0deg)';
    }
}

// Add mobile-friendly styles
{literal}
<style>
@media (max-width: 768px) {
    .purchase-item-header {
        flex-wrap: wrap;
    }
    
    .purchase-item-header > div:last-child {
        display: none;
    }
    
    .purchase-item-header::after {
        content: attr(data-arrow);
        width: 100%;
        text-align: right;
        font-size: 14px;
    }
    
    .purchase-details {
        font-size: 13px !important;
    }
    
    .purchase-details .row > div {
        margin-bottom: 12px !important;
    }
}
</style>
{/literal}
</script>
