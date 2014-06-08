{include file='common/header.tpl'}

<div class="container">

    <div class="row">
        <h1>Concluir negócio</h1><br/>

        <form class="form-horizontal" role="form" method="post"
              action="{$BASE_URL}actions/negotiations/concludeDeal.php">
            {foreach $FORM_VALUES.errors as $error}
                <div class="alert alert-danger">{$error}</div>
            {/foreach}
            <input hidden="hidden" name="idDeal" value="{$IDDEAL}">

            <div class="form-group">
                <label for="buyerAddress" class="col-sm-2 control-label">Morada</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.buyerAddress}" type="text" class="form-control" placeholder="Morada"
                           name="buyerAddress" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCity3" class="col-sm-2 control-label">Cidade</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCity3" placeholder="Cidade"
                           value="{$FORM_VALUES.city}" name="buyerCity" maxlength="20" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCity4" class="col-sm-2 control-label">Código Postal</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCity4" placeholder="4400-404"
                           value="{$FORM_VALUES.postalcode}" pattern=".+" name="buyerPostal" maxlength="20" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCountry3" class="col-sm-2 control-label">País</label>

                <div class="col-sm-2">
                    <select name="buyerCountry" id="inputCountry3" class="form-control">
                        <option value="-1"></option>
                        {foreach $countries as $country}
                            <option value="{$country.idcountry}">{$country.name}</option>
                        {/foreach}
                    </select>
                </div>
            </div>
            <div class="form-group">
            <label for="billingAddress" class="col-sm-2 control-label">Morada de Cobrança</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.billingAddress}" type="text" class="form-control"
                           placeholder="Morada de Cobrança" name="billingAddress" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCity3" class="col-sm-2 control-label">Cidade</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCity3" placeholder="Cidade"
                           value="{$FORM_VALUES.city}" name="billingCity" maxlength="20" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCity4" class="col-sm-2 control-label">Código Postal</label>

                <div class="col-sm-2">
                    <input type="text" class="form-control" id="inputCity4" placeholder="4400-404"
                           value="{$FORM_VALUES.postalcode}" pattern=".+" name="billingPostal" maxlength="20" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputCountry3" class="col-sm-2 control-label">País</label>

                <div class="col-sm-2">
                    <select name="billingCountry" id="inputCountry3" class="form-control">
                        <option value="-1"></option>
                        {foreach $countries as $country}
                            <option value="{$country.idcountry}">{$country.name}</option>
                        {/foreach}
                    </select>
                </div>
            </div>
            <div class="form-group">
            <label for="creditCardNumber" class="col-sm-2 control-label">Cartão de Crédito</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.creditCardNumber}" type="text" class="form-control"
                           placeholder="Cartão de Crédito" name="creditCardNumber" required>
                </div>
            </div>
            <div class="form-group">
                <label for="creditCardHolder" class="col-sm-2 control-label">Nome do Titular</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.creditCardNumber}" type="text" class="form-control"
                           placeholder="Nome do Titular" name="creditCardHolder" required>
                </div>
            </div>
            <div class="form-group">
                <label for="creditCardDate" class="col-sm-2 control-label">Data de Expiração</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.creditCardNumber}" type="month" class="form-control"
                           name="creditCardDate" required>
                </div>
            </div>
            <div class="form-group">
                <label for="deliveryMethod" class="col-sm-2 control-label">Método de Entrega</label>

                <div class="col-sm-2">
                    <select class="form-control" name="deliveryMethod">
                        <option value="In Hand">Em mão</option>
                        <option value="Shipping">Envio por Correio</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
            <label for="inputPassword3" class="col-sm-2 control-label">Confirmar password</label>

                <div class="col-sm-2">
                    <input type="password" class="form-control" id="inputPassword3" placeholder="Confirmar password"
                           name="password2" required>
                </div>
            </div>
            <div class="form-group"></div>
            <div class="form-group"></div>
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <button type="submit" class="btn btn-primary">Registar</button>
                </div>
            </div>
        </form>

    </div>

</div>

{include file='common/footer.tpl'}