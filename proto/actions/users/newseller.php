<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

if (!$_POST['password1'] || !$_POST['password2'] || !$_POST['email'] || !$_POST['username'] || !$_POST['address'] || !$_POST['postalcode'] || !$_POST['city'] || $_POST['country'] === '-1' || !$_POST['companyname'] || !$_POST['cellphone']) {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['form_values']['errors'] = array('Todos os campos s�o obrigat�rios.');

    header("Location: $BASE_URL" . 'pages/users/registerseller.php');
    exit;
}
$username = $_POST['username'];
$email = $_POST['email'];
$password1 = $_POST['password1'];
$password2 = $_POST['password2'];
$addressLine = $_POST['address'];
$postalCode = $_POST['postalcode'];
$city = $_POST['city'];
$idCountry = $_POST['country'];
$companyName = $_POST['companyname'];
$cellPhone = $_POST['cellphone'];

$_SESSION['form_values'] = $_POST;
$error = false;

if (strlen($username) > 80) {
    $error = true;
    $_SESSION['form_values']['errors'] = array('O número máximo de caratéres para o nome de utilizador é de 80.');
}

if (strlen($companyName) > 80) {
    $error = true;
    $_SESSION['form_values']['errors'] = array('O número máximo de caratéres para o nome da empresa é de 80.');
}

if (strlen($addressLine) > 140) {
    $error = true;
    $_SESSION['form_values']['errors'] = array('O número máximo de caratéres para a morada é de 140.');
}

if (strlen($city) > 80) {
    $error = true;
    $_SESSION['form_values']['errors'] = array('O número máximo de caratéres para o nome de uma cidade é de 80.');
}

if ($password1 !== $password2) {
    $error = true;
    $_SESSION['form_values']['errors'] = array('As passwords não são iguais.');
    if (strlen($password1) > 80) {
        $_SESSION['form_values']['errors'] = array('O número máximo de caratéres para a password é de 80.');
    }
}

if($error) {
    header("Location: $BASE_URL" . 'pages/users/registerseller.php');
    exit;
}

try {
    registerSeller($username, $password1, $email, $addressLine, $postalCode, $city, $idCountry, $companyName, $cellPhone);
} catch (PDOException $e) {

    $_SESSION['form_values'] = $_POST;
    if (strpos($e->getMessage(), 'registereduser_email_key') !== false) {
        $_SESSION['form_values']['errors'] = array('Email duplicado.');
    } elseif (strpos($e->getMessage(), 'registereduser_username_key') !== false) {
        $_SESSION['form_values']['errors'] = array('Nome de utilizador duplicado.');
    } elseif (strpos($e->getMessage(), 'validemail') !== false) {
        $_SESSION['form_values']['errors'] = array('Formato de email inválido.');
    } elseif (strpos($e->getMessage(), 'validpostalcode') !== false) {
        $_SESSION['form_values']['errors'] = array('Formato de código postal inválido.');
    } elseif (strpos($e->getMessage(), 'validcellnumber') !== false) {
        $_SESSION['form_values']['errors'] = array('Formato de número de telefone inválido.');
    } else $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na criaçãoo do utilizador.');

    header("Location: $BASE_URL" . 'pages/users/registerseller.php');
    exit;
}

$id = getIdUser($username);
$_SESSION['iduser'] = $id['iduser'];

header("Location: $BASE_URL");
?>
