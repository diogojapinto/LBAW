{include file='common/header.tpl'}
<div class = "container">

    <div class = "row">

        <div class = "col-md-5 thumbnail">

            <img src = "imgs/iphone5.png" class = "img-responsive">

        </div>

        <div class = "col-md-7 thumbnail">

            <h3><a href = "#">iPhone 4</a></h3>
            <p class = "text-justify">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vel dolor sed nisl pretium tempus. Duis in neque vitae nisl pulvinar gravida. Aliquam luctus diam ac molestie vehicula. Duis sed augue a ipsum fringilla vestibulum eget vel lacus.</p>
            <p class = "text-justify"><strong>PVP: </strong>499€</p>

            <form class="form-horizontal" role="form">
                <div class="form-group">
                    <label for="offered" class="col-sm-2 control-label">Proposta</label>
                    <div class="col-sm-2">
                        <input type="number" class="form-control" id="offered" placeholder="350€">
                    </div>
                    <button type="submit" class="btn btn-info">Submeter</button>
                </div>

                <div class="form-group">
                    <label for="offered" class="col-sm-2 control-label">Diferença</label>
                    <div class="col-sm-2">
                        <fieldset disabled><input type="number" class="form-control" id="offered" placeholder="149€"></fieldset>
                    </div>
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

