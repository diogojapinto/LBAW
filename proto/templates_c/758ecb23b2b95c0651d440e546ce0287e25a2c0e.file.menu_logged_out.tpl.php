<?php /* Smarty version Smarty-3.1.15, created on 2014-04-24 17:44:51
         compiled from "/srv/www/htdocs/realezy/proto/templates/common/menu_logged_out.tpl" */ ?>
<?php /*%%SmartyHeaderCode:17606138175359071a83e9b5-70421039%%*/if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '758ecb23b2b95c0651d440e546ce0287e25a2c0e' => 
    array (
      0 => '/srv/www/htdocs/realezy/proto/templates/common/menu_logged_out.tpl',
      1 => 1398356215,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '17606138175359071a83e9b5-70421039',
  'function' => 
  array (
  ),
  'version' => 'Smarty-3.1.15',
  'unifunc' => 'content_5359071a851259_50535957',
  'variables' => 
  array (
    'ERROR_MESSAGES' => 0,
    'error' => 0,
    'BASE_URL' => 0,
  ),
  'has_nocache_code' => false,
),false); /*/%%SmartyHeaderCode%%*/?>
<?php if ($_valid && !is_callable('content_5359071a851259_50535957')) {function content_5359071a851259_50535957($_smarty_tpl) {?><div class="col-md-2 navbar-right">
    <div class="navbar-collapse collapse">
        <ul class="list-inline" style="margin:0px;list-style-type:none">
            <li>
                <?php  $_smarty_tpl->tpl_vars['error'] = new Smarty_Variable; $_smarty_tpl->tpl_vars['error']->_loop = false;
 $_from = $_smarty_tpl->tpl_vars['ERROR_MESSAGES']->value; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array');}
foreach ($_from as $_smarty_tpl->tpl_vars['error']->key => $_smarty_tpl->tpl_vars['error']->value) {
$_smarty_tpl->tpl_vars['error']->_loop = true;
?>
                    <div class="alert alert-danger" style="padding: 1px 5px 1px 5px; margin:auto;"><?php echo $_smarty_tpl->tpl_vars['error']->value;?>
</div>
                <?php } ?>
            </li>
            <li>
                <a class="dropdown-toggle" data-toggle="dropdown">
                    <img class="img-responsive highlight_icon" alt="Negotiation Alerts"
                         heigth="30px" width="30px" src="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
images/icon_set/Users-User-icon.png"/>
                </a>
                <ul class="dropdown-menu" role="menu" style="padding: 15px;">
                    <form action="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
actions/users/login.php" method="post" accept-charset="UTF-8">
                        <input placeholder="Nome de utilizador" style="margin-bottom: 15px;" type="text" name="username"
                               size="30"/>
                        <input placeholder="Palavra-passe" style="margin-bottom: 15px;" type="password" name="password"
                               size="30"/>

                        <input class="btn btn-primary" style="clear: left; width: 100%; height: 32px; font-size: 13px;"
                               type="submit" name="commit" value="Sign In"/>
                    </form>
                    <a href="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
pages/users/registerseller.php" class="btn btn-success"
                       style="margin: 3px; float: right;">Registar Vendedor</a>
                    <a href="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
pages/users/registerbuyer.php" class="btn btn-success"
                       style="margin: 3px; float: right;">Registar Comprador</a>
                </ul>
            </li>
        </ul>
    </div>
</div><?php }} ?>
