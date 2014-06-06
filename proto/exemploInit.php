<?php
session_set_cookie_params(3600, '/LBAW/proto');
session_start();
/*
error_reporting(E_ALL);
ini_set('display_errors', '1');
*/
$BASE_DIR = '/var/www/LBAW/proto/';
$BASE_URL = '/LBAW/proto/';
$productsPerBlock = 4;

$conn = new PDO('pgsql:host=192.168.1.80;dbname=postgres', 'lbaw1312', 'eN123ln9');
$conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

include_once($BASE_DIR . 'lib/smarty/Smarty.class.php');

$smarty = new Smarty;

$smarty->template_dir = $BASE_DIR . 'templates/';
$smarty->compile_dir = $BASE_DIR . 'templates_c/';
$smarty->assign('BASE_URL', $BASE_URL);
$smarty->assign('PRODUCT_PER_BLOCK', $productsPerBlock);

$smarty->assign('ERROR_MESSAGES', $_SESSION['error_messages']);
$smarty->assign('FIELD_ERRORS', $_SESSION['field_errors']);
$smarty->assign('SUCCESS_MESSAGES', $_SESSION['success_messages']);
$smarty->assign('FORM_VALUES', $_SESSION['form_values']);
$smarty->assign('USERNAME', $_SESSION['username']);
$smarty->assign('USERTYPE', $_SESSION['usertype']);

unset($_SESSION['success_messages']);
unset($_SESSION['error_messages']);
unset($_SESSION['field_errors']);
unset($_SESSION['form_values']);
?>