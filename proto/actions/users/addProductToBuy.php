<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');

if (!$_SESSION['username']) {
    $_SESSION['error_messages'][] = 'Tem que iniciar sessão';

    header('Location: ' . $BASE_URL);
    exit;
}

if (!isset($_POST['idProduct']) || $_POST['idProduct'] == "" || !isset($_POST['proposedValue']) || $_POST['proposedValue'] == "") {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['error_messages'][] = 'Especifique um valor para a proposta';

    header('Location: ' . $_SERVER['HTTP_REFERER']);
    exit;
}

$idProduct = $_POST['idProduct'];
$proposedValue = $_POST['proposedValue'];
$username = $_SESSION['username'];

try {
    addToBuying($idProduct, $username, $proposedValue);

    $_SESSION["success_messages"][] = "Produto adicionado com sucesso";
    header('Location: ' . $BASE_URL);
    exit;
} catch (PDOException $e) {
    $_SESSION["error_messages"][] = $e->getMessage();
    $_SESSION['form_values'] = $_POST;
    header('Location: ' . $_SERVER['HTTP_REFERER']);
}
?>