<div class="container">

    <div class="row">
        <h1>Modificar dados de utilizador</h1><br/>

        <form class="form-horizontal" role="form" method="post" action="{$BASE_URL}actions/users/editseller.php" onsubmit="return validateEditSellerForm();">
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
                <label for="inputPassword3" class="col-sm-2 control-label">Password</label>

                <div class="col-sm-2">
                    <input type="password" class="form-control" id="inputPassword31" placeholder="Password"
                           name="password1">
                </div>
            </div>
            <div class="form-group">
                <label for="inputPassword3" class="col-sm-2 control-label">Confirmar password</label>

                <div class="col-sm-2">
                    <input type="password" class="form-control" id="inputPassword32" placeholder="Confirmar password"
                           name="password2">
                </div>
            </div>
            <div class="form-group">
                <label for="inputPassword3" class="col-sm-2 control-label">Password antiga</label>

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
                <label for="inputAddress3" class="col-sm-2 control-label">Morada</label>

                <div class="col-sm-5">
                    <input type="text" class="form-control" id="inputAddress3" placeholder="Morada"
                           value="{$FORM_VALUES.address}" name="address">
                </div>
            </div>
            <div class="form-group">
                <label for="inputCity3" class="col-sm-2 control-label">Cidade</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCity3" placeholder="Cidade"
                           value="{$FORM_VALUES.city}" name="city">
                </div>
            </div>
            <div class="form-group">
                <label for="inputCity4" class="col-sm-2 control-label">Código Postal</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCity4" placeholder="4400-404"
                           value="{$FORM_VALUES.postalcode}" name="postalcode">
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
                           value="{$FORM_VALUES.cellphone}" name="cellphone">
                </div>
            </div>
            <div class="form-group">
                <label for="inputDescription3" class="col-sm-2 control-label">Descrição</label>

                <div class="col-sm-5">
                    <textarea class="form-control" id="inputDescription3" placeholder="Relizam-se duplos negócios!"
                              name="description"></textarea>
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
