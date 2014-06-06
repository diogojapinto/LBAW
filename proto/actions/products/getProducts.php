<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');
header('Content-Type: application/json');

if(!isset($_GET['offset'])) {
    echo json_encode(array("error" => 'Tem que fornecer o offset'));

    exit;
}

global $productsPerBlock;

$name = trim($_GET['productName']);
$category = trim($_GET['productCategory']);
$offset = trim($_GET['offset']);

$products;

if (!isset($name) || $name == "") {

    if (!isset($category) || $category == "" || $category == "All") {
        $products = getAllProductsByBlocks($offset);
    } else {
        $products = getProductsByCategoryByBlocks($category, $offset);
    }

} else {

    if (!isset($category) || $category == "" || $category == "All") {
        $products = getProductsByNameByBlocks($name, $offset);
    } else {
        $products = getProductsByNameAndCategoryByBlocks($name, $category, $offset);
    }
}

if (sizeof($products) == 0)
    $products = array("error" => 'A sua pesquisa não retornou resultados');


echo json_encode($products);

?>