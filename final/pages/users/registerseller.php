<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

$countries = getCountryList();
$smarty->assign('countries', $countries);

$smarty->display('users/registerseller.tpl');
?>
