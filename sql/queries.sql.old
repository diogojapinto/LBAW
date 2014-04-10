--Pesquisar clientes que queiram comprar um produto acima de X
SELECT username
FROM RegisteredUser NATURAL JOIN WantsToBuy
WHERE idProduct = 5
	AND proposedPrice > 5;

--Pesquisar produtos dentro de uma categoria
SELECT Product.name
FROM Product
WHERE Product.idProduct =
	(
	SELECT ProductCategoryProduct.idProduct
	FROM ProductCategoryProduct, ProductCategory
	WHERE ProductCategoryProduct.idCategory = ProductCategory.idCategory
		AND ProductCategory.name = 'Digital Games'
	);

--Listagem das categorias
SELECT Category.name, Parent.name
FROM ProductCategory Category,
	ProductCategory Parent
WHERE Category.idParent = Parent.idCategory;

--Pesquisar produto pelo nome
SELECT idProduct
FROM Product
WHERE name LIKE '%porttitor%';

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
SELECT CNT(Deal.idDeal), AVG(Deal.sellerRating)
FROM Deal,
WHERE (Deal.dealState = 'Finished'
		OR Deal.dealState = 'Shipping')
	AND idSeller =
		(
		SELECT Seller.idUser
		FROM Seller
		WHERE Seller.companyName = 'Arcu Incorporated'
		);


--adicionar comprador
INSERT INTO RegisteredUser (username,password,email,isBanned) 
	VALUES ('Darryl',
			'BSB24QNW7SY',
			'turpis.nec@luctusCurabituregestas.edu',
			FALSE);
INSERT INTO Buyer (idUser) VALUES (5);

--adicionar produto

INSERT INTO ProductCategory (name) VALUES ('Digital Games');
INSERT INTO ProductCategory (parent,name) VALUES ( 1, 'Free-to-Play Games');
INSERT INTO Product (name,description,approved) VALUES ('Donec','risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas',FALSE);
INSERT INTO ProductCategoryProduct VALUES (1, 2);

-- atualizar preço do vendedor
UPDATE WantsToSell SET minimumPrice = 2, averagePrice = 10
	WHERE idProduct =
		(
		SELECT idProduct
		FROM Product
		WHERE name = 'potato'
		)
	AND
		idSeller =
		(
		SELECT idUser
		FROM Seller
		WHERE companyName = 'Pingo Doce'
		);

--Eliminar mensagens privadas
DELETE FROM PrivateMessage
	WHERE idPm = 43;