<?php
    include_once('../../config/init.php');
    include_once($BASE_DIR . 'pages/common/initializer.php');
    include_once($BASE_DIR . 'database/negotiation.php');
    include_once($BASE_DIR . 'database/users.php');
    include_once($BASE_DIR . 'database/products.php');

    $countries = getCountryList();
    $countries2 = getCountryList();
    $smarty->assign('countries', $countries);
$smarty->assign('countries2', $countries2);

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

    /*
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
        // todo: assign variables and show things
    */
    $smarty->assign('LASTINTERACTION', $lastInteraction);
    $smarty->assign('IDDEAL', $idDeal);

    $smarty->display('negotiation/concludeDeal.tpl');
    //}
