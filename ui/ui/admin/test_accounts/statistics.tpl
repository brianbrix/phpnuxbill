{include file="sections/header.tpl"}

<div class="row">
    <div class="col-sm-12">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">
                <div class="btn-group pull-right">
                    <a href="{Text::url('test_accounts/list')}" class="btn btn-default btn-xs">
                        <i class="glyphicon glyphicon-arrow-left"></i> {Lang::T('Back to List')}
                    </a>
                </div>
                <h4>{Lang::T('Statistics Comparison')}</h4>
            </div>
            <div class="panel-body">
                <div class="alert alert-info">
                    <i class="glyphicon glyphicon-info-sign"></i> 
                    <strong>{Lang::T('Understanding the Impact')}</strong><br>
                    {Lang::T('This page shows how excluding test accounts affects your dashboard statistics. Use this to see the difference between real and test data.')}
                </div>
                
                <div class="row">
                    <!-- Total Customers -->
                    <div class="col-md-4">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">
                                    <i class="glyphicon glyphicon-user"></i> {Lang::T('Total Customers')}
                                </h4>
                            </div>
                            <div class="panel-body">
                                <table class="table table-bordered">
                                    <tr>
                                        <td><strong>{Lang::T('All Accounts')}:</strong></td>
                                        <td class="text-right"><h4 class="text-primary" style="margin: 0;">{$total_all}</h4></td>
                                    </tr>
                                    <tr class="success">
                                        <td><strong>{Lang::T('Real Accounts')}:</strong></td>
                                        <td class="text-right"><h4 class="text-success" style="margin: 0;">{$total_included}</h4></td>
                                    </tr>
                                    <tr class="warning">
                                        <td><strong>{Lang::T('Test Accounts')}:</strong></td>
                                        <td class="text-right"><h4 class="text-warning" style="margin: 0;">{$total_excluded}</h4></td>
                                    </tr>
                                </table>
                                {if $total_excluded > 0}
                                    <div class="alert alert-warning" style="margin-bottom: 0;">
                                        <strong>{($total_excluded / $total_all * 100)|number_format:1}%</strong> {Lang::T('are test accounts')}
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </div>
                    
                    <!-- Active Subscriptions -->
                    <div class="col-md-4">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">
                                    <i class="glyphicon glyphicon-signal"></i> {Lang::T('Active Subscriptions')}
                                </h4>
                            </div>
                            <div class="panel-body">
                                <table class="table table-bordered">
                                    <tr>
                                        <td><strong>{Lang::T('All Active')}:</strong></td>
                                        <td class="text-right"><h4 class="text-primary" style="margin: 0;">{$active_all}</h4></td>
                                    </tr>
                                    <tr class="success">
                                        <td><strong>{Lang::T('Real Active')}:</strong></td>
                                        <td class="text-right"><h4 class="text-success" style="margin: 0;">{$active_included}</h4></td>
                                    </tr>
                                    <tr class="warning">
                                        <td><strong>{Lang::T('Test Active')}:</strong></td>
                                        <td class="text-right"><h4 class="text-warning" style="margin: 0;">{$active_excluded}</h4></td>
                                    </tr>
                                </table>
                                {if $active_excluded > 0 && $active_all > 0}
                                    <div class="alert alert-warning" style="margin-bottom: 0;">
                                        <strong>{($active_excluded / $active_all * 100)|number_format:1}%</strong> {Lang::T('are test subscriptions')}
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </div>
                    
                    <!-- Revenue This Month -->
                    <div class="col-md-4">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">
                                    <i class="glyphicon glyphicon-usd"></i> {Lang::T('Revenue This Month')}
                                </h4>
                            </div>
                            <div class="panel-body">
                                <table class="table table-bordered">
                                    <tr>
                                        <td><strong>{Lang::T('Total')}:</strong></td>
                                        <td class="text-right"><h4 class="text-primary" style="margin: 0;">{Lang::moneyFormat($revenue_all)}</h4></td>
                                    </tr>
                                    <tr class="success">
                                        <td><strong>{Lang::T('Real Revenue')}:</strong></td>
                                        <td class="text-right"><h4 class="text-success" style="margin: 0;">{Lang::moneyFormat($revenue_included)}</h4></td>
                                    </tr>
                                    <tr class="warning">
                                        <td><strong>{Lang::T('Test Revenue')}:</strong></td>
                                        <td class="text-right"><h4 class="text-warning" style="margin: 0;">{Lang::moneyFormat($revenue_excluded)}</h4></td>
                                    </tr>
                                </table>
                                {if $revenue_excluded > 0 && $revenue_all > 0}
                                    <div class="alert alert-warning" style="margin-bottom: 0;">
                                        <strong>{($revenue_excluded / $revenue_all * 100)|number_format:1}%</strong> {Lang::T('is test revenue')}
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="alert alert-success">
                    <h4><i class="glyphicon glyphicon-ok-sign"></i> {Lang::T('Dashboard Impact')}</h4>
                    <p>{Lang::T('Your dashboard will now show statistics based on')}: <strong>{$total_included} {Lang::T('real accounts')}</strong></p>
                    <p>{Lang::T('Excluded')}: <strong>{$total_excluded} {Lang::T('test accounts')}</strong></p>
                </div>
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
