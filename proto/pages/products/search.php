<?php
/**
 * Created by IntelliJ IDEA.
 * User: Vinnie
 * Date: 23-Apr-14
 * Time: 9:33 PM
 */
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');
include_once($BASE_DIR . 'database/users.php');

if (!$_POST['name'] && $_POST['category'] == '-1') {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['form_values']['errors'] = array('Todos os campos são obrigatórios.');

    header("Location: $BASE_URL");
    exit;
}

$products = search($_POST['name'], $_POST['category']);

$baseCategories = getRootCategories();

$notifications['privateMessages'] = getUnreadPrivateMessages($_SESSION['iduser']);

$notifications['interactions'] = getUnreadInteractions($_SESSION['iduser']);

$smarty->assign('notifications', $notifications);

$smarty->assign('products', $products);

$smarty->assign('baseCategories', $baseCategories);

$smarty->display('products/list.tpl');