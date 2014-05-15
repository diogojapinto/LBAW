{include file='common/header.tpl'}
<div class="container">
    <div class="jumbotron">

        <div class="row">

            <div class="col-md-5 thumbnail">

                <img src="{$BASE_URL}images/products/{$product.idproduct}.jpg" alt="Image of {$product.name}"
                     class="img-responsive">

            </div>

            <div class="col-md-7 thumbnail">

                <h3><a href="#">{$product.name}</a></h3>

                <p class="text-justify">{$product.description}</p>

                <form class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="offered" class="col-sm-2 control-label">Proposta</label>

                        <div class="col-sm-2">
                            <input type="number" class="form-control" id="offered" placeholder="100€">
                        </div>
                        <button type="submit" class="btn btn-info">Submeter</button>
                    </div>
                </form>

            </div>
        </div>

    </div>
</div>
<div class="container">

    <div class="row">
        <hr/>
        <h3>Produtos Relacionados</h3>
        <hr/>
    </div>

    <div class="container">
        <div class="row productThumbnails">
            {for $i=0 to $productsCount - 1}
                <a href="{$BASE_URL}pages/products/product.php?productId={$relatedProducts[$i].idproduct}">
                    <div class="col-md-3">
                        <div class="thumbnail">
                            <img src="{$BASE_URL}images/products/{$relatedProducts[$i].idproduct}.jpg" alt="Image of {$relatedProducts[$i].name}">

                            <div class="caption">
                                <h3>{$relatedProducts[$i].name}</h3>
                                <p>{$relatedProducts[$i].description}</p>
                            </div>
                        </div>
                    </div>
                </a>
            {/for}
        </div>
    </div>

</div>

{include file='common/footer.tpl'}

