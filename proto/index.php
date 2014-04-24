<?php
include_once('config/init.php');
include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');

$baseCategories = getRootCategories();

$highestRatedProducts = getHighestRatedProducts();

$notifications['privateMessages'] = getUnreadPrivateMessages($_SESSION['iduser']);

$notifications['interactions'] = getUnreadInteractions($_SESSION['iduser']);

$smarty->assign('notifications', $notifications);

$smarty->assign('products', $products);

$smarty->assign('baseCategories', $baseCategories);

$smarty->assign('baseCategories', $baseCategories);

$smarty->display('common/index.tpl');

?>
