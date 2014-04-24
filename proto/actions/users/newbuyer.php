<?php
  include_once('../../config/init.php');
  include_once($BASE_DIR .'database/users.php');  

  if (!$_POST['password1'] || !$_POST['password2'] || !$_POST['email'] || !$_POST['username']) {
    $_SESSION['form_values'] = $_POST;
	$_SESSION['form_values']['errors'] = array('Todos os campos são obrigatórios.');

    header("Location: $BASE_URL" . 'pages/users/registerbuyer.php');
    exit;
  }
  $username = $_POST['username'];
  $email = $_POST['email'];
  $password1 = $_POST['password1'];
  $password2 = $_POST['password2'];
  
  if( $password1 !== $password2 ) {
	$_SESSION['form_values'] = $_POST;
	$_SESSION['form_values']['errors'] = array('As passwords não são iguais.');

    header("Location: $BASE_URL" . 'pages/users/registerbuyer.php');
    exit;
  }
  
  try {
    registerBuyer($username, $password1, $email);
  } catch (PDOException $e) {
  
    $_SESSION['form_values'] = $_POST;
    if (strpos($e->getMessage(), 'registereduser_email_key') !== false) {
      $_SESSION['form_values']['errors'] = array('Nome de utilizador ou email duplicados.');
    }
    else $_SESSION['form_values']['errors'] = array($e->getMessage(),'Erro na criação do utilizador.');
	
    header("Location: $BASE_URL" . 'pages/users/registerbuyer.php');
	
    exit;
  }
  
  $id = getIdUser($username);
  $_SESSION['iduser'] = $id['iduser'];
  
  header("Location: $BASE_URL");
?>
