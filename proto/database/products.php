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
    $stmt = $conn->prepare("SELECT Product.*, ProductCategory.name as category
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory = ProductCategory.idcategory;");
    $stmt->execute();
    return $stmt->fetchAll();
}

function getProduct($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Product.idproduct, Product.name, description, ProductCategory.idcategory, ProductCategory.name as category
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory = ProductCategory.idcategory
                            AND Product.idProduct = ?;");
    $stmt->execute(array($id));
    $product = $stmt->fetch();
    return $product;
}

function getProductsByName($name)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Product.name, Product.idproduct, description, ProductCategory.name as category
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory = ProductCategory.idcategory
                            AND to_tsvector('portuguese', Product.name) @@ to_tsquery('portuguese', ?);");
    $stmt->execute(array($name));
    return $stmt->fetchAll();
}


function getProductsByCategory($category)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Product.*, ProductCategory.name as category
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory IN (SELECT idcategory
                                                                      FROM ProductCategory
                                                                      WHERE idcategory = :category
                                                                      OR idparent = :category)
                            AND ProductCategory.idcategory = ProductCategoryProduct.idcategory;");
    $stmt->execute(array($category));

    return $stmt->fetchAll();
}

function getProductsByNameAndCategory($name, $category)
{
    global $conn;
    if (!isset($category) || $category == "All") {
        return getProductsByName($name);
    } else {
        $stmt = $conn->prepare("SELECT Product.*
                            FROM Product, ProductCategoryProduct, ProductCategory
                            WHERE ProductCategory.idcategory = :category
                            AND to_tsvector('portuguese', Product.name) @@ to_tsquery('portuguese', :name)
                            AND Product.idproduct = ProductCategoryProduct.idproduct
                            AND ProductCategoryProduct.idcategory = ProductCategory.idcategory;");

        $stmt->execute(array(':name' => $name, ':category' => $category));
    }

    return $stmt->fetchAll();
}

function getRootCategories()
{
    global $conn;
    try {
        $stmt = $conn->prepare("SELECT ProductCategory.idCategory, ProductCategory.name
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

function insertProduct($name, $description, $category)
{
    global $conn;
    try {
        $sqlIns = "INSERT INTO Product(name, description)";
        $sqlIns .= " VALUES (" . $name . ", " . $description;
        $sqlIns .= ");";
        $stmt = $conn->prepare($sqlIns);
        $stmt->execute();

        $sqlGet = "SELECT idProduct FROM Product";
        $sqlGet .= " WHERE name = " . $name;
        $idGet = $conn->prepare($sqlGet);
        $idGet->execute();
        $idP = $idGet->fetch();

        $sqlInsP = "INSERT INTO ProductCategory(idProduct, idCategory)";
        $sqlInsP .= " VALUES(" . $idP["idProduct"] . ", " . $category;
        $sqlInsP .= ");";
        $prodIns = $conn->prepare($sqlInsP);
        $prodIns->execute();

    } catch (PDOException $e) {
        echo $e->errorInfo;
    }
}


?>