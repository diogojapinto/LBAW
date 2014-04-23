===== R101: Delete User =====
	DELETE FROM RegisteredUser WHERE idUser = :id;

===== R102: Register Buyer **Transaction** =====
	INSERT ON RegisteredUser(username, password, email) VALUES (:username, :password, :email);
	SELECT idUser AS idU FROM RegisteredUser WHERE name LIKE :username;
	INSERT ON Buyer(idUser) VALUES (idU);

===== R103: Register Seller **Transaction** =====
	INSERT ON RegisteredUser(username, password, email) VALUES (:username, :password, :email);
	SELECT idCountry AS idC FROM Country WHERE name LIKE :country;
	INSERT ON Adress(adressLine, postalCode, city) VALUES (:addressLine, :postalCode, :city, idC);
	SELECT idUser AS idU FROM RegisteredUser WHERE name LIKE :username;
	SELECT idAdress AS idA FROM Adresss WHERE addressLine LIKE :addressLine;
	INSERT ON Seller(idUser, idAdresss, companyName, cellPhone) VALUES (idU, idA, :companyName, :cellphone); 

===== R104: User Login =====
	SELECT password FROM RegisteredUser WHERE username = :username;

===== R105: List Notifications =====
	SELECT idPM, state, subject FROM PrivateMessage WHERE idUser = :id;
	SELECT interactionNo, state, date FROM Interaction WHERE idUser = :id;

===== R106: User Read Notification =====
	SELECT subject, Content FROM PrivateMessage WHERE idPM = :id;
	UPDATE PrivateMessage SET state = 'Read' WHERE idPM =:id;
	             ------- OR --------
	SELECT amount, date, interactionType FROM Interaction WHERE interactionNo = :id;
	UPDATE Interaction SET state = 'Read' WHERE interactionNo = :id;

===== R107: Check Field Availability =====
	SELECT idUser
	FROM RegisteredUser
	WHERE username = :newUserUsername;
	--------------- or ---------------
	SELECT idUser
	FROM RegisteredUser
	WHERE email = :newUserEmail;

===== R201: Add Interest in Product Action =====
	INSERT INTO WantsToBuy (idProduct, idUser, proposedPrice)
	VALUES (:idProduct, :idUser, :price);

===== R202: List Interests in Product Action
	SELECT idUser, proposedPrice
	FROM WantsToBuy
	WHERE idProduct = :id;

===== R203: Update Interest in Product Action =====
	UPDATE WantsToBuy SET proposedPrice = :price
	WHERE idProduct=:idProduct AND idUser=:idUser;

===== R204: Remove Interest in Product =====
	DELETE FROM WantsToBuy WHERE idProduct=:idProduct AND idUser=:idUser;

===== R205: List Addresses =====
	SELECT addressLine, postalCode, city, name
	FROM Adress, Country
	WHERE Adress.idCountry = Country.idCountry;

===== R206: Add Addresses Action =====
	INSERT INTO Adress(addressLine,postalCode,city,idCountry)
	VALUES (:addressLine, :postalCode, :city, :idCountry);

===== R207: Update Addresses Action =====
	UPDATE Adress 
	SET addressLine = :addressLine ,
		postalCode = :postalCode ,
		city = :city ,
		idCountry = :idCountry;
	
===== R208: Remove Address =====
	DELETE FROM Adress WHERE idAdress = :id;

===== R209: List Credit cards =====
	SELECT idUser, ownerName, number, dueDate
	FROM CreditCard;

===== R210: Add Credit cards Action =====
	INSERT INTO CreditCard (idUser, ownerName, number, dueDate)
	VALUES (:id, :name, :number, :dueDate);

===== R211: Remove Credit cards =====
	DELETE FROM CreditCard WHERE idCreditCard = :id;

===== R212: List Deals TRANSAÇAO =====
	SELECT dealState, Buyer.name, Seller.companyName, Product.name, beginningDate, endDate, deliveryMethod, sellerRating, buyerComment
	FROM Deal, Buyer, Seller
	WHERE idBuyer = Buyer.idUser
		AND idSeller = Seller.idUser
		AND Deal.idProduct = Product.idProduct;

===== R301: View Seller =====
	SELECT cellphone, companyName, description, city, port, postalCode, street, name
	FROM Seller, Address, Country
	WHERE Seller.idUser = :id AND Address.idAddress = :id AND
			Country.idCountry = Address.idCountry;

===== R302: Edit Seller Info Action =====
	UPDATE Seller
	SET cellphone = :cellphone, companyName = :companyName, description = :description
	WHERE idUser = :idUser;
	UPDATE Address
	SET city = :city, port = :port, postalCode = :postalCode, street = :street, idCountry = :idCountry
	WHERE idAddress = :idAddress;

===== R303: List Selling Products =====
	SELECT * FROM Product WHERE
	idProduct IN ( SELECT idProduct from WantsToSell WHERE idSeller = :id );

===== R304: Add Selling Product Action =====
	INSERT INTO WantsToSell (idSeller, idProduct, averagePrice, minimumPrice)
	VALUES (:idSeller, :idProduct, :averagePrice, :minimumPrice);

===== R305: Update Selling Product Action =====
	UPDATE WantsToSell
	SET minimumPrice = :minimumPrice, averagePrice = :averagePrice
	WHERE idSeller = :idSeller AND idProduct = :idProduct;

===== R306: Remove Selling ProductM=====
	DELETE FROM WantsToSell WHERE idSeller = :idSeller AND idProduct = :idProduct;

===== R307: List Deals =====
	SELECT * FROM DEAL WHERE idSeller = :id;

===== R401: Send Private Message Action =====
	INSERT INTO PrivateMessage(idUser, idAdministrator, subject, content)
	VALUES (:idUser, :idAdmin, :subject, :contect);

===== R402: Add Administrator Action =====
	INSERT INTO Administrator(idUser) VALUES (:id);

===== R403: Remove User Action =====
	DELETE FROM RegisteredUser WHERE idUser = :id;

===== R501: Add Category Action =====
	INSERT INTO ProductCategory (idParent, name)
	VALUES (:idParent, :name);

===== R502: View Product **Transaction** =====
	SELECT Product.name, description
	FROM Product
	WHERE Product.idProduct = :idProduct;

	SELECT name 
	FROM ProductProductCategory, ProductCategory, 
	WHERE idProduct = :id AND ProductCategory.idCategory = ProductProductCategory.idCategory;

===== R503: List Products =====
	--id to be used to query the several categories for each product
	SELECT idProduct, Product.name, description
	FROM Product;

	--to be executed for each product
	SELECT name
	FROM ProductCategoryProduct, ProductCategory, 
	WHERE idProduct = :idCurrentProduct AND ProductCategory.idCategory = ProductProductCategory.idCategory;

===== R504: List to-be-approved Products =====
	--id to be used to query the several categories for each product
	SELECT idProduct, Product.name, description
	FROM Product
	WHERE approved IS FALSE;

	--to be executed for each product
	SELECT name
	FROM ProductProductCategory, ProductCategory, 
	WHERE idProduct = :idCurrentProduct AND ProductCategory.idCategory = ProductProductCategory.idCategory;

===== R505: Remove Product =====
	DELETE FROM Product WHERE idProduct = :id;

===== R506: Edit Product Action **Transaction** =====
	UPDATE Product
	SET name = :name, description = :description
	WHERE idProduct = :id;

	DELETE FROM ProductCategoryProduct
	WHERE idProduct = :id;

	--For every category the product belongs to
	INSERT INTO ProductCategoryProduct (idProduct, idCategory)
	VALUES :id, :idCategory

===== R507: Add Product Rating Action =====
	INSERT INTO ProductRating (idBuyer, idProduct, rating, comment)
	VALUES (:idBuyer, :idProduct, :rating, :comment);

===== R602: Begin Deal Action -> Transaction **Transaction** =====
	INSERT INTO Deal (idBuyer, idSeller, idProduct) 
		VALUES (:idBuyer, :idSeller, :idProduct);
	INSERT INTO Interaction (idDeal, InteractionNo, amount, date,
			interactionType)
		VALUES (currval(pg_get_serial_sequence('Deal','idDeal'),
			0, :firstProposal, CURRENT_TIMESTAMP);

===== R607: View Buyers Deal =====
	SELECT Deal.dealState, Seller.companyName, Product.name,
		Product.description, Deal.beginningDate, Deal.endDate,
		Deal.deliveryMethod, Deal.sellerRating,
		Deal.BuyerRating, Interaction.amount
	FROM Deal, Seller, Product, Interaction
	WHERE Deal.idBuyer = :idBuyer
		AND Deal.idSeller = Seller.idSeller
		AND Deal.idProduct = Product.idProduct
		AND Interaction.idDeal = Deal.idDeal
		AND Interaction.interactionNo = 
			(SELECT MAX(Interaction.interactionNo)
			 FROM Interaction
			 WHERE Interaction.idDeal = Deal.idDeal)
		ORDERED BY endDate:date DESC, beginningDate:date DESC;
	-----------submenu--------------
	SELECT BuyerAddress.fullName, Address.addressLine,
		Address.postalCode, Address.city, Country.name,
		CreditCard.ownerName, CreditCard.number, CreditCard.dueDate
	FROM BuyerInfo, BuyerAddress, Address, CreditCard
	WHERE BuyerInfo.idBuyerInfo = :idBuyerInfo
		AND	BuyerAddress.idAddress = BuyerInfo.idShippingAddress
		AND Address.idAddress = BuyerAddress.idAddress
		AND CreditCard.idCreditCard = BuyerInfo.idCreditCard;

===== R608: Accept Proposal Action (Buyer) =====
	SELECT MAX(interactionNo), amount
	FROM Interaction
	WHERE idDeal = :idDeal;

	INSERT INTO Interaction (idDeal, InteractionNo, amount,
			date, interactionType)
		VALUES (:idDeal, :lastInteractionNo, :lastAmount, 'Offer');
	UPDATE Deal 
	SET dealState = 'Successful',
		endDate = CURRENT_TIMESTAMP,
		deliveryMethod = :deliveryMethod,
		idBuyerInfo = :idBuyerInfo
	WHERE idDeal = :idDeal;

===== R609: Reject Proposal Action (Buyer) =====
	SELECT MAX(interactionNo), amount
	FROM Interaction
	WHERE idDeal = :idDeal;

	INSERT INTO Interaction (idDeal, InteractionNo, amount,
			date, interactionType)
		VALUES (:idDeal, :lastInteractionNo + 1, :lastAmount, 'Refusal');
	UPDATE Deal 
	SET dealState = 'Unuccessful',
		endDate = CURRENT_TIMESTAMP
	WHERE idDeal = :idDeal;

===== R610: Add Company Rating Action =====
	UPDATE Deal
	SET sellerRating = :sellerRating,
		buyerComment = :buyerComment
	WHERE idDeal = :idDeal;

===== R610: Make Proposal Action **Transaction** =====
	---if price acceptable
	SELECT MAX(interactionNo), amount
	FROM Interaction
	WHERE idDeal = :idDeal;

	INSERT INTO Interaction (idDeal, InteractionNo, amount,
			date, interactionType)
		VALUES (:idDeal, :lastInteractionNo + 1, :lastAmount, 'Proposal');

	-- if lower price for sell reached
	SELECT MAX(interactionNo), amount
	FROM Interaction
	WHERE idDeal = :idDeal;

	INSERT INTO Interaction (idDeal, InteractionNo, amount,
			date, interactionType)
		VALUES (:idDeal, :lastInteractionNo, :lastAmount, 'Declined');

	UPDATE Deal 
	SET dealState = 'Unsuccessfull',
		endDate = CURRENT_TIMESTAMP
	WHERE idDeal = :idDeal;

===== R701: View Product Rating =====
	SELECT AVG(rating)
	FROM ProductRating
	WHERE idProduct = :idProduct;