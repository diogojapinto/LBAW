{include file='common/header.tpl'}
<div class="container">
    <div class="page-header">
        <h1>Adicionar Produto</h1>
    </div>
    <form role="form">
        <div class="input-group col-md-5">
            <span class="input-group-addon">Nome</span>
            <input type="text" class="form-control" placeholder="Nome do Produto">
        </div>
        <br>
        <div class="input-group col-md-5">
            <span class="input-group-addon">Imagem</span>
            <input type="file" class="form-control">
        </div>
        <br>
        <div class="input-group col-md-5 panel panel-default">
            <div class="panel-heading">Descri&ccedil;&atilde;o</div>
            <textarea class="form-control panel-body" rows="3" placeholder="Descrição do Produto"></textarea>
        </div>

        <div class="btn-group">
            <button type="button" class="btn btn-info">Categoria</button>
            <button type="button" class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                <span class="caret"></span>
                <span class="sr-only">Toggle Dropdown</span>
            </button>
            <ul class="dropdown-menu" role="menu">
                {foreach $baseCategories as $baseCategory}
                    <li><a class="categoryLink" href="#">{$baseCategory.name}</a></li>
                {/foreach}
            </ul>
        </div>
        <br><br>
        <button type="submit" class="btn btn-default">Submit</button>
    </form>
</div>
{include file='common/footer.tpl'}