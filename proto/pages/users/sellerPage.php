<?php
    include_once('../../config/init.php');
    include_once($BASE_DIR . 'pages/common/initializer.php');
    include_once($BASE_DIR . 'database/users.php');

    if (!$_SESSION['username']) {
        $_SESSION['error_messages'] = array('Tem que fazer login');

        header('Location: ' . $BASE_URL);
        exit;
    }

    $common = getRegisteredUser($_SESSION['username']);
    $smarty->assign('COMMON', $common);

    if (isBuyer($_SESSION['username'])) {
        $smarty->display('users/sellerPage.tpl');
    } else {
        $_SESSION['error_messages'] = array('Esse utilizador não é vendedor.');

        header('Location: ' . $BASE_URL);
        exit;
    }
?>