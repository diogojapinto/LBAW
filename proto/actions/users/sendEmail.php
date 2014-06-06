<?php
include_once('../../config/init.php');
if (!$_GET['email'] || !$_GET['subject'] || !$_GET['message']){
    $_SESSION['form_values'] = $_GET;
    $_SESSION['form_values']['errors'] = array('Por favor preencha todos os campos.');

    header("Location: $BASE_URL");
    exit;
}

$headers = "MIME-Version: 1.1\r\n";
$headers .= "Content-type: text/plain; charset=iso-8859-1\r\n";
$headers .= "From: noreply@realezy.pt\r\n"; // remetente
//$headers .= "Return-Path: eu@seudominio.com\r\n";
$destination=$_GET['email'];
$subject=$_GET['subject'];
$message=$_GET['message'];

mail($destination,$subject,$message, $headers);

header("Location: $BASE_URL");

