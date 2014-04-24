<?php

function deleteUserById($userId)
{
    global $conn;
    $stmt = $conn->prepare("DELETE FROM RegisteredUser WHERE idUser = :id;");
    return $stmt->execute(array(':id' => $userId));
}

function deleteUserByUserName($userName)
{
    global $conn;
    $stmt = $conn->prepare("DELETE FROM RegisteredUser WHERE username = :username;");
    return $stmt->execute(array(':username' => $userName));
}

function checkUsernameById($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE idUser = :id;");
    $stmt->execute(array(':id' => $id));
    $results = $stmt->fetchAll();
    if (sizeof($results) == 0)
        return true;
    else
        return false;
}

function checkUsernameByName($userName)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE username = :userName;");
    $stmt->execute(array(':userName' => $userName));
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
    $stmt->execute(array(':email' => $email));
    $results = $stmt->fetchAll();
    if (sizeof($results) == 0)
        return true;
    else
        return false;
}

function registerBuyer($userName, $password, $email)
{
        global $conn;
        $conn->beginTransaction();

        $stmt = $conn->prepare("INSERT INTO RegisteredUser(username, password, email) VALUES (:username, :password, :email);");

        $stmt->execute(array(':username' => $userName, ':password' => $password, ':email' => $email));

        $stmt = $conn->prepare("INSERT INTO Buyer(idBuyer) VALUES (currval('RegisteredUser_idUser_seq'));");

        $stmt->execute();

        return $conn->commit() == true;
}

function registerSeller($userName, $password, $email, $addressLine, $postalCode, $city, $idCountry, $companyName, $cellPhone)
{
        global $conn;
        $conn->beginTransaction();

        $stmt = $conn->prepare("INSERT INTO RegisteredUser(username, password, email) VALUES (:username, :password, :email);");

        $stmt->execute(array(':username' => $userName, ':password' => $password, ':email' => $email));

        $stmt = $conn->prepare("INSERT INTO Address(addressLine, postalCode, city, idCountry) VALUES (:addressLine, :postalCode, :city, :idCountry);");

        $stmt->execute(array(':addressLine' => $addressLine, ':postalCode' => $postalCode, ':city' => $city, ':idCountry' => $idCountry));

        $stmt = $conn->prepare("INSERT INTO Seller(idSeller, idAddress, companyName, cellPhone)
                                VALUES (currval('RegisteredUser_idUser_seq'), currval('Address_idAddress_seq'), :companyName, :cellphone);");

        $stmt->execute(array(':companyName' => $companyName, ':cellphone' => $cellPhone));

        return $conn->commit() == true;
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

function isBuyer($username)
{
    global $conn;
    $stmt = $conn->prepare("SELECT username
                            FROM RegisteredUser, Buyer
                            WHERE username = ? AND idUser = idBuyer");
    $stmt->execute(array($username));
    return $stmt->fetch() == true;
}

function getInteractions($userId)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Interaction.*, Product.name FROM Interaction, Deal, Product, registeredUser
                            WHERE Interaction.iddeal = Deal.iddeal AND
                                  Deal.idproduct = Product.idproduct AND
                                  Deal.idbuyer = registeredUser.idUser AND
                                  registeredUser.idUser = ?;");
    $stmt->execute(array($userId));
    return $stmt->fetchAll();
}

function getUnreadInteractions($userId)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Interaction.*, Product.name FROM Interaction, Deal, Product, registeredUser
                            WHERE Interaction.iddeal = Deal.iddeal AND
                                  Deal.idproduct = Product.idproduct AND
                                  Deal.idbuyer = registeredUser.idUser AND
                                  registeredUser.idUser = ? AND state = 'Unread';");
    $stmt->execute(array($userId));
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
    return $conn->query("SELECT * FROM Country ORDER BY name;");
}

function getIdUser($username)
{
    global $conn;
    $stmt = $conn->prepare("SELECT idUser FROM RegisteredUser WHERE username = :username;");
	$stmt->execute(array(':username' => $username));
	
	return $stmt->fetch();
}

function getRegistredUser($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE idUser = :id;");
	$stmt->execute(array(':id' => $id));
	
	return $stmt->fetch();
}

function getSeller($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT cellphone, companyName, description, addressline, city, postalCode, name
	FROM Seller, Address, Country
	WHERE Seller.idSeller = :id AND Seller.idAddress = Address.idAddress AND
		Country.idCountry = Address.idCountry;");
	$stmt->execute(array(':id' => $id));
	
	return $stmt->fetch();
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

function updateUserEmail($userid, $email) {
	global $conn;
    $stmt = $conn->prepare("UPDATE RegistredUser SET email = :email WHERE idUser = :id");
    return $stmt->execute(array(':email' => $email, ':id' => $userid));
}

function updateUserPassword($userid, $password) {
	global $conn;
    $stmt = $conn->prepare("UPDATE RegistredUser SET password = :password WHERE idUser = :id");
    return $stmt->execute(array(':password' => $password, ':id' => $userid));
}