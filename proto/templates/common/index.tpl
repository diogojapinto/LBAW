{include file='common/header.tpl'}

<div class = "container home-jumbotron">

    <div class = "jumbotron">
        <center>
            <div id="carousel" class="carousel slide" data-ride="carousel">
                <!-- Indicators -->
                <ol class="carousel-indicators">
                    <li data-target="#carousel" data-slide-to="0" class="active"></li>
                    <li data-target="#carousel" data-slide-to="1"></li>
                    <li data-target="#carousel" data-slide-to="2"></li>
                </ol>
                <div class="carousel-inner">
                    <div class="item active">
                        <h2>
                            Top Produtos
                        </h2>
                        <div class = "row">

                            <div class = "col-md-5">

                                <img src = "imgs/iphone5.png" class = "img-responsive">

                            </div>

                            <div class = "col-md-7">

                                <h3><a href = "#">iPhone 4</a></h3>
                                <p class = "text-justify">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vel dolor sed nisl pretium tempus. Duis in neque vitae nisl pulvinar gravida. Aliquam luctus diam ac molestie vehicula. Duis sed augue a ipsum fringilla vestibulum eget vel lacus.</p>
                                <p class = "text-justify"><strong>PVP: </strong>499 <b class="glyphicon glyphicon-euro"></b></p>
                                <form class="form-horizontal" role="form">
                                    <div class="form-group">
                                        <button type="submit" class="btn btn-info">Submeter</button>
                                    </div>
                                </form>



                            </div>

                        </div>
                    </div>
                    <div class="item">
                        <h2>
                            Top Empresas
                            <div class = "row">

                                <div class = "col-md-3">

                                    <img src = "imgs/company.gif" class = "img-responsive">

                                </div>

                                <div class = "col-md-9">

                                    <h3><a href = "#">Descrição 4</a></h3>
                                    <p class = "text-justify">Hella fashion axe chillwave, letterpress squid synth leggings. Wayfarers iPhone kale chips, Bushwick skateboard butache actually ennui pug hoodie Vice jean shorts. Williamsburg actually biodiesel sustainable wolf chillwave. Roof party food truck small batch master cleanse locavore letterpress. Brooklyn post-ironic tattooed, pour-over Odd Future seitan retro squid raw denim try-hard XOXO Marfa. Flexitarian readymade distillery Neutra actually Portland.</p><br>
                                </div>

                            </div>
                        </h2>
                    </div>
                    <div class="item">
                        <h2>
                            Top Negócios
                            <img class="img-responsive" src="imgs/company.gif" />
                        </h2>
                    </div>
                </div>

            </div>
    </div>

    </center>

    <!-- Controls -->
    <a class="left carousel-control" href="#carousel" data-slide="prev">
        <span class="glyphicon glyphicon-chevron-left"></span>
    </a>
    <a class="right carousel-control" href="#carousel" data-slide="next">
        <span class="glyphicon glyphicon-chevron-right"></span>
    </a>
</div>



<div class = "container">

    <div class = "row">

        {foreach $highestRatedProducts as $product}

        {/foreach}
        <div class = "col-md-3">
            <div class="thumbnail">
                <img src="imgs/hua.jpg" alt="...">
                <div class="caption">
                    <h3>Huawei</h3>
                    <p>Cras justo odio, dapibus ac facilisis in, egestas eget quam. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit.</p>
                </div
        </div>

    </div>

</div>

{include file='common/footer.tpl'}