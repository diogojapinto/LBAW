<?php

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');

if (!isset($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para submeter um produto para avaliação';

    header("Location: $BASE_URL" . 'index.php');
    exit;
}


if (!isset($_POST['users'])) {
    $_SESSION['error_messages'][] = 'Escolha pelo menos um utilizador';

    header("Location: " . $_SERVER['HTTP_REFERER']);
    exit;
}

$_SESSION['success_messages'][] = 'Propostas enviadas com sucesso';

header("Location: " . $BASE_URL . "index.php");
exit;