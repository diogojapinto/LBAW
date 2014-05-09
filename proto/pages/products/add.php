<?php
/**
 * Created by IntelliJ IDEA.
 * User: Acer
 * Date: 25/04/2014
 * Time: 01:22
 */

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

$smarty->assign('products', $products);

$smarty->display('products/add.tpl');