<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'pages/common/initializer.php');
include_once($BASE_DIR . 'database/negotiation.php');
include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/products.php');

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
$idDeal = $_POST['idDeal'];
$idUser = getIdUser($username);

$dealState = getDealState($idDeal);
if (!$dealState) {
    $_SESSION['error_messages'] = array('Negócio não encontrado');
    header('Location: ' . $BASE_URL);
    exit;

} else if ($dealState != "finalize") {
    $_SESSION['error_messages'] = array('Negócio não finalizado');
    header('Location: ' . $BASE_URL);
    exit;

} else if ($dealState == "unsuccessful") {
    $_SESSION['error_messages'] = array('Negócio não teve sucesso');
    header('Location: ' . $BASE_URL);
    exit;
    /*
     * possible states:
     * finalize, unsuccessful, success, (false)
     */
} else if ($dealState == "pending" || $dealState == "answer_proposal") {


}

$smarty->assign('LASTINTERACTION', $lastInteraction);

$smarty->display('negotiation/concludeDeal.tpl');
