DROP TABLE IF EXISTS Interaction;
DROP TABLE IF EXISTS WantsToSell; 
DROP TABLE IF EXISTS Deal;
DROP TABLE IF EXISTS BuyerInfo;
DROP TABLE IF EXISTS BuyerAddress;
DROP TABLE IF EXISTS PrivateMessage;
DROP TABLE IF EXISTS WantsToBuy;
DROP TABLE IF EXISTS ProductRating;
DROP TABLE IF EXISTS ProductCategoryProduct;
DROP TABLE IF EXISTS ProductCategory;
DROP TABLE IF EXISTS Administrator;
DROP TABLE IF EXISTS Seller;
DROP TABLE IF EXISTS CreditCard;
DROP TABLE IF EXISTS Buyer;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Country;
DROP TABLE IF EXISTS RegisteredUser;
DROP TYPE IF EXISTS NotificationState;
DROP TYPE IF EXISTS InteractionType;
DROP TYPE IF EXISTS DeliveryMethod;
DROP TYPE IF EXISTS DealState;
DROP DOMAIN IF EXISTS PostalCode;
DROP DOMAIN IF EXISTS CreditCardNo;
DROP DOMAIN IF EXISTS Rating;
DROP DOMAIN IF EXISTS CellPhone;
DROP DOMAIN IF EXISTS Email;
DROP DOMAIN IF EXISTS Amount;

CREATE TYPE  NotificationState AS ENUM ('Read', 'Unread');

CREATE TYPE  InteractionType AS ENUM ('Offer', 'Proposal');

CREATE TYPE  DeliveryMethod AS ENUM ('In Hand', 'Shipping');

CREATE TYPE  DealState AS ENUM ('Pending', 'Unsuccessful', 'Successful', 'Delivered');


CREATE DOMAIN  PostalCode VARCHAR(14)
    CONSTRAINT validPostalCode
    CHECK (VALUE ~ '.+');

CREATE DOMAIN  CreditCardNo VARCHAR(19)
    CONSTRAINT validCreditCardNo
    CHECK (VALUE ~ '\d{13,19}');

CREATE DOMAIN  Rating FLOAT
    CONSTRAINT validRating
    CHECK (VALUE >= 0 AND VALUE <= 5);

CREATE DOMAIN  CellPhone VARCHAR(20)
    CONSTRAINT validCellNumber
    CHECK (VALUE ~ '(\+)?[\- | 0-9]+');

CREATE DOMAIN  Email VARCHAR(254)
    CONSTRAINT validEmail
    CHECK (VALUE ~ '.+\@.+\..+');

CREATE DOMAIN  Amount FLOAT
    CONSTRAINT validAmount
    CHECK (VALUE >= 0);


CREATE TABLE  RegisteredUser (
    idUser SERIAL PRIMARY KEY,
    username VARCHAR(40) NOT NULL UNIQUE,
    password VARCHAR(40) NOT NULL,
    email Email NOT NULL UNIQUE,
    isBanned BOOLEAN NOT NULL DEFAULT FALSE,
    bannedDate DATE DEFAULT NULL
);

CREATE TABLE  Country (
    idCountry SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE  CreditCard (
    idCreditCard SERIAL PRIMARY KEY,
    idUser INTEGER NOT NULL REFERENCES Buyer(idUser),
    ownerName VARCHAR(40) NOT NULL,
    number CreditCardNo NOT NULL,
    dueDate DATE NOT NULL
);

CREATE TABLE  Address (
    idAddress SERIAL PRIMARY KEY,
    addressLine VARCHAR(140) NOT NULL,
    postalCode PostalCode NOT NULL,
    city VARCHAR(80) NOT NULL,
    idCountry INTEGER NOT NULL REFERENCES Country(idCountry)
);

CREATE TABLE  Product (
    idProduct SERIAL PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    description VARCHAR NOT NULL,
    approved BOOLEAN NOT NULL
);

CREATE TABLE  Buyer (
    idUser INTEGER PRIMARY KEY REFERENCES RegisteredUser(idUser)
);

CREATE TABLE  Seller (
    idUser INTEGER PRIMARY KEY REFERENCES RegisteredUser(idUser),
    idAddress INTEGER REFERENCES Address(idAddress) NOT NULL,
    companyName VARCHAR(40) NOT NULL,
    cellphone CellPhone NOT NULL,
    description VARCHAR,
    isVisibleToAPI BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE  Administrator (
    idUser INTEGER PRIMARY KEY REFERENCES RegisteredUser NOT NULL
);

CREATE TABLE  ProductCategory (
    idCategory SERIAL PRIMARY KEY,
    idParent INTEGER REFERENCES ProductCategory(idCategory),
    name VARCHAR(40) NOT NULL
);

CREATE TABLE  ProductCategoryProduct (
    idProduct INTEGER REFERENCES Product(idProduct),
    idCategory INTEGER REFERENCES ProductCategory(idCategory),
    PRIMARY KEY(idProduct, idCategory)
);

CREATE TABLE  ProductRating (
    idProduct INTEGER REFERENCES Product(idProduct),
    idUser INTEGER REFERENCES Buyer(idUser),
    rating Rating NOT NULL,
    comment VARCHAR,
    PRIMARY KEY(idProduct, idUser)
);

CREATE TABLE  WantsToBuy (
    idProduct INTEGER REFERENCES Product(idProduct),
    idUser INTEGER REFERENCES Buyer(idUser),
    proposedPrice Amount NOT NULL,
    PRIMARY KEY(idProduct, idUser)
);

CREATE TABLE  PrivateMessage (
    idPM SERIAL PRIMARY KEY,
    idUser INTEGER REFERENCES RegisteredUser(idUser) NOT NULL,
    idAdministrator INTEGER REFERENCES Administrator(idUser) NOT NULL,
    state NotificationState NOT NULL DEFAULT 'Unread',
    subject VARCHAR(40) NOT NULL,
    content VARCHAR NOT NULL
);

CREATE TABLE  BuyerAddress (
    idAddress INTEGER PRIMARY KEY REFERENCES Address(idAddress),
    idCreditCard INTEGER NOT NULL REFERENCES CreditCard(idCreditCard),
    idUser INTEGER NOT NULL REFERENCES Buyer(idUser),
    fullName VARCHAR NOT NULL
);

CREATE TABLE  BuyerInfo (
    idBuyerInfo SERIAL PRIMARY KEY,
    idShippingAddress INTEGER NOT NULL REFERENCES BuyerAddress(idAddress) NOT NULL,
    idBillingAddress INTEGER NOT NULL REFERENCES BuyerAddress(idAddress),
    idCreditCard INTEGER NOT NULL REFERENCES CreditCard
);

CREATE TABLE  Deal (
    idDeal SERIAL PRIMARY KEY,
    dealState DEALSTATE NOT NULL DEFAULT 'Pending',
    idBuyer INTEGER NOT NULL REFERENCES Buyer(idUser),
    idSeller INTEGER NOT NULL REFERENCES Seller(idUser),
    idProduct INTEGER NOT NULL REFERENCES Product(idProduct),
    beginningDate DATE NOT NULL,
    endDate DATE NOT NULL,
    deliveryMethod DELIVERYMETHOD,
    idBuyerInfo INTEGER REFERENCES BuyerInfo(idBuyerInfo),
    sellerRating RATING,
    buyerComment VARCHAR(140)
);

CREATE TABLE  WantsToSell (
    idSeller INTEGER REFERENCES Seller(idUser),
    idProduct INTEGER REFERENCES Product(idProduct),
    minimumPrice Amount NOT NULL,
    averagePrice Amount NOT NULL,
    PRIMARY KEY(idSeller, idProduct)
);

CREATE TABLE  Interaction(
    idDeal INTEGER REFERENCES Deal(idDeal),
    interactionNo INTEGER ,
    state NotificationState NOT NULL DEFAULT 'Unread',
    amount Amount NOT NULL,
    date DATE NOT NULL,
    interactionType InteractionType NOT NULL
);

-- Constraints

ALTER TABLE RegisteredUser 
    ADD CONSTRAINT ct_valid_banishment CHECK (NOT(isBanned) OR bannedDate IS NOT NULL);

ALTER TABLE PrivateMessage 
    ADD CONSTRAINT ct_valid_pm_recipient CHECK (idAdministrator != idUser);

ALTER TABLE Deal 
    ADD CONSTRAINT ct_valid_deal_dates CHECK (endDate::date > beginningDate::date);

ALTER TABLE WantsToSell 
    ADD CONSTRAINT ct_valid_seller_prices CHECK (minimumPrice < averagePrice);

-- Indexes

CREATE INDEX ix_username ON RegisteredUser USING hash (username);

CREATE INDEX ix_company_name ON Seller USING hash (companyName);

CREATE INDEX ix_deal_beginning_date ON Deal /*USING btree*/ (beginningDate);

-- Clustering

ALTER TABLE Deal CLUSTER ON ix_deal_beginning_date;

-- Triggers

CREATE OR REPLACE FUNCTION new_buyerinfo_trigger() RETURNS TRIGGER AS '
DECLARE
    idBuyer INTEGER;
BEGIN
    idBuyer := SELECT idBuyer FROM Deal WHERE idBuyerInfo = NEW.idBuyerInfo;
    
    IF (SELECT idBuyer FROM BuyerAddress WHERE idAddress = NEW.idShippingAddress) != idBuyer OR
    (SELECT idUser FROM CreditCard WHERE idOwner = NEW.idBuyer) != idBuyer OR
    (NEW.idBillingAddress IS NOT NULL AND
        (SELECT idUser FROM BuyerAddress WHERE idAddress = NEW.idBillingAddress) != idBuyer)
    THEN
        RETURN OLD; -- exception
    END IF;
    
    IF NEW.idBillingAddress IS NULL
    THEN
        NEW.idBillingAddress := NEW.idShippingAddress;
    END IF;
    
    RETURN NEW;
END
' LANGUAGE plpgsql;
    
CREATE OR REPLACE FUNCTION remove_productcategory_trigger() RETURNS TRIGGER AS '
BEGIN
    IF OLD.idParent IS NOT NULL
    THEN
        UPDATE ProductCategory
        SET idParent = OLD.idParent
        WHERE idParent = OLD.idCategory;
    END IF;
    
    RETURN NEW;
END
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_registreduser_trigger() RETURNS TRIGGER AS '
BEGIN
    IF OLD.isBanned != NEW.isBanned AND NEW.isBanned = TRUE
    THEN
        UPDATE RegistredUser
        SET bannedDate = CURRENT_DATE
        WHERE idUser = NEW.idUser;
    END IF;
    
    RETURN NEW;
END
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_deal_trigger() RETURNS TRIGGER AS '
BEGIN
    IF NEW.DealState = \'Successfull\' AND NEW.deliveryMethod IS NULL
    THEN
        RETURN OLD; -- exception
    END IF;
    
    IF NEW.deliveryMethod = \'Shipping\' AND idBuyerInfo IS NULL
    THEN
        RETURN OLD; -- exception
    END IF;
    
    RETURN NEW;
END
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION new_deal_trigger() RETURNS TRIGGER AS '
BEGIN
    NEW.dealState := \'Pending\';
    NEW.beginningDate := CURRENT_DATE;
    
    RETURN NEW;
END
' LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS new_buyerinfo_trigger ON BuyerInfo;
CREATE TRIGGER new_buyerinfo_trigger
    BEFORE INSERT ON BuyerInfo
    FOR EACH ROW EXECUTE PROCEDURE new_buyerinfo_trigger();
    
DROP TRIGGER IF EXISTS remove_productcategory_trigger ON ProductCategory;
CREATE TRIGGER remove_productcategory_trigger
    BEFORE DELETE ON ProductCategory
    FOR EACH ROW EXECUTE PROCEDURE remove_productcategory_trigger();
    
DROP TRIGGER IF EXISTS update_registreduser_trigger ON RegisteredUser;
CREATE TRIGGER update_registreduser_trigger
    BEFORE UPDATE ON RegisteredUser
    FOR EACH ROW EXECUTE PROCEDURE update_registreduser_trigger();
    
DROP TRIGGER IF EXISTS update_deal_trigger ON Deal;
CREATE TRIGGER update_deal_trigger
    BEFORE UPDATE ON Deal
    FOR EACH ROW EXECUTE PROCEDURE update_deal_trigger();
    
DROP TRIGGER IF EXISTS new_deal_trigger ON Deal;
CREATE TRIGGER new_deal_trigger
    BEFORE INSERT ON Deal
    FOR EACH ROW EXECUTE PROCEDURE new_deal_trigger();