{include file='common/header.tpl'}

<div class = "container">
<div class="panel panel-primary" style="margin-top: 10px;">
<div class="panel-heading">{$COMMON.username}</div>
<div class="panel-body">
<b>Nome da empresa:</b>    {$SELLER.companyname}<br/>
<b>Telefone:</b>    {$SELLER.cellphone}<br/>
<b>Morada:</b>    {$SELLER.addressline}<br/>
<b>Cidade:</b>    {$SELLER.city}<br/>
<b>C&oacute;digo Postal:</b>    {$SELLER.postalcode}<br/>
<b>Pa&iacute;s:</b>    {$SELLER.name}<br/>
<b>Descri&ccedil;&atilde;o:</b>    {$SELLER.description}<br/>
</div>
</div>
	<a class="btn btn-danger" href="{$BASE_URL}actions/users/deleteuser.php" role="button">Apagar Utilizador</a><br/><br/>
    <a class="btn btn-default" href="{$BASE_URL}pages/products/add.php" role="button">Adicionar Produto</a>
</div>

{include file='common/footer.tpl'}