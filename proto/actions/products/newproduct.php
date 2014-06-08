<?php
/**
 * Created by IntelliJ IDEA.
 * User: Acer
 * Date: 28/04/2014
 * Time: 23:57
 */

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/products.php');

if (!isset($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para submeter um produto para avaliação';

    header("Location: $BASE_URL" . 'index.php');
}

if (!isset($_POST['name']) || $_POST['name'] == ""
    || !isset($_POST['description']) || $_POST['description'] == ""
    || !isset($_POST['productCategory']) || $_POST['productCategory'] == ""
) {

    $_SESSION['form_values'] = $_POST;
    $_SESSION['error_messages'][] = 'Todos os campos são obrigatórios';

    header("Location: $BASE_URL" . 'pages/products/add.php');
    exit;
} else if ($_FILES['image']['type'] != 'image/jpeg') {
    $_SESSION['form_values'] = $_POST;
    $_SESSION['error_messages'][] = 'Selecione uma imagem com extenção <it>jpg</it>';
    $_SESSION['error_messages'][] = $_FILES['image']['type'];

    header("Location: $BASE_URL" . 'pages/products/add.php');
    exit;
}

$name = strip_tags($_POST['name']);
$description = strip_tags($_POST['description']);
$category = strip_tags($_POST['productCategory']);

try {
    $productId = insertProduct($name, $description, $category);
    move_uploaded_file($_FILES['image']['tmp_name'],
        $BASE_DIR . 'images/products/' . $productId . '.jpg');

    $_SESSION['success_messages'][] = "Producto submetido com sucesso";
    header("Location: $BASE_URL" . 'index.php');
    exit;
} catch (PDOException $e) {
    var_dump($e->errorInfo);
}
