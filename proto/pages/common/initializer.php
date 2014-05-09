<?php

include_once($BASE_DIR . 'database/products.php');

$baseCategories = array("All");
$baseCategories = getRootCategories();

if (isset($_SESSION['iduser'])) {
    $notifications['privateMessages'] = getUnreadPrivateMessages($_SESSION['iduser']);
    $notifications['interactions'] = getUnreadInteractions($_SESSION['iduser']);

    $smarty->assign('notifications', $notifications);
}

$smarty->assign('notifications', $notifications);

?>