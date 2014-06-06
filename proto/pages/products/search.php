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
        $products = getAllProductsByBlocks(0);
    } else {
        $products = getProductsByCategoryByBlocks($category, 0);
    }

} else {

    if (!isset($category) || $category == "" || $category == "All") {
        $products = getProductsByNameByBlocks($name, 0);
    } else {
        $products = getProductsByNameAndCategoryByBlocks($name, $category, 0);
    }
}

if (sizeof($products) == 0) {
    $_SESSION['error_messages'][] = 'A sua pesquisa não retornou resultados';

    header("Location: $BASE_URL" . 'index.php');
}

$smarty->assign('products', $products);
$smarty->assign('name', $name);
$smarty->assign('category', $category);

$smarty->display('products/searchList.tpl');