<?php

/*
 * Buyer  -> Offer / Refusal
 * Seller -> Proposed / Declined
 */

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
    $avgPrice = $sellingInfo['averageprice'];
    $minPrice = $sellingInfo['minimumprice'];
    $maxPrice = 2 * $avgPrice - $minPrice;

    $idSeller = getIdUser($username);

    $conn->beginTransaction();

    // find minimum deal value
    $nrValues = 100;
    $normDist = array_distribute($sellingInfo['averageprice'], $nrValues, $minPrice, $maxPrice);
    $i = mt_rand(0, $nrValues);
    $minForSale = $normDist[$i];


    $stmt = $conn->prepare("INSERT INTO Deal (idBuyer, idSeller, idProduct, beginningDate, minSaleValue)
                            VALUES (:idBuyer, :idSeller, :idProduct, CURRENT_TIMESTAMP, :minSaleValue)");
    $stmt->execute(array('idBuyer' => $idBuyer, 'idSeller' => $idSeller, 'idProduct' => $idProduct,
        ":minSaleValue" => $minForSale));

    $lastDeal = $conn->lastInsertId();

    $stmt = $conn->prepare("INSERT INTO Interaction (idDeal, InteractionNo, amount, date, interactionType)
	                        VALUES (:idDeal, 1, :firstProposal, CURRENT_TIMESTAMP, 'Proposal');");
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

    $stmt->execute(array(":idDeal" => $idDeal, ":lastInteractionNo" => $lastInteraction + 1, ':lastAmount', $amount));

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
    // TODO
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
                            VALUES (:idDeal, :lastInteractionNo, :lastAmount, CURRENT_TIMESTAMP, 'Refusal');");

    $stmt->execute(array(":idDeal" => $idDeal, ":lastInteractionNo" => $lastInteraction + 1, ':lastAmount' => $amount));

    $conn->commit();

    //TODO: call sellerAction after some random time
}

function sellerAction($idDeal)
{

    global $conn;

    $stmt = $conn->prepare("SELECT MAX(interactionNo), amount
                            FROM Interaction
                            WHERE idDeal = :idDeal
                            GROUP BY amount;");

    $stmt->execute(array(":idDeal" => $idDeal));

    $result = $stmt->fetch();
    $lastInteraction = $result['max'];
    $amount = $result['amount'];

    // get lowest possible offer
    $stmt = $conn->prepare("SELECT minSaleValue, idseller, idproduct
                            FROM Deal
                            WHERE iddeal = :idDeal");
    $stmt->execute(array(":idDeal" => $idDeal));
    $result = $stmt->fetch();
    $minSaleValue = $result['minsalevalue'];
    $idSeller = $result['idseller'];
    $idProduct = $result['idproduct'];

    if ($minSaleValue == $amount) {
        $stmt = $conn->prepare("INSERT INTO Interaction (idDeal, InteractionNo, amount, date, interactionType)
                            VALUES (:idDeal, :lastInteractionNo, :lastAmount, CURRENT_TIMESTAMP, 'Declined');");

        $stmt->execute(array(":idDeal" => $idDeal, ":lastInteractionNo" => $lastInteraction + 1, ':lastAmount' => $amount));

    } else {
        // send new proposal
        $sellingInfo = getSellingInfo($idSeller, $idProduct);

        $lowBound = $amount - ($sellingInfo['averagevalue'] - $sellingInfo['minimumvalue']) / 2.0;
        $uppBound = $amount - ($sellingInfo['averagevalue'] - $sellingInfo['minimumvalue']) / 5.0;

        $nextValue = max(rand($lowBound, $uppBound), $minSaleValue);

        $stmt = $conn->prepare("INSERT INTO Interaction (idDeal, InteractionNo, amount, date, interactionType)
                            VALUES (:idDeal, :lastInteractionNo, :nextAmount, CURRENT_TIMESTAMP, 'Proposal');");

        $stmt->execute(array(":idDeal" => $idDeal, ":lastInteractionNo" => $lastInteraction + 1, ':nextAmount' => $nextValue));

    }
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