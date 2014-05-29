<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

if ($_SESSION['username']) {
    $_SESSION['error_messages'] = array('Tem que fazer logout');

    header('Location: ' . $BASE_URL);
    exit;
}

$countries = getCountryList();
$smarty->assign('countries', $countries);

$smarty->display('users/registerseller.tpl');
?>
