<?php

    include_once('../../config/init.php');
    include_once($BASE_DIR . 'pages/common/initializer.php');
    include_once($BASE_DIR . 'database/negotiation.php');
    include_once($BASE_DIR . 'database/users.php');
    include_once($BASE_DIR . 'database/products.php');

    if (!$_SESSION['username']) {
        $_SESSION['error_messages'] = array('Tem que fazer login');

        header('Location: ' . $BASE_URL);
        exit;
    }

    if (isSeller($_SESSION['username'])) {
        $_SESSION['error_messages'] = array('Operação reservada a compradores.');

        header('Location: ' . $BASE_URL);
        exit;
    }

    $username = $_SESSION['username'];
    $idDeal = $_GET['idDeal'];
    $idUser = getIdUser($username);

    $dealState = getDealState($idDeal);

    if (!$dealState) {
        $_SESSION['error_messages'] = array('Negócio não encontrado');
        header('Location: ' . $BASE_URL);
        exit;

    } else if ($dealState == "unsuccessful") {
        $_SESSION['error_messages'] = array('Negócio não teve sucesso');
        header('Location: ' . $BASE_URL);
        exit;
    } else if ($dealState == "pending" || $dealState == "answer_proposal") {
        $_SESSION['error_messages'] = array('Negócio a decorrer');
        header('Location: ' . $BASE_URL);
        exit;
    } else if ($dealState == "success") {
        $_SESSION['error_messages'] = array('Negócio a decorrer');
        header('Location: ' . $BASE_URL);
        exit;

    } else if ($dealState == "finalize") {
        if (!$_POST['idDeal'] || !$_POST['buyerAddress'] || !$_POST['buyerCity'] || !$_POST['buyerPostal'] || !$_POST['buyerCountry'] || !$_POST['billingAddress'] || !$_POST['billingCity'] || !$_POST['billingPostal'] || !$_POST['billingCountry'] || !$_POST['creditCardNumber'] || !$_POST['creditCardDate'] || !$_POST['creditCardHolder'] || !$_POST['deliveryMethod'] || !$_POST['password2']) {
            $_SESSION['form_values'] = $_POST;
            $_SESSION['form_values']['errors'] = array('Todos os campos são obrigatórios.');

            header("Location: $BASE_URL" . 'pages/negotiation/concludeDeal.php');
            exit;
        }

        finishDeal($username, $_POST['idDeal'], $_POST['buyerAddress'], $_POST['buyerCity'], $_POST['buyerPostal'], $_POST['buyerCountry'], $_POST['billingAddress'], $_POST['billingCity'], $_POST['billingPostal'], $_POST['billingCountry'], $_POST['creditCardNumber'], $_POST['creditCardDate'], $_POST['creditCardHolder'], $_POST['deliveryMethod']);

    }
?>