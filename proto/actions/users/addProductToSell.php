<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');

if (!$_SESSION['username']) {
    $_SESSION['error_messages'][] = 'Tem que iniciar sessão';

    header('Location: ' . $BASE_URL);
    exit;
}

if (!isset($_POST['idProduct']) || $_POST['idProduct'] == "" || !isset($_POST['minimumValue']) || $_POST['minimumValue'] == "" || !isset($_POST['averageValue']) || $_POST['averageValue'] == "") {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['error_messages'][] = 'Tem que iniciar sessão';

    header('Location: ' . $_SERVER['HTTP_REFERER']);
}

$idProduct = $_POST['idProduct'];
$username = $_POST['username'];
$minimumValue = $_POST['minimumValue'];
$averageValue = $_POST['averageValue'];

try {

    addToSelling($idProduct, $username, $minimumValue, $averageValue);

    header('Location: ' . 'pages/negotiation/queryBuyers.php');

} catch (PDOException $e) {
    $_SESSION["error_messages"][] = $e->getMessage();
    $_SESSION['form_values'] = $_POST;
    header('Location: ' . $_SERVER['HTTP_REFERER']);
}
?>