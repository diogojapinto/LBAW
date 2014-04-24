<?php
  include_once('../config/init.php');
  include_once($BASE_DIR .'database/users.php');
  
  $countries = getCountryList();
  $smarty->assign('countries', $countries);
  
  $smarty->display('users/registerbuyer.tpl');
?>
