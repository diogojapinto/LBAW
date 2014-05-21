<?php
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

if (!$_SESSION['username']) {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['form_values']['errors'] = array('Tem que fazer login');

    header('Location: ' . $BASE_URL);
    exit;
}

if (!userLogin($_SESSION['username'], $_POST['oldpassword'])) {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['form_values']['errors'] = array('Password errada');

    header('Location: ' . $BASE_URL . 'pages/users/edituser.php');
    exit;
}

$error = false;

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

if ($error) {
    header("Location: $BASE_URL" . 'pages/users/edituser.php');
    exit;
}

if ($_POST['password1']) {
    try {
        updateUserPassword($_SESSION['iduser'], $_POST['password1']);
    } catch (PDOException $e) {
        $_SESSION['form_values']['errors'] = array($e->getMessage());
    }
}

if ($_POST['email']) {
    try {
        updateUserEmail($_SESSION['iduser'], $_POST['email']);
    } catch (PDOException $e) {
        $_SESSION['form_values'] = $_POST;
        if (strpos($e->getMessage(), 'registereduser_email_key') !== false) {
            $_SESSION['form_values']['errors'] = array('Email já em uso por outro utilizador.');
        } elseif (strpos($e->getMessage(), 'validemail') !== false) {
            $_SESSION['form_values']['errors'] = array('Formato de email inválido.');
        } else $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na edição do perfil.');
    }
}
if ($_POST['address']) {
    try {
        updateSellerAddressLine($_SESSION['iduser'], $_POST['address']);
    } catch (PDOException $e) {
        $_SESSION['form_values'] = $_POST;
        $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na edição do perfil.');
    }
}
if ($_POST['description']) {
    try {
        updateSellerDescription($_SESSION['iduser'], $_POST['description']);
    } catch (PDOException $e) {
        $_SESSION['form_values'] = $_POST;
        $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na edição do perfil.');
    }
}
if ($_POST['city']) {
    try {
        updateSellerCity($_SESSION['iduser'], $_POST['city']);
    } catch (PDOException $e) {
        $_SESSION['form_values'] = $_POST;
        $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na edição do perfil.');
    }
}
if ($_POST['postalcode']) {
    try {
        updateSellerPostalCode($_SESSION['iduser'], $_POST['postalcode']);
    } catch (PDOException $e) {
        $_SESSION['form_values'] = $_POST;
        if (strpos($e->getMessage(), 'validpostalcode') !== false)
            $_SESSION['form_values']['errors'] = array('Formato de código postal inválido.');
        else
            $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na edição do perfil.');
    }
}
if ($_POST['country'] && $_POST['country'] > 0) {
    try {
        updateSellerCountry($_SESSION['iduser'], $_POST['country']);
    } catch (PDOException $e) {
        $_SESSION['form_values'] = $_POST;
        $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na edição do perfil.');
    }
}
if ($_POST['cellphone']) {
    try {
        updateSellerCellphone($_SESSION['iduser'], $_POST['cellphone']);
    } catch (PDOException $e) {
        $_SESSION['form_values'] = $_POST;
        if (strpos($e->getMessage(), 'validcellnumber') !== false)
            $_SESSION['form_values']['errors'] = array('Formato de número de telefone inválido.');
        else
            $_SESSION['form_values']['errors'] = array($e->getMessage(), 'Erro na edição do perfil.');
    }
}

$_SESSION['error_messages'][] = "Edição bem sucedida.";
header('Location: ' . $BASE_URL . 'pages/users/showuser.php');
?>