<?php

include_once($BASE_DIR . 'database/products.php');

$baseCategories = array(0 => array("name" => "All", "idcategory" => 0));
$baseCategories = array_merge($baseCategories, getRootCategories());

if (isset($_SESSION['iduser'])) {
    $notifications['privateMessages'] = getUnreadPrivateMessages($_SESSION['iduser']);
    $notifications['interactions'] = getUnreadInteractions($_SESSION['iduser']);

    $smarty->assign('notifications', $notifications);
}

$smarty->assign('baseCategories', $baseCategories);

?>