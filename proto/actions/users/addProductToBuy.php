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

$idProduct = strip_tags($_POST['idProduct']);
$proposedValue = strip_tags($_POST['proposedValue']);
$username = $_SESSION['username'];

try {
    addToBuying($idProduct, $username, $proposedValue);

    $_SESSION["success_messages"][] = "Proposta de compra adicionada com sucesso";
    header('Location: ' . $_SERVER['HTTP_REFERER']);
    exit;
} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'wantstobuy_pkey') !== false) {
        try {
            // there is a previous value
            updateBuying($idProduct, $username, $proposedValue);
            $_SESSION["success_messages"][] = "Proposta de compra alterada com sucesso";
            header('Location: ' . $_SERVER['HTTP_REFERER']);
            exit;
        } catch (PDOException $e) {
            $_SESSION["error_messages"][] = $e->getMessage();
            $_SESSION['form_values'] = $_POST;
            header('Location: ' . $_SERVER['HTTP_REFERER']);
        }
    }
    $_SESSION["error_messages"][] = $e->getMessage();
    $_SESSION['form_values'] = $_POST;
    header('Location: ' . $_SERVER['HTTP_REFERER']);
}
?>