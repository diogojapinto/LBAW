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

$userType;

if (!isset($_SESSION['username']) || $_SESSION['username'] == "") {
    $userType = "unspecified";
} else {
    if (isBuyer($_SESSION['username'])) {
        $userType = "buyer";
        $isBuying = isUserBuying(getIdUser($_SESSION['username']), $product['idproduct']);
        $smarty->assign("isAlreadyBuying", $isBuying);
    } else {
        $userType = "seller";
    }
}

$smarty->assign("userType", $userType);
$smarty->assign('product', $product);
$smarty->assign('productsCount', $productsCount);
$smarty->assign('relatedProducts', $relatedProducts);

$smarty->display('products/product.tpl');

