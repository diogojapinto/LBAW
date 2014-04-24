<?php
include_once('config/init.php');
include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');

$baseCategories = getRootCategories();

$allHighestRatedProducts = getHighestRatedProducts();
/*for ($i = 0; $i < 4; $i++) {
    $rand[i] = rand(0, sizeof($allHighestRatedProducts) - 1);
    for ($j = 0; $j < $i; $j++) {
        if ($rand[$i] == $rand[$j]) {
            $i--;
            break;
        }
    }
}*/
$rand[0] = 0;
$rand[1] = 1;
$rand[2] = 2;
$rand[3] = 3;

for($i = 0; $i < 4; $i++) {
    $selectedProducts[$i] = $allHighestRatedProducts[$rand[$i]];
}


$highestRatedProducts = getHighestRatedProducts();

$notifications['privateMessages'] = getUnreadPrivateMessages($_SESSION['iduser']);

$notifications['interactions'] = getUnreadInteractions($_SESSION['iduser']);

$smarty->assign('notifications', $notifications);

$smarty->assign('products', $products);

$smarty->assign('baseCategories', $baseCategories);

$smarty->assign('baseCategories', $baseCategories);
$smarty->assign('highestRatedProducts', $selectedProducts);
$smarty->display('common/index.tpl');

?>
