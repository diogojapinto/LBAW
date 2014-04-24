<?php
  include_once('../../config/init.php');
  include_once($BASE_DIR .'database/users.php');  

  if (!$_POST['password1'] || !$_POST['password2'] || !$_POST['email'] || !$_POST['username'] || !$_POST['address'] || !$_POST['postalcode'] || !$_POST['city'] || $_POST['country'] === '-1' || !$_POST['companyname'] || !$_POST['cellphone'] ) {
    $_SESSION['form_values'] = $_POST;
	$_SESSION['form_values']['errors'] = array('Todos os campos são obrigatórios.');

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
  
  if( $password1 !== $password2 ) {
	$_SESSION['form_values'] = $_POST;
	$_SESSION['form_values']['errors'] = array('As passwords não são iguais.');

    header("Location: $BASE_URL" . 'pages/users/registerseller.php');
    exit;
  }
  /*
  try {
    registerSeller($username, $password1, $email, $addressLine, $postalCode, $city, $idCountry, $companyName, $cellPhone);
  } catch (PDOException $e) {
  
    $_SESSION['form_values'] = $_POST;
    if (strpos($e->getMessage(), 'registereduser_email_key') !== false) {
      $_SESSION['form_values']['errors'] = array('Email duplicado.');
    }
	elseif (strpos($e->getMessage(), 'registereduser_username_key') !== false) {
      $_SESSION['form_values']['errors'] = array('Nome de utilizador duplicado.');
    }
    else $_SESSION['form_values']['errors'] = array($e->getMessage(),'Erro na criação do utilizador.');
	
    header("Location: $BASE_URL" . 'pages/users/registerseller.php');
	
    exit;
  }*/
  registerSeller($username, $password1, $email, $addressLine, $postalCode, $city, $idCountry, $companyName, $cellPhone);
  $_SESSION['username'] = $username;
  header("Location: $BASE_URL");
?>
