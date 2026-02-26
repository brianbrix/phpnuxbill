{include file="sections/header.tpl"}

<div class="row">
    <div class="col-sm-12">
        <!-- Server Still Offline Warning -->
        {if $is_still_offline}
            <div class="alert alert-danger">
                <h4><i class="fa fa-warning"></i> Router is Still Offline</h4>
                <p>This offline period has not ended yet (no recovery timestamp recorded).</p>
                <p>You can only extend customer plans AFTER the router comes back online. Please wait for the router to recover.</p>
            </div>
        {elseif $is_too_old}
            <!-- Period has ended but is too old -->
            <div class="alert alert-danger">
                <h4><i class="fa fa-ban"></i> This offline period is too old for extensions</h4>
                <p>This period occurred <strong>{$period_age_days}</strong> days ago, which exceeds the maximum allowed age of <strong>{$max_days}</strong> days.</p>
                <p>Extensions are disabled for this period. You can adjust the maximum age in <a href="{Text::url('server_uptime/settings')}">Settings</a>.</p>
            </div>
        {/if}
        
        <div class="panel panel-info">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-exclamation-triangle"></i> Offline Period Details
                </h3>
                <div class="btn-group pull-right">
                    <a href="{Text::url('server_uptime')}" class="btn btn-default btn-xs">
                        <i class="fa fa-arrow-left"></i> Back
                    </a>
                </div>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-12">
                        <table class="table table-bordered">
                            <tr>
                                <th style="width: 200px;">Went Offline</th>
                                <td><strong>{Lang::dateTimeFormat($period.went_offline)}</strong></td>
                            </tr>
                            <tr>
                                <th>Came Online</th>
                                <td>
                                    {if $period.came_online}
                                        <strong>{Lang::dateTimeFormat($period.came_online)}</strong>
                                    {else}
                                        <span class="label label-danger">Still Offline</span>
                                    {/if}
                                </td>
                            </tr>
                            <tr>
                                <th>Total Duration</th>
                                <td>
                                    <strong>{$period.duration_minutes} minutes</strong>
                                    {if $period.duration_minutes >= 60}
                                        <br><small>({$period.duration_minutes / 60|round:2} hours)</small>
                                    {/if}
                                </td>
                            </tr>
                            <tr>
                                <th>Period Age</th>
                                <td>
                                    <strong>{$period_age_days} days</strong>
                                    {if $is_too_old}
                                        <span class="label label-danger" style="margin-left:10px;">
                                            <i class="fa fa-exclamation-triangle"></i> Too Old
                                        </span>
                                    {else}
                                        <span class="label label-success" style="margin-left:10px;">
                                            <i class="fa fa-check"></i> Eligible
                                        </span>
                                    {/if}
                                </td>
                            </tr>
                            <tr>
                                <th>Customers Affected</th>
                                <td><span class="badge badge-primary" style="font-size: 14px;">{$period.affected_customers}</span></td>
                            </tr>
                            <tr>
                                <th>Plans Extended</th>
                                <td><span class="badge badge-info" style="font-size: 14px;">{$period.plans_extended}</span></td>
                            </tr>
                            <tr>
                                <th>Extension Status</th>
                                <td>
                                    {if $period.extended}
                                        <span class="label label-success">✓ Extended on {Lang::dateTimeFormat($period.extension_date)}</span>
                                    {else}
                                        <span class="label label-warning">Pending Automatic Extension</span>
                                    {/if}
                                </td>
                            </tr>
                            {if $period.notes}
                            <tr>
                                <th>Notes</th>
                                <td>{$period.notes}</td>
                            </tr>
                            {/if}
                        </table>
                        
                        <!-- Manual Extension Button -->
                        {if !$is_too_old}
                            <div style="margin-top: 20px; margin-bottom: 20px;">
                                <a href="{Text::url('server_uptime/manual-extend')}/{$period.id}" class="btn btn-primary">
                                    <i class="fa fa-users"></i> Manually Extend Selected Customers
                                </a>
                                <p class="text-muted" style="margin-top: 10px;">
                                    <i class="fa fa-info-circle"></i> You can select specific customers to extend their plans by {$period.duration_minutes} minutes.
                                </p>
                            </div>
                        {/if}
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Affected Customers -->
        {if $affected_customers}
        <div class="panel panel-success">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-users"></i> Extended Customers ({count($affected_customers)})
                </h3>
            </div>
            <div class="panel-body">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>Username</th>
                                <th>Plan Name</th>
                                <th>Extension Duration</th>
                                <th>Old Expiration</th>
                                <th>New Expiration</th>
                                <th>Extended By</th>
                                <th>Date Extended</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $affected_customers as $cust}
                                <tr>
                                    <td>
                                        <strong>{$cust.username}</strong>
                                    </td>
                                    <td>{$cust.plan_name}</td>
                                    <td>
                                        <span class="label label-info">{$cust.extension_minutes} mins</span>
                                    </td>
                                    <td>{$cust.old_expiration}</td>
                                    <td><strong>{$cust.new_expiration}</strong></td>
                                    <td>
                                        {if $cust.extended_by == 'auto'}
                                            <span class="label label-info">
                                                <i class="fa fa-cog"></i> Automatic
                                            </span>
                                        {else}
                                            <span class="label label-warning">
                                                <i class="fa fa-user"></i> Manual
                                            </span>
                                        {/if}
                                    </td>
                                    <td>{$cust.extended_date}</td>
                                </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        {else}
            <div class="alert alert-info">
                <i class="fa fa-info-circle"></i> No customers have been extended for this offline period yet.
                {if !$is_too_old}
                    <br><br>
                    <a href="{Text::url('server_uptime/manual-extend')}/{$period.id}" class="btn btn-sm btn-primary">
                        <i class="fa fa-hand-pointer-o"></i> Select Customers to Extend
                    </a>
                {/if}
            </div>
        {/if}
    </div>
</div>

{include file="sections/footer.tpl"}
