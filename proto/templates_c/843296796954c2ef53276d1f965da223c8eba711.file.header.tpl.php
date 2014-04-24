<?php /* Smarty version Smarty-3.1.15, created on 2014-04-24 17:44:51
         compiled from "/srv/www/htdocs/realezy/proto/templates/common/header.tpl" */ ?>
<?php /*%%SmartyHeaderCode:19814652895359071a822881-79815394%%*/if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '843296796954c2ef53276d1f965da223c8eba711' => 
    array (
      0 => '/srv/www/htdocs/realezy/proto/templates/common/header.tpl',
      1 => 1398356215,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '19814652895359071a822881-79815394',
  'function' => 
  array (
  ),
  'version' => 'Smarty-3.1.15',
  'unifunc' => 'content_5359071a83cd99_49875115',
  'variables' => 
  array (
    'BASE_URL' => 0,
    'baseCategories' => 0,
    'baseCategory' => 0,
    'USERNAME' => 0,
  ),
  'has_nocache_code' => false,
),false); /*/%%SmartyHeaderCode%%*/?>
<?php if ($_valid && !is_callable('content_5359071a83cd99_49875115')) {function content_5359071a83cd99_49875115($_smarty_tpl) {?>﻿<!DOCTYPE html>
<html>

<head>
    <title>Realezy - Realize os seus desejos, "the easy way"</title>
    <meta content="text/html; charset=iso-8859-1" name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
css/bootstrap.min.css" rel="stylesheet">
    <link href="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
css/styles.css" rel="stylesheet">
</head>

<body>

<div class="navbar navbar-inverse navbar-static-desktop">

    <div class="container">

        <div class="row">
            <div class="col-md-2">
                <a class="navbar-brand" href="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
">
                    <img class="img-responsive" style="margin-top:-12px;"
                         src="<?php echo $_smarty_tpl->tpl_vars['BASE_URL']->value;?>
images/icon_set/logo.png" height="40px"
                         width="100px"
                         alt="Realezy Logo"/>
                </a>
            </div>

            <button class="navbar-toggle" data-toggle="collapse" data-target=".navHeaderCollapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>

            <div class="container collapse navbar-collapse navHeaderCollapse" style="margin-top:7px">
                <div class="container col-md-8">
                    <div class="col-md-6 navbar-search">
                        <input type="text" placeholder="Produto" class="form-control">
                    </div>
                    <div class="col-md-6">
                        <div class="btn-group">
                            <button id="btnCategory" type="button" class="btn btn-danger" data-toggle="dropdown">
                                Categorias
                            </button>
                            <button type="button" style="z-index:1" class="btn btn-danger dropdown-toggle"
                                    data-toggle="dropdown">
                                <span class="caret"></span>
                                <span class="sr-only">Toggle Dropdown</span>
                            </button>
                            <button type="button"
                                    style="z-index:0;left:-4px;border-top-right-radius:4px; border-bottom-right-radius:4px;"
                                    class="btn btn-success">
                                <span class="glyphicon glyphicon-search"></span>
                                <span class="sr-only">Toggle Dropdown</span>
                            </button>
                            <ul class="dropdown-menu" role="menu">

                                <?php  $_smarty_tpl->tpl_vars['baseCategory'] = new Smarty_Variable; $_smarty_tpl->tpl_vars['baseCategory']->_loop = false;
 $_from = $_smarty_tpl->tpl_vars['baseCategories']->value; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array');}
foreach ($_from as $_smarty_tpl->tpl_vars['baseCategory']->key => $_smarty_tpl->tpl_vars['baseCategory']->value) {
$_smarty_tpl->tpl_vars['baseCategory']->_loop = true;
?>
                                    <li><a class="categoryLink" href="#"><?php echo $_smarty_tpl->tpl_vars['baseCategory']->value['name'];?>
</a></li>
                                <?php } ?>

                            </ul>
                        </div>
                        <a data-toggle="modal" id="advSearchBtn" href="#advSearch" class="btn">Pesquisa
                            Avan&ccedil;ada</a>
                    </div>
                </div>
                <?php if ($_smarty_tpl->tpl_vars['USERNAME']->value) {?>
                    <?php echo $_smarty_tpl->getSubTemplate ('common/menu_logged_in.tpl', $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, null, array(), 0);?>

                <?php } else { ?>
                    <?php echo $_smarty_tpl->getSubTemplate ('common/menu_logged_out.tpl', $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, null, array(), 0);?>

                <?php }?>
            </div>
        </div>
    </div>
</div><?php }} ?>
