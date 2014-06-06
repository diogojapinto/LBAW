<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'pages/common/initializer.php');
include_once($BASE_DIR . 'database/negotiation.php');

if (!$_SESSION['username']) {
    $_SESSION['error_messages'] = array('Tem que fazer login');

    header('Location: ' . $BASE_URL);
    exit;
}

function sort_by_date($a, $b) {
    return $a['date'] < $b['date'];
}

$iduser = getIdUser($_SESSION['username']);

$interactions = getInteractions($iduser);
foreach($interactions as &$interaction) {
    $interaction['type'] = 'interaction';
   // $interaction['ended'] = hasDealEnded($interaction['iddeal']);
}
$privateMessages = getPrivateMessages($iduser);
foreach($privateMessages as &$privateMessage)
    $privateMessage['type'] = 'privateMessage';

$notifications = array_merge($interactions, $privateMessages);
uksort($notifications, "sort_by_date");

$smarty->assign('fullnotifications', $notifications);
$smarty->display('users/shownotifications.tpl');
?>