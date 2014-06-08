<?php
include_once('../../config/init.php');
if (!$_POST['email'] || !$_POST['subject'] || !$_POST['message'] || !$_POST['username']){
    $_SESSION['form_values'] = $_POST;
    $_SESSION['form_values']['errors'] = array('Por favor preencha todos os campos.');

    header("Location: $BASE_URL");
    exit;
}

$sendermail = null;
if(!$_POST['sendermail']){
    $sendermail = "realezy@realezy.pt";
}
else $sendermail = $_POST['sendermail'];
$headers = "MIME-Version: 1.1\r\n";
$headers .= "Content-type: text/plain; charset=iso-8859-1\r\n";
$headers .= "From: " . $sendermail . "\r\n"; // remetente
$headers .= "Return-Path: realezy@realezy.pt\r\n";
$destination=$_POST['email'];
$subject=$_POST['subject'];
$message=$_POST['message'];

mail($destination,$subject,$message, $headers);

header("Location: $BASE_URL");

