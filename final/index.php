<?php
include_once('config/init.php');
include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/products.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

$highestRatedProducts = getHighestRatedProducts();

shuffle($highestRatedProducts);

$highestRatedProducts = array_slice($highestRatedProducts, 0, 4);

$smarty->assign('products', $products);

$smarty->assign('highestRatedProducts', $highestRatedProducts);

$smarty->display('common/index.tpl');

?>
