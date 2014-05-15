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

$product = getProduct($_GET['productId']);

$relatedProducts = getProductsByCategory($product['idcategory']);

shuffle($relatedProducts);

$productsCount = min(sizeof($relatedProducts), 4);

$smarty->assign('product', $product);
$smarty->assign('productsCount', $productsCount);
$smarty->assign('relatedProducts', $relatedProducts);

$smarty->display('products/product.tpl');

