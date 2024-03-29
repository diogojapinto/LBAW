﻿<div class="container">

    <div class="row">
        <h1>Modificar dados de utilizador</h1><br/>

        <form class="form-horizontal" role="form" method="post" action="{$BASE_URL}actions/users/editbuyer.php" onsubmit="return validateEditBuyerForm();">
            {foreach $FORM_VALUES.errors as $error}
                <div class="alert alert-danger">{$error}</div>
            {/foreach}
            <div class="form-group">
                <label for="inputEmail3" class="col-sm-2 control-label">E-mail</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.email}" type="email" class="form-control" id="inputEmail3"
                           placeholder="Email" name="email">
                </div>
            </div>
            <div class="form-group">
                <label for="inputPassword31" class="col-sm-2 control-label">Password</label>

                <div class="col-sm-2">
                    <input type="password" class="form-control" id="inputPassword31" placeholder="Password"
                           name="password1">
                </div>
            </div>
            <div class="form-group">
                <label for="inputPassword32" class="col-sm-2 control-label">Confirmar password</label>

                <div class="col-sm-2">
                    <input type="password" class="form-control" id="inputPassword32" placeholder="Confirmar password"
                           name="password2">
                </div>
            </div>
            <div class="form-group">
                <label for="inputPassword4" class="col-sm-2 control-label">Password antiga</label>

                <div class="col-sm-2">
                    <input type="password" class="form-control" id="inputPassword4" placeholder="Password antiga"
                           name="oldpassword" required>
                </div>
                <div class="col-sm-2">
                    <button type="button" class="btn btn-danger" data-toggle="tooltip" data-placement="right" title="Obrigatório inserir"><span class="glyphicon glyphicon-info-sign"></span>
                    </button>
                </div>
            </div>
            <div class="form-group">
            </div>
            <div class="form-group">
            </div>
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <button type="submit" class="btn btn-primary">Submeter alterações</button>
                </div>
            </div>
        </form>

    </div>

</div>