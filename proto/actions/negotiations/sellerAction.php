<?php
include_once('../../config/init.php');
include_once($BASE_DIR . "database/negotiation.php");

$idDeal = $_GET['idDeal'];
$waitTime = rand(60, 60 * 5);
//sleep($waitTime);
sellerAction($idDeal);