<?php
/**
 * Created by IntelliJ IDEA.
 * User: Acer
 * Date: 28/04/2014
 * Time: 23:57
 */ 
 
include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');

  echo $_POST['name'], $_POST['image'], $_POST['description'], $_POST['category'];
    /*
  if (!isset($_POST['name']) || $_POST['name'] != ""
      || !isset($_POST['image'])
      || !isset($_POST['description']) || $_POST['description'] != ""
      || $_POST['category'] == '-1') {
    $_SESSION['form_values'] = $_POST;
	$_SESSION['form_values']['errors'] = array('Todos os campos são obrigatórios.');
	
	header("Location: $BASE_URL" . 'pages/products/add.php');
    exit;
  }*/
  
  $name = $_POST['name'];
  $image = $_POST['image'];
  $description = $_POST['description'];
  $category = $_POST['category'];
 /*
  try{
	insertProduct($name, $description, $category);
  } catch(PDOException $e) {
        echo $e->errorInfo;
  }
  */