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

    $stmt = $conn->prepare("INSERT INTO Deal (idBuyer, idSeller, idProduct, beginningdate)
                            VALUES (:idBuyer, :idSeller, :idProduct, CURRENT_TIMESTAMP)");
    $stmt->execute(array('idBuyer' => $idBuyer, 'idSeller' => $idSeller, 'idProduct' => $idProduct));

    $lastDeal = $conn->lastInsertId();

    $stmt = $conn->prepare("INSERT INTO Interaction (idDeal, InteractionNo, amount, date, interactionType)
	                        VALUES (:idDeal, 0, :firstProposal, CURRENT_TIMESTAMP, 'Proposal');");
    $stmt->execute(array(':idDeal' => $lastDeal, ':firstProposal' => $maxPrice));

    $conn->commit();

}

function acceptProposal($username, $idDeal)
{
    global $conn;

    if (!isBuyer($username)) {
        return false;
    }

    $conn->beginTransaction();

    $stmt = $conn->prepare("SELECT MAX(interactionNo), amount
                            FROM Interaction
                            WHERE idDeal = :idDeal
                            GROUP BY amount;");

    $stmt->execute(array(":idDeal" => $idDeal));

    $result = $stmt->fetch();
    $lastInteraction = $result['max'];
    $amount = $result['amount'];

    $stmt = $conn->prepare("INSERT INTO Interaction (idDeal, InteractionNo, amount, date, interactionType)
                            VALUES (:idDeal, :lastInteractionNo, :lastAmount, CURRENT_TIMESTAMP, 'Offer');");

    $stmt->execute(array(":idDeal" => $idDeal, ":lastInteractionNo" => $lastInteraction, ':lastAmount', $amount));

    $conn->commit();
}

function hasDealEnded($idDeal)
{
    global $conn;

    $stmt = $conn->prepare("SELECT MAX(interactionNo), interactionType, amount
                            FROM Interaction
                            WHERE idDeal = :idDeal
                            GROUP BY amount, interactionType;");

    $stmt->execute(array(":idDeal" => $idDeal));

    $result = $stmt->fetch();

    if ($result['interactiontype'] == "Offer") {
        $ret = array("amount" => $result['amount'], "state" => "success");
        return $ret;
    } else if ($result['interactiontype'] == "Refusal" || $result['interactiontype'] == "Declined") {
        $ret = array("state" => "failure");
        return $ret;
    } else {
        return false;
    }
}

function finishDeal($username, $idDeal, $billingAddress, $shippingAddress, $creditCard)
{
    global $conn;

    if (!isBuyer($username)) {
        return false;
    }

    $conn->beginTransaction();

    $stmt = $conn->prepare("SELECT MAX(interactionNo), amount
                            FROM Interaction
                            WHERE idDeal = :idDeal
                            ORDER BY amount;");

    $stmt->execute(array(":idDeal" => $idDeal));
    $result = $stmt->fetch();
    $amount = $result['amount'];


    $stmt = $conn->prepare("UPDATE Deal
                            SET dealState = 'Successful',
                                endDate = CURRENT_TIMESTAMP,
                                deliveryMethod = :deliveryMethod,
                                idBuyerInfo = :idBuyerInfo
                            WHERE idDeal = :idDeal;");

    $conn->commit();
}

function declineProposal($username, $idDeal)
{
    /*
     * TODO
     * Don't forget to use Proposal & Declined.
     */
    global $conn;

    if (!isBuyer($username)) {
        return false;
    }

    $conn->beginTransaction();

    $stmt = $conn->prepare("SELECT MAX(interactionNo), amount
                            FROM Interaction
                            WHERE idDeal = :idDeal
                            GROUP BY amount;");

    $stmt->execute(array(":idDeal" => $idDeal));

    $result = $stmt->fetch();
    $lastInteraction = $result['max'];
    $amount = $result['amount'];

    $stmt = $conn->prepare("INSERT INTO Interaction (idDeal, InteractionNo, amount, date, interactionType)
                            VALUES (:idDeal, :lastInteractionNo, :lastAmount, CURRENT_TIMESTAMP, 'Offer');");

    $stmt->execute(array(":idDeal" => $idDeal, ":lastInteractionNo" => $lastInteraction, ':lastAmount', $amount));

    $conn->commit();
}

/*
* @param float  $mean, desired average
* @param number $sd, number of items in array
* @param number $min, minimum desired random number
* @param number $max, maximum desired random number
* @return array
*/
function array_distribute($mean, $sd, $min, $max)
{
    $result = array();
    $total_mean = intval($mean * $sd);
    while ($sd > 1) {
        $allowed_max = $total_mean - $sd - $min;
        $allowed_min = intval($total_mean / $sd);
        $random = mt_rand(max($min, $allowed_min), min($max, $allowed_max));
        $result[] = $random;
        $sd--;
        $total_mean -= $random;
    }
    $result[] = $total_mean;
    return $result;
}