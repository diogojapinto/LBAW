{include file='common/header.tpl'}

<div class="container">

    <div class="row">
        <h1>Concluir negócio</h1><br/>

        <form class="form-horizontal" role="form" method="post"
              action="{$BASE_URL}actions/negotiations/concludeDeal.php">
            {foreach $FORM_VALUES.errors as $error}
                <div class="alert alert-danger">{$error}</div>
            {/foreach}
            <div class="form-group">
                <label for="buyerAddress" class="col-sm-2 control-label">Morada</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.buyerAddress}" type="text" class="form-control" placeholder="Morada"
                           name="buyerAddress" required>
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
                <label for="creditCardNumber" class="col-sm-2 control-label">Cartão de Crédito</label>

                <div class="col-sm-2">
                    <input value="{$FORM_VALUES.creditCardNumber}" type="text" class="form-control"
                           placeholder="Cartão de Crédito" name="creditCardNumber" required>
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