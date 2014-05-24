<?php
include_once($BASE_DIR . 'database/users.php');

if (isset($_SESSION['iduser'])) {
    $unreadNotifications['privateMessages'] = getUnreadPrivateMessages($_SESSION['iduser']);
    $unreadNotifications['interactions'] = getUnreadInteractions($_SESSION['iduser']);

    $smarty->assign('notifications', $unreadNotifications);
} else {

}

?>