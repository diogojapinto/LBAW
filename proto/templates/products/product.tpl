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
                {if userType == "buyer" }
                    <h2>Adicionar proposta de compra:</h2>
                    <form class="form-horizontal" role="form" action="{$BASE_URL}action/addProductToBuy.php">
                        <div class="form-group">
                            <label for="offered" class="col-sm-2 control-label">Proposta</label>

                            <div class="col-sm-2">
                                <input type="text" class="form-control" id="offered" placeholder="100">
                                <span class="glyphicon glyphicon-euro"></span><br>
                            </div>
                            <button type="submit" class="btn btn-info">Confirmar</button>
                        </div>
                    </form>
                {elseif userType == "seller" }
                    <h2>Adicionar produto para venda:</h2>
                    <form class="form-horizontal" role="form" action="{$BASE_URL}action/addProductToBuy.php">
                        <div class="form-group">
                            <label for="offered" class="col-sm-2 control-label">Proposta</label>

                            <div class="col-sm-2">
                                <input type="text" class="form-control" id="minimum" placeholder="50">
                                <span class="glyphicon glyphicon-euro"></span><br>
                                <input type="text" class="form-control" id="average" placeholder="100">
                                <span class="glyphicon glyphicon-euro"></span><br>
                            </div>
                            <button type="submit" class="btn btn-info">Confirmar</button>
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

