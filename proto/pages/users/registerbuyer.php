<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

include_once($BASE_DIR . 'pages/common/initializer.php');

$smarty->display('users/registerbuyer.tpl');
?>
