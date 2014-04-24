<?php /* Smarty version Smarty-3.1.15, created on 2014-04-24 13:19:11
         compiled from "/srv/www/htdocs/realezy/proto/templates/common/menu_logged_in.tpl" */ ?>
<?php /*%%SmartyHeaderCode:187040400253590d422d2ab3-27471040%%*/if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'ff9f947fcde4a22f5cd98574019f3f815b617edf' => 
    array (
      0 => '/srv/www/htdocs/realezy/proto/templates/common/menu_logged_in.tpl',
      1 => 1398345544,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '187040400253590d422d2ab3-27471040',
  'function' => 
  array (
  ),
  'version' => 'Smarty-3.1.15',
  'unifunc' => 'content_53590d422db074_46697814',
  'variables' => 
  array (
    'BASE_URL' => 0,
  ),
  'has_nocache_code' => false,
),false); /*/%%SmartyHeaderCode%%*/?>
<?php if ($_valid && !is_callable('content_53590d422db074_46697814')) {function content_53590d422db074_46697814($_smarty_tpl) {?> <div class="col-md-2 navbar-right">
                    <div class="navbar-collapse collapse">
                        <ul class="list-inline" style="margin:0px;list-style-type:none">
                            <li>
                                <a class="dropdown-toggle" data-toggle="dropdown">
                                    <img class="img-responsive highlight_icon" alt="Negotiation Alerts" heigth="30px" width="30px" src="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
images/icon_set/negotiation.png" />
                                </a>
                                <ul class="dropdown-menu" role="menu">
                                    <li><a href="#">Negócio 1</a></li>
                                    <li><a href="#">Negócio Recusado por Vendedor</a></li>
                                    <li class="divider"></li>
                                    <li><a href="#">Negócio 2</a></li>
                                    <li><a href="#">Novo Preço: 0.00 <b class="glyphicon glyphicon-euro"></b></a></li>
                                </ul>
                            </li>
                            <li>
                                <a class="dropdown-toggle" data-toggle="dropdown">
                                    <img class="img-responsive highlight_icon" alt="Negotiation Alerts" heigth="30px" width="30px" src="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
images/icon_set/Users-User-icon.png" />
                                </a>
                                <ul class="dropdown-menu" role="menu">
                                    <li><a href="#">Ver Dados</a></li>
                                    <li><a href="#">Configurar Conta</a></li>
                                    <li class="divider"></li>
                                    <li><a href="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
actions/logout.php">Terminar Sessão</a></li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div><?php }} ?>
