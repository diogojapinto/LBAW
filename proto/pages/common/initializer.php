<?php

include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');

$baseCategories = array(0 => array("name" => "All", "idcategory" => 0));
$baseCategories = array_merge($baseCategories, getRootCategories());

if (isset($_SESSION['username'])) {
    $iduser = getIdUser($_SESSION['username']);
    $notifications['privateMessages'] = getUnreadPrivateMessages($iduser);
    $notifications['interactions'] = getUnreadInteractions($iduser);

    $nr = 0;
    foreach($notifications['privateMessages'] as $n){
        if($n['state']='Unread')
            $nr++;
    }
    foreach($notifications['interactions'] as $n){
        if($n['state']='Unread')
            $nr++;
    }
    $notifications['count'] = $nr;
    $notifications['privateMessages'] = array_slice($notifications['privateMessages'], 0, 3);
    $notifications['interactions'] = array_slice($notifications['interactions'], 0, 3);
    $smarty->assign('notifications', $notifications);
}

$smarty->assign('baseCategories', $baseCategories);

?>