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

$i = 0;
foreach ($relatedProducts as $prod) {
    if ($prod['idproduct'] == $product['idproduct']) {
        unset($relatedProducts[$i]);
        break;
    }
    $i++;
}

shuffle($relatedProducts);

$productsCount = min(sizeof($relatedProducts), 4);

$userType;

if (!isset($_SESSION['username']) || $_SESSION['username'] == "") {
    $userType = "unspecified";
} else {
    $username = $_SESSION['username'];
    if (isBuyer($_SESSION['username'])) {
        $userType = "buyer";
        $buyingPrice = isUserBuying($_SESSION['username'], $product['idproduct']);
        if ($buyingPrice != false) {
            $smarty->assign('isAlreadyBuying', true);
            $smarty->assign('buyingPrice', $buyingPrice);
        }
    } else {
        $userType = 'seller';
        $isDealRunning = isDealRunning($username, $product['idproduct']);
        $smarty->assign("isDealRunning", $isDealRunning);

        if (!$isDealRunning) {
            $previousSaleInfo = getSellingInfo($username, $product['idproduct']);
            $smarty->assign('minimumPrice', $previousSaleInfo['minimumprice']);
            $smarty->assign('averagePrice', $previousSaleInfo['averageprice']);
        }
    }
}

$smarty->assign('userType', $userType);
$smarty->assign('product', $product);
$smarty->assign('productsCount', $productsCount);
$smarty->assign('relatedProducts', $relatedProducts);

$smarty->display('products/product.tpl');

