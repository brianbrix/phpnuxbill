{include file="customer/header.tpl"}
<!-- user-dashboard -->

<style>
    /* Mobile-friendly dashboard styles */
    @media (max-width: 768px) {
        .row {
            margin-left: -5px;
            margin-right: -5px;
        }
        
        .row > div {
            padding-left: 5px;
            padding-right: 5px;
        }
        
        .box {
            margin-bottom: 10px;
        }
        
        .box-header {
            padding: 10px 15px;
        }
        
        .box-body {
            padding: 15px 10px;
        }
        
        /* Improve readability on small screens */
        h1, h2, h3 {
            font-size: 1.2em !important;
        }
        
        .table {
            font-size: 12px;
        }
        
        .table th, .table td {
            padding: 6px 8px;
        }
        
        /* Better button layout on mobile */
        .btn {
            padding: 8px 12px;
            font-size: 12px;
        }
        
        .btn-block {
            margin-bottom: 5px;
        }
    }
    
    @media (max-width: 480px) {
        .row {
            margin-left: -3px;
            margin-right: -3px;
        }
        
        .row > div {
            padding-left: 3px;
            padding-right: 3px;
        }
        
        .table {
            font-size: 11px;
        }
        
        .table th, .table td {
            padding: 4px 5px;
        }
    }
</style>

{function showWidget pos=0}
    {foreach $widgets as $w}
        {if $w['position'] == $pos}
            {$w['content']}
        {/if}
    {/foreach}
{/function}


{assign rows explode(".", $_c['dashboard_Customer'])}
{assign pos 1}
{foreach $rows as $cols}
    {if $cols == 12}
        <div class="row">
            <div class="col-md-12 col-sm-12 col-xs-12">
                {showWidget widgets=$widgets pos=$pos}
            </div>
        </div>
        {assign pos value=$pos+1}
    {else}
        {assign colss explode(",", $cols)}
        <div class="row">
            {foreach $colss as $c}
                <div class="col-md-{$c} col-sm-6 col-xs-12">
                    {showWidget widgets=$widgets pos=$pos}
                </div>
                {assign pos value=$pos+1}
            {/foreach}
        </div>
    {/if}
{/foreach}


{if isset($hostname) && $hchap == 'true' && $_c['hs_auth_method'] == 'hchap'}
    <script type="text/javascript" src="/ui/ui/scripts/md5.js"></script>
    <script type="text/javascript">
        var hostname = "http://{$hostname}/login";
        var user = "{$_user['username']}";
        var pass = "{$_user['password']}";
        var dst = "{$apkurl}";
        var authdly = "2";
        var key = hexMD5('{$key1}' + pass + '{$key2}');
        var auth = hostname + '?username=' + user + '&dst=' + dst + '&password=' + key;
        document.write('<meta http-equiv="refresh" target="_blank" content="' + authdly + '; url=' + auth + '">');
    </script>
{/if}
{include file="customer/footer.tpl"}