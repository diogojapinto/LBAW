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

$product = getProduct($_GET['idProduct']);

$relatedProducts = getProductsByCategory($product['category']);

shuffle($relatedProducts);

$baseCategories = getRootCategories();


$notifications['privateMessages'] = getUnreadPrivateMessages($_SESSION['iduser']);

$notifications['interactions'] = getUnreadInteractions($_SESSION['iduser']);

$smarty->assign('notifications', $notifications);

$smarty->assign('product', $product);

$smarty->assign('relatedProducts', $relatedProducts);

$smarty->assign('baseCategories', $baseCategories);

$smarty->display('products/product.tpl');

