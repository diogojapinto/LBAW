<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');
header('Content-Type: application/json');

if(!$_SESSION['username'])
    $notifications = array("error" => "Acesso nao autorizado");
else {
    $iduser = getIdUser($_SESSION['username']);
    $notifications['privateMessages'] = getUnreadPrivateMessages($iduser);
    $notifications['interactions'] = getUnreadInteractions($iduser);
    $notifications['count'] = count($notifications['privateMessages']) + count($notifications['interactions']);
}

echo json_encode($notifications);

?>