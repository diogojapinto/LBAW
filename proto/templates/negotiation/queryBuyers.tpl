{include file='common/header.tpl'}

<h1>Utilizadores interessados<br>
    <small>Selecione os que deseja</small>
</h1>
<div clas="container">
    <div class="jumbotron interestedBuyersJumbotron">
        <form role="form" method="post" action="{$BASE_URL}actions/negotiations/sendFirstProposal.php">
            <input type="hidden" name="idProduct" value="{$PRODUCT_ID}">
            {foreach $HIGH_BUYERS as $BUYER}
                <div class="alert alert-success interestedBuyersCheckBox">
                    <input type="checkbox" name="users[]" value="{$BUYER['iduser']}">
                    <label>{$BUYER['username']}</label>
                    <span style="float: right">
                        <label>{$BUYER['proposedprice']}</label>
                        <span class="glyphicon glyphicon-euro"></span>
                    </span>
                </div>
            {/foreach}

            <hr>

            {foreach $MID_BUYERS as $BUYER}
                <div class="alert alert-warning interestedBuyersCheckBox">
                    <input type="checkbox" name="users[]" value="{$BUYER['iduser']}">
                    <label>{$BUYER['username']}</label>
                    <span style="float: right">
                        <label>{$BUYER['proposedprice']}</label>
                        <span class="glyphicon glyphicon-euro"></span>
                    </span>
                </div>
            {/foreach}

            <hr>

            {foreach $LOW_BUYERS as $BUYER}
                <div class="alert alert-danger interestedBuyersCheckBox">
                    <input type="checkbox" name="users[]" value="{$BUYER['iduser']}">
                    <label>{$BUYER['username']}</label>
                    <span style="float: right">
                        <label>{$BUYER['proposedprice']}</label>
                        <span class="glyphicon glyphicon-euro"></span>
                    </span>
                </div>
            {/foreach}
            <button class="btn btn-default" type="submit">Submeter</button>
        </form>
    </div>
</div>

{include file='common/footer.tpl'}