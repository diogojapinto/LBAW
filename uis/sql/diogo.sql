--R111: Check Field Availability 
SELECT idUser
FROM RegisteredUser
WHERE username = :newUserUsername;
--------------- or ---------------
SELECT idUser
FROM RegisteredUser
WHERE email = :newUserEmail;

--R602: Begin Deal Action -> Transaction
INSERT INTO Deal (idBuyer, idSeller, idProduct) 
	VALUES (:idBuyer, :idSeller, :idProduct);
INSERT INTO Interaction (idDeal, InteractionNo, amount, date,
		interactionType)
	VALUES (currval(pg_get_serial_sequence('Deal','idDeal'),
		0, :firstProposal, CURRENT_TIMESTAMP);

--R607: View Buyer's Deal
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

--R608: Accept Proposal Action (Buyer) -> Transaction
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

--R609: Reject Proposal Action (Buyer) 
SELECT MAX(interactionNo), amount
FROM Interaction
WHERE idDeal = :idDeal;

INSERT INTO Interaction (idDeal, InteractionNo, amount,
		date, interactionType)
	VALUES (:idDeal, :lastInteractionNo + 1, :lastAmount, 'Refusal');

--R610: Add Company Rating Action

--R610: Make Proposal Action
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

--R702: View Product Rating
SELECT AVG(rating)
FROM ProductRating
WHERE idProduct = :idProduct;

--R703: List Products by Criteria 
--R704: List Company by Criteria