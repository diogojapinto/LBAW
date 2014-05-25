<?php

function getInterestedBuyers($idProduct)
{
    global $conn;

    $stmt = $conn->prepare("SELECT username, idUser, proposedPrice
                            FROM RegisteredUser, Buyer NATURAL JOIN WantsToBuy
                            WHERE idProduct = :idProduct
                              AND idUser = idBuyer");
    $stmt->execute(array(':idProduct' => $idProduct));

    $results = $stmt->fetchAll();

    for ($i = 0; $i < sizeof($results); $i++) {
        $results[$i]['proposedprice'] = floatval($results[$i]['proposedprice']);
    }

    return $results;
}

function beginDeal($username, $idBuyer, $idProduct)
{

    global $conn;

    if (!isSeller($username)) {
        return false;
    }

    // determine the max selling price for this product
    $sellingInfo = getSellingInfo($username, $idProduct);
    $maxPrice = 2 * $sellingInfo['averageprice'] - $sellingInfo['minimumprice'];

    $idSeller = getIdUser($username);

    $conn->beginTransaction();

    $stmt = $conn->prepare("INSERT INTO Deal (idBuyer, idSeller, idProduct)
                            VALUES (:idBuyer, :idSeller, :idProduct)");
    $stmt->execute(array('idBuyer' => $idBuyer, 'idSeller' => $idSeller, 'idProduct' => $idProduct));

    $lastDeal = $conn->lastInsertId();

    $stmt = $conn->prepare("INSERT INTO Interaction (idDeal, InteractionNo, amount, date, interactionType)
	                        VALUES (:idDeal, 0, :firstProposal, CURRENT_TIMESTAMP);");
    $stmt->execute(array(':idDeal' => $lastDeal, ':firstProposal' => $maxPrice));

    $conn->commit();

}

function declineProposal($username) {



}

function acceptProposal($username) {

}

/*
* @param float  $mean, desired average
* @param number $sd, number of items in array
* @param number $min, minimum desired random number
* @param number $max, maximum desired random number
* @return array
*/
function array_distribute($mean,$sd,$min,$max){
    $result = array();
    $total_mean = intval($mean*$sd);
    while($sd>1){
        $allowed_max = $total_mean - $sd - $min;
        $allowed_min = intval($total_mean/$sd);
        $random = mt_rand(max($min,$allowed_min),min($max,$allowed_max));
        $result[]=$random;
        $sd--;
        $total_mean-=$random;
    }
    $result[] = $total_mean;
    return $result;
}