<?php

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/negotiation.php');

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
$idProduct = intval($_POST['idProduct']);

$successes = 0;
$failures = 0;

foreach ($users as $user) {
    $success = false;
    try {
        $success = beginDeal($username, $user, $idProduct);
    } catch (PDOException $e) {
        $_SESSION['error_messages'][] = $e->getMessage();
        $failures++;
    }
    if (!$success) {
        $failures++;
    } else {
        $successes++;
    }
}

if($successes != 0) {
    $_SESSION['success_messages'][] = $successes . ' propostas enviadas com sucesso';
}

if ($failures != 0) {
    $_SESSION['error_messages'][] = $failures . ' propostas falhadas';
}

header("Location: " . $BASE_URL);
exit;