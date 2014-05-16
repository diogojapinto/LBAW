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

                <div class="alert alert-warning">
                    {if $userType == "buyer" }
                        <h2>Adicionar proposta de compra:</h2>
                        <form class="form-horizontal" role="form" method="post"
                              action="{$BASE_URL}action/addProductToBuy.php">
                            <input type="hidden" value={$product.idproduct} name="idProduct">

                            <div class="form-group">
                                <label for="offered" class="col-sm-2 control-label" id="productLabel">Proposta</label>

                                <div class="col-sm-2" id="productPriceInput">
                                    <input type="text" class="form-control" id="offered" placeholder="100"
                                           name="proposedValue">
                                </div>
                                <span class="col-sm-2 glyphicon glyphicon-euro" id="productEuroGlyphicon"></span>
                                <button type="submit" class="btn btn-info">Confirmar</button>
                            </div>
                        </form>
                    {elseif $userType == "seller" }
                        <h2>Adicionar produto para venda:</h2>
                        <form class="form-horizontal" role="form" method="post"
                              action="{$BASE_URL}action/addProductToSell.php">
                            <input type="hidden" value={$product.idproduct} name="idProduct">

                            <div class="form-group">
                                <label for="offered" class="col-sm-2 control-label" id="productLabel">Preço
                                    Mínimo</label>

                                <div class="col-sm-2" id="productPriceInput">
                                    <input type="text" class="form-control" id="minimum" placeholder="50"
                                           name="minimumValue">
                                </div>
                                <span class="glyphicon glyphicon-euro" id="productEuroGlyphicon"></span><br><br><br>

                                <label for="offered" class="col-sm-2 control-label" id="productLabel">Preço
                                    Médio</label>

                                <div class="col-sm-2" id="productPriceInput">
                                    <input type="text" class="form-control" id="average" placeholder="100"
                                           name="averageValue">
                                </div>
                                <span class="glyphicon glyphicon-euro" id="productEuroGlyphicon"></span><br><br><br>

                                <button type="submit" class="btn btn-info" id="productProposeButton">Confirmar</button>
                            </div>
                        </form>
                    {else}
                        <h5>
                            <!--<a href="#" class="dropdown-toggle" data-toggle="dropdown" id="sessionLink">-->
                            Registe-se ou inicie sessão
                            <!-- </a> -->
                            para aceder às suas opções de produtos
                        </h5>
                    {/if}
                </div>

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
                            <img src="{$BASE_URL}images/products/{$relatedProducts[$i].idproduct}.jpg"
                                 alt="Image of {$relatedProducts[$i].name}">

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

