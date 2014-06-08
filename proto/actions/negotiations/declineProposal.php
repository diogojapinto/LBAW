<?php

include_once('../../config/init.php');
include_once($BASE_DIR . "database/negotiation");
include_once($BASE_DIR . "aux_classes/SellerAction.php");

if (!isset($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para rejeitar propostas';
    header("Location: $BASE_URL" . 'index.php');
    exit;
}

$username = $_SESSION['username'];
$idDeal = $_POST['idDeal'];

declineProposal($username, $idDeal);

$thread = new SellerAction($idDeal);
$thread->start();

header($_SERVER["HTTP_REFERER"]);

exit;