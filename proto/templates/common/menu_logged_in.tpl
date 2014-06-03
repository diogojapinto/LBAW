<script>
    $(document).ready(function() {
        $("#showAllNotifications").click(function() {
            window.location.href="{$BASE_URL}pages/users/shownotifications.php";
        });
    });
</script>

<div class="col-md-3 navbar-right">
    <div class="navbar-collapse collapse" id="sessionTab">
        <ul class="list-inline" style="display:inline-block; margin:0px;list-style-type:none">
            <li>
                <a class="dropdown-toggle" data-toggle="dropdown" id="sessionLink">
                    <span class="glyphicon glyphicon-envelope"></span> Notificações
                </a>
                <ul class="dropdown-menu" role="menu">
                    {foreach from=$notifications['interactions'] key=interactionno item=interaction}
                        <li style="padding: 3px 20px 3px 20px">
                            Nova oferta no produto {$interaction.name}<br/>

                            <b>Valor:</b> {$interaction.amount}<span class="glyphicon glyphicon-euro"></span>&nbsp;&nbsp;&nbsp;
                            <a href="#" style="display: inline;background-color: #5cb85c"><span style="color: #398439" class="glyphicon glyphicon-ok"></span></a>
                            <a href="#" style="display: inline;background-color: #D16666"><span style="color: #B20000" class="glyphicon glyphicon-remove"></span></a>
                        </li>
                    {/foreach}
                    <li class="divider"></li>
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
                <a class="dropdown-toggle" data-toggle="dropdown" id="sessionLink">
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