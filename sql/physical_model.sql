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

CREATE TYPE  InteractionType AS ENUM ('Offer', 'Refusal', 'Proposal', 'Declined');

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
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE  CreditCard (
    idCreditCard SERIAL PRIMARY KEY,
    idUser INTEGER NOT NULL REFERENCES Buyer(idUser)
        ON DELETE SET NULL,
    ownerName VARCHAR(40) NOT NULL,
    number CreditCardNo NOT NULL UNIQUE,
    dueDate DATE NOT NULL
);

CREATE TABLE  Address (
    idAddress SERIAL PRIMARY KEY,
    addressLine VARCHAR(140) NOT NULL,
    postalCode PostalCode NOT NULL,
    city VARCHAR(80) NOT NULL,
    idCountry INTEGER NOT NULL REFERENCES Country(idCountry)
        ON DELETE SET NULL
);

CREATE TABLE  Product (
    idProduct SERIAL PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    description VARCHAR,
    approved BOOLEAN NOT NULL DEFAULT FALSE
); 

CREATE TABLE  Buyer (
    idBuyer INTEGER PRIMARY KEY REFERENCES RegisteredUser(idUser)
        ON DELETE CASCADE
);

CREATE TABLE  Seller (
    idSeller INTEGER PRIMARY KEY REFERENCES RegisteredUser(idUser)
        ON DELETE CASCADE,
    idAddress INTEGER REFERENCES Address(idAddress) NOT NULL
        ON DELETE SET NULL,
    companyName VARCHAR(40) NOT NULL,
    cellphone CellPhone,
    description VARCHAR,
    isVisibleToAPI BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE  Administrator (
    idAdmin INTEGER PRIMARY KEY REFERENCES RegisteredUser(idUser) NOT NULL
);

CREATE TABLE  ProductCategory (
    idCategory SERIAL PRIMARY KEY,
    idParent INTEGER REFERENCES ProductCategory(idCategory)
        ON DELETE SET NULL,
    name VARCHAR(80) NOT NULL
);

CREATE TABLE  ProductCategoryProduct (
    idProduct INTEGER REFERENCES Product(idProduct)
        ON DELETE CASCADE,
    idCategory INTEGER REFERENCES ProductCategory(idCategory)
        ON DELETE CASCADE,
    PRIMARY KEY(idProduct, idCategory)
);

CREATE TABLE  ProductRating (
    idProduct INTEGER REFERENCES Product(idProduct)
        ON DELETE CASCADE,
    idBuyer INTEGER REFERENCES Buyer(idUser)
        ON DELETE SET NULL,
    rating Rating NOT NULL,
    comment VARCHAR(200),
    PRIMARY KEY(idProduct, idUser)
);

CREATE TABLE  WantsToBuy (
    idProduct INTEGER REFERENCES Product(idProduct)
        ON DELETE CASCADE,
    idBuyer INTEGER REFERENCES Buyer(idUser)
        ON DELETE CASCADE,
    proposedPrice Amount NOT NULL,
    PRIMARY KEY(idProduct, idUser)
);

CREATE TABLE  PrivateMessage (
    idPM SERIAL PRIMARY KEY,
    idUser INTEGER REFERENCES RegisteredUser(idUser) NOT NULL
        ON DELETE CASCADE,
    idAdmin INTEGER REFERENCES Administrator(idUser) NOT NULL
        ON DELETE CASCADE,
    state NotificationState NOT NULL DEFAULT 'Unread',
    subject VARCHAR(40) NOT NULL,
    content VARCHAR(1000) NOT NULL
);

CREATE TABLE  BuyerAddress (
    idAddress INTEGER PRIMARY KEY REFERENCES Address(idAddress)
        ON DELETE CASCADE,
    idBuyer INTEGER NOT NULL REFERENCES Buyer(idUser)
        ON DELETE SET NULL,
    fullName VARCHAR NOT NULL
);

CREATE TABLE  BuyerInfo (
    idBuyerInfo SERIAL PRIMARY KEY,
    idShippingAddress INTEGER NOT NULL REFERENCES BuyerAddress(idAddress) NOT NULL
        ON DELETE SET NULL,
    idBillingAddress INTEGER NOT NULL REFERENCES BuyerAddress(idAddress)
        ON DELETE SET NULL,
    idCreditCard INTEGER NOT NULL REFERENCES CreditCard
        ON DELETE SET NULL
);

CREATE TABLE  Deal (
    idDeal SERIAL PRIMARY KEY,
    dealState DealState NOT NULL DEFAULT 'Pending',
    idBuyer INTEGER NOT NULL REFERENCES Buyer(idUser)
        ON DELETE SET NULL,
    idSeller INTEGER NOT NULL REFERENCES Seller(idUser)
        ON DELETE SET NULL,
    idProduct INTEGER NOT NULL REFERENCES Product(idProduct)
        ON DELETE SET NULL,
    beginningDate DATE NOT NULL,
    endDate DATE,
    deliveryMethod DeliveryMethod,
    idBuyerInfo INTEGER REFERENCES BuyerInfo(idBuyerInfo)
        ON DELETE SET NULL,
    sellerRating RATING,
    buyerComment VARCHAR(140)
);

CREATE TABLE  WantsToSell (
    idSeller INTEGER REFERENCES Seller(idUser)
        ON DELETE CASCADE,
    idProduct INTEGER REFERENCES Product(idProduct)
        ON DELETE CASCADE,
    minimumPrice Amount NOT NULL,
    averagePrice Amount NOT NULL,
    PRIMARY KEY(idSeller, idProduct)
);

CREATE TABLE  Interaction(
    idDeal INTEGER REFERENCES Deal(idDeal)
        ON DELETE CASCADE,
    interactionNo SERIAL,
    state NotificationState NOT NULL DEFAULT 'Unread',
    amount Amount NOT NULL,
    date DATE NOT NULL,
    interactionType InteractionType NOT NULL,
    PRIMARY KEY (idDeal, interactionNoa)
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

CREATE INDEX login_info_ix ON RegisteredUser (username, password); -- login

CREATE INDEX email_ix ON RegisteredUser USING hash (email); -- to check if already exists

CREATE INDEX deal_beginning_date_ix ON Deal (beginningDate DESC NULLS LAST);

CREATE INDEX deal_buyer_ix ON Deal (idBuyer);

CREATE INDEX deal_seller_ix ON Deal (idSeller);

CREATE INDEX interaction_ix ON Interaction (idDeal, interactionNo); -- to fetch all interactions

CREATE INDEX private_message_ix ON PrivateMessage (idUser)

CREATE INDEX product_name_ix ON Product USING gin (name);

CREATE INDEX category_name_ix ON ProductCategory USING gin (name);

CREATE INDEX products_in_category_ix ON ProductCategoryProduct (idCategory);

CREATE INDEX buyer_price_ix ON WantsToBuy (idProduct, proposedPrice);

-- Clustering

ALTER TABLE Interaction CLUSTER ON interaction_ix;

ALTER TABLE Deal CLUSTER ON deal_buyer_ix;

ALTER TABLE ProductCategoryProduct CLUSTER ON products_in_category_ix;

ALTER TABLE WantsToBuy CLUSTER ON buyer_price_ix;