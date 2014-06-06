<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');
header('Content-Type: application/json');

$idPrivateMessage = $_GET['idPrivateMessage'];

if(!$_SESSION['username'] || !isPrivateMessageFromUser($idPrivateMessage, $_SESSION['username']))
    $privateMessage = array("error" => "Acesso nao autorizado");
else $privateMessage = getPrivateMessage($idPrivateMessage);

echo json_encode($privateMessage);

?>