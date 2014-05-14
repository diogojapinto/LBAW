<?php
  include_once('../../config/init.php');
  include_once($BASE_DIR .'database/users.php');  

  if (!$_POST['username'] || !$_POST['password']) {
    $_SESSION['error_messages'][] = 'Invalid login';
    $_SESSION['form_values'] = $_POST;
    header('Location: ' . $_SERVER['HTTP_REFERER']);
    exit;
  }

  $username = $_POST['username'];
  $password = $_POST['password'];
  $id = getIdUser($username);
  $_SESSION['iduser'] = $id['iduser'];
  
  if (userLogin($username, $password)) {
    $_SESSION['username'] = $username;
    $_SESSION['success_messages'][] = 'Login successful';
      var_dump($_SESSION);
  } else {
    $_SESSION['error_messages'][] = 'Login failed';
  }

  header('Location: ' . $BASE_URL);
?>
