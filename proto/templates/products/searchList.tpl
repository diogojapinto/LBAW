{include file='common/header.tpl'}

<div class="container">
    <div class="page-header" style>
        <h1 style="float:left">Resultados
            <small>Pesquisa de Produtos</small>
        </h1>
        {if $USERNAME }
            <a class="btn btn-default pull-right addProduct" href="{$BASE_URL}pages/products/add.php"
               role="button">Adicionar Produto</a>
        {/if}

    </div>
    <div id="productsList" class="container" style="clear:both">
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


    <div id="getMoreProducts" style="text-align: center;">
        <button onclick="loadMoreProducts()" type="button" class="btn btn-primary">Ver mais <span class="caret"></span></button>
    </div>
</div>

{include file='common/footer.tpl'}

<script src="{$BASE_URL}javascript/handlebars-v1.3.0.js"></script>
<input type="hidden" name="baseUrl" value="{$BASE_URL}" />
<input type="hidden" name="productsPerBlock" value="{$PRODUCT_PER_BLOCK}" />
<input type="hidden" name="name" value="{$name}" />
<input type="hidden" name="category" value="{$category}" />
<script id="product-template" type="text/x-handlebars-template">
    {literal}
    <a href="{/literal}{$BASE_URL}{literal}pages/products/product.php?productId={{idproduct}}">
        <div class="col-md-3">
            <div class="thumbnail">
                <img src="{/literal}{$BASE_URL}{literal}images/products/{{idproduct}}.jpg" alt="Image of {{name}}">

                <div class="caption">
                    <h3>{{name}}</h3>

                    <p>{{description}}</p>
                </div>
            </div>
        </div>
    </a>
    {/literal}
</script>
<script id="product-row-template" type="text/x-handlebars-template">
    {literal}
    <div class="row productThumbnails">
        {{#each products}}
        {{{this}}}
        {{/each}}
    </div>
    {/literal}
</script>

<script src="{$BASE_URL}javascript/productsSearch.js"></script>