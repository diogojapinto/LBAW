<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/products.php');

if (!$_SESSION['username']) {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['error_messages'][] = 'Tem que iniciar sessão';

    header('Location: ' . $BASE_URL);
    exit;
}

if (!isset($_POST['idProduct']) || !isset($_POST['proposedValue'])) {

}
?>