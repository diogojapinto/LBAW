<?php
/**
 * Created by IntelliJ IDEA.
 * User: Vinnie
 * Date: 23-Apr-14
 * Time: 9:13 PM
 */

function getAllProducts()
{
    global $conn;
    $stmt = $conn->prepare("SELECT Product.*, description, ProductCategory.name as category
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory = ProductCategory.idcategory;");
    $stmt->execute();
    return $stmt->fetchAll();
}

function getProduct($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Product.name, description, ProductCategory.name as category
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory = ProductCategory.idcategory
                            AND Product.idProduct = ?;");
    $stmt->execute(array($id));
    $product = $stmt->fetch();
    var_dump($product);
    return $product;
}

function getProductsByName($name)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Product.name, description, ProductCategory.name as category
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory = ProductCategory.idcategory
                            AND to_tsvector('portuguese', name) @@ to_tsquery('portuguese', :name);");
    $stmt->execute(array(':name', $name));
    return $stmt->fetchAll();
}


function getProductsByCategory($category)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Product.*, ProductCategory.name as category
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory = ProductCategory.idcategory;");
    $stmt->execute(array($category));
    $products = $stmt->fetchAll();

    return $products;
}


function getRootCategories()
{
    global $conn;
    try {
        $stmt = $conn->prepare("SELECT ProductCategory.name
                            FROM ProductCategory
                            WHERE idParent IS NULL;");

        $stmt->execute();

        $categories = $stmt->fetchAll();

        return $categories;
    } catch (PDOException $e) {
        echo $e->errorInfo;
    }
}

function getHighestRatedProducts()
{
    global $conn;
    try {
        $stmt = $conn->prepare("SELECT idProduct, name, description
                                FROM Product
                                WHERE idProduct IN (SELECT idProduct
                                                    FROM ProductRating
                                                    WHERE rating = (SELECT MAX(rating)
                                                                    FROM ProductRating));");

        $stmt->execute();

        $products = $stmt->fetchAll();

        return $products;
    } catch (PDOException $e) {
        echo $e->errorInfo;
    }
}

?>