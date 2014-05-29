<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

if (!$_POST['password1'] || !$_POST['password2'] || !$_POST['email'] || !$_POST['username']) {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['form_values']['errors'] = array('Todos os campos s�o obrigat�rios.');

    header("Location: $BASE_URL" . 'pages/users/registerbuyer.php');
    exit;
}
$username = $_POST['username'];
$email = $_POST['email'];
$password1 = $_POST['password1'];
$password2 = $_POST['password2'];

$error = false;

if (strlen($username) > 80) {
    $_SESSION['form_values']['errors'] = array('O número máximo de caratéres para o nome de utilizador é de 80.');
}

if ($password1 !== $password2) {
    $_SESSION['form_values']['errors'] = array('As passwords não são iguais.');
    if (strlen($password1) > 80) {
        $_SESSION['form_values']['errors'] = array('O número máximo de caratéres para a password é de 80.');
    }
}

if ($error) {
    header("Location: $BASE_URL" . 'pages/users/registerseller.php');
    exit;
}

try {
    registerBuyer($username, $password1, $email);
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
    } else $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na criaçãoo do utilizador.');

    header("Location: $BASE_URL" . 'pages/users/registerbuyer.php');

    exit;
}

$id = getIdUser($username);
session_regenerate_id();
$_SESSION['username'] = $username;
$_SESSION['usertype'] = 'buyer';
$_SESSION['success_messages'][] = 'Login successful';

header("Location: $BASE_URL");
?>
