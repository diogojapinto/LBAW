<?php
include_once('../../config/init.php');
include_once($BASE_DIR . "database/negotiation.php");

class SellerAction
{
    private $idDeal;

    function __construct($idDeal)
    {
        $this->idDeal = $idDeal;
    }

    public function run()
    {
        $waitTime = rand(60, 60 * 5);
        sleep($waitTime);
        sellerAction($this->idDeal);
    }
} 