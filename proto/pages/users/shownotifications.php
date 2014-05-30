<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'pages/common/initializer.php');

if (!$_SESSION['username']) {
    $_SESSION['error_messages'] = array('Tem que fazer login');

    header('Location: ' . $BASE_URL);
    exit;
}

$smarty->display('users/shownotifications.tpl');

?>