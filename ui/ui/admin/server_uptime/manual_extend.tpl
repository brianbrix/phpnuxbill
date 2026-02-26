{include file="admin/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Manual Plan Extension - Offline Period #{$period['id']}</h3>
                <div class="box-tools pull-right">
                    <a href="{Text::url('server_uptime/offline-period')}/{$period['id']}" class="btn btn-default btn-sm">
                        <i class="fa fa-arrow-left"></i> Back to Period Details
                    </a>
                </div>
            </div>
            
            <div class="box-body">
                <!-- Period Info -->
                <div class="alert alert-info">
                    <h4><i class="fa fa-info-circle"></i> Offline Period Information</h4>
                    <p><strong>Went Offline:</strong> {$period['went_offline']}</p>
                    <p><strong>Came Online:</strong> {$period['came_online']}</p>
                    <p><strong>Duration:</strong> {$period['duration_minutes']} minutes ({($period['duration_minutes']/60)|round:1} hours)</p>
                    <p class="text-muted">Each selected customer's plan will be extended by this duration.</p>
                </div>
                
                {if count($customers) == 0}
                    <div class="alert alert-warning">
                        <i class="fa fa-exclamation-triangle"></i> No active customers found to extend.
                    </div>
                {else}
                    <form method="post" action="{Text::url('server_uptime/manual-extend')}/{$period['id']}" id="extendForm">
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped">
                                <thead>
                                    <tr>
                                        <th width="40">
                                            <input type="checkbox" id="selectAll"> <label for="selectAll" style="font-weight:normal;margin:0;">All</label>
                                        </th>
                                        <th>Username</th>
                                        <th>Full Name</th>
                                        <th>Plan Name</th>
                                        <th>Expiration Date</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {foreach $customers as $cust}
                                        <tr class="{if $cust['already_extended']}success{/if}">
                                            <td>
                                                {if $cust['already_extended']}
                                                    <input type="checkbox" disabled>
                                                {else}
                                                    <input type="checkbox" name="selected_customers[]" value="{$cust['recharge_id']}" class="customer-checkbox">
                                                {/if}
                                            </td>
                                            <td>{$cust['username']}</td>
                                            <td>{$cust['fullname']}</td>
                                            <td>{$cust['plan_name']}</td>
                                            <td>{$cust['expiration_date']}</td>
                                            <td>
                                                {if $cust['already_extended']}
                                                    <span class="label label-success">
                                                        <i class="fa fa-check"></i> Already Extended
                                                    </span>
                                                {else}
                                                    <span class="label label-warning">
                                                        <i class="fa fa-clock-o"></i> Eligible for Extension
                                                    </span>
                                                {/if}
                                            </td>
                                        </tr>
                                    {/foreach}
                                </tbody>
                            </table>
                        </div>
                        
                        <div class="form-group">
                            <button type="submit" name="extend_selected" value="1" class="btn btn-primary btn-lg" onclick="return confirmExtension();">
                                <i class="fa fa-check"></i> Extend Selected Customers
                            </button>
                            <span class="text-muted" style="margin-left: 15px;">
                                <span id="selectedCount">0</span> customer(s) selected for extension
                            </span>
                        </div>
                    </form>
                    
                    <div class="alert alert-warning" style="margin-top: 20px;">
                        <h4><i class="fa fa-exclamation-triangle"></i> Important Notes:</h4>
                        <ul>
                            <li>Customers marked with green background have already been extended for this offline period and cannot be selected again.</li>
                            <li>Only active plans will be extended.</li>
                            <li>Each customer will receive an inbox notification about the extension.</li>
                            <li>The extension will be logged in the system for audit purposes.</li>
                            <li>This action cannot be undone - please review carefully before proceeding.</li>
                        </ul>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

<script>
// Select all checkbox functionality
document.getElementById('selectAll').addEventListener('change', function() {
    var checkboxes = document.querySelectorAll('.customer-checkbox');
    checkboxes.forEach(function(checkbox) {
        checkbox.checked = this.checked;
    }.bind(this));
    updateSelectedCount();
});

// Update selected count
var checkboxes = document.querySelectorAll('.customer-checkbox');
checkboxes.forEach(function(checkbox) {
    checkbox.addEventListener('change', updateSelectedCount);
});

function updateSelectedCount() {
    var checked = document.querySelectorAll('.customer-checkbox:checked');
    document.getElementById('selectedCount').textContent = checked.length;
}

function confirmExtension() {
    var checked = document.querySelectorAll('.customer-checkbox:checked');
    if (checked.length == 0) {
        alert('Please select at least one customer to extend.');
        return false;
    }
    
    var duration = {$period['duration_minutes']};
    var hours = (duration / 60).toFixed(1);
    
    return confirm('Are you sure you want to extend ' + checked.length + ' customer(s) by ' + duration + ' minutes (' + hours + ' hours)?\n\nThis action cannot be undone.');
}

// Initialize count on page load
updateSelectedCount();
</script>

{include file="admin/footer.tpl"}
