<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

$name = trim($_POST['productName']);
$category = trim($_POST['productCategory']);

$products;

if (!isset($name) || $name == "") {

    if (!isset($category) || $category == "" || $category == "All") {
        $products = getAllProducts();
    } else {
        $products = getProductsByCategory($category);
    }

} else {

    if (!isset($category) || $category == "" || $category == "All") {
        $products = getProductsByName($name);
    } else {
        $products = getProductsByNameAndCategory($name, $category);
    }
}


$smarty->assign('products', $products);

$smarty->display('products/searchList.tpl');