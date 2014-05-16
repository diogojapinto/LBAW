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
            <button id="btnCategory" type="button" class="btn btn-danger" data-toggle="dropdown">
                Categorias
            </button>
            <button type="button" style="z-index:1" class="btn btn-danger dropdown-toggle"
                    data-toggle="dropdown">
                <span class="caret"></span>
                <span class="sr-only">Toggle Dropdown</span>
            </button>
            <ul class="dropdown-menu" role="menu">
                {foreach $baseCategories as $baseCategory}
                    <li>
                        <a href="#" class="categoryLink">{$baseCategory.name}</a>
                        <span style="display: none">{$baseCategory.idcategory}</span>
                    </li>
                {/foreach}
            </ul>
            <input type="hidden" id="searchCategory" name="productCategory" value="All">
        </div>
        <br><br>
        <button type="submit" class="btn btn-default">Submit</button>
    </form>
</div>
{include file='common/footer.tpl'}