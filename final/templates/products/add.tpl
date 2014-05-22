{include file='common/header.tpl'}
<div class="container">
    <div class="page-header">
        <h1>Adicionar Produto</h1>
    </div>
    <form role="form" method="post" action="{$BASE_URL}actions/products/newproduct.php" enctype="multipart/form-data">
        <div class="input-group col-md-5">
            <span class="input-group-addon">Nome</span>
            <input value="{$FORM_VALUES.name}" type="text" name="name" class="form-control"
                   placeholder="Nome do Produto">
        </div>
        <br>

        <div class="input-group col-md-5">
            <span class="input-group-addon">Imagem</span>
            <input type="file" name="image" id="imageInput" class="form-control" accept="image/jpeg">
        </div>
        <br>

        <div class="input-group col-md-5 panel panel-default">
            <div class="panel-heading">Descri&ccedil;&atilde;o</div>
            <textarea name="description" class="form-control panel-body" rows="3"
                      placeholder="Descrição do Produto">{$FORM_VALUES.description}</textarea>
        </div>

        <div class="btn-group col-md-5 col-sm-3" style="padding-left:0;padding-right: 0">
            <button id="btnCategory" style="width:94.7%" type="button" class="btn" data-toggle="dropdown">
                {if !$FORM_VALUES.productCategory}
                    Selecione uma categoria
                {else}
                    {$baseCategories[$FORM_VALUES.productCategory].name}
                {/if}
            </button>
            <button type="button" style="z-index:1" class="btn dropdown-toggle"
                    data-toggle="dropdown">
                <span class="caret"></span>
                <span class="sr-only">Toggle Dropdown</span>
            </button>
            <ul class="dropdown-menu" role="menu">
                {foreach $baseCategories as $baseCategory}
                    {if $baseCategory.name == "All"}
                        {continue}
                    {/if}
                    <li>
                        <a href="#" class="categoryLink">{$baseCategory.name}</a>
                        <span style="display: none">{$baseCategory.idcategory}</span>
                    </li>
                {/foreach}
            </ul>
            <input type="hidden" id="searchCategory" name="productCategory"
                   value="{if $FORM_VALUES}{$FORM_VALUES.productCategory}{/if}">
        </div>
        <br><br>
        <button type="submit" class="btn btn-default">Submit</button>
    </form>
</div>
{include file='common/footer.tpl'}