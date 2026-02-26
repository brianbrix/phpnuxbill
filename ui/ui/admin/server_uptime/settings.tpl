{include file="sections/header.tpl"}

<div class="row">
    <div class="col-sm-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-cog"></i> Server Uptime & Extension Settings
                </h3>
                <div class="btn-group pull-right">
                    <a href="{Text::url('server_uptime')}" class="btn btn-default btn-xs">
                        <i class="fa fa-arrow-left"></i> Back to Dashboard
                    </a>
                </div>
            </div>
            <div class="panel-body">
                <form method="post" action="{Text::url('server_uptime/settings')}" class="form-horizontal">
                    
                    <!-- Auto Extension Toggle -->
                    <div class="form-group">
                        <label class="col-sm-3 control-label">
                            <strong>Auto-Extend on Recovery</strong>
                            <br><small class="text-muted">Automatically extend plans when server comes back online</small>
                        </label>
                        <div class="col-sm-9">
                            <div class="radio">
                                <label>
                                    <input type="radio" name="auto_extend_on_recovery" value="yes" {if $auto_extend == 'yes'}checked{/if}>
                                    <strong>Yes</strong> - Plans will be extended automatically when server recovers
                                </label>
                            </div>
                            <div class="radio">
                                <label>
                                    <input type="radio" name="auto_extend_on_recovery" value="no" {if $auto_extend == 'no'}checked{/if}>
                                    <strong>No</strong> - Manual extension only (admin must select customers)
                                </label>
                            </div>
                            <p class="help-block">
                                <i class="fa fa-info-circle"></i> When enabled, all active customer plans will be automatically extended by the downtime duration. When disabled, you must manually select customers to extend.
                            </p>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <!-- Max Days for Extension -->
                    <div class="form-group">
                        <label class="col-sm-3 control-label">
                            <strong>Maximum Extension Age</strong>
                            <br><small class="text-muted">How long offline periods remain eligible</small>
                        </label>
                        <div class="col-sm-9">
                            <div class="input-group" style="max-width: 300px;">
                                <input type="number" name="max_offline_extension_days" class="form-control" 
                                       value="{$max_days}" min="1" max="365" required>
                                <span class="input-group-addon">days</span>
                            </div>
                            <p class="help-block">
                                <i class="fa fa-info-circle"></i> Offline periods older than this many days cannot be used to extend customer plans. This prevents extending plans for very old outages.
                                <br><strong>Range:</strong> 1 to 365 days
                            </p>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <!-- Save Button -->
                    <div class="form-group">
                        <div class="col-sm-offset-3 col-sm-9">
                            <button type="submit" name="save_settings" value="1" class="btn btn-primary btn-lg">
                                <i class="fa fa-save"></i> Save Settings
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Information Panel -->
        <div class="panel panel-info">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-question-circle"></i> How It Works
                </h3>
            </div>
            <div class="panel-body">
                <h4>Automatic Extension Mode (Default)</h4>
                <ul>
                    <li>Every 5 minutes, a cron job checks if the RADIUS server is responding</li>
                    <li>If the server fails 3 consecutive checks (15 minutes), it's marked as offline</li>
                    <li>When the server comes back online, the system calculates the total downtime duration</li>
                    <li>All active customer plans are automatically extended by that duration</li>
                    <li>Each customer receives an inbox notification about the extension</li>
                    <li>Duplicate extensions are prevented - each customer can only be extended once per offline period</li>
                </ul>
                
                <h4 style="margin-top: 20px;">Manual Extension Mode</h4>
                <ul>
                    <li>Offline periods are recorded, but no automatic extensions happen</li>
                    <li>Admin must visit the offline period details page and click "Manually Extend Selected Customers"</li>
                    <li>Admin can select which customers to compensate with checkbox selections</li>
                    <li>This gives full control over who gets compensated for downtime</li>
                </ul>
                
                <h4 style="margin-top: 20px;">Age Limit Protection</h4>
                <ul>
                    <li>Offline periods older than the configured days cannot be used for extensions</li>
                    <li>This prevents extending plans for historical outages after too much time has passed</li>
                    <li>Helps avoid confusion and abuse of the extension system</li>
                    <li>Periods marked as "Too Old" will show a warning and disable extension options</li>
                </ul>
                
                <h4 style="margin-top: 20px;">Duplicate Prevention</h4>
                <ul>
                    <li>The system tracks exactly which customers have been extended for each offline period</li>
                    <li>Once a customer's plan is extended for a specific outage, they cannot be extended again for that same outage</li>
                    <li>This works for both automatic and manual extensions</li>
                    <li>Customers already extended will be grayed out in the manual selection interface</li>
                </ul>
                
                <div class="alert alert-warning" style="margin-top: 20px;">
                    <i class="fa fa-exclamation-triangle"></i> <strong>Important:</strong> Make sure your cron job is running every 5 minutes:
                    <pre style="margin-top: 10px;">*/5 * * * * php /path/to/phpnuxbill/system/cron_server_health.php</pre>
                </div>
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
