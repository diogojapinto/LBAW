<?php /* Smarty version Smarty-3.1.15, created on 2014-04-23 14:09:30
         compiled from "/srv/www/htdocs/realezy/RealezyFinal/templates/common/menu_logged_out.tpl" */ ?>
<?php /*%%SmartyHeaderCode:15195888325357c99a98cd66-75728298%%*/if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'b973c794e48c51e77a2055bacecd066c0ce73152' => 
    array (
      0 => '/srv/www/htdocs/realezy/RealezyFinal/templates/common/menu_logged_out.tpl',
      1 => 1386927924,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '15195888325357c99a98cd66-75728298',
  'function' => 
  array (
  ),
  'variables' => 
  array (
    'BASE_URL' => 0,
  ),
  'has_nocache_code' => false,
  'version' => 'Smarty-3.1.15',
  'unifunc' => 'content_5357c99a991295_37916723',
),false); /*/%%SmartyHeaderCode%%*/?>
<?php if ($_valid && !is_callable('content_5357c99a991295_37916723')) {function content_5357c99a991295_37916723($_smarty_tpl) {?><a href="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
pages/users/register.php">Register</a>
<form action="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
actions/users/login.php" method="post">
  <input type="text" placeholder="username" name="username">
  <input type="password" placeholder="password" name="password">
  <input type="submit" value=">">
</form>
<?php }} ?>
