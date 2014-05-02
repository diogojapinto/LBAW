{include file='common/header.tpl'}

<div class="container">
    <div class="page-header" style>
        <h1>Resultados <small>Pesquisa de Produtos</small></h1>
    </div>

    <ul class="media-list">
        {foreach $products as $product}
        <li class="media">
            <a class="pull-left" href="{$BASE_URL}pages/products/product.php?productId={$product.idproduct}">
                <img class="media-object" src="{$BASE_URL}/images/{$product.idproduct}.jpg" alt="...">
            </a>
            <div class="media-body">
                <h4 class="media-heading">
                    <a href="{$BASE_URL}pages/products/product.php?productId={$product.idproduct}">
                    {$product.name}
                    </a>
                </h4>
                {$product.description}
            </div>
        </li>
        <hr>
        {/foreach}
    </ul>
</div>

{include file='common/footer.tpl'}