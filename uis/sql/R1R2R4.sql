-- R112: List Users
SELECT username, email
FROM RegisteredUser;

-- R201: Add Interest in Product Action
INSERT INTO WantsToBuy (idProduct, idUser, proposedPrice)
VALUES (:idProduct, :idUser, :price);

-- R200: List Interests in Product Action
SELECT idUser, proposedPrice
FROM WantsToBuy
WHERE idProduct = :id;

-- R201: Update Interest in Product Action
UPDATE WantsToBuy SET proposedPrice = :price
WHERE idProduct=:idProduct AND idUser=:idUser;

-- R202: Remove Interest in Product 
DELETE FROM WantsToBuy WHERE idProduct=:idProduct AND idUser=:idUser;

-- R203: List Addresses
SELECT addressLine, postalCode, city, name
FROM Adress, Country
WHERE Adress.idCountry = Country.idCountry;

-- R205: Add Addresses Action
INSERT INTO Adress(addressLine,postalCode,city,idCountry)
VALUES (:addressLine, :postalCode, :city, :idCountry);

-- R205: Update Addresses Action
UPDATE Adress 
SET addressLine = :addressLine ,
	postalCode = :postalCode ,
	city = :city ,
	idCountry = :idCountry;
	
-- R204: Remove Address
DELETE FROM Adress WHERE idAdress = :id;

-- R206: List Credit cards
SELECT idUser, ownerName, number, dueDate
FROM CreditCard;

-- R209: Add Credit cards Action 
INSERT INTO CreditCard (idUser, ownerName, number, dueDate)
VALUES (:id, :name, :number, :dueDate);

-- R209: Remove Credit cards 
DELETE FROM CreditCard WHERE idCreditCard = :id;

-- R209: List Deals TRANSAÇAO
SELECT dealState, Buyer.name, Seller.companyName, Product.name, beginningDate, endDate, deliveryMethod, sellerRating, buyerComment
FROM Deal, Buyer, Seller
WHERE idBuyer = Buyer.idUser
	AND idSeller = Seller.idUser
	AND Deal.idProduct = Product.idProduct;

-- R402: Send Private Message Action
INSERT INTO PrivateMessage(idUser, idAdministrator, subject, content)
VALUES (:idUser, :idAdmin, :subject, :contect);

-- R404: Add Administrator Action
INSERT INTO Administrator(idUser) VALUES (:id);

-- R405: Remove User Action
DELETE FROM RegisteredUser WHERE idUser = :id;