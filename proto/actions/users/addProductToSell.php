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
    $_SESSION['error_messages'][] = 'Insira valores para a proposta';

    header('Location: ' . $_SERVER['HTTP_REFERER']);
    exit;
}

$idProduct = strip_tags($_POST['idProduct']);
$username = $_SESSION['username'];
$minimumValue = strip_tags($_POST['minimumValue']);
$averageValue = strip_tags($_POST['averageValue']);

try {

    if (addToSelling($idProduct, $username, $minimumValue, $averageValue)) {
        header('Location: ' . $BASE_URL . 'pages/negotiation/queryBuyers.php?idProduct=' . $idProduct);
        exit;
    } else {
        $_SESSION['error_messages'][] = "Algo falhou. Por favor tente novamente";
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit;
    }

} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'wantstosell_pkey') != FALSE) {
        try {
            updateSelling($idProduct, $username, $minimumValue, $averageValue);
            header('Location: ' . $BASE_URL . 'pages/negotiation/queryBuyers.php?idProduct=' . $idProduct);
            exit;
        } catch (PDOException $e) {
            if (strpos($e->getMessage(), 'ct_valid_seller_prices') != FALSE) {
                $_SESSION["error_messages"][] = "Selecione um valor mínimo inferior ao valor médio";
                $_SESSION['form_values'] = $_POST;
                header('Location: ' . $_SERVER['HTTP_REFERER']);
                exit;
            } else {
                $_SESSION["error_messages"][] = $e->getMessage();
                $_SESSION['form_values'] = $_POST;
                header('Location: ' . $_SERVER['HTTP_REFERER']);
                exit;
            }
        }
    } else
        if (strpos($e->getMessage(), 'ct_valid_seller_prices') != FALSE) {
            $_SESSION["error_messages"][] = "Selecione um valor mínimo inferior ao valor médio";
            $_SESSION['form_values'] = $_POST;
            header('Location: ' . $_SERVER['HTTP_REFERER']);
            exit;
        } else {
            $_SESSION["error_messages"][] = $e->getMessage();
            $_SESSION['form_values'] = $_POST;
            header('Location: ' . $_SERVER['HTTP_REFERER']);
            exit;
        }
}
?>