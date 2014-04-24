<div class="col-md-2 navbar-right">
    <div class="navbar-collapse collapse">
        <ul class="list-inline" style="margin:0px;list-style-type:none">
            <li>
                {foreach $ERROR_MESSAGES as $error}
                    <div class="alert alert-danger" style="padding: 1px 5px 1px 5px; margin:auto;">{$error}</div>
                {/foreach}
            </li>
            <li>
                <a class="dropdown-toggle" data-toggle="dropdown">
                    <img class="img-responsive highlight_icon" alt="Negotiation Alerts"
                         heigth="30px" width="30px" src="{$BASE_URL}images/icon_set/Users-User-icon.png"/>
                </a>
                <ul class="dropdown-menu" role="menu" style="padding: 15px;">
                    <form action="{$BASE_URL}actions/users/login.php" method="post" accept-charset="UTF-8">
                        <input placeholder="Nome de utilizador" style="margin-bottom: 15px;" type="text" name="username"
                               size="30"/>
                        <input placeholder="Palavra-passe" style="margin-bottom: 15px;" type="password" name="password"
                               size="30"/>

                        <input class="btn btn-primary" style="clear: left; width: 100%; height: 32px; font-size: 13px;"
                               type="submit" name="commit" value="Sign In"/>
                    </form>
                    <a href="{$BASE_URL}pages/users/registerseller.php" class="btn btn-success"
                       style="margin: 3px; float: right;">Registar Vendedor</a>
                    <a href="{$BASE_URL}pages/users/registerbuyer.php" class="btn btn-success"
                       style="margin: 3px; float: right;">Registar Comprador</a>
                </ul>
            </li>
        </ul>
    </div>
</div>