<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'pages/common/initializer.php');
include_once($BASE_DIR . 'database/negotiation.php');


//TODO : query interested buyers (username) and respective price

$smarty->display('negotiation/queryBuyers.tpl');


function organizeBuyers($buyers, $minimumPrice, $averagePrice) {
    $retBuyers = array(3);
    foreach ($buyers as $buyer) {
        // TODO
    }

    return $retBuyers;
}