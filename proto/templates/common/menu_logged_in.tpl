<div class="col-md-3 navbar-right">
    <div id="sessionTab">
        <ul class="list-inline" style="display:inline-block; margin:0px;list-style-type:none">
            <li>
                <a class="dropdown-toggle" data-toggle="dropdown" id="sessionLink">
                    <span class="glyphicon glyphicon-envelope"></span> Notificações{if $notifications['count'] != 0}
                    <span class="badge">{$notifications['count']}</span>{/if}
                </a>
                <ul id="notificationsHeaderList" class="dropdown-menu" role="menu">
                    {foreach from=$notifications['interactions'] key=interactionno item=interaction}
                        <li style="padding: 3px 20px 3px 20px">
                            Nova oferta no produto {$interaction.name} por <a
                                    href="{$BASE_URL}pages/users/sellerPage?seller={$interaction.username}">{$interaction.username}</a>

                            <b>Valor:</b> {$interaction.amount}<span class="glyphicon glyphicon-euro"></span>&nbsp;&nbsp;&nbsp;
                        </li>
                        <hr>
                    {/foreach}
                    <li id="firstDivider" class="divider"></li>
                    {foreach from=$notifications['privateMessages'] key=messageno item=message}
                        <li><a href="#">
                                Mensagem {$message@iteration} <br/>
                                Assunto: {$message.subject}
                            </a></li>
                    {/foreach}
                    <li class="divider"></li>
                    <div id="showAllNotifications" style="text-align: center;"><b>
                            <a href="{$BASE_URL}pages/users/shownotifications.php">Ver todas</a>
                        </b></div>
                </ul>
            </li>
            <li>
                <a class="dropdown-toggle" data-toggle="dropdown">
                    <span class="glyphicon glyphicon-user"></span> Perfil
                </a>
                <ul class="dropdown-menu" role="menu">
                    <li><a href="{$BASE_URL}pages/users/showuser.php">Ver Dados</a></li>
                    <li><a href="{$BASE_URL}pages/users/edituser.php">Configurar Conta</a></li>
                    <li class="divider"></li>
                    <li><a href="{$BASE_URL}actions/users/logout.php">Terminar Sessão</a></li>
                </ul>
            </li>
        </ul>
    </div>
</div>

<input type="hidden" name="baseUrl" value="{$BASE_URL}"/>
<script id="interaction-template" type="text/x-handlebars-template">
    {literal}
        <li style="padding: 3px 20px 3px 20px">
            Nova oferta no produto {{name}} por <a
                    href="{$BASE_URL}pages/users/sellerPage?seller={{username}}">{{username}}</a>

            <b>Valor:</b> {{amount}}<span class="glyphicon glyphicon-euro"></span>&nbsp;&nbsp;&nbsp;
        </li>
        <hr>
    {/literal}
</script>
<script id="privateMessage-template" type="text/x-handlebars-template">
    {literal}
        <li><a href="#">
                Mensagem {{number}} <br/>
                Assunto: {{subject}}
            </a></li>
    {/literal}
</script>
<script src="{$BASE_URL}javascript/notificationsHeader.js"></script>