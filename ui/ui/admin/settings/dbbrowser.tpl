{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">{Lang::T('Database Browser')}</div>
            <div class="panel-body">
                <form method="post" action="{Text::url('settings/dbbrowser')}" id="dbbrowserForm">
                    <div class="form-group">
                        <label>{Lang::T('Select Table')}</label>
                        <select class="form-control" name="table" required>
                            <option value="">{Lang::T('Choose Table')}</option>
                            {foreach $tables as $tbl}
                                <option value="{$tbl.name}" {if $selected_table eq $tbl.name}selected{/if}>
                                    {$tbl.name} ({$tbl.rows} rows)
                                </option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="form-group">
                        <label>{Lang::T('Search')}</label>
                        <input type="text" name="search" class="form-control" value="{$search_term|escape}" placeholder="{Lang::T('Search Table')}" />
                    </div>
                    <div class="form-row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>{Lang::T('Per Page')}</label>
                                <select class="form-control" name="per_page">
                                    {foreach from=$per_page_options key=key item=label}
                                        <option value="{$key}" {if $per_page_value eq $key}selected{/if}>{$label}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>{Lang::T('Username')}</label>
                                <input type="text" name="db_username" class="form-control" value="{$_admin.username}" required>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>{Lang::T('Password')}</label>
                        <input type="password" name="db_password" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">{Lang::T('Show Table Data')}</button>
                </form>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">{Lang::T('Available Tables')}</div>
            <div class="table-responsive">
                <table class="table table-condensed table-striped">
                    <thead>
                        <tr>
                            <th>{Lang::T('Table Name')}</th>
                            <th>{Lang::T('Rows')}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $tables as $tbl}
                            <tr>
                                <td>{$tbl.name}</td>
                                <td>{$tbl.rows}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        {if $browser_error}
            <div class="alert alert-danger">{$browser_error}</div>
        {/if}
        {if $table_preview}
            <div class="panel panel-info">
                <div class="panel-heading">
                    Preview: {$table_preview.name} ({$table_preview.total} rows{if $table_preview.per_page}, showing {$table_preview.start} - {$table_preview.end}{else}{if $table_preview.total} (all rows){/if}{/if})
                </div>
                <div class="table-responsive" style="max-height:520px; overflow:auto;">
                    <table class="table table-bordered table-hover table-condensed">
                        <thead>
                            <tr>
                                {foreach $table_preview.columns as $column}
                                    <th>{$column}</th>
                                {/foreach}
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $table_preview.rows as $row}
                                <tr>
                                    {foreach $table_preview.columns as $column}
                                        <td>{if isset($row[$column])}{$row[$column]|escape}{else}&nbsp;{/if}</td>
                                    {/foreach}
                                </tr>
                            {/foreach}
                            {if !$table_preview.rows}
                                <tr>
                                    <td colspan="{count($table_preview.columns)}" class="text-center">
                                        {Lang::T('No records found.')}
                                    </td>
                                </tr>
                            {/if}
                        </tbody>
                    </table>
                </div>
                <div class="panel-footer clearfix">
                    {if isset($table_preview.search) && $table_preview.search != ''}
                        <div class="text-muted small" style="margin-bottom:6px;">{Lang::T('Filtered by')} "{$table_preview.search|escape}"</div>
                    {/if}
                    {if $table_preview.per_page}
                        <div class="pull-left text-muted small" style="margin-top:4px;">
                            {Lang::T('Showing')} {$table_preview.start} - {$table_preview.end} / {$table_preview.total}
                        </div>
                    {/if}
                    {if $table_preview.per_page && $table_preview.total_pages > 1}
                        <div class="btn-group pull-right" role="group" aria-label="Pagination">
                            <button type="submit" form="dbbrowserForm" name="page" value="{$table_preview.page-1}" class="btn btn-default btn-xs" {if $table_preview.page <= 1}disabled{/if}>{Lang::T('Prev')}</button>
                            <span class="btn btn-default btn-xs" style="pointer-events:none;">{Lang::T('Page')} {$table_preview.page} / {$table_preview.total_pages}</span>
                            <button type="submit" form="dbbrowserForm" name="page" value="{$table_preview.page+1}" class="btn btn-default btn-xs" {if $table_preview.page >= $table_preview.total_pages}disabled{/if}>{Lang::T('Next')}</button>
                        </div>
                    {/if}
                </div>
            </div>
        {else}
            <div class="alert alert-info">
                {Lang::T('Re-enter your admin username and password, then choose a table to preview its latest rows.')}
            </div>
        {/if}
    </div>
</div>

{include file="sections/footer.tpl"}
