<?php
/**
 * Created by IntelliJ IDEA.
 * User: Vinnie
 * Date: 23-Apr-14
 * Time: 9:13 PM
 */
include_once($BASE_DIR . 'database/users.php');

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

    $conn->beginTransaction();

    $stmt = $conn->prepare("INSERT INTO Product(name, description)
                            VALUES (:name, :description);");

    $stmt->execute(array(':name' => $name, ':description' => $description));

    $stmt = $conn->prepare("SELECT currval('product_idproduct_seq');");
    $stmt->execute();
    $result = $stmt->fetch();
    $id = $result['currval'];

    $stmt = $conn->prepare("INSERT INTO ProductCategoryProduct(idproduct, idcategory)
                            VALUES (:productid, :category);");

    $stmt->execute(array(':productid' => $id, ':category' => $category));

    $conn->commit();

    return $id;
}

function addToBuying($idProduct, $username, $proposedPrice)
{
    global $conn;

    if (isSeller($username)) {
        $id = getIdUser($username);
        $stmt = $conn->prepare("INSERT INTO WantsToBuy(idproduct, idbuyer, proposedPrice)
                                VALUES (:id, :idProduct, :proposedPrice);");
        return $stmt->execute(array(':id' => $id, ':idProduct' => $idProduct, ':proposedPrice' => $proposedPrice));
    } else {
        return false;
    }
}

function addToSelling($idProduct, $username, $minimumPrice, $averagePrice)
{
    global $conn;

    if (isSeller($username)) {
        $id = getIdUser($username);
        $stmt = $conn->prepare("INSERT INTO WantsToSell(idseller, idproduct, minumumprice, averageprice)
                                VALUES (:id, :idProduct, :minimumPrice, :averagePrice);");
        return $stmt->execute(array(':id' => $id, ':idProduct' => $idProduct, ':minimumPrice' => $minimumPrice, ':averagePrice' => $averagePrice));
    } else {
        return false;
    }
}


?>