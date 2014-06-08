<?php

include_once('../../config/init.php');

if (!isset($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para aceitar propostas';

    header("Location: $BASE_URL" . 'index.php');
    exit;
}

$username = $_SESSION['username'];
$idDeal = $_POST['idDeal'];

acceptProposal($username, $idDeal);

// has idDeal in post
header($BASE_URL . "concludeDeal.php");
exit;