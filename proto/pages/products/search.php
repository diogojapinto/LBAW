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


$name = $_POST['name'];
$cat = $_POST['category'];

$products = search($name, $cat);

$baseCategories = getRootCategories();

$notifications['privateMessages'] = getUnreadPrivateMessages($_SESSION['iduser']);

$notifications['interactions'] = getUnreadInteractions($_SESSION['iduser']);

$smarty->assign('notifications', $notifications);

$smarty->assign('products', $products);

$smarty->assign('baseCategories', $baseCategories);

$smarty->display('products/list.tpl');