<?php

function deleteUserById($userId){
    global $conn;
    $stmt = $conn->prepare("DELETE FROM RegisteredUser WHERE idUser = :id;");
    return $stmt->execute(array(':id', $userId));
}

function deleteUserByUserName($userName){
    global $conn;
    $stmt = $conn->prepare("DELETE FROM RegisteredUser WHERE username = :username;");
    return $stmt->execute(array(':username', $userName));
}

function checkUsername($userName){
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM RegisteredUser WHERE idUser = :id;");
    $results = $stmt->execute(array(':id', $userName));
    if(sizeof($results) == 0)
        return true;
    else
        return false;
}

function registerBuyer($userName, $password, $email){
    if(checkUsername($userName)){
        global $conn;
        $conn->beginTransaction();

        $stmt = $conn->prepare("INSERT INTO RegisteredUser(username, password, email) VALUES (:username, :password, :email);");

        $stmt->execute(array(':username' => $userName, ':password' => $password, ':email' => $email));

        $stmt = $conn->prepare("INSERT INTO Buyer(idUser) VALUES (currval('RegisteredUser_idUser_seq'));");

        $stmt->execute();

        return $conn->commit();
    }
}

function registerSeller($userName, $password, $email, $addressLine, $postalCode, $city, $idCountry, $companyName, $cellPhone){
    if(checkUsername($userName)){
        global $conn;
        $conn->beginTransaction();

        $stmt = $conn->prepare("INSERT INTO RegisteredUser(username, password, email) VALUES (:username, :password, :email);");

        $stmt->execute(array(':username' => $userName, ':password' => $password, ':email' => $email));

        $stmt = $conn->prepare("INSERT INTO Address(addressLine, postalCode, city) VALUES (:addressLine, :postalCode, :city, :idCountry);");

        $stmt->execute(array(':addressLine' => $addressLine, ':postalCode' => $postalCode, ':city' => $city, ':idCountry' => $idCountry));

        $stmt = $conn->prepare("INSERT INTO Seller(idUser, idAdresss, companyName, cellPhone)
                                VALUES (currval('RegisteredUser_idUser_seq'), currval('Address_idAddress_seq'), :companyName, :cellphone);");

        $stmt->execute(array(':companyName' => $companyName, ':cellphone' => $cellPhone));

        return $conn->commit();
    }
}

function createUser($realname, $username, $password) {
    global $conn;
    $stmt = $conn->prepare("INSERT INTO users VALUES (?, ?, ?)");
    $stmt->execute(array($username, $realname, sha1($password)));
}

function isLoginCorrect($username, $password) {
    global $conn;
    $stmt = $conn->prepare("SELECT * 
                            FROM users 
                            WHERE username = ? AND password = ?");
    $stmt->execute(array($username, sha1($password)));
    return $stmt->fetch() == true;
}
