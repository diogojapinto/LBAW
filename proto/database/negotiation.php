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
        $result = $stmt->execute(array(':idBuyer' => $idBuyer, ':idSeller' => $idSeller, ':idProduct' => $idProduct, ":minSaleValue" => $minForSale));

        $lastDeal = $conn->lastInsertId('deal_iddeal_seq');

        $stmt = $conn->prepare("INSERT INTO Interaction (idDeal, InteractionNo, amount, date, interactionType)
	                        VALUES (:idDeal, 1, :firstProposal, CURRENT_TIMESTAMP, 'Proposal');");
        $stmt->execute(array(':idDeal' => $lastDeal, ':firstProposal' => $maxPrice));

        $conn->commit();

        return true;
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

        $stmt = $conn->prepare("UPDATE Deal
                            SET dealState = 'Successful'
                            WHERE idDeal = ?;");

        $stmt->execute(array($idDeal));

        $conn->commit();
    }

    function getDealState($idDeal)
    {
        /*
         * possible states:
         * pending, answer_proposal, finalize, unsuccessful, success, (false)
         */
        $response = null;

        global $conn;

        $stmt = $conn->prepare("SELECT dealState
                            FROM Deal
                            WHERE idDeal = ?");

        $stmt->execute(array($idDeal));
        $result = $stmt->fetch();

        if (!$result) {
            return false;
        }

        $dealState = $result['dealstate'];

        switch ($dealState) {
            case "Pending":

                $stmt = $conn->prepare("SELECT MAX(interactionNo), interactionType
                            FROM Interaction
                            WHERE idDeal = :idDeal
                            GROUP BY amount, interactionType;");

                $stmt->execute(array(":idDeal" => $idDeal));

                $result = $stmt->fetch();

                $interactionType = $result['interactiontype'];

                switch ($interactionType) {
                    case "Refusal":
                        $response = "pending";
                        break;
                    case "Proposal":
                        $response = "answer_proposal";
                        break;
                }

                break;
            case "Unsuccessful":
                $response = "unsuccessful";
                break;
            case "Successful":
                $response = "finalize";
                break;
            case "Delivered":
                $response = "success";
                break;
            default:
                return false;
        }

        return $response;
    }

    function finishDeal($username, $idDeal, $buyerAddress, $buyerCity, $buyerPostal, $buyerCountry, $billingAddress, $billingCity, $billingPostal, $billingCountry, $creditCardNumber, $creditCardDate, $creditCardHolder, $deliveryMethod)
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
        $temp = $stmt->fetch();
        $amount = $temp['amount'];

        $stmt = $conn->prepare("INSERT INTO Address (addressline, postalcode, city, idcountry)
                            VALUES (?, ?, ?, ?);");
        $stmt->execute(array($buyerAddress, $buyerPostal, $buyerCity, $buyerCountry));
        $shippingAddress = $conn->lastInsertId("address_idaddress_seq");

        $stmt = $conn->prepare("INSERT INTO Address (addressline, postalcode, city, idcountry)
                            VALUES (?, ?, ?, ?);");
        $stmt->execute(array($billingAddress, $billingPostal, $billingCity, $billingCountry));
        $billingAddress = $conn->lastInsertId("address_idaddress_seq");

        $stmt = $conn->prepare("INSERT INTO CreditCard (idbuyer, ownername, number, duedate)
                            VALUES (?, ?, ?, ?);");
        $stmt->execute(array(getIdUser($username), $creditCardHolder, $creditCardNumber, $creditCardDate));
        $creditCard = $conn->lastInsertId("address_idaddress_seq");

        $stmt = $conn->prepare("INSERT INTO BuyerInfo (idshippingaddress, idbillingaddress, idcreditcard)
                            VALUES (?, ?, ?);");
        $stmt->execute(array($shippingAddress, $billingAddress, $creditCard));
        $buyerInfo = $conn->lastInsertId("address_idaddress_seq");

        $stmt = $conn->prepare("UPDATE Deal
                            SET dealState = 'Successful',
                                endDate = CURRENT_TIMESTAMP,
                                deliveryMethod = ?,
                                idBuyerInfo = ?
                            WHERE idDeal = ?;");

        $stmt->execute(array($deliveryMethod, $buyerInfo, $idDeal));

        $stmt = $conn->prepare("UPDATE Deal
                            SET dealState = 'Delivered'
                            WHERE idDeal = ?;");

        $stmt->execute(array($idDeal));

        $conn->commit();

        sendFinishedDealEmail($username, $idDeal, $billingAddress, $shippingAddress, $amount);
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

        $stmt = $conn->prepare("UPDATE Deal
                            SET dealState = 'Unsuccessful'
                            WHERE idDeal = ?;");

        $stmt->execute(array($idDeal));

        $conn->commit();
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

            $stmt = $conn->prepare("UPDATE Deal
                            SET dealState = 'Unsuccessful'
                            WHERE idDeal = ?;");

            $stmt->execute(array($idDeal));

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

    function getLastAmount($idDeal)
    {
        global $conn;

        $conn->beginTransaction();

        $stmt = $conn->prepare("SELECT MAX(interactionNo), amount
                            FROM Interaction
                            WHERE idDeal = :idDeal
                            GROUP BY amount;");

        $stmt->execute(array(":idDeal" => $idDeal));

        $result = $stmt->fetch();
        $amount = $result['amount'];

        return $amount;
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

    function sendFinishedDealEmail($username, $idDeal, $billingAddress, $shippingAddress, $amount)
    {
        global $conn;
        $stmt = $conn->prepare("SELECT email FROM RegisteredUser WHERE username = :username;");
        $stmt->execute(array(':username' => $username));
        $email = $stmt->fetch();

        $stmt = $conn->prepare("SELECT name
                            FROM deal, product
                            WHERE idDeal = :idDeal AND product.idproduct = deal.idproduct ;");
        $stmt->execute(array(":idDeal" => $idDeal));

        $pname = $stmt->fetch();

        $sendermail = "realezy@realezy.pt";
        $headers = "MIME-Version: 1.1\r\n";
        $headers .= "Content-type: text/plain; charset=iso-8859-1\r\n";
        $headers .= "From: " . $sendermail . "\r\n"; // remetente
        $headers .= "Return-Path: realezy@realezy.pt\r\n";
        $subject = "Finished Deal on " . $pname;
        $message = "Dear Customer,\r\n";
        $message .= "You've successfully purchased " . $pname . " for the amount of " . $amount . " euros.\r\n\r\n";
        $message .= "Billing Adress:\r\n";
        $message .= $billingAddress . "\r\n";
        $message .= "Shiping Address:\r\n";
        $message .= $shippingAddress . "\r\n\r\n";
        $message .= "Best regards,\r\n";
        $message .= "Realezy.";

        mail($email, $subject, $message, $headers);
    }