<?php
    include_once('../../config/init.php');
    include_once($BASE_DIR . 'pages/common/initializer.php');
    include_once($BASE_DIR . 'database/negotiation.php');
    include_once($BASE_DIR . 'database/users.php');
    include_once($BASE_DIR . 'database/products.php');

    /*if (!$_SESSION['username']) {
        $_SESSION['error_messages'] = array('Tem que fazer login');

        header('Location: ' . $BASE_URL);
        exit;
    }

    if(isSeller($_SESSION['username'])) {
        $_SESSION['error_messages'] = array('Operação reservada a compradores.');

        header('Location: ' . $BASE_URL);
        exit;
    }*/

    $username = $_SESSION['username'];
    $idDeal = $_POST['idDeal'];
    $idUser = getIdUser($username);

    /*if(!$lastInteraction = hasDealEnded($idDeal)){
        $_SESSION['error_messages'] = array('Negócio não finalizado');

        header('Location: ' . $BASE_URL);
        exit;
    }*/
    var_dump($lastInteraction);

    $smarty->assign('LASTINTERACTION', $lastInteraction);

    $smarty->display('negotiation/concludeDeal.tpl');
