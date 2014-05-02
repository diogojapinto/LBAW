{include file='common/header.tpl'}

<div class="container home-jumbotron">

    <div class="jumbotron text-center">
        <div id="carousel" class="carousel slide" data-ride="carousel">
            <ol class="carousel-indicators">
                <li data-target="#carousel" data-slide-to="0" class="active"></li>
                <li data-target="#carousel" data-slide-to="1"></li>
                <li data-target="#carousel" data-slide-to="2"></li>
            </ol>
            <div class="carousel-inner">
                <div class="item active">
                    <h2>
                        Objetivo
                    </h2>

                    <p>O Realezy pretende aproximar os clientes dos vendedores, para que se compreendam mutuamente,
                        e encontrem a melhor solução para alcançar o que pretendem.</p>
                </div>
                <div class="item">
                    <h2>
                        É comprador?

                    </h2>

                    <p>Para si, para além de poder conhecer vários produtos, temos a possibilidade de dar a conhecer o
                        preço que está disposto a pagar pelo que deseja adquirir. Após se apresentar como interessado
                        num produto, será notificado por um vendedor que lhe apresentará uma proposta. A partir daí
                        poderá rejeitar as propostas do mesmo até um valor que lhe agrade. Contudo, não se esqueça que
                        há um preço mínimo pelo qual o produto lhe pode ser vendido...</p>
                </div>
                <div class="item">
                    <h2>
                        É vendedor?
                    </h2>

                    <img height="200px" width="200px" style="float:left; top:50px" class="img img-responsive"
                         src="{$BASE_URL}images/icon_set/seller.png">
                        <p>Através desta plataforma poderá conhecer os seus clientes. Terá acesso ao preço que estes
                            estão
                            dispostos a pagar pelos seus produtos, bem como ser avaliado por estes pelos seus
                            serviços.
                        </p>
                </div>
            </div>

        </div>
    </div>

    <!-- Controls -->
    <a class="left carousel-control" href="#carousel" data-slide="prev">
        <span class="glyphicon glyphicon-chevron-left"></span>
    </a>
    <a class="right carousel-control" href="#carousel" data-slide="next">
        <span class="glyphicon glyphicon-chevron-right"></span>
    </a>
</div>


<div class="container">

    <div class="row">

        {foreach $highestRatedProducts as $product}
        <div class="col-md-3">
            <div class="thumbnail">
                <img src="{$BASE_URL}images/products/{$product.idProduct}.jpg" alt="Image of {$product.name}">

                <div class="caption">
                    <h3>{$product.name}</h3>

                    <p>{$product.description}</p>
                </div
            </div>
        </div>
    </div>
    {/foreach}

</div>
</div>

{include file='common/footer.tpl'}