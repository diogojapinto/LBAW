<?php

include_once('../../config/init.php');
include_once($BASE_DIR . "database/users.php");
include_once($BASE_DIR . "database/negotiation.php");
include_once($BASE_DIR . "aux_classes/SellerAction.php");

if (!isset($_SESSION['username']) || !isBuyer($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para rejeitar propostas';
    header("Location: $BASE_URL" . 'index.php');
    exit;
}

$username = $_SESSION['username'];
$idDeal = $_GET['idDeal'];

declineProposal($username, $idDeal);

$pid = pcntl_fork();
if ($pid == -1) {
    $_SESSION['error_messages'][] = 'Algo correu mal';
    header('Location: '.$_SERVER["HTTP_REFERER"]);
    exit;
} else if ($pid) { // parent
    $_SESSION['success_messages'][] = 'Proposta recusada. Aguarde contra-proposta';
    header('Location: '.$_SERVER["HTTP_REFERER"]);
    exit;
} else { // child
    $stub = new SellerAction($idDeal);
    $stub->run();
}