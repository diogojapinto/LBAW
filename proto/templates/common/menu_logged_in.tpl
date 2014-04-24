 <div class="col-md-2 navbar-right">
                    <div class="navbar-collapse collapse">
                        <ul class="list-inline" style="margin:0px;list-style-type:none">
                            <li>
                                <a class="dropdown-toggle" data-toggle="dropdown">
                                    <img class="img-responsive highlight_icon" alt="Negotiation Alerts" heigth="30px" width="30px" src="{$BASE_URL}images/icon_set/negotiation.png" />
                                </a>
                                <ul class="dropdown-menu" role="menu">
                                    {foreach from=$notifications['interactions'] key=interactionno item=interaction}
                                        <li><a href="#">Nova oferta no produto {$interaction.name}</a></li>
                                        <li><a href="#">Novo Preço: {$interaction.amount} <b class="glyphicon glyphicon-euro"></b></a></li>
                                    {/foreach}
                                    <li class="divider"></li>
                                    {foreach from=$notifications['privateMessages'] key=messageno item=message}
                                        <li><a href="#">Mensagem {$message@iteration}</a></li>
                                        <li><a href="#">Assunto: {$message.subject}</a></li>
                                    {/foreach}
                                </ul>
                            </li>
                            <li>
                                <a class="dropdown-toggle" data-toggle="dropdown">
                                    <img class="img-responsive highlight_icon" alt="Negotiation Alerts" heigth="30px" width="30px" src="{$BASE_URL}images/icon_set/Users-User-icon.png" />
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