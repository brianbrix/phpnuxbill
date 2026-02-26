{include file="sections/header.tpl"}

<div class="row">
    <div class="col-sm-12">
        <!-- Server Status Summary -->
        <div class="row mb20">
            <div class="col-sm-3">
                <div class="info-box {if $health.is_online}bg-green{else}bg-red{/if}">
                    <span class="info-box-icon">
                        <i class="fa {if $health.is_online}fa-signal{else}fa-warning{/if}"></i>
                    </span>
                    <div class="info-box-content">
                        <span class="info-box-text">Router Status</span>
                        <span class="info-box-number">
                            {if $health.is_online}
                                <span style="color: #00a65a;">🟢 ONLINE</span>
                            {else}
                                <span style="color: #dd4b39;">🔴 OFFLINE</span>
                            {/if}
                        </span>
                    </div>
                </div>
            </div>
            
            <div class="col-sm-3">
                <div class="info-box bg-blue">
                    <span class="info-box-icon"><i class="fa fa-clock-o"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Last Check</span>
                        <span class="info-box-number">{Lang::dateTimeFormat($health.last_check)}</span>
                    </div>
                </div>
            </div>
            
            <div class="col-sm-3">
                <div class="info-box bg-yellow">
                    <span class="info-box-icon"><i class="fa fa-users"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Total Extended</span>
                        <span class="info-box-number">{$total_extended_customers}</span>
                    </div>
                </div>
            </div>
            
            <div class="col-sm-3">
                <div class="info-box bg-light-blue">
                    <span class="info-box-icon"><i class="fa fa-hourglass"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Total Downtime (mins)</span>
                        <span class="info-box-number">{$total_offline_minutes}</span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Offline Periods History -->
        <div class="panel panel-primary">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-history"></i> Offline Periods & Plan Extensions
                    <span class="badge badge-primary" style="margin-left: 10px;">{$total_offline_periods}</span>
                </h3>
                <div class="btn-group pull-right">
                    <a href="{Text::url('server_uptime/settings')}" class="btn btn-default btn-xs">
                        <i class="fa fa-cog"></i> Settings
                    </a>
                </div>
            </div>
            <div class="panel-body">
                <div class="alert alert-info" style="margin-bottom: 20px;">
                    <i class="fa fa-info-circle"></i> <strong>Maximum Extension Age:</strong> {$max_days} days
                    - Offline periods older than this are not eligible for extensions.
                    <a href="{Text::url('server_uptime/settings')}" class="btn btn-xs btn-primary pull-right">Change Settings</a>
                </div>
                
                {if $offline_periods|count == 0}
                    <div class="alert alert-info">
                        <i class="fa fa-info-circle"></i> No offline periods recorded
                    </div>
                {else}
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped table-hover">
                            <thead>
                                <tr>
                                    <th>{Lang::T('Went Offline')}</th>
                                    <th>{Lang::T('Came Online')}</th>
                                    <th>Duration (mins)</th>
                                    <th>Age (days)</th>
                                    <th>Customers Extended</th>
                                    <th>Plans Extended</th>
                                    <th>Eligibility</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                {foreach $offline_periods as $period}
                                    <tr {if $period.is_too_old}class="text-muted"{/if}>
                                        <td>{Lang::dateTimeFormat($period.went_offline)}</td>
                                        <td>
                                            {if $period.came_online}
                                                {Lang::dateTimeFormat($period.came_online)}
                                            {else}
                                                <span class="label label-danger">Still Offline</span>
                                            {/if}
                                        </td>
                                        <td>
                                            <strong>{$period.duration_minutes}</strong>
                                            {if $period.duration_minutes >= 60}
                                                <br><small>({$period.duration_minutes / 60|round:2} hours)</small>
                                            {/if}
                                        </td>
                                        <td>
                                            <strong>{$period.age_days}</strong>
                                        </td>
                                        <td>
                                            <span class="badge badge-warning">{$period.affected_customers}</span>
                                        </td>
                                        <td>
                                            <span class="badge badge-info">{$period.plans_extended}</span>
                                        </td>
                                        <td>
                                            {if $period.is_still_offline}
                                                <span class="label label-danger">
                                                    <i class="fa fa-warning"></i> Still Offline
                                                </span>
                                            {elseif $period.is_too_old}
                                                <span class="label label-danger">
                                                    <i class="fa fa-ban"></i> Too Old
                                                </span>
                                            {else}
                                                <span class="label label-success">
                                                    <i class="fa fa-check"></i> Eligible
                                                </span>
                                            {/if}
                                        </td>
                                        <td>
                                            {if $period.extended}
                                                <span class="label label-success">✓ Extended</span><br>
                                                <small>{Lang::dateTimeFormat($period.extension_date)}</small>
                                            {else}
                                                <span class="label label-warning">Pending</span>
                                            {/if}
                                        </td>
                                        <td>
                                            <a href="{Text::url('server_uptime/offline-period/', $period.id)}" class="btn btn-info btn-xs">
                                                <i class="fa fa-eye"></i> Details
                                            </a>
                                        </td>
                                    </tr>
                                {/foreach}
                            </tbody>
                        </table>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
