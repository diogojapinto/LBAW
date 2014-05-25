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