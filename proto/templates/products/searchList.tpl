{include file='common/header.tpl'}

<div class="container">
    <div class="page-header" style>
        <h1 style="float:left">Resultados
            <small>Pesquisa de Produtos</small>
        </h1>

        <a class="btn btn-default pull-right addProduct" href="{$BASE_URL}pages/products/add.php"
           role="button">Adicionar Produto</a>
    </div>
    <div class="container" style="clear:both">
        {$productsCount = 0}
        {foreach $products as $product}
            {$productCount = $productCount + 1}
            {if $productCount == 1}
                <div class="row productThumbnails">
            {/if}
            <a href="{$BASE_URL}pages/products/product.php?productId={$product.idproduct}">
                <div class="col-md-3">
                    <div class="thumbnail">
                        <img src="{$BASE_URL}images/products/{$product.idproduct}.jpg" alt="Image of {$product.name}">

                        <div class="caption">
                            <h3>{$product.name}</h3>

                            <p>{$product.description}</p>
                        </div>
                    </div>
                </div>
            </a>
            {if $productCount == 4}
                </div>
                {$productCount = 0}
            {/if}
        {/foreach}
    </div>
</div>

{include file='common/footer.tpl'}