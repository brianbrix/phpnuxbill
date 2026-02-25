{include file="customer/header.tpl"}
<!-- user-activation-list -->

<style>
    @media (max-width: 768px) {
        .table {
            font-size: 12px;
        }
        
        .table th, .table td {
            padding: 8px 6px;
        }
        
        .table th {
            font-size: 11px;
        }
        
        .table-responsive {
            border: none;
            -webkit-overflow-scrolling: touch;
            -ms-overflow-style: -ms-autohiding-scrollbar;
        }
    }
    
    @media (max-width: 480px) {
        .table {
            font-size: 11px;
        }
        
        .table th, .table td {
            padding: 6px 4px;
        }
        
        .btn-sm {
            padding: 4px 8px;
            font-size: 11px;
        }
    }
</style>

<div class="row">
    <div class="col-sm-12">
        <div class="panel mb20 panel-hovered panel-primary">
            <div class="panel-heading">{Lang::T('Transaction History List')}</div>
            <div class="panel-body">
                <div class="table-responsive">
                    <table id="datatable" class="table table-bordered table-striped table-condensed">
                        <thead>
                            <tr>
                                <th>{Lang::T('Invoice')}</th>
                                <th>{Lang::T('Package Name')}</th>
                                <th>{Lang::T('Package Price')}</th>
                                <th>{Lang::T('Type')}</th>
                                <th>{Lang::T('Created On')}</th>
                                <th>{Lang::T('Expires On')}</th>
                                <th>{Lang::T('Method')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $d as $ds}
                                <tr onclick="window.location.href = '{Text::url('voucher/invoice/')}{$ds.id|escape:'html'}'" style="cursor: pointer;">
                                    <td>{$ds.invoice|escape:'html'}</td>
                                    <td>{$ds.plan_name|escape:'html'}</td>
                                    <td>{Lang::moneyFormat($ds.price)}</td>
                                    <td>{$ds.type|escape:'html'}</td>
                                    <td>{Lang::dateAndTimeFormat($ds.recharged_on, $ds.recharged_time)}</td>
                                    <td>{Lang::dateAndTimeFormat($ds.expiration, $ds.time)}</td>
                                    <td>{$ds.method|escape:'html'}</td>
                                </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
                {include file="pagination.tpl"}
            </div>
        </div>
    </div>
</div>

{include file="customer/footer.tpl"}
