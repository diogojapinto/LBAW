<?php

include_once('../../config/init.php');
include_once($BASE_DIR . "database/negotiation.php");
include_once($BASE_DIR . "database/users.php");

if (!isset($_SESSION['username']) || !isBuyer($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para aceitar propostas';

    header("Location: $BASE_URL" . 'index.php');
    exit;
}

$username = $_SESSION['username'];
$idDeal = $_GET['idDeal'];

acceptProposal($username, $idDeal);

$_SESSION['success_messages'][] = 'Proposta aceite';

header('Location: ' . $BASE_URL . "pages/negotiation/concludeDeal.php");
exit;