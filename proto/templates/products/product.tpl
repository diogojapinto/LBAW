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
                <img src="imgs/hua.jpg" alt="...">
                <div class="caption">
                    <h3>Huawei</h3>
                    <p>Cras justo odio, dapibus ac facilisis in, egestas eget quam. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit.</p>
                </div>
            </div>

        </div>

        <div class = "col-md-3">

            <div class="thumbnail">
                <img src="imgs/z1.png" alt="...">
                <div class="caption">
                    <h3>Sony</h3>
                    <p>Cras justo odio, dapibus ac facilisis in, egestas eget quam. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit.</p>
                </div>
            </div>

        </div>

        <div class = "col-md-3">

            <div class="thumbnail">
                <img src="imgs/lg.png" alt="...">
                <div class="caption">
                    <h3>LG</h3>
                    <p>Cras justo odio, dapibus ac facilisis in, egestas eget quam. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit.</p>
                </div>
            </div>

        </div>

        <div class = "col-md-3">

            <div class="thumbnail">
                <img src="imgs/s4.png" alt="...">
                <div class="caption">
                    <h3>Samsung</h3>
                    <p>Cras justo odio, dapibus ac facilisis in, egestas eget quam. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit.</p>
                </div>
            </div>

        </div>

    </div>

</div>

{include file='common/footer.tpl'}

