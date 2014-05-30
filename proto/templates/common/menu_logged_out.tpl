<div class="col-md-2 navbar-right">
    <div class="navbar-collapse collapse" id="sessionTab">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown" id="sessionLink">
            <span class="glyphicon glyphicon-user"></span> Sessão
        </a>
        <ul class="dropdown-menu" role="menu" style="padding: 15px;">
            <form action="{$BASE_URL}actions/users/login.php" method="post" accept-charset="UTF-8">
                <input placeholder="Nome de utilizador" class="form-control" style="margin-bottom: 3px;" type="text"
                       name="username"
                       size="30"/>
                <input placeholder="Palavra-passe" class="form-control" style="margin-bottom: 8px;" type="password"
                       name="password"
                       size="30"/>

                <input class="btn btn-primary" style="clear: left; width: 100%; height: 32px; font-size: 13px;"
                       type="submit" name="commit" value="Iniciar Sess&atilde;o"/>
            </form>
            <hr>
            <a href="{$BASE_URL}pages/users/registerseller.php" class="btn btn-success form-control"
               style="margin-top: 3px;">Registar Vendedor</a>
            <a href="{$BASE_URL}pages/users/registerbuyer.php" class="btn btn-success form-control"
               style="margin-top: 3px;">Registar Comprador</a>
        </ul>
    </div>
</div>