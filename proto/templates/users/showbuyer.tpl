{include file='common/header.tpl'}

<div class = "container">
<div class="panel panel-primary" style="margin-top: 10px;">
<div class="panel-heading">{$COMMON.username}</div>
<div class="panel-body"><b>Email:</b>    {$COMMON.email}</div>
</div>
	<a class="btn btn-danger" href="{$BASE_URL}actions/users/deleteuser.php" role="button">Apagar Utilizador</a><br/><br/>
    <a class="btn btn-default" href="{$BASE_URL}pages/products/add.php" role="button">Adicionar Produto</a>
</div>


{include file='common/footer.tpl'}