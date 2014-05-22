-- SQL001
DELETE FROM RegisteredUser WHERE idUser = :id;

-- SQL002 -> register buyer action
INSERT ON RegisteredUser(username, password, email) VALUES (:username, :password, :email);
SELECT idUser AS idU FROM RegisteredUser WHERE name LIKE :username;
INSERT ON Buyer(idUser) VALUES (idU);
-- \\\  ADD nas tabelas do A11 -> username | address é opcional e acrescentar postalcode se houver address

-- SQL003 -> register seller action
INSERT ON RegisteredUser(username, password, email) VALUES (:username, :password, :email);
SELECT idCountry AS idC FROM Country WHERE name LIKE :country;
INSERT ON Adress(adressLine, postalCode, city) VALUES (:addressLine, :postalCode, :city, idC);
SELECT idUser AS idU FROM RegisteredUser WHERE name LIKE :username;
SELECT idAdress AS idA FROM Adresss WHERE addressLine LIKE :addressLine;
INSERT ON Seller(idUser, idAdresss, companyName, cellPhone) VALUES (idU, idA, :companyName, :cellphone); 
-- \\\  ADD nas tabelas do A11 -> username | companyName | postalCode 

-- SQL004 -> user login action
SELECT password FROM RegisteredUser WHERE username LIKE :username;

-- SQL005 -> notifications (??)
SELECT idPM, state, subject FROM PrivateMessage WHERE idUser = :id;
SELECT interactionNo, state, date FROM Interaction WHERE idUser = :id;

-- SQL006 -> user Read Notification | adicionar id da sessao
SELECT subject, Content FROM PrivateMessage WHERE idPM = :id;
UPDATE PrivateMessage SET state = 'Read' WHERE idPM =:id;
             ------- OU --------
SELECT amount, date, interactionType FROM Interaction WHERE interactionNo = :id;
UPDATE Interaction SET state = 'Read' WHERE interactionNo = :id;

---- #### UPDATED QUERIES -----

--Pesquisar clientes que queiram comprar um produto acima de X
SELECT username 
FROM RegisteredUser NATURAL JOIN WantsToBuy 
WHERE idProduct = :id AND proposedPrice > :price;

--Pesquisar produtos dentro de uma categoria
SELECT Product.name 
FROM Product
WHERE Product.idProduct =
	(
	SELECT ProductCategoryProduct.idProduct
	FROM ProductCategoryProduct, ProductCategory
	WHERE ProductCategoryProduct.idCategory = ProductCategory.idCategory
		AND ProductCategory.name = :category
	);

--Listagem das categorias -> help from php, several queries
SELECT Category.name, Parent.name
FROM ProductCategory Category,
	ProductCategory Parent
WHERE Category.idParent = Parent.idCategory;

--Pesquisar produto pelo nome
SELECT idProduct
FROM Product
WHERE name LIKE :name;

--listagem de mensagens privadas por utilizador
SELECT Sender.username AS Sender, 
	Recipient.username AS Recipient,
	PrivateMessage.state AS State,
	PrivateMessage.subject AS Subject,
	PrivateMessage.content AS Content
FROM RegisteredUser Sender,
	RegisteredUser.Recipient,
	PrivateMessage
WHERE Sender.idUser = PrivateMessage.idAdministrator,
	AND Recipient.idUser = PrivateMessage.idUser;

--avaliação de um vendedor
SELECT COUNT(Deal.idDeal), AVG(Deal.sellerRating)
FROM Deal,
WHERE Deal.dealState != 'Pending'
	AND idSeller =
		(
		SELECT Seller.idUser
		FROM Seller
		WHERE Seller.companyName = :companyName
		);

-- adicionar produto
INSERT INTO Product (name,description,approved) VALUES (:name,:description,FALSE);
SELECT idProduct AS idP FROM Product WHERE name LIKE :name AND description LIKE :description;
INSERT INTO ProductCategoryProduct VALUES (idP, :idCat);

-- atualizar preço do vendedor
UPDATE WantsToSell SET minimumPrice = :minPrice, averagePrice = :avgPrice
	WHERE idProduct =
		(
		SELECT idProduct
		FROM Product
		WHERE name = :productName
		)
	AND
		idSeller =
		(
		SELECT idUser
		FROM Seller
		WHERE companyName = :companyName
		);

-- Eliminar mensagens privadas
DELETE FROM PrivateMessage
	WHERE idPm = :id;