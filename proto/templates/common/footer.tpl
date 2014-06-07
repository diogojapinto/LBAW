<div class="navbar navbar-default navbar-fixed-bottom">

    <div class="container ">
        <p class="navbar-text pull-left">Site built by Realezy Team</p>
        <a href="http://www.paypal.com" class="navbar-btn btn-success btn pull-right">Donate</a>
        <a href="#contact" class="navbar-btn btn-default btn pull-right" style="margin-right: 3px;" data-toggle="modal">Contact</a>
    </div>

</div>
<!--
<div class="modal fade" id="advSearch" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <form class="form-horizontal" role="form">
                <div class="modal-header">
                    <h4>Pesquisa Avan&ccedil;ada</h4>
                </div>
                <div class="modal-body">
                    <div class="form-group form-inline">
                        <div class="col-sm-10">
                            <label for="palavraschave" class="control-label">Insira as palavras-chave</label>
                        </div>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="palavraschave" placeholder="Palavras-Chave"
                                   type="search" required>
                            <select class="form-control">
                                <option value="all-any">Todas as palavras, qualquer Ordem</option>
                                <option value="any-any">Qualquer palavra, qualquer Ordem</option>
                                <option value="all-exact">Palavras exatas, ordem exata</option>
                                <option value="exact-any">Palavras exatas, qualquer ordem</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="categorias" class="col-lg-2 control-label">Categoria</label>

                        <div class="col-lg-6">
                            <select class="form-control" id="categorias">
                                <option value="0">Todas as Categorias</option>
                                <option value="1">Antiques</option>
                                <option value="2">Art</option>
                                <option value="3">Baby</option>
                                <option value="4">Books</option>
                                <option value="5">Business &amp; Industrial</option>
                                <option value="6">Cameras &amp; Photo</option>
                                <option value="7">Cell Phones &amp; Accessories</option>
                                <option value="8">Clothing, Shoes &amp; Accessories</option>
                                <option value="9">Coins &amp; Paper Money</option>
                                <option value="10">Collectibles</option>
                                <option value="11">Computers/Tablets &amp; Networking</option>
                                <option value="12">Consumer Electronics</option>
                                <option value="13">Crafts</option>
                                <option value="14">Dolls &amp; Bears</option>
                                <option value="15">DVDs &amp; Movies</option>
                                <option value="16">Entertainment Memorabilia</option>
                                <option value="17">Gift Cards &amp; Coupons</option>
                                <option value="18">Health &amp; Beauty</option>
                                <option value="19">Home &amp; Garden</option>
                                <option value="20">Jewelry &amp; Watches</option>
                                <option value="21">Music</option>
                                <option value="22">Musical Instruments &amp; Gear</option>
                                <option value="23">Pet Supplies</option>
                                <option value="24">Pottery &amp; Glass</option>
                                <option value="25">Real Estate</option>
                                <option value="26">Specialty Services</option>
                                <option value="27">Sporting Goods</option>
                                <option value="28">Sports Mem, Cards &amp; Fan Shop</option>
                                <option value="29">Stamps</option>
                                <option value="30">Toys &amp; Hobbies</option>
                                <option value="31">Travel</option>
                                <option value="32">Video Games &amp; Consoles</option>
                                <option value="33">Everything Else</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group form-inline">
                        <div class="col-lg-10">
                            <label for="ordenar" class="control-label">Ordenar por &nbsp;</label>
                            <select class="form-control" id="ordenar">
                                <option value="1">Melhor correspond&ecirc;ncia</option>
                                <option value="2">Pre&ccedil;o: ascendente</option>
                                <option value="3">Pre&ccedil;o: descendente</option>
                                <option value="4">Tempo: pr&oacute;ximo do fim</option>
                                <option value="5">Tempo: mais recente</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group form-inline">
                        <div class="col-lg-10">
                            <label for="nr_res" class="control-label">Resultados por p&aacute;gina &nbsp;</label>
                            <select class="form-control" id="nr_res">
                                <option value="1">25</option>
                                <option value="2">50</option>
                                <option value="3">75</option>
                                <option value="4">100</option>
                                <option value="5">200</option>
                            </select>
                        </div>
                    </div>

                </div>
                <div class="modal-footer">
                    <button class="btn btn-primary" type="submit">Procurar</button>
                </div>
            </form>
        </div>
    </div>
</div>
-->

<div class="modal fade" id="contact" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <form class="form-horizontal" method="post" action="{$BASE_URL}actions/users/sendEmail.php">
                <div class="modal-header">
                    <h4>Contact Realezy Team</h4>
                </div>
                <div class="modal-body">

                    <div class="form-group">
                        <label for="contact-name" class="col-lg-2 control-label">Name:</label>

                        <div class="col-lg-10">

                            <input type="text" class="form-control" id="contact-name" placeholder="Full Name" value="{$FORM_VALUES.username}">

                        </div>
                    </div>

                    <div class="form-group">
                        <label for="contact-email" class="col-lg-2 control-label">Email:</label>

                        <div class="col-lg-10">

                            <input type="email" class="form-control" id="contact-email" placeholder="you@example.com" value="{$FORM_VALUES.email}">

                        </div>
                    </div>

                    <div class="form-group">
                        <label for="contact-message" class="col-lg-2 control-label">Message:</label>

                        <div class="col-lg-10">

                            <textarea name="contact-message" class="form-control" rows="8" value="{$FORM_VALUES.message}"></textarea>

                        </div>
                    </div>
                    {$FORM_VALUES.subject = "Realezy Team Contact"}
                </div>
                <div class="modal-footer">
                    <a class="btn btn-primary" data-dismiss="modal">Close</a>
                    <a class="btn btn-primary" type="submit">Send</a>
                </div>

            </form>
        </div>
    </div>
</div>

<script src="{$BASE_URL}javascript/bootstrap.min.js"></script>
<script src="{$BASE_URL}javascript/session.js"></script>
<script id="error-template" type="text/x-handlebars-template">
    {literal}
        <div class="alert alert-{{type}} errorsAlert">{{text}}</div>
    {/literal}
</script>
<script src="{$BASE_URL}javascript/warnings.js"></script>

</body>
</html>