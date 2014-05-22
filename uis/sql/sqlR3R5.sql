R301: View Seller
SELECT cellphone, companyName, description, city, port, postalCode, street, name
FROM Seller, Address, Country
WHERE Seller.idUser = :id AND Address.idAddress = :id AND
		Country.idCountry = Address.idCountry;

R302: Edit Seller Info Action
UPDATE Seller
SET cellphone = :cellphone, companyName = :companyName, description = :description
WHERE idUser = :idUser;
UPDATE Address
SET city = :city, port = :port, postalCode = :postalCode, street = :street, idCountry = :idCountry
WHERE idAddress = :idAddress;

R303: List Selling Products
SELECT * FROM Product WHERE
idProduct IN ( SELECT idProduct from WantsToSell WHERE idSeller = :id );

R304: Add Selling Product Action
INSERT INTO WantsToSell (idSeller, idProduct, averagePrice, minimumPrice)
VALUES (:idSeller, :idProduct, :averagePrice, :minimumPrice);

R305: Update Selling Product Action
UPDATE WantsToSell
SET minimumPrice = :minimumPrice, averagePrice = :averagePrice
WHERE idSeller = :idSeller AND idProduct = :idProduct;

R306: Remove Selling Product
DELETE FROM WantsToSell WHERE idSeller = :idSeller AND idProduct = :idProduct;

R307: List Deals
SELECT * FROM DEAL WHERE idSeller = :id;

R501: Add Category Action
INSERT INTO ProductCategory (idParent, name)
VALUES (:idParent, :name);

R502: View Product
SELECT Product.name, description
FROM Product
WHERE Product.idProduct = :idProduct;

SELECT name
FROM ProductProductCategory, ProductCategory, 
WHERE idProduct = :id AND ProductCategory.idCategory = ProductProductCategory.idCategory;

R503: List Products
--id to be used to query the several categories for each product
SELECT idProduct, Product.name, description
FROM Product;

--to be executed for each product
SELECT name
FROM ProductProductCategory, ProductCategory, 
WHERE idProduct = :idCurrentProduct AND ProductCategory.idCategory = ProductProductCategory.idCategory;

R504: List to-be-approved Products
--id to be used to query the several categories for each product
SELECT idProduct, Product.name, description
FROM Product
WHERE approved IS FALSE;

--to be executed for each product
SELECT name
FROM ProductProductCategory, ProductCategory, 
WHERE idProduct = :idCurrentProduct AND ProductCategory.idCategory = ProductProductCategory.idCategory;

R505: Remove Product
DELETE FROM Product WHERE idProduct = :id;

R506: Edit Product Action 
UPDATE Product
SET name = :name, description = :description
WHERE idProduct = :id;

DELETE FROM ProductCategoryProduct
WHERE idProduct = :id;

--For every category the product belongs to
INSERT INTO ProductCategoryProduct (idProduct, idCategory)
VALUES :id, :idCategory

R507: Add Product Rating Action
INSERT INTO ProductRating (idBuyer, idProduct, rating, comment)
VALUES (:idBuyer, :idProduct, :rating, :comment);