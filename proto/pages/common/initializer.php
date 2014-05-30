<?php

include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');

$baseCategories = array(0 => array("name" => "All", "idcategory" => 0));
$baseCategories = array_merge($baseCategories, getRootCategories());

if (isset($_SESSION['username'])) {
    $iduser = getIdUser($_SESSION['username']);
    $notifications['privateMessages'] = getUnreadPrivateMessages($iduser);
    $notifications['interactions'] = getUnreadInteractions($iduser);

    $smarty->assign('notifications', $notifications);
}

$smarty->assign('baseCategories', $baseCategories);

?>