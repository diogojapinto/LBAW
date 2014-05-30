{include file='common/header.tpl'}

<div class="container">

    <div class="row">
        <h1>Registo de utilizador</h1><br/>

        <form class="form-horizontal" role="form" method="post" action="{$BASE_URL}actions/users/newbuyer.php">
            {foreach $FORM_VALUES.errors as $error}
                <div class="alert alert-danger">{$error}</div>
            {/foreach}
            <div class="form-group">
                <label for="inputUsername3" class="col-sm-2 control-label">Nome de utilizador</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.username}" type="text" class="form-control" id="inputUsername3"
                           placeholder="Nome de utilizador" name="username" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputEmail3" class="col-sm-2 control-label">E-mail</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.email}" type="email" class="form-control" id="inputEmail3"
                           placeholder="Email" name="email" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputPassword3" class="col-sm-2 control-label">Password</label>

                <div class="col-sm-2">
                    <input type="password" class="form-control" id="inputPassword3" placeholder="Password"
                           name="password1" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputPassword3" class="col-sm-2 control-label">Confirmar password</label>

                <div class="col-sm-2">
                    <input type="password" class="form-control" id="inputPassword3" placeholder="Confirmar password"
                           name="password2" required>
                </div>
            </div>
            <div class="form-group">
            </div>
            <div class="form-group">
            </div>
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <button type="submit" class="btn btn-primary">Registar</button>
                </div>
            </div>
        </form>

    </div>

</div>


{include file='common/footer.tpl'}