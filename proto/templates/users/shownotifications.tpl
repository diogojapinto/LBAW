{include file='common/header.tpl'}

{$notificationsByPage = 3}

<div class="container">
    <table id="privateMessagesTable" class="table table-hover">
        <thead>
        <tr>
            <th></th>
            <th>Assunto</th>
            <th></th>
            <th>Data</th>
        </tr>
        </thead>
        {foreach from=$fullnotifications item=notification name=notifications}
            <tr valign="middle" class="{$notification.type}
                    {if $notification.state == 'Read'}
                        bg-success
                    {else}
                        bg-danger
                    {/if}"

                    {if $smarty.foreach.notifications.iteration > $notificationsByPage}
                        style="display: none"
                    {/if}
                    >

                {if $notification['type'] == 'interaction'}
                    <td style="display: none;">{$notification.iddeal}</td>
                {else}
                    <td style="display: none;">{$notification.idpm}</td>
                {/if}
                <td style="vertical-align: middle">
                    {if $notification.state == 'Read'}
                        <span class="glyphicon glyphicon-ok-circle"></span>
                    {else}
                        <span class="glyphicon glyphicon-remove-circle"></span>
                    {/if}
                    {if $notification['type'] == 'interaction'}
                        <span>Nova oferta</span>
                    {else}
                        Mensagem privada
                    {/if}
                </td>

                <td style="vertical-align: middle">
                    {if $notification['type'] == 'interaction'}
                        <b>{$notification.amount}</b>
                        <span class="glyphicon glyphicon-euro"></span>
                        no produto {$notification.name}
                    {else}
                        <span style="-webkit-transform: rotate(-90deg); transform: rotate(-90deg); -ms-transform: rotate(-90deg)" class="caret"></span>
                        {$notification.subject}
                    {/if}
                </td>

                <td>
                    {if $notification['type'] == 'interaction'}
                        <a class="btn btn-success"  href="#"><span class="glyphicon glyphicon-ok"></span></a>
                        <a class="btn btn-danger"  href="#"><span class="glyphicon glyphicon-remove"></span></a>
                    {/if}
                </td>

                <td style="vertical-align: middle">
                    {$notification.date}
                </td>
            </tr>
        {/foreach}
    </table>

    <div id="pagination" style="text-align: center">
        <ul style="display: inline-block" class="pagination">
            <li><a href="#">&laquo;</a></li>
            <li class="active"><a href="#">1</a></li>
            {for $i=2 to $fullnotifications|@count/$notificationsByPage}
                <li><a href="#">{$i}</a></li>
            {/for}
            <li><a href="#">&raquo;</a></li>
        </ul>
    </div>
</div>

{include file='common/footer.tpl'}

<script src="{$BASE_URL}javascript/handlebars-v1.3.0.js"></script>
<input type="hidden" name="baseUrl" value="{$BASE_URL}" />
<script id="privatemessage-template" type="text/x-handlebars-template">
    {literal}
        <tr>
            <td class='privateMessageContent' colspan='4'>{{content}}</td>
        </tr>
    {/literal}
</script>

<script>
    var notificationsByPage = {$notificationsByPage};
    var numberOfPages = Math.ceil({$fullnotifications|@count/$notificationsByPage});
</script>
<script src="{$BASE_URL}javascript/privateMessages.js">
</script>