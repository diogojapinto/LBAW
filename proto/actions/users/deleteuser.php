<?php
include('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

if (!$_SESSION['username']) {
    $_SESSION['errors'] = array('Tem que fazer login');

    header('Location: ' . $BASE_URL);
    exit;
}

try {
    deleteUser($_SESSION['username']);
} catch(PDOException $e) {
    $_SESSION['error_messages'][] = 'Erro a apagar o utilizador '.$e->getMessage();

    header('Location: ' . $BASE_URL);
    exit;
}

session_destroy();
include('../../config/init.php');
$_SESSION['success_messages'][] = 'User deleted successfully';
header('Location: ' . $BASE_URL);
?>