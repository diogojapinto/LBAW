<?php

include_once('../../config/init.php');
include_once($BASE_DIR . "database/users.php");
include_once($BASE_DIR . "database/negotiation.php");

if (!isset($_SESSION['username']) || !isBuyer($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para rejeitar propostas';
    header("Location: $BASE_URL" . 'index.php');
    exit;
}

$username = $_SESSION['username'];
$idDeal = $_GET['idDeal'];

declineProposal($username, $idDeal);

exec($BASE_DIR . 'actions/negotiations/sellerAction.php ' . $idDeal . ' > /dev/null &');

//include_once($BASE_DIR . 'actions/negotiations/sellerAction.php');

$_SESSION['success_messages'][] = 'Proposta recusada. Aguarde contra-proposta';
header('Location: ' . $_SERVER["HTTP_REFERER"]);