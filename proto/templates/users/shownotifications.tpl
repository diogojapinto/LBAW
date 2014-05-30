{include file='common/header.tpl'}

<div class="container">
    <table id="privateMessagesTable" class="table table-striped">
        <thead><tr>
            <th>Tipo</th>
            <th>Assunto</th>
            <th>Data</th>
        </tr></thead>
        {foreach $fullnotifications as $notification}
            <tr class="{$notification.type}">
                {if $notification['type'] == 'interaction'}
                    <td style="display: none;">{$notification.iddeal}</td>
                {else}
                    <td style="display: none;">{$notification.idpm}</td>
                {/if}
                <td>
                    {if $notification.state == 'Read'}
                        <span class="glyphicon glyphicon-ok-circle"></span>
                    {else}
                        <span class="glyphicon glyphicon-remove-circle"></span>
                    {/if}
                    {if $notification['type'] == 'interaction'}
                        Nova oferta
                    {else}
                        Mensagem privada
                    {/if}
                </td>

                <td>
                    {if $notification['type'] == 'interaction'}
                        {$notification.amount} <b class="glyphicon glyphicon-euro"></b> no produto {$notification.name} <br/>
                    {else}
                        {$notification.subject}
                    {/if}
                </td>
                <td>
                    {$notification.date}
                </td>
            </tr>
        {/foreach}
    </table>
</div>

{include file='common/footer.tpl'}
<script src="{$BASE_URL}javascript/privatemessages.js"></script>