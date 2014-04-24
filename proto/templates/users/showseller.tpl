{include file='common/header.tpl'}

<div class = "container">
<div class="panel panel-primary" style="margin-top: 10px;">
<div class="panel-heading">{$COMMON.username}</div>
<div class="panel-body">
<b>Nome da empresa:</b>    {$SELLER.companyname}<br/>
<b>Telefone:</b>    {$SELLER.cellphone}<br/>
<b>Morada:</b>    {$SELLER.addressline}<br/>
<b>Cidade:</b>    {$SELLER.city}<br/>
<b>Código Postal:</b>    {$SELLER.postalcode}<br/>
<b>País:</b>    {$SELLER.name}<br/>
<b>Descrição:</b>    {$SELLER.description}<br/>
</div>
</div>
</div>

{include file='common/footer.tpl'}