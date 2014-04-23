<?php
/**
 * Created by IntelliJ IDEA.
 * User: Vinnie
 * Date: 23-Apr-14
 * Time: 9:13 PM
 */

function getAllProducts(){

    global $conn;
    $stmt = $conn->prepare("SELECT idProduct, Product.name, description FROM Product;");
    $stmt->execute();
    $products = $stmt->fetchAll();
    foreach($products as $product){
        $stmt = $conn->prepare("SELECT name
                                FROM ProductCategoryProduct, ProductCategory,
                                WHERE idProduct = :idCurrentProduct AND ProductCategory.idCategory = ProductProductCategory.idCategory;");
        $stmt->execute();
        $product['Category'] = $stmt->fetch();
    }

    return $products;
}

function getProductsByName($name){
    global $conn;
    $stmt = $conn->prepare("SELECT *
                            FROM Product
                            WHERE to_tsvector('portuguese', name) @@ to_tsquery('portuguese', :name);");
    $stmt->execute(array(':name', $name));
    $products = $stmt->fetchAll();

    foreach($products as $product){
        $stmt = $conn->prepare("SELECT name
                                FROM ProductCategoryProduct, ProductCategory,
                                WHERE idProduct = :idCurrentProduct AND ProductCategory.idCategory = ProductProductCategory.idCategory;");
        $stmt->execute();
        $product['Category'] = $stmt->fetch();
    }

    return $products;
}

function getProduct($id){
    global $conn;
    $stmt = $conn->prepare("SELECT Product.name, description
                            FROM Product
                            WHERE Product.idProduct = :idProduct;");
    $stmt->execute(array(':idProduct', $id));
    $product = $stmt->fetch();
    $stmt = $conn->prepare("SELECT name
                            FROM ProductProductCategory, ProductCategory,
                            WHERE idProduct = :id AND ProductCategory.idCategory = ProductProductCategory.idCategory;");
    $stmt->execute(array(':id', $id));
    $product['Category'] = $stmt->fetch();
    return $product;
}

?>