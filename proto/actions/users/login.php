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
echo 0;
  if (userLogin($username, $password)) {
	session_regenerate_id();
      echo 1;
    $_SESSION['username'] = $username;
	$_SESSION['iduser'] = $id['iduser'];
	
	if( isBuyer($username) )
		$_SESSION['usertype'] = 'buyer';
	else
		$_SESSION['usertype'] = 'seller';
      echo 0;
    $_SESSION['success_messages'][] = 'Login successful';
  } else {
      echo 3;
    $_SESSION['error_messages'][] = 'Login failed';
  }

  header('Location: ' . $BASE_URL);
?>
