<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

$name = $_POST['name'];
$cat = $_POST['category'];

$products = search($name, $category);
var_dump($products);
$smarty->assign('products', $products);

$smarty->display('products/searchList.tpl');