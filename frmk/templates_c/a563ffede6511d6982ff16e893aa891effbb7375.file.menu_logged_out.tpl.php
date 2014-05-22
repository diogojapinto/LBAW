<?php /* Smarty version Smarty-3.1.15, created on 2014-04-11 09:35:49
         compiled from "/opt/lbaw/lbaw1312/public_html/frmk/templates/common/menu_logged_out.tpl" */ ?>
<?php /*%%SmartyHeaderCode:869988015347a965162397-19331523%%*/if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'a563ffede6511d6982ff16e893aa891effbb7375' => 
    array (
      0 => '/opt/lbaw/lbaw1312/public_html/frmk/templates/common/menu_logged_out.tpl',
      1 => 1386927924,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '869988015347a965162397-19331523',
  'function' => 
  array (
  ),
  'variables' => 
  array (
    'BASE_URL' => 0,
  ),
  'has_nocache_code' => false,
  'version' => 'Smarty-3.1.15',
  'unifunc' => 'content_5347a965174e74_59504997',
),false); /*/%%SmartyHeaderCode%%*/?>
<?php if ($_valid && !is_callable('content_5347a965174e74_59504997')) {function content_5347a965174e74_59504997($_smarty_tpl) {?><a href="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
pages/users/register.php">Register</a>
<form action="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
actions/users/login.php" method="post">
  <input type="text" placeholder="username" name="username">
  <input type="password" placeholder="password" name="password">
  <input type="submit" value=">">
</form>
<?php }} ?>
