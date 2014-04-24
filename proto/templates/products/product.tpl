{include file='common/header.tpl'}
<div class = "container">

    <div class = "row">

        <div class = "col-md-5 thumbnail">

            <img src = "images/products/{$product.idproduct}.png" class = "img-responsive">

        </div>

        <div class = "col-md-7 thumbnail">

            <h3><a href = "#">{$product.name}</a></h3>
            <p class = "text-justify">{$product.description}</p>

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

    <div class = "row">
        <hr/>
        <h3>Produtos Relacionados</h3>
        <hr/>
    </div>

    <div class = "row">

        <div class = "col-md-3">

            <div class="thumbnail">
                <img src="imgs/{$relatedProducts[0].idproduct}.jpg" alt="...">
                <div class="caption">
                    <h3>{$relatedProducts[0].name}</h3>
                    <p>{$relatedProducts[0].description}</p>
                </div>
            </div>

        </div>

        <div class = "col-md-3">

            <div class="thumbnail">
                <img src="imgs/{$relatedProducts[1].idproduct}.jpg" alt="...">
                <div class="caption">
                    <h3>{$relatedProducts[1].name}</h3>
                    <p>{$relatedProducts[1].description}</p>
                </div>
            </div>

        </div>

        <div class = "col-md-3">

            <div class="thumbnail">
                <img src="imgs/{$relatedProducts[2].idproduct}.jpg" alt="...">
                <div class="caption">
                    <h3>{$relatedProducts[2].name}</h3>
                    <p>{$relatedProducts[2].description}</p>
                </div>
            </div>

        </div>

        <div class = "col-md-3">

            <div class="thumbnail">
                <img src="imgs/{$relatedProducts[3].idproduct}.jpg" alt="...">
                <div class="caption">
                    <h3>{$relatedProducts[3].name}</h3>
                    <p>{$relatedProducts[3].description}</p>
                </div>
            </div>

        </div>

    </div>

</div>

{include file='common/footer.tpl'}

