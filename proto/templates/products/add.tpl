{include file='common/header.tpl'}
<div class="container">
    <div class="page-header">
        <h1>Adicionar Produto</h1>
    </div>
    <form role="form" method="post" action="{$BASE_URL}actions/products/newproduct.php">
		{foreach $FORM_VALUES.errors as $error}
			<div class="alert alert-danger">{$error}</div>
		{/foreach}
        <div class="input-group col-md-5">
            <span class="input-group-addon">Nome</span>
            <input value="{$FORM_VALUES.name}" type="text" class="form-control" placeholder="Nome do Produto">
        </div>
        <br>
        <div class="input-group col-md-5">
            <span class="input-group-addon">Imagem</span>
            <!-- TODO: Add verification of file extension (must be jpg) -->
            <input value="{$FORM_VALUES.image}" type="file" class="form-control">
        </div>
        <br>
        <div class="input-group col-md-5 panel panel-default">
            <div class="panel-heading">Descri&ccedil;&atilde;o</div>
            <textarea value="{$FORM_VALUES.description}" class="form-control panel-body" rows="3" placeholder="Descrição do Produto"></textarea>
        </div>

        <div class="btn-group">
            <button type="button" class="btn btn-info">Categoria</button>
            <button type="button" class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                <span class="caret"></span>
                <span class="sr-only">Toggle Dropdown</span>
            </button>
            <div>
				<select name="category" id="catID" class="form-control">
					<option value="-1"></option>
					{foreach $baseCategories as $baseCategory}
					<option value="{$baseCategory.idCategory}">{$baseCategory.name}</option>
					{/foreach}
				</select>
			</div>
        </div>
        <br><br>
        <button type="submit" class="btn btn-default">Submit</button>
    </form>
</div>
{include file='common/footer.tpl'}