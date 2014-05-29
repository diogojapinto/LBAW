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
    $smarty->display('users/showbuyer.tpl');
} else {
    $iduser = getIdUser($_SESSION['username']);
    $seller = getSeller($iduser);
    $smarty->assign('SELLER', $seller);
    $smarty->display('users/showseller.tpl');
}
?>