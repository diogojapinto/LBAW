{include file='common/header.tpl'}

<div class="container">

    <div class="row">
        <h1>Registo de Empresa</h1><br/>

        <form class="form-horizontal" role="form" method="post" action="{$BASE_URL}actions/users/newseller.php">
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
                <label for="inputCompName" class="col-sm-2 control-label">Nome da empresa</label>

                <div class="col-sm-5">
                    <input type="text" class="form-control" id="inputCompName" placeholder="Nome da empresa"
                           value="{$FORM_VALUES.companyname}" name="companyname" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputAddress3" class="col-sm-2 control-label">Morada</label>

                <div class="col-sm-5">
                    <input type="text" class="form-control" id="inputAddress3" placeholder="Morada"
                           value="{$FORM_VALUES.address}" name="address" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCity3" class="col-sm-2 control-label">Cidade</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCity3" placeholder="Cidade"
                           value="{$FORM_VALUES.city}" name="city" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCity4" class="col-sm-2 control-label">Código Postal</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCity4" placeholder="4400-404"
                           value="{$FORM_VALUES.postalcode}" name="postalcode" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCountry3" class="col-sm-2 control-label">País</label>

                <div class="col-sm-2">
                    <select name="country" id="inputCountry3" class="form-control">
                        <option value="-1"></option>
                        {foreach $countries as $country}
                            <option value="{$country.idcountry}">{$country.name}</option>
                        {/foreach}
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCellphone3" class="col-sm-2 control-label">Contacto telefónico</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCellphone3" placeholder="+351 22578467"
                           value="{$FORM_VALUES.cellphone}" name="cellphone" required>
                </div>
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