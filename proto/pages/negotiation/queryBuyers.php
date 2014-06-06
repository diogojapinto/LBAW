<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'pages/common/initializer.php');
include_once($BASE_DIR . 'database/negotiation.php');
include_once($BASE_DIR . 'database/products.php');

    if (!$_SESSION['username']) {
        $_SESSION['error_messages'] = array('Tem que fazer login');

        header('Location: ' . $BASE_URL);
        exit;
    }

    $username = $_SESSION['username'];
$idProduct = $_GET['idProduct'];

    $sellingInfo = getSellingInfo($username, $idProduct);

$buyers = getInterestedBuyers($idProduct);
if (sizeof($buyers) == 0) {
    $_SESSION['error_messages'][] = 'Ninguém está interessado neste produto. Por favor tente mais tarde';
    header('Location: ' . $_SERVER['HTTP_REFERER']);
    exit;
}


$buyers = organizeBuyers($buyers, $sellingInfo['minimumprice'], $sellingInfo['averageprice']);

$smarty->assign('LOW_BUYERS', $buyers[0]);
$smarty->assign('MID_BUYERS', $buyers[1]);
$smarty->assign('HIGH_BUYERS', $buyers[2]);

$smarty->display('negotiation/queryBuyers.tpl');


function organizeBuyers($buyers, $minimumPrice, $averagePrice)
{
    $retBuyers = array();
    foreach ($buyers as $buyer) {
        if ($buyer['proposedprice'] < $minimumPrice) {
            $retBuyers[0][] = $buyer;
        } else if ($buyer['proposedprice'] >= $minimumPrice && $buyer['proposedprice'] <= $averagePrice) {
            $retBuyers[1][] = $buyer;
        } else {
            $retBuyers[2][] = $buyer;
        }
    }

    return $retBuyers;
}