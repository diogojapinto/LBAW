<?php
include_once('config/init.php');
include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/products.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

$allHighestRatedProducts = getHighestRatedProducts();

$rand;

$i;

for ($i = 0; $i < 4; $i++) {
    $rand[$i] = rand(0, sizeof($allHighestRatedProducts) - 1);
    for ($j = 0; $j < $i; $j++) {
        if ($rand[$i] == $rand[$j]) {
            $i--;
            break;
        }
    }
}

for($i = 0; $i < 4; $i++) {
    $selectedProducts[$i] = $allHighestRatedProducts[$rand[$i]];
}

$highestRatedProducts = getHighestRatedProducts();

$smarty->assign('products', $products);

$smarty->assign('highestRatedProducts', $selectedProducts);

$smarty->display('common/index.tpl');

?>
