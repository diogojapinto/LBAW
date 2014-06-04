<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'pages/common/initializer.php');
include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');


$name = trim($_POST['productName']);
$category = trim($_POST['productCategory']);

$products;

if (!isset($name) || $name == "") {

    if (!isset($category) || $category == "" || $category == "All") {
        $products = getAllProducts(0);
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

if (sizeof($products) == 0) {
    $_SESSION['error_messages'][] = 'A sua pesquisa não retornou resultados';

    header("Location: $BASE_URL" . 'index.php');
}


$smarty->assign('products', $products);

$smarty->display('products/searchList.tpl');