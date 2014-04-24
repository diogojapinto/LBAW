<?php

function deleteUserById($userId)
{
    global $conn;
    $stmt = $conn->prepare("DELETE FROM RegisteredUser WHERE idUser = :id;");
    return $stmt->execute(array(':id', $userId));
}

function deleteUserByUserName($userName)
{
    global $conn;
    $stmt = $conn->prepare("DELETE FROM RegisteredUser WHERE username = :username;");
    return $stmt->execute(array(':username', $userName));
}

function checkUsername($userName)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE idUser = :id;");
    $stmt->execute(array(':id', $userName));
    $results = $stmt->fetchAll();
    if (sizeof($results) == 0)
        return true;
    else
        return false;
}

function checkEmail($email)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE email = :email;");
    $stmt->execute(array(':email', $email));
    $results = $stmt->fetchAll();
    if (sizeof($results) == 0)
        return true;
    else
        return false;
}

function registerBuyer($userName, $password, $email)
{
    if (checkUsername($userName)) {
        global $conn;
        $conn->beginTransaction();

        $stmt = $conn->prepare("INSERT INTO RegisteredUser(username, password, email) VALUES (:username, :password, :email);");

        $stmt->execute(array(':username' => $userName, ':password' => $password, ':email' => $email));

        $stmt = $conn->prepare("INSERT INTO Buyer(idUser) VALUES (currval('RegisteredUser_idUser_seq'));");

        $stmt->execute();

        return $conn->commit() == true;
    }
}

function registerSeller($userName, $password, $email, $addressLine, $postalCode, $city, $idCountry, $companyName, $cellPhone)
{
    if (checkUsername($userName)) {
        global $conn;
        $conn->beginTransaction();

        $stmt = $conn->prepare("INSERT INTO RegisteredUser(username, password, email) VALUES (:username, :password, :email);");

        $stmt->execute(array(':username' => $userName, ':password' => $password, ':email' => $email));

        $stmt = $conn->prepare("INSERT INTO Address(addressLine, postalCode, city) VALUES (:addressLine, :postalCode, :city, :idCountry);");

        $stmt->execute(array(':addressLine' => $addressLine, ':postalCode' => $postalCode, ':city' => $city, ':idCountry' => $idCountry));

        $stmt = $conn->prepare("INSERT INTO Seller(idUser, idAdresss, companyName, cellPhone)
                                VALUES (currval('RegisteredUser_idUser_seq'), currval('Address_idAddress_seq'), :companyName, :cellphone);");

        $stmt->execute(array(':companyName' => $companyName, ':cellphone' => $cellPhone));

        return $conn->commit() == true;
    }
}

function userLogin($username, $password)
{
    global $conn;
    $stmt = $conn->prepare("SELECT username
                            FROM RegisteredUser
                            WHERE username = ? AND password = ?");
    $stmt->execute(array($username, $password));
    return $stmt->fetch() == true;
}

function getInteractions($userId)
{
    global $conn;
    $stmt = $conn->prepare("SELECT interactionNo, state, date FROM Interaction WHERE idUser = :id;");
    $stmt->execute(array(':id' => $userId));
    return $stmt->fetchAll();
}

function getUnreadInteractions($userId)
{
    global $conn;
    $stmt = $conn->prepare("SELECT interactionNo, date FROM Interaction WHERE idUser = :id AND state = 'Unread';");
    $stmt->execute(array(':id' => $userId));
    return $stmt->fetchAll();
}

function getInteraction($interactionId)
{
    global $conn;

    $conn->beginTransaction();

    $stmt = $conn->prepare("SELECT amount, date, interactionType FROM Interaction WHERE interactionNo = :id;");

    $stmt->execute(array(':id' => $interactionId));

    $result = $stmt->fetch();

    $stmt = $conn->prepare("UPDATE Interaction SET state = 'Read' WHERE interactionNo = :id;");

    $stmt->execute(array(':id' => $interactionId));

    $conn->commit();

    return $result;
}

function getPrivateMessages($userId)
{
    global $conn;
    $stmt = $conn->prepare("SELECT idPM, state, subject FROM PrivateMessage WHERE idUser = :id;");
    $stmt->execute(array(':id' => $userId));
    return $stmt->fetchAll();
}

function getUnreadPrivateMessages($userId)
{
    global $conn;
    $stmt = $conn->prepare("SELECT idPM, subject FROM PrivateMessage WHERE idUser = :id AND state = 'Unread';");
    $stmt->execute(array(':id' => $userId));
    return $stmt->fetchAll();
}

function getCountryList()
{
    global $conn;
	echo 10;
    $stmt = $conn->prepare("SELECT * FROM Country ORDER BY name;");
    return $stmt->fetchAll();
}

function getPrivateMessage($privateMessageId)
{
    global $conn;

    $conn->beginTransaction();

    $stmt = $conn->prepare("SELECT subject, Content FROM PrivateMessage WHERE idPM = :id;");

    $stmt->execute(array(':id' => $privateMessageId));

    $result = $stmt->fetch();

    $stmt = $conn->prepare("UPDATE PrivateMessage SET state = 'Read' WHERE idPM =:id;");

    $stmt->execute(array(':id' => $privateMessageId));

    $conn->commit();

    return $result;
}