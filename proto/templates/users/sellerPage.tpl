{include file='common/header.tpl'}

<div class="container">

    <div class="row">

        <div class="widewrapper main thumbnail" style="height: 33%; overflow: hidden">
            <img src="{$BASE_URL}images/seller/{$USERNAME}_banner.jpg" class="img-responsive">
        </div>

    </div>

    <div class="row">

        <div class="col-md-3 thumbnail">

            <img src="{$BASE_URL}images/seller/{$USERNAME}_profile.jpg" class="img-responsive">

        </div>

        <div class="col-md-9 thumbnail">

            <h3><a href="#">Descrição 4</a></h3>

            <p class="text-justify">{$SELLER['description']}</strong>

        </div>

    </div>

    <div class="row">
        <hr/>
        <h3>Produtos Populares</h3>
        <hr/>
    </div>

    <div class="container">
        <div class="row productThumbnails">
            {foreach from=$PRODUCTS item=product}
                <a href="{$BASE_URL}pages/products/product.php?productId={$product.idproduct}">
                    <div class="col-md-3">
                        <div class="thumbnail">
                            <img src="{$BASE_URL}images/products/{$product.idproduct}.jpg"
                                 alt="Image of {$product.name}">

                            <div class="caption">
                                <h3>{$product.name}</h3>

                                <p>{$product.description}</p>
                            </div>
                        </div>
                    </div>
                </a>
            {/foreach}
        </div>
    </div>

</div>

{include file='common/footer.tpl'}