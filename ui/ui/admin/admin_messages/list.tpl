{include file="sections/header.tpl"}

<div class="row">
    <div class="col-sm-12">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">
                <h4>{Lang::T('Admin Messages')} 
                    {if $unread_count > 0}
                        <span class="badge badge-danger" style="margin-left: 10px;">{$unread_count} {Lang::T('Unread')}</span>
                    {/if}
                </h4>
                <div class="btn-group pull-right">
                    <a href="{Text::url('admin_messages/list')}&filter=unread" 
                       class="btn btn-{if $filter eq 'unread'}primary{else}default{/if} btn-xs">
                        <i class="glyphicon glyphicon-envelope"></i> {Lang::T('Unread')}
                    </a>
                    <a href="{Text::url('admin_messages/list')}&filter=all" 
                       class="btn btn-{if $filter eq 'all'}primary{else}default{/if} btn-xs">
                        <i class="glyphicon glyphicon-th-list"></i> {Lang::T('All')}
                    </a>
                    {if $unread_count > 0}
                        <a href="{Text::url('admin_messages/mark_all_read')}" 
                           class="btn btn-success btn-xs"
                           onclick="return confirm('{Lang::T('Mark all messages as read')}?')">
                            <i class="glyphicon glyphicon-ok"></i> {Lang::T('Mark All Read')}
                        </a>
                    {/if}
                </div>
            </div>
            <div class="panel-body">
                {if Lang::arrayCount($messages) == 0}
                    <div class="alert alert-info">
                        <i class="glyphicon glyphicon-info-sign"></i> 
                        {if $filter eq 'unread'}
                            {Lang::T('No unread messages')}
                        {else}
                            {Lang::T('No messages')}
                        {/if}
                    </div>
                {else}
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped table-hover">
                            <thead>
                                <tr>
                                    <th>{Lang::T('Date')}</th>
                                    <th>{Lang::T('Type')}</th>
                                    <th>{Lang::T('Title')}</th>
                                    <th>{Lang::T('Status')}</th>
                                    <th style="width: 180px;">{Lang::T('Action')}</th>
                                </tr>
                            </thead>
                            <tbody>
                                {foreach $messages as $msg}
                                    <tr class="{if $msg['status'] == 'unread'}info{/if}">
                                        <td>
                                            {Lang::dateTimeFormat($msg['created_date'])}
                                        </td>
                                        <td>
                                            {if $msg['type'] == 'guest_message'}
                                                <span class="label label-warning">
                                                    <i class="glyphicon glyphicon-comment"></i> {Lang::T('Guest Message')}
                                                </span>
                                            {elseif $msg['type'] == 'recharge_request'}
                                                <span class="label label-info">
                                                    <i class="glyphicon glyphicon-refresh"></i> {Lang::T('Recharge Request')}
                                                </span>
                                            {else}
                                                <span class="label label-default">
                                                    <i class="glyphicon glyphicon-bell"></i> {Lang::T('Notification')}
                                                </span>
                                            {/if}
                                        </td>
                                        <td>
                                            <strong>{$msg['title']}</strong>
                                            {if $msg['status'] == 'unread'}
                                                <span class="label label-danger" style="margin-left: 5px;">NEW</span>
                                            {/if}
                                        </td>
                                        <td>
                                            {if $msg['status'] == 'unread'}
                                                <span class="label label-danger">{Lang::T('Unread')}</span>
                                            {else}
                                                <span class="label label-success">{Lang::T('Read')}</span>
                                            {/if}
                                        </td>
                                        <td>
                                            <a href="{Text::url('admin_messages/view/', $msg['id'])}" 
                                               class="btn btn-info btn-xs">
                                                <i class="glyphicon glyphicon-eye-open"></i> {Lang::T('View')}
                                            </a>
                                            {if $msg['status'] == 'unread'}
                                                <a href="{Text::url('admin_messages/mark_read/', $msg['id'])}" 
                                                   class="btn btn-success btn-xs">
                                                    <i class="glyphicon glyphicon-ok"></i> {Lang::T('Mark Read')}
                                                </a>
                                            {/if}
                                            <a href="{Text::url('admin_messages/delete/', $msg['id'])}" 
                                               class="btn btn-danger btn-xs"
                                               onclick="return confirm('{Lang::T('Delete this message')}?')">
                                                <i class="glyphicon glyphicon-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                {/foreach}
                            </tbody>
                        </table>
                    </div>
                    {$paginator['contents']}
                {/if}
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
