<?php

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');

if (!isset($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para submeter propostas';

    header("Location: $BASE_URL" . 'index.php');
    exit;
}


if (!isset($_POST['users'])) {
    $_SESSION['error_messages'][] = 'Escolha pelo menos um utilizador';

    header("Location: " . $_SERVER['HTTP_REFERER']);
    exit;
}

$users = $_POST['users'];
$username = $_SESSION['username'];

$successes = 0;
$failures = 0;

foreach ($users as $user) {
    if (!beginDeal($username, $user, $id)) {
        $failures++;
    } else {
        $successes++;
    }
}

$_SESSION['success_messages'][] = $successes . ' propostas enviadas com sucesso';

if ($failures != 0) {
    $_SESSION['error_messages'][] = $failures . ' propostas falhadas';
}

header("Location: " . $BASE_URL . "index.php");
exit;