<?php

function deleteUser($username)
{
    global $conn;
    /*
        $stmt = $conn->prepare("SELECT iduser FROM RegisteredUser WHERE username = :username");
        $stmt->execute(array(':username' => $username));
        $result = $stmt->fetch();
        $id = $result['iduser'];

        if(!$id)
            return;

        $conn->beginTransaction();

        $stmt = $conn->prepare("DELETE FROM Address WHERE username = :username;");
        $stmt->execuite(array(':username' => $username));*/

    $stmt = $conn->prepare("DELETE FROM RegisteredUser WHERE username = :username;");
    $stmt->execute(array(':username' => $username));
}

function checkUsernameById($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE idUser = :id;");
    $stmt->execute(array(':id' => $id));
    $results = $stmt->fetchAll();
    if (sizeof($results) == 0) return true; else
        return false;
}

function checkUsernameByName($userName)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE username = :userName;");
    $stmt->execute(array(':userName' => $userName));
    $results = $stmt->fetchAll();
    if (sizeof($results) == 0) return true; else
        return false;
}

function checkEmail($email)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE email = :email;");
    $stmt->execute(array(':email' => $email));
    $results = $stmt->fetchAll();
    if (sizeof($results) == 0) return true; else
        return false;
}

function registerBuyer($userName, $password, $email)
{
    global $conn;
    $conn->beginTransaction();

    $stmt = $conn->prepare("INSERT INTO RegisteredUser(username, password, email) VALUES (:username, :password, :email);");

    $stmt->execute(array(':username' => $userName, ':password' => sha1($password), ':email' => $email));

    $stmt = $conn->prepare("INSERT INTO Buyer(idBuyer) VALUES (currval('RegisteredUser_idUser_seq'));");

    $stmt->execute();

    return $conn->commit() == true;
}

function registerSeller($userName, $password, $email, $addressLine, $postalCode, $city, $idCountry, $companyName, $cellPhone, $description)
{
    global $conn;
    $conn->beginTransaction();

    $stmt = $conn->prepare("INSERT INTO RegisteredUser(username, password, email) VALUES (:username, :password, :email);");

    $stmt->execute(array(':username' => $userName, ':password' => sha1($password), ':email' => $email));

    $stmt = $conn->prepare("INSERT INTO Address(addressLine, postalCode, city, idCountry) VALUES (:addressLine, :postalCode, :city, :idCountry);");

    $stmt->execute(array(':addressLine' => $addressLine, ':postalCode' => $postalCode, ':city' => $city, ':idCountry' => $idCountry));

    $stmt = $conn->prepare("INSERT INTO Seller(idSeller, idAddress, companyName, cellPhone, description)
                                VALUES (currval('RegisteredUser_idUser_seq'), currval('Address_idAddress_seq'),
                                :companyName, :cellphone, :description);");

    $stmt->execute(array(':companyName' => $companyName, ':cellphone' => $cellPhone, ':description' => $description));

    return $conn->commit() == true;
}

function userLogin($username, $password)
{
    global $conn;
    $stmt = $conn->prepare("SELECT username
                            FROM RegisteredUser
                            WHERE username = ? AND password = ?");
    $stmt->execute(array($username, sha1($password)));

    return $stmt->fetch() == true;
}

function isBuyer($username)
{
    global $conn;
    $stmt = $conn->prepare("SELECT username
                            FROM RegisteredUser, Buyer
                            WHERE username = ? AND idUser = idBuyer");
    $stmt->execute(array($username));
    $result = $stmt->fetch();

    return $result['username'] == $username;
}

function isSeller($username)
{
    global $conn;
    $stmt = $conn->prepare("SELECT username
                            FROM RegisteredUser, Seller
                            WHERE username = ? AND idUser = idSeller");
    $stmt->execute(array($username));
    $result = $stmt->fetch();

    return $result['username'] == $username;
}

function getInteractions($userId)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Interaction.*, Product.name
                                FROM Interaction, Deal as Deal1, Product, registeredUser
                                WHERE Interaction.iddeal = Deal1.iddeal AND
                                    Deal1.idproduct = Product.idproduct AND
                                    Deal1.idbuyer = registeredUser.idUser AND
                                    registeredUser.idUser = ? AND
                                    Interaction.interactionNo = (SELECT MAX(Interaction.interactionNo)
                                                                 FROM Interaction
                                                                 WHERE Interaction.idDeal = Deal1.idDeal);");
    $stmt->execute(array($userId));

    $result = $stmt->fetchAll();

    foreach ($result as &$interaction) {
        $stmt = $conn->prepare("SELECT RegisteredUser.username FROM RegisteredUser, Interaction, Deal
                                    WHERE Interaction.iddeal = ? AND
                                    interactionNo = ? AND
                                    Interaction.iddeal = Deal.iddeal AND
                                    Deal.idSeller = RegisteredUser.iduser;");

        $stmt->execute(array($interaction['iddeal'], $interaction['interactionno']));
        $temp = $stmt->fetchAll();
        $interaction['username'] = $temp[0]['username'];
    }

    return $result;
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

    $result = $stmt->fetchAll();

    foreach ($result as &$interaction) {
        $stmt = $conn->prepare("SELECT RegisteredUser.username FROM RegisteredUser, Interaction, Deal
                                    WHERE Interaction.iddeal = ? AND
                                    interactionNo = ? AND
                                    Interaction.iddeal = Deal.iddeal AND
                                    Deal.idSeller = RegisteredUser.iduser;");

        $stmt->execute(array($interaction['iddeal'], $interaction['interactionno']));
        $temp = $stmt->fetchAll();
        $interaction['username'] = $temp[0]['username'];
    }

    return $result;
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

    $user = $stmt->fetch();

    return $user['iduser'];
}

function getUsername($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT username FROM RegisteredUser WHERE iduser = :id;");
    $stmt->execute(array(':id' => $id));

    $user = $stmt->fetch();

    return $user['username'];
}

function getRegisteredUser($username)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE username = :username");
    $stmt->execute(array(':username' => $username));

    return $stmt->fetch();
}

function getRegisteredUserById($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE iduser = :id");
    $stmt->execute(array(':id' => $id));

    return $stmt->fetch();
}

function getSeller($iduser)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Seller.idseller, cellphone, companyName, description, addressline, city, postalCode, name
	FROM Seller, Address, Country
	WHERE Seller.idSeller = :iduser AND Seller.idAddress = Address.idAddress AND
		Country.idCountry = Address.idCountry");
    $stmt->execute(array(':iduser' => $iduser));

    return $stmt->fetch();
}

function isPrivateMessageFromUser($privateMessageId, $username)
{
    global $conn;

    $stmt = $conn->prepare("SELECT PrivateMessage.idUser FROM PrivateMessage, RegisteredUser
                            WHERE idPM = :id AND PrivateMessage.idUser = RegisteredUser.idUser
                            AND username = :username;");

    $stmt->execute(array(':id' => $privateMessageId, ':username' => $username));

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

function updateUserEmail($userid, $email)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE RegisteredUser SET email = :email WHERE idUser = :id");

    return $stmt->execute(array(':email' => $email, ':id' => $userid));
}

function updateUserPassword($userid, $password)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE RegisteredUser SET password = :password WHERE idUser = :id");

    return $stmt->execute(array(':password' => sha1($password), ':id' => $userid));
}

function updateSellerCellphone($userid, $cellphone)
{
    global $conn;

    $stmt = $conn->prepare("UPDATE Seller SET cellphone = :cellphone WHERE idUser = :id");

    return $stmt->execute(array(':cellphone' => $cellphone, ':id' => $userid));
}

function updateSellerCompanyName($userid, $companyname)
{
    global $conn;

    $stmt = $conn->prepare("UPDATE Seller SET companyname = :companyname WHERE idSeller = :id");

    return $stmt->execute(array(':companyname' => $companyname, ':id' => $userid));
}

function updateSellerDescription($userid, $description)
{
    global $conn;

    $stmt = $conn->prepare("UPDATE Seller SET description = :description WHERE idSeller = :id");

    return $stmt->execute(array(':description' => $description, ':id' => $userid));
}

function updateSellerAddressLine($userid, $address)
{
    global $conn;

    $stmt = $conn->prepare("SELECT idAddress FROM Seller WHERE idSeller = :id;");
    $stmt->execute(array(':id' => $userid));
    $result = $stmt->fetch();
    $idAddress = $result['idaddress'];

    $stmt = $conn->prepare("UPDATE Address SET addressline = :addressline WHERE idAddress = :id");

    return $stmt->execute(array(':addressline' => $address, ':id' => $idAddress));
}

function updateSellerCity($userid, $city)
{
    global $conn;

    $stmt = $conn->prepare("SELECT idAddress FROM Seller WHERE idSeller = :id;");
    $stmt->execute(array(':id' => $userid));
    $result = $stmt->fetch();
    $idAddress = $result['idaddress'];

    $stmt = $conn->prepare("UPDATE Address SET city = :city WHERE idAddress = :id");

    return $stmt->execute(array(':city' => $city, ':id' => $idAddress));
}

function updateSellerPostalCode($userid, $postalcode)
{
    global $conn;

    $stmt = $conn->prepare("SELECT idAddress FROM Seller WHERE idSeller = :id;");
    $stmt->execute(array(':id' => $userid));
    $result = $stmt->fetch();
    $idAddress = $result['idaddress'];

    $stmt = $conn->prepare("UPDATE Address SET postalcode = :postalcode WHERE idAddress = :id");

    return $stmt->execute(array(':postalcode' => $postalcode, ':id' => $idAddress));
}

function updateSellerCountry($userid, $country)
{
    global $conn;

    $stmt = $conn->prepare("SELECT idAddress FROM Seller WHERE idSeller = :id;");
    $stmt->execute(array(':id' => $userid));
    $result = $stmt->fetch();
    $idAddress = $result['idaddress'];

    $stmt = $conn->prepare("UPDATE Address SET idcountry = :country WHERE idAddress = :id");

    return $stmt->execute(array(':country' => $country, ':id' => $idAddress));
}

function hashPass()
{
    $i = 1;

    while (($user = getRegisteredUserById($i)) != false) {
        updateUserPassword($i, $user['password']);
        $i++;
    }
}