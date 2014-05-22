<?php
  include('../../config/init.php');
  session_destroy();
  
  include('../../config/init.php');
  $_SESSION['success_messages'][] = 'Logout successful';

  header('Location: ' . $BASE_URL);
?>
