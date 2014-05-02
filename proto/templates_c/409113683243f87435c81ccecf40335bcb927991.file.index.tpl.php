<?php /* Smarty version Smarty-3.1.15, created on 2014-05-02 10:34:13
         compiled from "/srv/www/htdocs/realezy/proto/templates/common/index.tpl" */ ?>
<?php /*%%SmartyHeaderCode:163061046453592256aedbb2-43158291%%*/if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '409113683243f87435c81ccecf40335bcb927991' => 
    array (
      0 => '/srv/www/htdocs/realezy/proto/templates/common/index.tpl',
      1 => 1399026852,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '163061046453592256aedbb2-43158291',
  'function' => 
  array (
  ),
  'version' => 'Smarty-3.1.15',
  'unifunc' => 'content_53592256b207d5_54285690',
  'variables' => 
  array (
    'BASE_URL' => 0,
    'highestRatedProducts' => 0,
    'product' => 0,
  ),
  'has_nocache_code' => false,
),false); /*/%%SmartyHeaderCode%%*/?>
<?php if ($_valid && !is_callable('content_53592256b207d5_54285690')) {function content_53592256b207d5_54285690($_smarty_tpl) {?><?php echo $_smarty_tpl->getSubTemplate ('common/header.tpl', $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, null, array(), 0);?>


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
                         src="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
images/icon_set/seller.png">
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

        <?php  $_smarty_tpl->tpl_vars['product'] = new Smarty_Variable; $_smarty_tpl->tpl_vars['product']->_loop = false;
 $_from = $_smarty_tpl->tpl_vars['highestRatedProducts']->value; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array');}
foreach ($_from as $_smarty_tpl->tpl_vars['product']->key => $_smarty_tpl->tpl_vars['product']->value) {
$_smarty_tpl->tpl_vars['product']->_loop = true;
?>
        <div class="col-md-3">
            <div class="thumbnail">
                <img src="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
images/products/<?php echo $_smarty_tpl->tpl_vars['product']->value['idProduct'];?>
.jpg" alt="Image of <?php echo $_smarty_tpl->tpl_vars['product']->value['name'];?>
">

                <div class="caption">
                    <h3><?php echo $_smarty_tpl->tpl_vars['product']->value['name'];?>
</h3>

                    <p><?php echo $_smarty_tpl->tpl_vars['product']->value['description'];?>
</p>
                </div
            </div>
        </div>
    </div>
    <?php } ?>

</div>
</div>

<?php echo $_smarty_tpl->getSubTemplate ('common/footer.tpl', $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, null, array(), 0);?>
<?php }} ?>
