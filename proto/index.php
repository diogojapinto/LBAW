<?php
include_once('config/init.php');
include_once('database/products.php');

$baseCategories = getRootCategories();
$highestRatedProducts = getHighestRatedProducts();

$smarty->assign('baseCategories', $baseCategories);
$smarty->display('common/index.tpl');

?>
