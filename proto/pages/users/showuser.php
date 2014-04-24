<?php
  include_once('../../config/init.php');
  include_once($BASE_DIR .'database/users.php');
   
  $common = getRegistredUser($_SESSION['iduser']);
  $smarty->assign('COMMON', $common); 
   
  if(isBuyer($_SESSION['username']))
	$smarty->display('users/showbuyer.tpl');
  else {
    $seller = getSeller($_SESSION['iduser']);
    $smarty->assign('SELLER', $seller); 
	$smarty->display('users/showseller.tpl');
  }
?>