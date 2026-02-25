{if $_bills}
    <div class="box box-primary box-solid">
        {foreach $_bills as $_bill}
            {if $_bill['routers'] != 'radius'}
                <div class="box-header">
                    <h3 class="box-title">{$_bill['routers']}</h3>
                    <div class="btn-group pull-right">
                        {if $_bill['type'] == 'Hotspot'}
                            {if $_c['hotspot_plan']==''}Hotspot Plan{else}{$_c['hotspot_plan']}{/if}
                        {else if $_bill['type'] == 'PPPOE'}
                            {if $_c['pppoe_plan']==''}PPPOE Plan{else}{$_c['pppoe_plan']}{/if}
                        {else if $_bill['type'] == 'VPN'}
                            {if $_c['pppoe_plan']==''}VPN Plan{else}{$_c['vpn_plan']}{/if}
                        {/if}
                    </div>
                </div>
            {else}
                <div class="box-header">
                    <h3 class="box-title">{if $_c['radius_plan']==''}Radius Plan{else}{$_c['radius_plan']}{/if}</h3>
                </div>
            {/if}
            <div style="margin-left: 5px; margin-right: 5px;">
                <table class="table table-bordered table-striped table-bordered table-hover" style="margin-bottom: 0px;">
                    <tr>
                        <td class="small text-primary text-uppercase text-normal">{Lang::T('Package Name')}</td>
                        <td class="small mb15">
                            {$_bill['namebp']}
                            {if $_bill['status'] != 'on'}
                                <a class="label label-danger pull-right"
                                    href="{Text::url('order/package')}">{Lang::T('Expired')}</a>
                            {/if}
                        </td>
                    </tr>
                    {if $_c['show_bandwidth_plan'] == 'yes'}
                        <tr>
                            <td class="small text-primary text-uppercase text-normal">{Lang::T('Bandwidth')}</td>
                            <td class="small mb15">
                                {$_bill['name_bw']}
                            </td>
                        </tr>
                    {/if}
                    <tr>
                        <td class="small text-info text-uppercase text-normal">{Lang::T('Created On')}</td>
                        <td class="small mb15">
                            {if $_bill['time'] ne ''}
                                {Lang::dateAndTimeFormat($_bill['recharged_on'],$_bill['recharged_time'])}
                            {/if}
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="small text-danger text-uppercase text-normal">{Lang::T('Expires On')}</td>
                        <td class="small mb15 text-danger">
                            {if $_bill['time'] ne ''}
                                {Lang::dateAndTimeFormat($_bill['expiration'],$_bill['time'])}
                            {/if}&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td class="small text-success text-uppercase text-normal">{Lang::T('Type')}</td>
                        <td class="small mb15 text-success">
                            <b>{if $_bill['prepaid'] eq yes}Prepaid{else}Postpaid{/if}</b>
                            {$_bill['plan_type']}
                        </td>
                    </tr>
                    {if $_bill['type'] == 'VPN' && $_bill['routers'] == $vpn['routers']}
                        <tr>
                            <td class="small text-success text-uppercase text-normal">{Lang::T('Public IP')}</td>
                            <td class="small mb15">{$vpn['public_ip']} / {$vpn['port_name']}</td>
                        </tr>
                        <tr>
                            <td class="small text-success text-uppercase text-normal">{Lang::T('Private IP')}</td>
                            <td class="small mb15">{$_user['pppoe_ip']}</td>
                        </tr>
                        {foreach $cf as $tcf}
                            <tr>
                                {if $tcf['field_name'] == 'Winbox' or $tcf['field_name'] == 'Api' or $tcf['field_name'] == 'Web'}
                                    <td class="small text-info text-uppercase text-normal">{$tcf['field_name']} - Port</td>
                                    <td class="small mb15"><a href="http://{$vpn['public_ip']}:{$tcf['field_value']}"
                                            target="_blank">{$tcf['field_value']}</a></td>
                                </tr>
                            {/if}
                        {/foreach}
                    {/if}

                    {if $nux_ip neq ''}
                        <tr>
                            <td class="small text-primary text-uppercase text-normal">{Lang::T('Current IP')}</td>
                            <td class="small mb15">{$nux_ip}</td>
                        </tr>
                    {/if}
                    {if $nux_mac neq ''}
                        <tr>
                            <td class="small text-primary text-uppercase text-normal">{Lang::T('Current MAC')}</td>
                            <td class="small mb15">{$nux_mac}</td>
                        </tr>
                    {/if}
                    {if $_bill['type'] == 'Hotspot' && $_bill['status'] == 'on' && $_bill['routers'] != 'radius' && $_c['hs_auth_method'] != 'hchap'}
                        <tr>
                            <td class="small text-primary text-uppercase text-normal">{Lang::T('Login Status')}</td>
                            <td class="small mb15" id="login_status_{$_bill['id']}">
                                <img src="{$app_url}/ui/ui/images/loading.gif">
                            </td>
                        </tr>
                    {/if}
                    {if $_bill['type'] == 'Hotspot' && $_bill['status'] == 'on' && $_c['hs_auth_method'] == 'hchap'}
                        <tr>
                            <td class="small text-primary text-uppercase text-normal">{Lang::T('Login Status')}</td>
                            <td class="small mb15">
                                {if $logged == '1'}
                                    <a href="http://{$hostname}/status" class="btn btn-success btn-xs btn-block">
                                        {Lang::T('You are Online, Check Status')}</a>
                                {else}
                                    <a href="{Text::url('home&mikrotik=login')}"
                                        onclick="return ask(this, '{Lang::T('Connect to Internet')}')"
                                        class="btn btn-danger btn-xs btn-block">{Lang::T('Not Online, Login now?')}</a>
                                {/if}
                            </td>
                        </tr>
                    {/if}
                    <tr>
                        <td class="small text-primary text-uppercase text-normal">
                            {if $_bill['status'] == 'on' && $_bill['prepaid'] != 'YES'}
                                <a href="{Text::url('home&deactivate=', $_bill['id'])}"
                                    onclick="return ask(this, '{Lang::T('Deactivate')}?')" class="btn btn-danger btn-xs"><i
                                        class="glyphicon glyphicon-trash"></i></a>
                            {/if}
                            {if $_bill['status'] != 'on'}
                                <a href="{Text::url('home&forget=', $_bill['id'], '&stoken=', App::getToken())}"
                                    onclick="return ask(this, '{Lang::T('Hide this plan')}?')" class="btn btn-secondary btn-xs" style="background-color: #999; color: white;"><i
                                        class="glyphicon glyphicon-eye-close"></i> {Lang::T('Forget')}</a>
                            {/if}
                        </td>
                        <td class="small row">
                            {if $_bill['status'] != 'on' && $_bill['prepaid'] != 'yes' && $_c['extend_expired']}
                                <a class="btn btn-warning text-black btn-sm"
                                    href="{Text::url('home&extend=', $_bill['id'], '&stoken=', App::getToken())}"
                                    onclick="return ask(this, '{Text::toHex($_c['extend_confirmation'])}')">{Lang::T('Extend')}</a>
                            {/if}
                            <a class="btn btn-primary pull-right btn-sm"
                                href="{Text::url('home&recharge=', $_bill['id'], '&stoken=', App::getToken())}"
                                onclick="return ask(this, '{Lang::T('Recharge')}?')">{Lang::T('Recharge')}</a>
                            <a class="btn btn-info pull-right btn-sm" style="margin-right: 5px;" onclick="requestRecharge('{$_bill['id']}', '{$_bill['namebp']|escape:'html'}')">
                                <i class="glyphicon glyphicon-plus"></i> {Lang::T('Request')}
                            </a>
                            <a class="btn btn-warning text-black pull-right btn-sm"
                                href="{Text::url('home&sync=', $_bill['id'], '&stoken=', App::getToken())}"
                                onclick="return ask(this, '{Lang::T('Sync account if you failed login to internet')}?')"
                                data-toggle="tooltip" data-placement="top"
                                title="{Lang::T('Sync account if you failed login to internet')}"><span
                                    class="glyphicon glyphicon-refresh" aria-hidden="true"></span> {Lang::T('Sync')}</a>
                        </td>
                    </tr>
                </table>
            </div>
            &nbsp;&nbsp;
        {/foreach}
    </div>
    {foreach $_bills as $_bill}
        {if $_bill['type'] == 'Hotspot' && $_bill['status'] == 'on' && $_c['hs_auth_method'] != 'hchap'}
            <script>
                setTimeout(() => {
                    $.ajax({
                        url: "{Text::url('autoload_user/isLogin/')}{$_bill['id']}",
                        cache: false,
                        success: function(msg) {
                            $("#login_status_{$_bill['id']}").html(msg);
                        }
                    });
                }, 2000);
            </script>
        {/if}
    {/foreach}

    <!-- Recharge Request Modal and JavaScript -->
    <script>
    // Global function to handle recharge requests
    function requestRecharge(billId, planName) {
        console.log('requestRecharge called with billId:', billId, 'planName:', planName);
        const modal = document.getElementById('rechargeRequestModal') || createRechargeModal();
        document.getElementById('recharge_bill_id').value = billId;
        document.getElementById('recharge_plan_name').textContent = planName;
        if (typeof jQuery !== 'undefined') {
            jQuery(modal).modal('show');
        } else {
            modal.style.display = 'block';
        }
    }

    function createRechargeModal() {
        const modal = document.createElement('div');
        modal.id = 'rechargeRequestModal';
        modal.className = 'modal fade';
        modal.innerHTML = `
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Request Plan Recharge</h4>
                    </div>
                    <div class="modal-body">
                        <p>You are requesting a recharge for: <strong id="recharge_plan_name"></strong></p>
                        <form id="rechargeRequestForm">
                            <input type="hidden" id="recharge_bill_id" name="bill_id">
                            <div class="form-group">
                                <label>Request Message (Optional)</label>
                                <textarea class="form-control" name="message" rows="3" placeholder="Add any special request or note..."></textarea>
                            </div>
                            <div class="form-group">
                                <button type="submit" class="btn btn-primary btn-block">Send Request to Admin</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
        
        // Handle form submission
        jQuery(document).on('submit', '#rechargeRequestForm', function(e) {
            e.preventDefault();
            const billId = document.getElementById('recharge_bill_id').value;
            const message = jQuery('[name="message"]').val();
            
            console.log('Submitting recharge request with billId:', billId, 'message:', message);
            
            jQuery.post('{Text::url('autoload_user/request_recharge')}', {
                bill_id: billId,
                message: message
            }, function(resp) {
                console.log('Response:', resp);
                if (resp.status === 'success') {
                    alert('Recharge request sent successfully!');
                    jQuery('#rechargeRequestModal').modal('hide');
                    jQuery('[name="message"]').val('');
                    setTimeout(() => location.reload(), 1500);
                } else {
                    alert('Error: ' + (resp.message || 'Failed to send request'));
                }
            }, 'json').fail(function(jqXHR, textStatus, errorThrown) {
                console.error('AJAX Request failed:', textStatus, errorThrown);
                console.error('Full response:', jqXHR.responseText);
                alert('Error sending request. Check browser console for details.');
            });
        });
        
        return modal;
    }
    </script>
{/if}