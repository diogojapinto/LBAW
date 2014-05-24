{include file='common/header.tpl'}

<h1>Utilizadores interessados<br><small>Selecione os que deseja</small></h1>

<form role="form" method="post" action="{$BASE_URL}actions/negotiations/sendFirstProposal.php">
    {foreach $HIGH_BUYERS as $BUYER}
        <div class="alert alert-success interestedBuyersCheckBox">
            <input type="checkbox" name="users[]" value="{$BUYER['iduser']}">
            <label>{$BUYER['username']}</label>
            <label>{$BUYER['proposedprice']}</label>
        </div>
    {/foreach}

    <hr>

    {foreach $MID_BUYERS as $BUYER}
        <div class="alert alert-warning interestedBuyersCheckBox">
            <input type="checkbox" name="users[]" value="{$BUYER['iduser']}">
            <label>{$BUYER['username']}</label>
            <label>{$BUYER['proposedprice']}</label>
        </div>
    {/foreach}

    <hr>

    {foreach $LOW_BUYERS as $BUYER}
        <div class="alert alert-danger interestedBuyersCheckBox">
            <input type="checkbox" name="users[]" value="{$BUYER['iduser']}">
            <label>{$BUYER['username']}</label>
            <label>{$BUYER['proposedprice']}</label>
        </div>
    {/foreach}

</form>

{include file='common/footer.tpl'}