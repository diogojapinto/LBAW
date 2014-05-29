{include file='common/header.tpl'}

<div class="container">
    <ul>
        {foreach from=$notifications['interactions'] key=interactionno item=interaction}
            <li><a href="#">
                    Nova oferta no produto {$interaction.name} <br/>
                    Novo Preço: {$interaction.amount} <b class="glyphicon glyphicon-euro"></b>
                </a></li>
        {/foreach}
        <li class="divider"></li>
        {foreach from=$notifications['privateMessages'] key=messageno item=message}
            <li><a href="#">
                    Mensagem {$message@iteration} <br/>
                    Assunto: {$message.subject}
                </a></li>
        {/foreach}
        <li class="divider"></li>
        <div style="text-align: center;"><b>
                <a href="{$BASE_URL}pages/users/shownotifications.php">Ver todas</a>
            </b></div>
    </ul>
</div>

{include file='common/footer.tpl'}