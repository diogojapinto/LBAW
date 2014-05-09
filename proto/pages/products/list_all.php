<?php
/**
 * Created by IntelliJ IDEA.
 * User: Vinnie
 * Date: 23-Apr-14
 * Time: 9:33 PM
 */

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

$products = getAllProducts();

$smarty->assign('products', $products);

$smarty->display('products/list.tpl');

