DROP SCHEMA IF EXISTS public CASCADE; 
CREATE SCHEMA public;
SET SCHEMA 'public';
    SET DATESTYLE TO PostgreSQL,European;
    SET TIMEZONE TO 'Portugal';

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
        username VARCHAR(80) NOT NULL UNIQUE,
        password VARCHAR(80) NOT NULL,
        email Email NOT NULL UNIQUE,
        isBanned BOOLEAN NOT NULL DEFAULT FALSE,
        bannedDate DATE DEFAULT NULL
    );

    CREATE TABLE  Country (
        idCountry SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE
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
        name VARCHAR(80) NOT NULL,
        description VARCHAR,
        approved BOOLEAN NOT NULL DEFAULT FALSE
    ); 

    CREATE TABLE  Buyer (
        idBuyer INTEGER PRIMARY KEY REFERENCES RegisteredUser(idUser)
            ON DELETE CASCADE
    );

    CREATE TABLE  CreditCard (
        idCreditCard SERIAL PRIMARY KEY,
        idBuyer INTEGER NOT NULL REFERENCES Buyer(idBuyer)
            ON DELETE SET NULL,
        ownerName VARCHAR(80) NOT NULL,
        number CreditCardNo NOT NULL UNIQUE,
        dueDate DATE NOT NULL
    );

    CREATE TABLE  Seller (
        idSeller INTEGER PRIMARY KEY REFERENCES RegisteredUser(idUser)
            ON DELETE CASCADE,
        idAddress INTEGER REFERENCES Address(idAddress) NOT NULL,
        companyName VARCHAR(80) NOT NULL,
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
        idBuyer INTEGER REFERENCES Buyer(idBuyer)
            ON DELETE SET NULL,
        rating Rating NOT NULL,
        comment VARCHAR(200),
        PRIMARY KEY(idProduct, idBuyer)
    );

    CREATE TABLE  WantsToBuy (
        idProduct INTEGER REFERENCES Product(idProduct)
            ON DELETE CASCADE,
        idBuyer INTEGER REFERENCES Buyer(idBuyer)
            ON DELETE CASCADE,
        proposedPrice Amount NOT NULL,
        PRIMARY KEY(idProduct, idBuyer)
    );

    CREATE TABLE  PrivateMessage (
        idPM SERIAL PRIMARY KEY,
        idUser INTEGER REFERENCES RegisteredUser(idUser) NOT NULL,
        idAdmin INTEGER REFERENCES Administrator(idAdmin) NOT NULL,
        state NotificationState NOT NULL DEFAULT 'Unread',
        date DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        subject VARCHAR(180) NOT NULL,
        content VARCHAR(1000) NOT NULL
    );

    CREATE TABLE  BuyerAddress (
        idAddress INTEGER PRIMARY KEY REFERENCES Address(idAddress)
            ON DELETE CASCADE,
        idBuyer INTEGER NOT NULL REFERENCES Buyer(idBuyer)
            ON DELETE SET NULL,
        fullName VARCHAR NOT NULL
    );

    CREATE TABLE  BuyerInfo (
        idBuyerInfo SERIAL PRIMARY KEY,
        idShippingAddress INTEGER NOT NULL REFERENCES BuyerAddress(idAddress),
        idBillingAddress INTEGER NOT NULL REFERENCES BuyerAddress(idAddress),
        idCreditCard INTEGER NOT NULL REFERENCES CreditCard
    );

    CREATE TABLE  Deal (
        idDeal SERIAL PRIMARY KEY,
        dealState DealState NOT NULL DEFAULT 'Pending',
        idBuyer INTEGER NOT NULL REFERENCES Buyer(idBuyer)
            ON DELETE SET NULL,
        idSeller INTEGER NOT NULL REFERENCES Seller(idSeller)
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
        idSeller INTEGER REFERENCES Seller(idSeller)
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
        PRIMARY KEY (idDeal, interactionNo)
    );

    -- Constraints

    ALTER TABLE RegisteredUser 
        ADD CONSTRAINT ct_valid_banishment CHECK (NOT(isBanned) OR bannedDate IS NOT NULL);

    ALTER TABLE PrivateMessage 
        ADD CONSTRAINT ct_valid_pm_recipient CHECK (idAdmin != idUser);

    ALTER TABLE Deal 
        ADD CONSTRAINT ct_valid_deal_dates CHECK (endDate::date > beginningDate::date);

    ALTER TABLE WantsToSell 
        ADD CONSTRAINT ct_valid_seller_prices CHECK (minimumPrice < averagePrice);
     
    -- Indexes
    DROP INDEX IF EXISTS login_info_ix;
    DROP INDEX IF EXISTS email_ix;
    DROP INDEX IF EXISTS deal_beginning_date_ix;
    DROP INDEX IF EXISTS deal_buyer_ix;
    DROP INDEX IF EXISTS deal_seller_ix;
    DROP INDEX IF EXISTS interaction_ix;
    DROP INDEX IF EXISTS private_message_ix;
    DROP INDEX IF EXISTS product_name_ix;
    DROP INDEX IF EXISTS category_name_ix;
    DROP INDEX IF EXISTS products_in_category_ix;
    DROP INDEX IF EXISTS buyer_price_ix;

    CREATE INDEX login_info_ix ON RegisteredUser (username, password); -- login

    CREATE INDEX email_ix ON RegisteredUser USING hash (email); -- to check if already exists

    CREATE INDEX deal_beginning_date_ix ON Deal (beginningDate DESC NULLS LAST);

    CREATE INDEX deal_buyer_ix ON Deal (idBuyer);

    CREATE INDEX deal_seller_ix ON Deal (idSeller);

    CREATE INDEX interaction_ix ON Interaction (idDeal, interactionNo); -- to fetch all interactions

    CREATE INDEX private_message_ix ON PrivateMessage (idUser);

    CREATE INDEX product_name_ix ON Product USING gin (to_tsvector('portuguese', name));

    CREATE INDEX category_name_ix ON ProductCategory USING gin (to_tsvector('portuguese', name));

    CREATE INDEX products_in_category_ix ON ProductCategoryProduct (idCategory);

    CREATE INDEX buyer_price_ix ON WantsToBuy (idProduct, proposedPrice);

    -- Clustering

    ALTER TABLE Interaction CLUSTER ON interaction_ix;

    ALTER TABLE Deal CLUSTER ON deal_buyer_ix;

    ALTER TABLE ProductCategoryProduct CLUSTER ON products_in_category_ix;

    ALTER TABLE WantsToBuy CLUSTER ON buyer_price_ix;



    CREATE OR REPLACE FUNCTION new_buyerinfo_trigger() RETURNS TRIGGER AS $$
    DECLARE
        buyerid INTEGER;
    BEGIN
        SELECT INTO buyerid idBuyer FROM Deal WHERE idBuyerInfo = NEW.idBuyerInfo;
        
        IF (SELECT idBuyer FROM BuyerAddress WHERE idAddress = NEW.idShippingAddress) != buyerid OR
        (SELECT idBuyer FROM CreditCard WHERE idBuyer = buyerid) != buyerid OR
        (NEW.idBillingAddress IS NOT NULL AND
            (SELECT idBuyer FROM BuyerAddress WHERE idAddress = NEW.idBillingAddress) != buyerid)
        THEN
            RAISE EXCEPTION 'Addresses must belong to the Buyer in a Deal';
        END IF;
        
        IF NEW.idBillingAddress IS NULL
        THEN
            NEW.idBillingAddress := NEW.idShippingAddress;
        END IF;
        
        RETURN NEW;
    END
    $$ LANGUAGE plpgsql;
        
    CREATE OR REPLACE FUNCTION remove_productcategory_trigger() RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.idParent IS NOT NULL
        THEN
            UPDATE ProductCategory
            SET idParent = OLD.idParent
            WHERE idParent = OLD.idCategory;
        END IF;
        
        RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION update_registreduser_trigger() RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.isBanned != NEW.isBanned AND NEW.isBanned = TRUE
        THEN
            UPDATE RegistredUser
            SET bannedDate = CURRENT_DATE
            WHERE idUser = NEW.idUser;
        END IF;
        
        RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION update_deal_trigger() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.DealState = "Successful" AND NEW.deliveryMethod IS NULL
        THEN
            RAISE EXCEPTION 'When a Deal is successful, a Delivery Method must be set';
        END IF;
        
        IF NEW.deliveryMethod = "Shipping" AND idBuyerInfo IS NULL
        THEN
            RAISE EXCEPTION 'When a Deal is shipping, Buyer Info must be specified';
        END IF;
        
        RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION new_deal_trigger() RETURNS TRIGGER AS $$
    BEGIN
        NEW.dealState = 'Pending';
        NEW.beginningDate = CURRENT_DATE;
        
        RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION update_selling_product_trigger() RETURNS TRIGGER AS $$
    BEGIN
        IF EXISTS (SELECT idProduct 
            FROM Deal
            WHERE dealState = 'Pending'
                AND idSeller = NEW.idSeller
                AND idProduct = NEW.idProduct)
        THEN
            RAISE EXCEPTION 'Product currently being sold';
        END IF;
        
        RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION delete_seller_trigger() RETURNS TRIGGER AS $$
    BEGIN
      DELETE FROM Address WHERE Address.idAddress = OLD.idAddress;

      RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

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

    DROP TRIGGER IF EXISTS update_selling_product_trigger ON Deal;
    CREATE TRIGGER update_selling_product_trigger
        BEFORE INSERT ON WantsToSell
        FOR EACH ROW EXECUTE PROCEDURE update_selling_product_trigger();

    DROP TRIGGER IF EXISTS delete_seller_trigger ON Seller;
    CREATE TRIGGER delete_seller_trigger
        AFTER DELETE ON Seller
        FOR EACH ROW EXECUTE PROCEDURE delete_seller_trigger();


        -- ########### RegisteredUser #################
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Chelsea','QLR97AEB8JF','mollis@ullamcorpernisl.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Andrew','KRB65CIQ7ND','semper@justoeu.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Ethan','YIE05JUT0ZO','risus.Donec.egestas@Nuncsollicitudincommodo.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Timothy','EMA55AYI5NY','et.risus@lobortisquis.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Darryl','BSB24QNW7SY','turpis.nec@luctusCurabituregestas.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Callie','BIS87CQP4OT','tincidunt@in.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Blaze','VTH98FFI5PG','convallis@gravida.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Jasmine','GOB31BNF9ZA','conubia.nostra.per@ad.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Xandra','LNR04CQV6CH','quis.accumsan.convallis@dictum.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Wallace','QCS09ZEV1DQ','sed.sem@hymenaeosMaurisut.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Marny','MJY82PNX9DW','faucibus@consequatpurus.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Christopher','QDB21XNU9RA','consequat.lectus@nequeIn.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Marsden','UYI62LSP2ZX','rutrum@necluctus.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Fitzgerald','IGV14VKZ7TG','euismod.est@massanonante.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Len','MFJ23MQW9TU','eu.augue@Morbimetus.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Aurelia','SQK86DVN1SQ','velit.eget@odio.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Kirsten','MAX23ENO7LV','auctor.vitae@Donec.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Nomlanga','VHF97NPW5TV','nibh@ipsumdolor.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Kelly','MGR04WLG7BB','Etiam@semut.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Jason','PXB77WZD3LW','semper.rutrum.Fusce@facilisisfacilisis.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Omar','NNY85GOV4KG','consectetuer.mauris.id@imperdieterat.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Carl','DTL78YSJ2YS','Mauris.blandit@estarcu.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Lois','KFJ12VIJ0YU','egestas.blandit.Nam@Donec.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Julian','SEK55HTW7LI','at.nisi@anteipsumprimis.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Pearl','VII41YPA6XO','massa.Integer@vitaediamProin.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Lyle','IQH88INM5PY','nibh@ametconsectetuer.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Barbara','UIK28GHQ6KH','porttitor@mollis.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Danielle','RLJ02FTP7EM','amet@consequat.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Fredericka','UDS40DNF9ZN','consequat.lectus@nullaatsem.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Arthur','QOU88FBO9NX','tincidunt@egetipsumDonec.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Penelope','XLT13NFT1PM','dignissim.pharetra@vitaedolor.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Griffin','CBN85QYZ4YM','Sed.eget@elitafeugiat.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Norman','YOJ86NZN0FX','erat.semper.rutrum@sedconsequat.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Rhiannon','ZKA03VWY1CK','amet.luctus.vulputate@mollis.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Barbarian','EYZ70FES8IW','fringilla@orci.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Julie','VZU87FZY7LL','sed.sapien@sagittis.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Wanda','JRI63MMQ7DH','mattis.ornare.lectus@acurnaUt.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Martena','CKY44QTS7QR','ligula@Nuncsollicitudin.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Ocean','DTM99SNJ5MU','Nunc.mauris@sem.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Vance','RGR11QQA8EE','porttitor.interdum@nonante.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Tanek','AKG24UOB6KK','ut.sem.Nulla@ipsumdolor.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Bethany','VAX43EVK4KX','amet.risus@dui.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Raphael','NOL71KYV1QT','a@InloremDonec.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Luke','EKQ04YUD2EV','eget.varius@musProin.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Zorita','XOY84DRH5RV','fermentum.metus@tellusNunclectus.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Harlan','ENA61DVK2QK','tincidunt@lectusquis.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Samuel','GSR86BWF3KY','in.dolor@pede.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Jamal','CAJ63PWQ3AM','dictum.placerat@Sedet.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Miranda','ZBR86YNL3NM','rutrum.Fusce.dolor@facilisis.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Elvis','XNL14CVP5SU','non@laoreetlibero.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Ira','VRE61QFZ8WF','at@libero.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Harrison','QZS10DXW8CZ','Donec.est@Phasellus.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Lesley','KNH35KNX6PY','nec@NullafacilisiSed.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Naida','GKR11QUN5WU','diam@ornareelitelit.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Quintessa','KBB14OAN0GP','Vivamus@pulvinararcuet.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Mechelle','OUU99AOU9UB','In.mi@arcuVestibulum.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Nina','UMF16ZWG2DI','varius@lectus.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Anne','FTR03CDQ3CN','consequat@aaliquetvel.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Benedict','JEP98AYT4EM','non@a.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Madeline','IVJ17KJW2PR','convallis.erat@velconvallis.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Rhonda','SXE48OJI4UW','molestie.orci.tincidunt@etnunc.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Destiny','TVO98FON5OZ','neque.tellus@primisin.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Mufutau','DUQ88LIU4CB','vitae@Naminterdum.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Audra','WVS30PBP6LK','orci@anteipsum.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Cruz','QGO27FST3JR','sollicitudin.orci@semper.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Charles','ZRU03WNX5FJ','aliquet@laoreetlectusquis.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Ariana','MTQ99IEM4TN','nulla.Donec@nec.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Alvin','BVH39HEW6BJ','pellentesque@infaucibus.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Nissim','YWE14DJR5NP','lobortis.tellus.justo@Nunc.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Mason','LOM13QCR6MQ','Praesent.eu@a.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Holly','TMH01BTC3NV','Aenean.sed@magnaatortor.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Rogan','JEI25ETG7ZA','Etiam.vestibulum.massa@ametmassa.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Odette','DKG26GXD9UR','Quisque.varius.Nam@nequeseddictum.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Amos','AYN05HNB1UV','justo@a.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Zachery','WWB15MVY4AN','nibh.sit@sagittislobortis.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Erich','JIP38PNH0EL','ac.metus.vitae@risusquis.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Erasmus','CAB75HPN6KZ','dolor.Donec@interdumSed.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Kyla','UIU66AVR9HV','massa.Mauris@aliquetlobortis.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Cadman','DLN21PST7IQ','ultrices.Vivamus@acfacilisisfacilisis.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Carolyn','GRC28BUG2JZ','ante.lectus.convallis@loremut.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Amity','SRL36IGZ6DR','ornare.lectus@pretiumneque.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Katell','LXJ62CUU5KT','et@Nunccommodoauctor.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Bruce','TEE09UUD6AH','ornare.lectus@quisturpis.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Addison','LPG64NOM7SW','senectus.et.netus@eumetusIn.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Maya','RDI98BBU1CN','accumsan.neque@euismodest.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Ryan','BBS60EEZ8JI','arcu.eu.odio@aenimSuspendisse.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Shaeleigh','LTR93NDP5NC','arcu.Vestibulum@fringillaDonec.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Cameron','KGA99PAH5AS','eu.erat.semper@quisdiamluctus.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Kylan','JKP39YJF3HA','Integer.id@semvitae.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Brent','CSV20VQD0TY','et.netus.et@aliquetlibero.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Aline','PKK52TGI4UF','lorem@risus.org',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Ferris','YKM13RMW5XS','felis.Nulla.tempor@justo.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Colin','VDC60EFV8TY','semper.tellus@lobortis.edu',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Ian','XRY22YKU9VT','amet@nasceturridiculus.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Elton','MVT26FOP8EM','accumsan@variusorciin.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Josephine','IXO91JTN6SG','tincidunt@Etiamvestibulummassa.net',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Rachel','SXZ16JXZ3OB','rhoncus.Nullam.velit@leoelementumsem.co.uk',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Emerald','BBD90QHH0KF','lorem.vitae.odio@sapienimperdietornare.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Vivian','LAG31CVQ1JR','nec@anteipsum.com',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('Kareem','BYY94PMH6YT','auctor.vitae.aliquet@netus.ca',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('admin1','BYY94PMH6YT','admin1@coiso.pt',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('admin2','BYY94PMH6YT','admin2@coiso.pt',FALSE);
        INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('admin3','BYY94PMH6YT','admin3@coiso.pt',FALSE);

            -- ################## Buyer ###############
        INSERT INTO Buyer (idBuyer) VALUES (1);
        INSERT INTO Buyer (idBuyer) VALUES (2);
        INSERT INTO Buyer (idBuyer) VALUES (3);
        INSERT INTO Buyer (idBuyer) VALUES (4);
        INSERT INTO Buyer (idBuyer) VALUES (5);
        INSERT INTO Buyer (idBuyer) VALUES (6);
        INSERT INTO Buyer (idBuyer) VALUES (7);
        INSERT INTO Buyer (idBuyer) VALUES (8);
        INSERT INTO Buyer (idBuyer) VALUES (9);
        INSERT INTO Buyer (idBuyer) VALUES (10);
        INSERT INTO Buyer (idBuyer) VALUES (11);
        INSERT INTO Buyer (idBuyer) VALUES (12);
        INSERT INTO Buyer (idBuyer) VALUES (13);
        INSERT INTO Buyer (idBuyer) VALUES (14);
        INSERT INTO Buyer (idBuyer) VALUES (15);
        INSERT INTO Buyer (idBuyer) VALUES (16);
        INSERT INTO Buyer (idBuyer) VALUES (17);
        INSERT INTO Buyer (idBuyer) VALUES (18);
        INSERT INTO Buyer (idBuyer) VALUES (19);
        INSERT INTO Buyer (idBuyer) VALUES (20);
        INSERT INTO Buyer (idBuyer) VALUES (21);
        INSERT INTO Buyer (idBuyer) VALUES (22);
        INSERT INTO Buyer (idBuyer) VALUES (23);
        INSERT INTO Buyer (idBuyer) VALUES (24);
        INSERT INTO Buyer (idBuyer) VALUES (25);
        INSERT INTO Buyer (idBuyer) VALUES (26);
        INSERT INTO Buyer (idBuyer) VALUES (27);
        INSERT INTO Buyer (idBuyer) VALUES (28);
        INSERT INTO Buyer (idBuyer) VALUES (29);
        INSERT INTO Buyer (idBuyer) VALUES (30);
        INSERT INTO Buyer (idBuyer) VALUES (31);
        INSERT INTO Buyer (idBuyer) VALUES (32);
        INSERT INTO Buyer (idBuyer) VALUES (33);
        INSERT INTO Buyer (idBuyer) VALUES (34);
        INSERT INTO Buyer (idBuyer) VALUES (35);
        INSERT INTO Buyer (idBuyer) VALUES (36);
        INSERT INTO Buyer (idBuyer) VALUES (37);
        INSERT INTO Buyer (idBuyer) VALUES (38);
        INSERT INTO Buyer (idBuyer) VALUES (39);
        INSERT INTO Buyer (idBuyer) VALUES (40);
        INSERT INTO Buyer (idBuyer) VALUES (41);
        INSERT INTO Buyer (idBuyer) VALUES (42);
        INSERT INTO Buyer (idBuyer) VALUES (43);
        INSERT INTO Buyer (idBuyer) VALUES (44);
        INSERT INTO Buyer (idBuyer) VALUES (45);
        INSERT INTO Buyer (idBuyer) VALUES (46);
        INSERT INTO Buyer (idBuyer) VALUES (47);
        INSERT INTO Buyer (idBuyer) VALUES (48);
        INSERT INTO Buyer (idBuyer) VALUES (49);
        INSERT INTO Buyer (idBuyer) VALUES (50);


        -- ##################### Country ####################
        INSERT INTO Country (name) VALUES ('Colombia');
        INSERT INTO Country (name) VALUES ('Seychelles');
        INSERT INTO Country (name) VALUES ('Mauritania');
        INSERT INTO Country (name) VALUES ('Saint Pierre and Miqulon');
        INSERT INTO Country (name) VALUES ('China');
        INSERT INTO Country (name) VALUES ('United States Minor Outlying Islands');
        INSERT INTO Country (name) VALUES ('Tunisia');
        INSERT INTO Country (name) VALUES ('Cocos (Keeling) Islands');
        INSERT INTO Country (name) VALUES ('Paraguay');
        INSERT INTO Country (name) VALUES ('Algerio');
        INSERT INTO Country (name) VALUES ('Guinea');
        INSERT INTO Country (name) VALUES ('Singapore');
        INSERT INTO Country (name) VALUES ('Honduras');
        INSERT INTO Country (name) VALUES ('LALALALA');
        INSERT INTO Country (name) VALUES ('Cook Islands');
        INSERT INTO Country (name) VALUES ('Liberia');
        INSERT INTO Country (name) VALUES ('Turkey');
        INSERT INTO Country (name) VALUES ('Hungary');
        INSERT INTO Country (name) VALUES ('Croatia');
        INSERT INTO Country (name) VALUES ('Sierra Leone');
        INSERT INTO Country (name) VALUES ('Trinidade and Tobago');
        INSERT INTO Country (name) VALUES ('São Cosme');
        INSERT INTO Country (name) VALUES ('Estonia');
        INSERT INTO Country (name) VALUES ('Dominican Republico');
        INSERT INTO Country (name) VALUES ('New Zealand');
        INSERT INTO Country (name) VALUES ('Congo (Brazzaville)');
        INSERT INTO Country (name) VALUES ('Saint Lucia');
        INSERT INTO Country (name) VALUES ('Trinidad and Tobago');
        INSERT INTO Country (name) VALUES ('Malawi');
        INSERT INTO Country (name) VALUES ('Central African Republic');
        INSERT INTO Country (name) VALUES ('French Guiano');
        INSERT INTO Country (name) VALUES ('Puerto Rico');
        INSERT INTO Country (name) VALUES ('Semen');
        INSERT INTO Country (name) VALUES ('Fuji');
        INSERT INTO Country (name) VALUES ('Central African Republico');
        INSERT INTO Country (name) VALUES ('Spain');
        INSERT INTO Country (name) VALUES ('Niger');
        INSERT INTO Country (name) VALUES ('Cuba');
        INSERT INTO Country (name) VALUES ('Tuvalu');
        INSERT INTO Country (name) VALUES ('Mayotte');
        INSERT INTO Country (name) VALUES ('Samoa');
        INSERT INTO Country (name) VALUES ('Malawis');
        INSERT INTO Country (name) VALUES ('Bulgaria');
        INSERT INTO Country (name) VALUES ('Christmas Island');
        INSERT INTO Country (name) VALUES ('Kasakhstan');
        INSERT INTO Country (name) VALUES ('Israel');
        INSERT INTO Country (name) VALUES ('Bangladesh');
        INSERT INTO Country (name) VALUES ('Dominica');
        INSERT INTO Country (name) VALUES ('Serbia');
        INSERT INTO Country (name) VALUES ('Sweden');
        INSERT INTO Country (name) VALUES ('Mauritanio');
        INSERT INTO Country (name) VALUES ('I KILL YOU');
        INSERT INTO Country (name) VALUES ('Norfolk Island');
        INSERT INTO Country (name) VALUES ('Bonaire, Sint Eustatius and Saba');
        INSERT INTO Country (name) VALUES ('Belarus');
        INSERT INTO Country (name) VALUES ('United Arab Emirates');
        INSERT INTO Country (name) VALUES ('Dominican Republic');
        INSERT INTO Country (name) VALUES ('Jersey');
        INSERT INTO Country (name) VALUES ('Togo');
        INSERT INTO Country (name) VALUES ('Brains');
        INSERT INTO Country (name) VALUES ('Nepal');
        INSERT INTO Country (name) VALUES ('Ghana');
        INSERT INTO Country (name) VALUES ('Australia');
        INSERT INTO Country (name) VALUES ('Fiji');
        INSERT INTO Country (name) VALUES ('Syria');
        INSERT INTO Country (name) VALUES ('Japan');
        INSERT INTO Country (name) VALUES ('Laos');
        INSERT INTO Country (name) VALUES ('Azerbaijan');
        INSERT INTO Country (name) VALUES ('Bahrain');
        INSERT INTO Country (name) VALUES ('French Guiana');
        INSERT INTO Country (name) VALUES ('Germany');
        INSERT INTO Country (name) VALUES ('Saint Martin');
        INSERT INTO Country (name) VALUES ('Yemen');
        INSERT INTO Country (name) VALUES ('Korea, North');
        INSERT INTO Country (name) VALUES ('Saint Pierre and Miquelon');
        INSERT INTO Country (name) VALUES ('Nigeria');
        INSERT INTO Country (name) VALUES ('Algeria');
        INSERT INTO Country (name) VALUES ('Grenada');
        INSERT INTO Country (name) VALUES ('Turkmenistan');
        INSERT INTO Country (name) VALUES ('Reunion');
        INSERT INTO Country (name) VALUES ('British Indian Ocean Territory');
        INSERT INTO Country (name) VALUES ('Heard Island and Mcdonald Islands');
        INSERT INTO Country (name) VALUES ('Tokelau');
        INSERT INTO Country (name) VALUES ('Uganda');
        INSERT INTO Country (name) VALUES ('Liechtenstein');
        INSERT INTO Country (name) VALUES ('Egypt');
        INSERT INTO Country (name) VALUES ('Luxembourg');
        INSERT INTO Country (name) VALUES ('El Salvador');
        INSERT INTO Country (name) VALUES ('Nicaragua');
        INSERT INTO Country (name) VALUES ('Niue');
        INSERT INTO Country (name) VALUES ('Cayman Islands');
        INSERT INTO Country (name) VALUES ('New Caledonia');
        INSERT INTO Country (name) VALUES ('Chile');
        INSERT INTO Country (name) VALUES ('Korea, South');
        INSERT INTO Country (name) VALUES ('Kazakhstan');
        INSERT INTO Country (name) VALUES ('Jamaica');
        INSERT INTO Country (name) VALUES ('Iraq');
        INSERT INTO Country (name) VALUES ('Sint Maarten');
        INSERT INTO Country (name) VALUES ('Andorra');
        INSERT INTO Country (name) VALUES ('Kiribati');

          -- ############### Address ###################### 
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 130, 3920 Cras Ave','0209VV','Poggio San Marcello',71);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 148, 5028 Ante Rd.','4948','Gouda',3);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('733-2795 Diam Ave','61202','Siena',69);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('806-8948 Interdum Ave','96037','Moen',38);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('166-4891 Risus Street','9714','Casoli',82);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('4894 Et Road','408615','Carleton',80);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('583-292 Ornare Street','N2N 0M8','Villers-la-Bonne-Eau',37);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 418, 967 Ornare, St.','34095','Gudivada',13);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('360 Suspendisse St.','71913','Barcelona',57);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('7877 Cum Av.','G8B 4Y5','Sainte-Flavie',7);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('270-3815 Proin Road','X8S 7A4','Osasco',49);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #545-6216 Sollicitudin Street','5173','Pointe-au-Pic',65);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('119-7786 Lorem Rd.','1882','Bogaarden',31);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #312-7930 Aenean Av.','J0K 6W1','Westmount',9);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 497, 405 Sapien. Avenue','3493VU','Albisola Superiore',65);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #150-1576 Luctus, Rd.','27904','Warren',14);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #801-1460 Augue Av.','3616','Todi',94);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 454, 439 Orci. Rd.','27498','Wattrelos',3);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #633-9804 Nibh. Street','8380','Stockport',12);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #807-2616 Penatibus Av.','67450','Martello/Martell',55);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #706-9239 Eros Street','69655','Baltasound',81);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('787-166 Non St.','4082','Bowden',65);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 605, 7560 Ut Av.','18124','San Piero a Sieve',48);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('8194 Sed Avenue','3582','Newport',53);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('874-7389 Sagittis. St.','11855','Queenstown',96);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #729-6209 Euismod Road','R5E 7T4','Roubaix',51);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('7423 Purus, St.','7217','Chesapeake',51);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #737-7240 Consectetuer Street','61740','Douai',58);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #909-7944 Dignissim St.','71305','Jacksonville',25);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('644-2187 Risus Av.','96008','Udaipur',52);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('9804 Cras St.','88309','Baili�vre',29);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #150-1887 Vestibulum, Rd.','26775','Cuddapah',47);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #341-8279 Ut, Street','6587','Donosti',63);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('226-4228 Vivamus Street','32867-189','Bhagalpur',77);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 777, 5054 Et St.','C0 3QA','Drachten',43);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('9980 Commodo Ave','76109','Collinas',55);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('166-8836 Dictum Street','11800','Ferrere',84);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('6644 Egestas. Av.','6862WG','Durham',22);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #973-4459 Fusce Road','20723','Harlingen',29);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('8668 Turpis. Rd.','0057','Maltignano',78);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('7388 Leo Road','21890','Ransart',73);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('988-409 Urna St.','27463','Ingolstadt',2);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('765-1163 Ultricies Rd.','57399','Rochester',38);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #871-2331 Tristique Av.','2714','Bolsward',48);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #945-9728 Tempor Ave','8262','Whangarei',24);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('5708 Curabitur Rd.','07452','Welland',67);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('347-7890 Egestas, Street','9617','Torino',38);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 620, 1954 Erat, Rd.','J2 3XU','Rocky Mountain House',44);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('989-1570 A, Rd.','05397','Bogaarden',81);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #106-5137 Eu Avenue','8888','Vilna',70);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('338-9053 Turpis. Avenue','276339','Dorval',76);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('2321 Et Rd.','5347','Bear',58);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #235-7271 Dignissim Rd.','59727','Huntsville',37);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #994-7415 Torquent Rd.','710029','Southaven',96);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #276-8519 Hendrerit Av.','55725','Saint-Dizier',38);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('3084 Pede. Rd.','5553','San Cristóbal de la Laguna',81);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('635-4360 Ante. Street','954770','Thorembais-les-B�guines',24);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 242, 1723 Maecenas Street','52219','Marcinelle',23);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('559-1119 Urna Rd.','06813','Lauder',80);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('3955 Sagittis St.','94139-592','Wabamun',27);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #458-4004 Urna. Av.','X6C 3NY','Muzaffarpur',12);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #680-1174 Sagittis St.','20714','St. Thomas',27);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('450-9926 Mi Ave','6917','Millesimo',28);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('2315 Nec, Av.','1669','Hamme',17);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('506-4919 Purus Av.','2012','Sant''Agapito',97);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 292, 4281 Orci St.','R8C 5B9','Malgesso',87);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('5010 Non, St.','3820','Autelbas',66);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 951, 1776 Tellus St.','6862','Sherbrooke',58);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('217-1821 Eu, Ave','7536','Kanpur',73);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 373, 6161 Elit Rd.','851954','Arsoli',98);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('191-2092 Non St.','1430AB','Neuville',63);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #765-9420 Arcu Avenue','09166-119','Llandovery',63);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #265-450 Eu, St.','70139','Roosendaal',24);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('1244 Vitae St.','7955LC','Aylesbury',90);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('446-199 At, Rd.','C9H 8X4','Hay River',73);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('833-4137 Nonummy Rd.','862294','Louth',50);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('6580 Ante. Street','71815','Scala Coeli',28);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #753-5494 Phasellus Road','82395','Villanova d''Albenga',86);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('921-2882 Tristique Road','51609','Brest',95);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #857-9187 Lectus Rd.','160649','Provost',85);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 222, 6495 Aliquet Ave','3807','Port Moody',69);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 910, 816 Tortor Rd.','126601','Guarapuava',16);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 639, 2441 Ornare Street','62709','Arzano',95);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('4357 Sagittis. Rd.','51519','Preore',73);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('2413 Risus Street','07572','Sloten',35);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 830, 8586 Tincidunt Street','68699','Clackmannan',40);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 371, 9024 Diam Street','4114','Castel San Niccolò',11);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #674-7466 Nunc Road','64846','Kapolei',43);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 556, 2620 Posuere St.','8754','Silvassa',14);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 821, 3843 Pretium Street','54475-713','Baie-Saint-Paul',97);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 350, 6930 Risus, Av.','3918','Queenstown',40);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 904, 542 Mauris Road','J5Y 8P0','New Bombay',80);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #254-4690 A St.','9561','Gonnosnò',33);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('990-9248 Tincidunt Avenue','14919','Cuddalore',33);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #228-7930 Aliquet, St.','0177','Zeitz',52);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('2977 Lectus, St.','4332PE','St. Neots',48);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('295-562 Aliquam Road','43821','Bolano',64);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('P.O. Box 714, 8142 Magnis Street','25750','Villata',76);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('9340 Orci Avenue','6297','Gandhinagar',23);
        INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Ap #790-2133 Tempus Av.','K5A 7X6','Meeuwen-Gruitrode',78);


        -- ###################### Seller #########################
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (51,2,'Tempus Risus Donec PC','1-844-458-6944','porttitor tellus non magna. Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in, hendrerit consectetuer, cursus et,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (52,3,'Ipsum Associates','1-356-327-8589','nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit. Donec porttitor tellus non magna. Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in, hendrerit',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (53,4,'Bibendum Fermentum Metus Corp.','327-2397','id, blandit at, nisi. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel nisl. Quisque fringilla euismod enim. Etiam gravida molestie arcu. Sed eu nibh vulputate mauris sagittis placerat. Cras dictum ultricies ligula. Nullam enim. Sed',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (54,5,'Eu Incorporated','1-382-984-1347','sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean eget magna.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (55,6,'Vitae Velit Egestas Inc.','1-511-582-5303','turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit. Donec porttitor tellus non magna. Nam ligula',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (56,7,'Aliquet Molestie Tellus Institute','286-5356','non enim commodo hendrerit. Donec porttitor tellus non magna. Nam ligula elit, pretium et, rutrum',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (57,8,'Accumsan Convallis Industries','1-129-360-0902','gravida sit amet, dapibus id, blandit at, nisi. Cum sociis natoque penatibus et magnis',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (58,9,'Ullamcorper Duis Associates','1-913-310-3975','diam. Sed diam lorem, auctor quis, tristique ac, eleifend vitae, erat. Vivamus nisi. Mauris nulla. Integer urna. Vivamus molestie dapibus ligula. Aliquam erat volutpat. Nulla dignissim. Maecenas ornare',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (59,10,'Eu Augue Inc.','1-322-906-3886','consectetuer euismod est arcu ac orci. Ut semper pretium neque. Morbi quis urna. Nunc quis arcu vel quam dignissim pharetra. Nam ac nulla. In tincidunt congue turpis.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (60,11,'Suspendisse LLC','1-683-465-4340','tempor, est ac mattis semper, dui lectus rutrum urna, nec luctus felis purus ac tellus. Suspendisse sed dolor. Fusce mi lorem, vehicula et, rutrum eu, ultrices sit amet, risus.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (61,12,'Semper Egestas Urna Corporation','909-3441','mi tempor lorem, eget mollis lectus pede et risus. Quisque libero lacus, varius et, euismod et, commodo at, libero. Morbi accumsan laoreet ipsum. Curabitur consequat, lectus sit amet luctus',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (62,13,'Purus Accumsan Incorporated','915-6579','Cras dolor dolor, tempus non, lacinia at, iaculis quis, pede. Praesent',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (63,14,'Eu Neque Pellentesque Consulting','654-3509','Aenean eget magna. Suspendisse tristique neque venenatis lacus. Etiam bibendum fermentum metus. Aenean sed pede',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (64,15,'Ullamcorper Duis Cursus Foundation','596-5960','velit in aliquet lobortis, nisi nibh lacinia orci, consectetuer euismod est arcu ac orci. Ut semper pretium',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (65,16,'Dui LLP','1-335-593-4484','luctus vulputate, nisi sem semper erat, in consectetuer ipsum nunc id enim. Curabitur massa. Vestibulum accumsan neque et nunc. Quisque ornare tortor at risus. Nunc ac sem ut dolor dapibus gravida. Aliquam tincidunt, nunc',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (66,17,'Libero Integer Industries','966-0419','adipiscing non, luctus sit amet, faucibus ut, nulla. Cras eu tellus eu augue porttitor interdum. Sed auctor odio a purus. Duis elementum,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (67,18,'Interdum Inc.','778-0848','gravida non, sollicitudin a, malesuada id, erat. Etiam vestibulum massa rutrum magna. Cras convallis convallis dolor. Quisque tincidunt pede ac urna. Ut tincidunt vehicula risus. Nulla eget metus',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (68,19,'Volutpat Ornare Facilisis Corp.','1-451-868-5551','quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (69,20,'Id Foundation','1-795-633-5451','Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce aliquet magna a neque. Nullam ut nisi a odio semper cursus. Integer mollis. Integer tincidunt aliquam arcu. Aliquam ultrices iaculis odio. Nam interdum enim non nisi. Aenean eget metus. In',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (70,21,'Eu Euismod Ac Limited','441-8634','nisl. Maecenas malesuada fringilla est. Mauris eu turpis. Nulla aliquet. Proin velit. Sed malesuada augue ut lacus. Nulla tincidunt, neque vitae semper egestas, urna justo faucibus lectus, a sollicitudin orci sem eget massa. Suspendisse eleifend. Cras',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (71,22,'Proin Ultrices Corp.','193-8501','velit. Sed malesuada augue ut lacus. Nulla tincidunt, neque vitae semper egestas, urna justo faucibus lectus,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (72,23,'Lobortis Ultrices LLP','1-864-568-1401','In nec orci. Donec nibh. Quisque nonummy ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque. Sed',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (73,24,'Pharetra Quisque Incorporated','597-8689','Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna tellus faucibus leo, in',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (74,25,'In Sodales Elit Institute','1-608-528-4532','tincidunt dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus id, libero. Donec consectetuer mauris',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (75,26,'Arcu Incorporated','461-8708','pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (76,27,'Sollicitudin LLC','1-738-899-2868','lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (77,28,'Dui Associates','1-962-940-5748','Phasellus nulla. Integer vulputate, risus a ultricies adipiscing, enim mi tempor lorem, eget mollis lectus pede et risus. Quisque libero lacus, varius et, euismod et, commodo at, libero. Morbi accumsan laoreet ipsum.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (78,29,'Tellus Non Corporation','519-7715','cursus purus. Nullam scelerisque neque sed sem egestas blandit. Nam nulla magna, malesuada vel, convallis in, cursus et, eros. Proin ultrices. Duis volutpat nunc sit amet metus. Aliquam erat volutpat. Nulla facilisis. Suspendisse commodo tincidunt nibh. Phasellus nulla. Integer vulputate,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (79,30,'Dui Limited','698-2943','nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam a felis ullamcorper viverra. Maecenas iaculis aliquet diam. Sed diam lorem, auctor quis, tristique',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (80,31,'At Augue Id Institute','784-4109','et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (81,32,'Mauris Vel Corp.','508-2787','Donec vitae erat vel pede blandit congue. In scelerisque scelerisque dui.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (82,33,'Egestas LLP','626-7221','eu tellus eu augue porttitor interdum. Sed auctor odio a purus. Duis elementum, dui quis accumsan convallis, ante lectus convallis est,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (83,34,'Aliquet Ltd','1-876-671-1526','facilisis facilisis, magna tellus faucibus leo, in lobortis tellus justo sit amet nulla. Donec non justo. Proin non massa non ante bibendum ullamcorper. Duis cursus, diam at',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (84,35,'Ut Eros Non Incorporated','1-603-502-4890','arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus. Vivamus euismod urna.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (85,36,'Ipsum Primis In Institute','1-297-843-5415','sollicitudin orci sem eget massa. Suspendisse eleifend. Cras sed leo. Cras vehicula aliquet libero. Integer',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (86,37,'Sed Associates','1-540-434-7306','Maecenas mi felis, adipiscing fringilla, porttitor vulputate, posuere vulputate, lacus. Cras interdum. Nunc sollicitudin commodo ipsum. Suspendisse non leo. Vivamus',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (87,38,'Sapien Molestie Orci LLC','168-7442','fringilla. Donec feugiat metus sit amet ante. Vivamus non lorem vitae odio sagittis semper. Nam tempor diam dictum sapien.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (88,39,'Gravida Sagittis Duis PC','1-274-544-1269','eget tincidunt dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus id, libero. Donec consectetuer mauris id sapien. Cras dolor dolor, tempus non, lacinia at, iaculis quis, pede. Praesent eu dui. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (89,40,'Placerat Augue Sed Ltd','1-318-537-3003','et, commodo at, libero. Morbi accumsan laoreet ipsum. Curabitur consequat,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (90,41,'Etiam Ltd','804-6152','Nunc sed orci lobortis augue scelerisque mollis. Phasellus libero mauris, aliquam eu,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (91,42,'Sapien Cras Associates','645-3863','aliquam adipiscing lacus. Ut nec urna et arcu imperdiet ullamcorper.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (92,43,'Phasellus Incorporated','1-768-522-9389','dolor dolor, tempus non, lacinia at, iaculis quis, pede. Praesent eu dui. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean eget magna. Suspendisse tristique neque venenatis lacus.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (93,44,'Laoreet Industries','428-4425','pharetra. Nam ac nulla. In tincidunt congue turpis. In condimentum. Donec at arcu. Vestibulum ante ipsum primis in faucibus orci luctus et',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (94,45,'Odio Sagittis Corporation','570-4538','mattis semper, dui lectus rutrum urna, nec luctus felis purus ac tellus. Suspendisse sed dolor. Fusce mi lorem, vehicula et,',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (95,46,'Sem Industries','1-377-729-2867','urna justo faucibus lectus, a sollicitudin orci sem eget massa. Suspendisse eleifend. Cras sed leo. Cras vehicula aliquet libero. Integer in magna. Phasellus dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus quis massa. Mauris vestibulum, neque sed dictum',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (96,47,'Sed Sapien Nunc Associates','1-727-249-2626','gravida. Aliquam tincidunt, nunc ac mattis ornare, lectus ante dictum mi, ac mattis velit',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (97,48,'Eu Foundation','1-869-636-8643','et risus. Quisque libero lacus, varius et, euismod et, commodo at, libero.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (98,49,'Magnis Dis Incorporated','938-4997','dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit. Donec porttitor tellus non',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (99,50,'Ullamcorper Eu LLP','1-167-499-5441','odio. Nam interdum enim non nisi. Aenean eget metus. In nec orci. Donec nibh. Quisque nonummy ipsum non arcu.',TRUE);
        INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (100,1,'Quisque Varius Limited','143-1078','sem egestas blandit. Nam nulla magna, malesuada vel, convallis in, cursus et, eros. Proin ultrices. Duis volutpat nunc sit amet metus. Aliquam erat volutpat. Nulla facilisis. Suspendisse commodo tincidunt nibh. Phasellus nulla. Integer vulputate, risus',FALSE);

        -- ################### CreditCard ################## 
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (1,'Emma Gillespie','5041253650431245','2014-01-02T20:02:09-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (2,'Sawyer Fletcher','6355194127376399','2013-08-04T03:56:23-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (3, 'Aphrodite Richmond','6574075500175935','2014-06-18T18:03:52-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (4,'Stone Mosley','0599842513216293','2014-01-31T16:27:03-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (5,'Oscar Chan','0195288060418791','2013-08-08T13:15:32-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (6,'Wayne Booth','0693458843715105','2014-10-03T19:52:06-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (7,'Orli Nelson','7795053162478302','2015-01-19T15:12:46-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (8,'Jolene Durham','8363434914739623','2014-06-10T12:23:46-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (9,'Priscilla Wynn','9459232709033290','2013-09-22T15:58:59-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (10,'Cheryl Mcdaniel','0319659098103236','2014-10-11T14:52:22-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (11,'Oleg Frost','8025168157542019','2013-07-18T19:59:35-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (12,'Ava Anthony','1443350608941052','2013-07-18T04:23:02-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (13,'Desirae Andrews','7333955199090786','2014-11-06T03:29:27-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (14,'ElliottWashington','8133013501902841','2013-10-09T19:16:06-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (15,'Fallon Bright','9230570851178736','2014-04-25T21:08:43-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (16,'Amaya Frederick','2951261395178984','2014-05-02T08:03:50-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (17,'September Franklin','8937258927161708','2014-10-24T03:16:55-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (18,'Karen Douglas','5591003430819183','2014-08-27T20:08:11-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (19,'Carson Pate','2477190470670315','2014-04-17T17:06:00-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (20,'Odysseus Horne','0374934046833693','2014-02-24T10:52:06-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (21,'Kiara Pruitt','1229743277327977','2014-01-20T17:30:10-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (22,'Myra King','6300302217939952','2014-05-10T15:42:39-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (23,'Cairo Blackwell','4792422381298298','2013-05-07T20:51:02-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (24,'Fallon Byers','2323830326692775','2014-10-19T17:23:29-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (25,'Zoe Valdez','6274436352199378','2014-09-01T00:51:51-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (26,'Kyla Hyde','9050396560402283','2014-01-08T03:07:54-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (27,'Charity Jones','0825434130273299','2015-03-15T14:37:11-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (28,'Brendan Carver','6580504089937086','2013-12-18T10:41:09-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (29,'Chava Diaz','1318354470902574','2014-02-11T08:29:23-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (30,'Blossom Barr','2777665851630381','2015-03-14T16:15:37-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (31,'Demetria Langley','2145710822774978','2013-10-09T03:34:26-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (32,'Elliott Lancaster','6101678498687852','2013-08-24T05:39:24-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (33,'Henry Hull','4770739009523930','2013-06-02T04:30:21-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (34,'Lacota Wallace','5130672609162480','2013-11-12T01:41:40-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (35,'Scarlett Gaines','6792128594579474','2013-09-15T01:13:22-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (36,'Driscoll Kane','1703984658208148','2013-08-27T05:14:04-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (37,'Darius Romero','5198380384338320','2014-07-25T11:20:51-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (38,'Nathan Lyons','0540344384713458','2015-02-25T10:52:02-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (39,'Holly Adams','8198368942091469','2014-10-02T14:59:01-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (40,'Hu Cox','6240813814592625','2014-09-02T20:25:04-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (41,'Tatyana Cantu','5998540114035627','2014-01-29T14:04:31-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (42,'Desiree Guerra','1277567843065121','2015-03-15T05:04:04-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (43,'Aquila Mcclure','0283542974185109','2014-11-08T23:30:23-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (44,'Tate Compton','5699245103457236','2014-11-09T13:40:36-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (45,'Griffith Carpenter','9863867341160405','2013-06-14T05:29:01-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (46,'Ila Montoya','8028331871305488','2014-05-12T00:20:07-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (47,'Latifah Petersen','1898418083834140','2015-01-02T10:48:02-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (48,'Abbot Mullins','4481956723255876','2015-02-19T08:08:32-08:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (49,'Molly Atkins','2397999791045792','2013-08-31T22:31:25-07:00');
        INSERT INTO CreditCard (idBuyer,ownerName,number,dueDate) VALUES (50,'Palmer Hancock','8191813344459324','2013-10-11T08:32:22-07:00');

        -- ###################### Product #########################
        INSERT INTO Product (name,description,approved) VALUES ('et, rutrum eu, ultrices','turpis egestas. Aliquam fringilla cursus purus. Nullam scelerisque neque sed sem egestas blandit. Nam nulla',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('leo. Morbi neque tellus, imperdiet','Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit nonummy. Fusce fermentum fermentum',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('aliquam','dis parturient montes, nascetur ridiculus mus. Aenean eget magna. Suspendisse tristique neque venenatis lacus. Etiam bibendum fermentum metus. Aenean sed pede nec ante blandit viverra. Donec tempus, lorem fringilla',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('amet,','Proin vel nisl. Quisque fringilla euismod enim. Etiam gravida molestie arcu. Sed eu nibh vulputate mauris sagittis placerat. Cras dictum ultricies ligula. Nullam enim. Sed nulla',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('diam','nec tempus mauris erat eget ipsum. Suspendisse sagittis. Nullam vitae diam. Proin dolor. Nulla',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('mus. Donec dignissim magna a','enim mi tempor lorem, eget mollis lectus pede et risus. Quisque libero lacus, varius et, euismod et, commodo at, libero. Morbi accumsan laoreet ipsum. Curabitur',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('arcu. Sed eu','lectus quis massa. Mauris vestibulum, neque sed dictum eleifend, nunc risus varius orci, in consequat enim diam vel arcu. Curabitur ut odio vel est',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('aliquam iaculis, lacus pede sagittis','hendrerit id, ante. Nunc mauris sapien, cursus in, hendrerit consectetuer, cursus et, magna. Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('ridiculus mus.','vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc nulla vulputate dui, nec tempus mauris erat eget ipsum. Suspendisse sagittis. Nullam',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('Nunc','egestas a, dui. Cras pellentesque. Sed dictum. Proin eget odio. Aliquam vulputate ullamcorper magna. Sed eu eros. Nam consequat dolor vitae dolor.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('Nunc ut','ut, molestie in, tempus eu, ligula. Aenean euismod mauris eu elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit nonummy. Fusce fermentum fermentum arcu.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('mi eleifend egestas. Sed','massa. Mauris vestibulum, neque sed dictum eleifend, nunc risus varius orci, in consequat enim diam vel arcu. Curabitur ut odio vel est tempor bibendum. Donec felis orci, adipiscing',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('Mauris','consectetuer ipsum nunc id enim. Curabitur massa. Vestibulum accumsan neque et nunc. Quisque ornare tortor at risus. Nunc',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('egestas. Aliquam nec enim. Nunc','pharetra sed, hendrerit a, arcu. Sed et libero. Proin mi. Aliquam gravida mauris ut mi. Duis risus odio,',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('Nullam vitae diam. Proin dolor.','ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('lectus convallis est, vitae sodales','Proin ultrices. Duis volutpat nunc sit amet metus. Aliquam erat volutpat. Nulla facilisis. Suspendisse commodo tincidunt nibh. Phasellus nulla.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('laoreet lectus quis massa. Mauris','Phasellus dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('In nec orci.','elit, a feugiat tellus lorem eu metus. In lorem. Donec elementum, lorem',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('iaculis odio. Nam interdum','lectus, a sollicitudin orci sem eget massa. Suspendisse eleifend. Cras sed leo. Cras vehicula aliquet libero. Integer in magna. Phasellus',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('fringilla','malesuada augue ut lacus. Nulla tincidunt, neque vitae semper egestas, urna justo faucibus lectus, a',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('neque. Nullam nisl. Maecenas malesuada','Integer eu lacus. Quisque imperdiet, erat nonummy ultricies ornare, elit elit fermentum risus, at fringilla purus mauris a nunc. In at pede. Cras vulputate velit',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('lacus.','aliquet. Proin velit. Sed malesuada augue ut lacus. Nulla tincidunt, neque vitae semper egestas, urna justo faucibus',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('libero. Integer in magna. Phasellus','aliquet lobortis, nisi nibh lacinia orci, consectetuer euismod est arcu ac orci. Ut semper pretium',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('mi lorem, vehicula et, rutrum','posuere at, velit. Cras lorem lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('sit amet, consectetuer adipiscing elit.','sollicitudin adipiscing ligula. Aenean gravida nunc sed pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('scelerisque neque. Nullam nisl.','urna et arcu imperdiet ullamcorper. Duis at lacus. Quisque purus sapien, gravida non, sollicitudin a, malesuada id, erat.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('Vivamus molestie dapibus','risus. In mi pede, nonummy ut, molestie in, tempus eu, ligula. Aenean euismod mauris eu elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('nunc. In at pede.','est mauris, rhoncus id, mollis nec, cursus a, enim. Suspendisse aliquet, sem ut cursus',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('purus.','diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('vel sapien imperdiet ornare. In','commodo hendrerit. Donec porttitor tellus non magna. Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in,',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('augue porttitor interdum. Sed','Vivamus non lorem vitae odio sagittis semper. Nam tempor diam',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('nunc id enim. Curabitur massa.','sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('nulla.','magna. Cras convallis convallis dolor. Quisque tincidunt pede ac urna. Ut tincidunt vehicula risus. Nulla eget metus',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('ridiculus mus. Donec','Sed pharetra, felis eget varius ultrices, mauris ipsum porta elit, a feugiat tellus lorem eu metus. In lorem. Donec',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('magna a tortor.','ante dictum mi, ac mattis velit justo nec ante. Maecenas mi felis, adipiscing',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('et netus et','eget mollis lectus pede et risus. Quisque libero lacus, varius et, euismod et, commodo',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('mi. Aliquam gravida mauris','convallis in, cursus et, eros. Proin ultrices. Duis volutpat nunc sit amet metus. Aliquam erat volutpat. Nulla facilisis. Suspendisse commodo tincidunt nibh. Phasellus nulla. Integer vulputate, risus a',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('nonummy.','cursus et, eros. Proin ultrices. Duis volutpat nunc sit amet metus. Aliquam erat volutpat.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('sapien','vehicula aliquet libero. Integer in magna. Phasellus dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus quis massa. Mauris vestibulum, neque sed dictum eleifend, nunc',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('accumsan convallis, ante lectus','ac mattis ornare, lectus ante dictum mi, ac mattis velit justo nec ante. Maecenas mi felis, adipiscing fringilla, porttitor vulputate, posuere vulputate, lacus. Cras interdum. Nunc sollicitudin commodo ipsum.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('Curabitur','dolor. Quisque tincidunt pede ac urna. Ut tincidunt vehicula risus. Nulla eget metus eu erat semper rutrum. Fusce dolor quam, elementum at, egestas a, scelerisque sed, sapien.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('Aliquam fringilla cursus purus.','natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec dignissim magna a tortor. Nunc commodo auctor velit. Aliquam nisl. Nulla eu neque pellentesque massa lobortis ultrices. Vivamus rhoncus.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('pellentesque. Sed dictum. Proin eget','ut, pharetra sed, hendrerit a, arcu. Sed et libero. Proin mi. Aliquam gravida mauris',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('amet ultricies sem magna','Aliquam adipiscing lobortis risus. In mi pede, nonummy ut, molestie in, tempus eu, ligula. Aenean euismod',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('porttitor','lorem lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('aptent taciti sociosqu ad','Nunc pulvinar arcu et pede. Nunc sed orci lobortis augue scelerisque mollis. Phasellus',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('et malesuada fames ac','nec, euismod in, dolor. Fusce feugiat. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam auctor, velit eget laoreet posuere, enim nisl elementum purus,',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('odio. Etiam ligula','nibh sit amet orci. Ut sagittis lobortis mauris. Suspendisse aliquet molestie tellus. Aenean egestas hendrerit neque. In ornare sagittis felis.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('auctor velit. Aliquam','feugiat non, lobortis quis, pede. Suspendisse dui. Fusce diam nunc, ullamcorper eu, euismod ac, fermentum vel,',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('commodo tincidunt nibh. Phasellus nulla.','ante blandit viverra. Donec tempus, lorem fringilla ornare placerat, orci lacus vestibulum lorem, sit amet ultricies sem magna nec quam.',TRUE);
        INSERT INTO Product (name,description,approved) VALUES ('consectetuer, cursus et, magna.','vitae sodales nisi magna sed dui. Fusce aliquam, enim nec tempus scelerisque, lorem ipsum sodales purus, in molestie tortor nibh sit amet orci. Ut',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('diam. Proin dolor. Nulla','Mauris non dui nec urna suscipit nonummy. Fusce fermentum fermentum arcu. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('accumsan interdum libero dui nec','et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in, hendrerit consectetuer, cursus et,',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('varius','Aenean euismod mauris eu elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit nonummy. Fusce fermentum',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('nisl sem, consequat nec,','Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('aliquet, metus urna','porttitor interdum. Sed auctor odio a purus. Duis elementum, dui quis accumsan convallis, ante lectus convallis est, vitae sodales nisi magna sed',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('non, vestibulum nec, euismod in,','montes, nascetur ridiculus mus. Proin vel nisl. Quisque fringilla euismod enim. Etiam gravida molestie arcu. Sed eu nibh vulputate mauris sagittis',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('ipsum leo','quis turpis vitae purus gravida sagittis. Duis gravida. Praesent eu nulla at',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Cum','mi fringilla mi lacinia mattis. Integer eu lacus. Quisque imperdiet, erat',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Ut tincidunt orci','elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus quis massa. Mauris vestibulum,',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Nunc lectus','Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna tellus faucibus leo, in lobortis tellus justo sit amet nulla. Donec non justo. Proin non massa non ante',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('In ornare sagittis','consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus.',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('ac mi eleifend egestas. Sed','ligula tortor, dictum eu, placerat eget, venenatis a, magna. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam laoreet, libero et',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('enim, sit amet','molestie arcu. Sed eu nibh vulputate mauris sagittis placerat. Cras dictum ultricies ligula. Nullam enim. Sed nulla ante, iaculis nec, eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('at, velit.','Vivamus sit amet risus. Donec egestas. Aliquam nec enim. Nunc ut erat.',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Phasellus elit pede,','taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien imperdiet ornare. In faucibus. Morbi',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('venenatis vel, faucibus id,','ultrices sit amet, risus. Donec nibh enim, gravida sit amet, dapibus id, blandit at, nisi. Cum sociis natoque penatibus et magnis',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Donec','risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('lacus. Etiam','tincidunt, nunc ac mattis ornare, lectus ante dictum mi, ac mattis velit justo nec ante. Maecenas mi felis, adipiscing fringilla,',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('ac risus. Morbi metus. Vivamus','parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit.',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('sit amet, faucibus ut, nulla.','scelerisque scelerisque dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('dis parturient montes,','pharetra sed, hendrerit a, arcu. Sed et libero. Proin mi. Aliquam gravida mauris ut mi. Duis risus odio, auctor vitae, aliquet nec, imperdiet nec, leo. Morbi',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('pharetra sed, hendrerit a, arcu.','dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus id, libero.',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('neque','sem egestas blandit. Nam nulla magna, malesuada vel, convallis in, cursus et, eros. Proin ultrices. Duis volutpat nunc sit amet metus. Aliquam erat volutpat. Nulla facilisis. Suspendisse commodo',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('In nec orci. Donec nibh.','eleifend nec, malesuada ut, sem. Nulla interdum. Curabitur dictum. Phasellus in felis. Nulla tempor augue ac ipsum. Phasellus vitae mauris sit amet lorem',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Vestibulum ante','ornare placerat, orci lacus vestibulum lorem, sit amet ultricies sem magna nec quam. Curabitur vel lectus. Cum',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('augue.','Nam interdum enim non nisi. Aenean eget metus. In nec orci. Donec nibh. Quisque nonummy ipsum non arcu. Vivamus sit',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('congue, elit','aliquet. Proin velit. Sed malesuada augue ut lacus. Nulla tincidunt, neque vitae semper egestas, urna justo faucibus lectus, a sollicitudin orci sem eget massa. Suspendisse eleifend. Cras sed leo.',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('consequat dolor vitae dolor. Donec','Cras eu tellus eu augue porttitor interdum. Sed auctor odio a purus. Duis elementum,',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('fringilla','magna a tortor. Nunc commodo auctor velit. Aliquam nisl. Nulla eu',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('est arcu ac orci.','ultrices. Vivamus rhoncus. Donec est. Nunc ullamcorper, velit in aliquet',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('facilisis vitae, orci. Phasellus','hendrerit a, arcu. Sed et libero. Proin mi. Aliquam gravida',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('non','ac mi eleifend egestas. Sed pharetra, felis eget varius ultrices, mauris ipsum porta elit, a feugiat tellus lorem eu metus. In lorem. Donec elementum, lorem ut aliquam iaculis,',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('magna. Praesent','Nullam suscipit, est ac facilisis facilisis, magna tellus faucibus leo, in lobortis tellus',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('mauris id','elit, pharetra ut, pharetra sed, hendrerit a, arcu. Sed et libero. Proin mi. Aliquam gravida mauris ut mi. Duis risus odio, auctor vitae, aliquet nec, imperdiet nec, leo. Morbi',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('erat','Donec elementum, lorem ut aliquam iaculis, lacus pede sagittis augue, eu tempor erat',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Cras eu tellus eu augue','dui quis accumsan convallis, ante lectus convallis est, vitae sodales nisi magna sed dui. Fusce aliquam, enim',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('feugiat metus','nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque. Sed dictum. Proin eget odio. Aliquam vulputate ullamcorper',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('vel arcu.','nibh vulputate mauris sagittis placerat. Cras dictum ultricies ligula. Nullam enim. Sed nulla ante, iaculis nec, eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Nam nulla magna, malesuada','Aenean sed pede nec ante blandit viverra. Donec tempus, lorem fringilla',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Aenean sed pede nec','Nunc pulvinar arcu et pede. Nunc sed orci lobortis augue scelerisque mollis. Phasellus libero mauris, aliquam eu, accumsan sed, facilisis vitae, orci. Phasellus dapibus quam quis diam.',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('lectus','sit amet risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('enim. Suspendisse aliquet, sem','lacus. Ut nec urna et arcu imperdiet ullamcorper. Duis at lacus. Quisque',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('sem molestie sodales.','lobortis ultrices. Vivamus rhoncus. Donec est. Nunc ullamcorper, velit in aliquet lobortis, nisi nibh lacinia orci,',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('ut eros','ultricies adipiscing, enim mi tempor lorem, eget mollis lectus pede et risus. Quisque libero lacus, varius et, euismod et, commodo at, libero.',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('eu','justo eu arcu. Morbi sit amet massa. Quisque porttitor eros nec tellus. Nunc lectus pede, ultrices a, auctor non, feugiat nec, diam. Duis mi enim,',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('sodales purus, in molestie','gravida non, sollicitudin a, malesuada id, erat. Etiam vestibulum massa rutrum magna. Cras convallis convallis dolor. Quisque tincidunt pede ac urna. Ut tincidunt vehicula risus. Nulla eget metus eu erat',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('Nam nulla magna,','risus. Nulla eget metus eu erat semper rutrum. Fusce dolor quam, elementum at, egestas a, scelerisque sed, sapien. Nunc pulvinar arcu et pede.',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('sit','mauris erat eget ipsum. Suspendisse sagittis. Nullam vitae diam. Proin dolor. Nulla semper',FALSE);
        INSERT INTO Product (name,description,approved) VALUES ('natoque penatibus et','libero lacus, varius et, euismod et, commodo at, libero. Morbi accumsan laoreet ipsum. Curabitur consequat, lectus sit amet luctus vulputate, nisi sem',FALSE);

        -- ############# Administrator ######################
        INSERT INTO Administrator (idAdmin) VALUES (101);
        INSERT INTO Administrator (idAdmin) VALUES (102);
        INSERT INTO Administrator (idAdmin) VALUES (103);

        -- ######################  ProductCategory ####################
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Digital Games &amp; Software');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Books');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Movies, TV, Music, Games');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Electronics &amp; Computers');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Home, Garden, Pets &amp; DIY');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Toys, Children &amp; Baby');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Clothes, Shoes &amp; Jewellery');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Sports &amp; Outdoors');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Grocery, Health &amp; Beauty');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Car &amp; Motorbike');
        --  \\\ Digital Games & Software
        INSERT INTO ProductCategory (idParent,name) VALUES ( 1, 'Digital Games');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 1, 'Free-to-Play Games');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 1, 'Digital Software');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 1, 'Your Games &amp; Software Library');
        --  \\\ Books
        INSERT INTO ProductCategory (idParent,name) VALUES ( 2, 'Books');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 2, 'Books For Study');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 2, 'Audiobooks');
        --  \\\ Movies, TV, Music, Games
        INSERT INTO ProductCategory (idParent,name) VALUES ( 3, 'DVD &amp; Blu-ray');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 3, 'Music');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 3, 'MP3 Downloads');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 3, 'Musical Instruments &amp; DJ');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 3, 'PC &amp; Video Games');
        --  \\\ Electronics & Computers
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Camera &amp; Photo');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'TV &amp; Home Cinema');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Audio &amp; HiFi');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Sat Nav &amp; Car Electronics');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Phones');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Electronics Accessories');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'All Electronics');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Laptops');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Tablets');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Computer Accessories');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Computer Components');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Software');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Printers &amp; Ink');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'All Computers &amp; Accessories');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 4, 'Stationery &amp; Office Supplies');
        -- \\\ Home, Garden, Pets & DIY
        INSERT INTO ProductCategory (idParent,name) VALUES ( 5, 'Garden &amp; Outdoors');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 5, 'Homeware &amp; Furniture');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 5, 'Kitchen &amp; Dining');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 5, 'Kitchen &amp; Home Appliances');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 5, 'Lighting');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 5, 'All Home &amp; Garden');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 5, 'Pet Supplies');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 5, 'DIY &amp; Tools');
        --  \\\ Toys, Children & Baby
        INSERT INTO ProductCategory (idParent,name) VALUES ( 6, 'Toys &amp; Games');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 6, 'Baby');
        --  \\\ Clothes, Shoes & Jewellery
        INSERT INTO ProductCategory (idParent,name) VALUES ( 7, 'Clothing');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 7, 'Shoes');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 7, 'Jewellery');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 7, 'Watches');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 7, 'Handbags & Shoulder Bags');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 7, 'Luggage');
        -- \\\ Sports & Outdoors
        INSERT INTO ProductCategory (idParent,name) VALUES ( 8, 'Fitness');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 8, 'Camping &amp; Hiking');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 8, 'Cycling');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 8, 'Athletic &amp; Outdoor Clothing');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 8, 'Winter Sports');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 8, 'Golf');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 8, 'Water Sports');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 8, 'All Sports &amp; Outdoors');
        --  \\\ Grocery, Health & Beauty
        INSERT INTO ProductCategory (idParent,name) VALUES ( 9, 'All Beauty');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 9, 'Health &amp; Personal Care');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 9, 'Mens Grooming');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 9, 'Grocery');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 9, 'Beer, Wine &amp; Spirits');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 9, 'Subscribe &amp; Save');
        --  \\\ Car & Motorbike
        INSERT INTO ProductCategory (idParent,name) VALUES ( 10, 'Car Accessories &amp; Parts');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 10, 'Tools &amp; Equipment');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 10, 'Sat Nav &amp; Car Electronics');
        INSERT INTO ProductCategory (idParent,name) VALUES ( 10, 'Motorbike Accessories &amp; Parts');


        -- ######################  ProductCategoryProduct ####################
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (1,18);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (2,47);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (3,29);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (4,47);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (5,36);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (6,58);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (7,31);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (8,56);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (9,22);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (10,50);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (11,59);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (12,60);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (13,30);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (14,11);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (15,33);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (16,32);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (17,13);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (18,30);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (19,61);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (20,23);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (21,26);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (22,23);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (23,29);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (24,61);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (25,40);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (26,21);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (27,11);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (28,60);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (29,23);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (30,18);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (31,60);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (32,48);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (33,31);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (34,52);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (35,52);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (36,36);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (37,30);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (38,70);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (39,67);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (40,12);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (41,64);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (42,20);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (43,34);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (44,20);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (45,30);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (46,53);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (47,18);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (48,67);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (49,61);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (50,59);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (51,26);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (52,30);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (53,31);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (54,21);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (55,37);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (56,12);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (57,59);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (58,63);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (59,28);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (60,46);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (61,58);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (62,70);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (63,60);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (64,32);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (65,16);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (66,16);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (67,27);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (68,32);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (69,48);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (70,40);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (71,59);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (72,58);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (73,32);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (74,34);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (75,22);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (76,43);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (77,43);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (78,26);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (79,41);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (80,37);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (81,69);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (82,62);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (83,24);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (84,67);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (85,44);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (86,51);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (87,17);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (88,38);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (89,32);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (90,17);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (91,67);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (92,64);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (93,53);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (94,26);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (95,28);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (96,19);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (97,57);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (98,44);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (99,47);
        INSERT INTO ProductCategoryProduct (idProduct,idCategory) VALUES (100,58);

        -- ################### ProductRating ##################
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (85,29,0,'auctor vitae, aliquet nec, imperdiet nec, leo. Morbi neque tellus, imperdiet non, vestibulum nec, euismod in, dolor. Fusce feugiat.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (87,22,2,'Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in, hendrerit consectetuer, cursus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (17,14,0,'lorem fringilla ornare placerat, orci');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (3,25,0,'lobortis quam a felis ullamcorper viverra. Maecenas iaculis aliquet diam. Sed diam lorem, auctor quis, tristique ac, eleifend vitae, erat.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (32,42,5,'commodo auctor velit. Aliquam nisl. Nulla eu neque pellentesque massa lobortis ultrices. Vivamus rhoncus. Donec est. Nunc ullamcorper,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (69,14,4,'molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl arcu iaculis enim, sit amet ornare lectus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (69,7,4,'Aliquam tincidunt, nunc ac mattis ornare, lectus ante dictum mi, ac mattis velit justo nec ante. Maecenas');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (2,7,1,'dolor. Fusce feugiat. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam auctor, velit');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (86,30,2,'blandit. Nam nulla magna, malesuada vel, convallis in, cursus et, eros. Proin ultrices. Duis volutpat');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (25,27,4,'at augue id ante dictum cursus. Nunc mauris elit, dictum eu, eleifend nec, malesuada ut, sem. Nulla');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (29,31,4,'nulla. Donec non justo. Proin');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (70,22,2,'ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Phasellus ornare. Fusce mollis.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (68,18,4,'ultricies sem magna nec quam. Curabitur');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (2,48,2,'aliquet molestie tellus. Aenean egestas hendrerit neque. In ornare sagittis felis. Donec');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (58,47,2,'nisl sem, consequat nec, mollis');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (58,45,0,'consequat purus. Maecenas libero est, congue a, aliquet vel,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (21,18,2,'Cum sociis natoque penatibus et magnis dis');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (51,46,4,'enim, condimentum eget, volutpat ornare, facilisis eget,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (47,6,1,'sed turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (16,50,3,'dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (28,30,1,'amet ultricies sem magna nec quam. Curabitur');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (60,40,4,'egestas blandit. Nam nulla magna, malesuada vel, convallis in, cursus et, eros. Proin ultrices. Duis volutpat');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (95,13,2,'placerat velit. Quisque varius. Nam porttitor scelerisque neque. Nullam');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (20,10,5,'a neque. Nullam ut nisi a odio semper cursus. Integer mollis. Integer tincidunt');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (71,21,5,'tincidunt tempus risus. Donec egestas. Duis ac');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (56,8,5,'Morbi neque tellus, imperdiet non, vestibulum nec, euismod in, dolor. Fusce feugiat. Lorem');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (64,23,1,'Ut tincidunt orci quis lectus. Nullam suscipit, est ac');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (10,46,0,'porttitor tellus non magna. Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (59,4,0,'mauris, rhoncus id, mollis nec, cursus a, enim. Suspendisse');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (52,25,4,'Integer sem elit, pharetra ut, pharetra sed,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (92,5,5,'sit amet, consectetuer adipiscing elit. Etiam');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (5,41,5,'Ut tincidunt vehicula risus. Nulla eget metus eu erat semper');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (17,19,3,'Donec porttitor tellus non magna. Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (38,18,2,'cursus, diam at pretium aliquet, metus urna convallis erat,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (8,27,4,'lorem ipsum sodales purus, in molestie tortor nibh sit amet');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (43,27,0,'enim. Etiam gravida molestie arcu. Sed eu nibh vulputate mauris sagittis placerat. Cras');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (30,40,5,'sem egestas blandit. Nam nulla magna, malesuada vel, convallis in, cursus et, eros. Proin');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (41,3,3,'mollis nec, cursus a, enim. Suspendisse aliquet, sem ut cursus luctus, ipsum leo elementum sem, vitae aliquam eros turpis non');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (30,28,5,'felis eget varius ultrices, mauris ipsum porta elit, a feugiat tellus lorem eu metus. In lorem.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (74,32,0,'est, congue a, aliquet vel, vulputate eu, odio. Phasellus at augue id ante dictum cursus. Nunc mauris elit, dictum eu,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (15,8,0,'adipiscing fringilla, porttitor vulputate, posuere vulputate,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (32,5,1,'non massa non ante bibendum ullamcorper. Duis cursus, diam');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (20,31,5,'nascetur ridiculus mus. Donec dignissim magna a tortor. Nunc commodo auctor');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (7,43,2,'eu metus. In lorem. Donec elementum, lorem ut aliquam iaculis, lacus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (50,35,3,'viverra. Maecenas iaculis aliquet diam. Sed diam lorem, auctor quis, tristique');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (42,23,5,'semper, dui lectus rutrum urna, nec luctus felis purus ac tellus. Suspendisse sed dolor. Fusce mi');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (85,42,0,'Aenean gravida nunc sed pede.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (46,20,5,'pede sagittis augue, eu tempor erat neque non quam. Pellentesque habitant');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (68,22,4,'vulputate dui, nec tempus mauris erat eget ipsum.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (90,50,1,'facilisis, magna tellus faucibus leo, in');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (13,1,5,'mauris, aliquam eu, accumsan sed, facilisis vitae,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (33,41,3,'ac, feugiat non, lobortis quis, pede. Suspendisse dui. Fusce diam nunc, ullamcorper eu, euismod');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (24,40,5,'porta elit, a feugiat tellus lorem eu metus. In lorem.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (96,42,5,'Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque. Sed dictum. Proin eget');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (52,26,1,'eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed turpis nec mauris blandit');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (35,22,0,'Curae; Phasellus ornare. Fusce mollis. Duis sit amet diam eu dolor egestas rhoncus. Proin nisl sem, consequat');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (2,23,2,'felis. Donec tempor, est ac mattis semper, dui');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (41,19,0,'tellus eu augue porttitor interdum. Sed');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (34,44,3,'justo sit amet nulla. Donec non justo. Proin non massa non ante');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (92,17,3,'eget varius ultrices, mauris ipsum porta');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (34,32,0,'adipiscing elit. Aliquam auctor, velit eget laoreet posuere, enim nisl elementum purus,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (16,15,2,'massa. Integer vitae nibh. Donec est mauris, rhoncus id, mollis nec, cursus a, enim. Suspendisse aliquet,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (97,43,4,'tincidunt nibh. Phasellus nulla. Integer vulputate, risus a ultricies');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (6,9,5,'Integer aliquam adipiscing lacus. Ut nec urna et arcu imperdiet ullamcorper. Duis at lacus. Quisque purus sapien,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (9,21,5,'blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (66,34,4,'ac nulla. In tincidunt congue turpis. In condimentum. Donec at arcu. Vestibulum ante ipsum primis in faucibus orci');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (64,4,4,'Donec tincidunt. Donec vitae erat');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (12,35,0,'sit amet luctus vulputate, nisi sem semper erat, in consectetuer');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (48,33,3,'tincidunt. Donec vitae erat vel pede blandit congue. In scelerisque scelerisque dui.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (2,30,5,'turpis. Aliquam adipiscing lobortis risus. In mi pede, nonummy ut, molestie in, tempus eu, ligula. Aenean euismod mauris');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (31,8,0,'mus. Aenean eget magna. Suspendisse tristique');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (17,10,3,'Aenean euismod mauris eu elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (82,9,2,'lectus quis massa. Mauris vestibulum, neque sed dictum eleifend, nunc risus varius orci, in consequat enim diam');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (29,9,1,'ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque. Sed dictum.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (29,44,3,'dictum. Proin eget odio. Aliquam vulputate ullamcorper magna. Sed eu eros. Nam consequat');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (74,11,0,'sem mollis dui, in sodales elit erat');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (26,5,2,'sagittis felis. Donec tempor, est');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (78,26,2,'sed, sapien. Nunc pulvinar arcu et pede. Nunc sed orci lobortis augue scelerisque mollis. Phasellus libero mauris, aliquam eu,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (92,21,0,'risus quis diam luctus lobortis.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (2,49,2,'rutrum non, hendrerit id, ante. Nunc mauris sapien,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (89,18,5,'lectus sit amet luctus vulputate, nisi sem semper erat, in');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (37,23,0,'at, nisi. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (7,45,5,'cursus vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit. Donec porttitor tellus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (59,29,1,'libero. Morbi accumsan laoreet ipsum. Curabitur consequat, lectus sit amet luctus vulputate, nisi sem semper');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (43,26,0,'risus a ultricies adipiscing, enim mi tempor lorem,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (80,7,2,'vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (16,6,4,'orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (27,9,3,'dignissim tempor arcu. Vestibulum ut eros');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (58,42,5,'scelerisque dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (65,22,5,'sed, hendrerit a, arcu. Sed et libero. Proin mi. Aliquam gravida mauris ut mi. Duis risus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (57,48,4,'pharetra ut, pharetra sed, hendrerit a, arcu. Sed et libero. Proin mi. Aliquam gravida mauris ut mi. Duis');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (10,31,4,'semper et, lacinia vitae, sodales at, velit. Pellentesque');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (91,16,0,'enim, sit amet ornare lectus justo eu arcu. Morbi sit amet massa.');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (7,47,3,'massa non ante bibendum ullamcorper. Duis cursus, diam at pretium aliquet, metus urna convallis erat,');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (28,37,4,'bibendum ullamcorper. Duis cursus, diam at pretium aliquet, metus urna convallis erat, eget tincidunt dui augue eu');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (5,15,3,'aliquet. Proin velit. Sed malesuada augue ut lacus. Nulla tincidunt, neque vitae semper egestas, urna justo faucibus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (99,35,4,'consectetuer adipiscing elit. Etiam laoreet, libero et tristique pellentesque, tellus');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (63,37,1,'ligula consectetuer rhoncus. Nullam velit');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (28,8,2,'Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim');
        INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (72,3,3,'Integer in magna. Phasellus dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc');

        -- ##########################  WantsToBuy ######################
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (25,1,304.004);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (46,2, 481.894);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (12,3,10.053);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (26,4, 197.543);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (55,5, 354.272);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (4,6, 101.636);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (57,7, 445.159);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (53,8, 162.566);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (33,9, 4.345);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (46,10, 100.508);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (22,11, 142.362);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (3,12, 383.578);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (24,13, 14.061);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (13,14, 361.249);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (32,15, 345.775);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (74,16, 399.928);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (22,17, 409.660);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (44,18, 215.998);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (11,19, 317.707);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (84,20, 74.747);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (13,21, 120.978);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (42,22, 178.940);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (23,23, 104.298);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (26,24, 30.147);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (42,25, 59.401);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (35,26, 44.727);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (96,27, 488.677);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (60,28, 251.007);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (22,29, 250.454);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (66,30, 410.869);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (78,31, 462.456);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (50,32, 467.171);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (15,33, 431.643);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (57,34, 126.849);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (98,35, 84.292);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (45,36, 196.050);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (90,37, 467.529);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (84,38, 115.061);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (29,39, 81.135);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (53,40, 358.244);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (34,41, 80.050);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (34,42, 431.500);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (27,43, 451.666);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (64,44, 313.633);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (35,45, 312.121);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (56,46, 325.783);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (81,47, 36.103);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (61,48, 3.798);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (77,49, 383.148);
        INSERT INTO WantsToBuy (idProduct,idBuyer,proposedPrice) VALUES (71,50, 19.517);


        -- ###################  PrivateMessage #######################
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (63,102,'Read','Fusce fermentum fermentum arcu. Vestibulum ante ipsum','purus ac tellus. Suspendisse sed dolor. Fusce mi lorem, vehicula et, rutrum eu, ultrices sit amet, risus. Donec nibh enim, gravida sit amet, dapibus id, blandit at, nisi. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel nisl. Quisque fringilla euismod enim. Etiam gravida molestie arcu. Sed eu nibh vulputate mauris sagittis placerat. Cras dictum ultricies ligula. Nullam enim. Sed nulla ante, iaculis nec, eleifend non, dapibus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (59,102,'Read','et magnis dis parturient','fringilla. Donec feugiat metus sit amet ante. Vivamus non lorem vitae odio sagittis semper. Nam');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (48,102,'Read','netus et malesuada fames ac turpis egestas. Aliquam','dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit. Donec porttitor tellus non magna. Nam ligula elit, pretium et,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (33,103,'Read','Nunc quis','et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam a felis ullamcorper viverra. Maecenas iaculis aliquet diam. Sed diam lorem, auctor quis, tristique ac, eleifend vitae, erat. Vivamus nisi. Mauris nulla. Integer urna. Vivamus molestie dapibus ligula. Aliquam erat volutpat. Nulla dignissim. Maecenas ornare');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (77,102,'Read','lacinia vitae, sodales','quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam fringilla cursus purus. Nullam scelerisque neque sed sem egestas blandit. Nam nulla magna, malesuada vel, convallis in,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (34,101,'Read','Quisque purus sapien,','sit amet ornare lectus justo eu arcu. Morbi sit amet massa. Quisque porttitor eros nec tellus. Nunc lectus pede, ultrices a, auctor non, feugiat nec, diam. Duis mi enim, condimentum eget, volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing ligula. Aenean gravida nunc sed pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (86,102,'Read','lorem,','semper. Nam tempor diam dictum sapien. Aenean massa. Integer vitae nibh. Donec est mauris, rhoncus id, mollis nec, cursus a, enim. Suspendisse aliquet, sem ut cursus luctus, ipsum leo elementum sem, vitae aliquam eros turpis non enim. Mauris quis turpis vitae purus gravida sagittis. Duis gravida. Praesent eu nulla at sem molestie sodales. Mauris blandit enim consequat purus. Maecenas libero est, congue a, aliquet vel, vulputate eu, odio. Phasellus at augue id ante dictum cursus. Nunc mauris elit, dictum eu, eleifend nec, malesuada ut, sem. Nulla interdum. Curabitur dictum. Phasellus in felis. Nulla tempor augue ac ipsum. Phasellus vitae mauris');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (55,103,'Read','egestas lacinia. Sed congue, elit sed consequat auctor, nunc','Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien imperdiet ornare. In faucibus. Morbi vehicula. Pellentesque tincidunt tempus risus. Donec egestas.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (98,102,'Read','pede sagittis','eu, ultrices sit amet, risus. Donec nibh enim, gravida sit amet, dapibus id, blandit at, nisi. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel nisl. Quisque fringilla euismod enim. Etiam gravida molestie arcu. Sed eu nibh vulputate mauris sagittis placerat. Cras dictum ultricies ligula. Nullam enim. Sed nulla ante, iaculis nec, eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (60,102,'Read','arcu. Nunc mauris. Morbi non sapien molestie orci tincidunt adipiscing.','Cras vehicula aliquet libero. Integer in magna. Phasellus dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus quis massa. Mauris vestibulum, neque sed dictum eleifend, nunc risus varius orci, in consequat enim diam vel arcu. Curabitur ut odio vel est tempor bibendum. Donec felis orci, adipiscing non, luctus sit amet, faucibus ut, nulla. Cras eu tellus eu augue porttitor interdum. Sed auctor odio a purus. Duis elementum, dui quis accumsan convallis, ante lectus convallis est, vitae sodales nisi magna sed');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (80,101,'Read','viverra. Donec tempus, lorem fringilla ornare placerat,','dictum cursus. Nunc mauris elit, dictum eu, eleifend nec, malesuada ut, sem. Nulla interdum. Curabitur dictum. Phasellus in felis. Nulla tempor augue ac ipsum. Phasellus vitae mauris sit amet lorem semper auctor. Mauris vel turpis. Aliquam adipiscing lobortis risus. In mi pede, nonummy ut, molestie in, tempus eu, ligula. Aenean euismod mauris eu elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit nonummy. Fusce fermentum fermentum arcu. Vestibulum ante ipsum primis in faucibus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (23,102,'Read','mauris eu elit. Nulla facilisi. Sed neque. Sed eget','Maecenas ornare egestas ligula. Nullam feugiat placerat velit. Quisque varius. Nam porttitor scelerisque neque. Nullam nisl. Maecenas malesuada fringilla est. Mauris eu turpis.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (72,102,'Read','a, magna. Lorem ipsum dolor sit amet, consectetuer','ante dictum cursus. Nunc mauris elit, dictum eu, eleifend nec, malesuada ut, sem. Nulla interdum. Curabitur dictum. Phasellus in felis. Nulla tempor augue ac ipsum. Phasellus vitae mauris sit amet lorem semper auctor. Mauris vel turpis. Aliquam adipiscing lobortis risus. In mi pede, nonummy ut, molestie in, tempus eu, ligula. Aenean euismod mauris eu elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit nonummy. Fusce fermentum fermentum arcu. Vestibulum ante ipsum');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (15,101,'Read','cursus, diam at pretium aliquet, metus urna','ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque. Sed dictum. Proin eget odio. Aliquam vulputate ullamcorper magna. Sed eu eros. Nam consequat dolor vitae dolor. Donec fringilla. Donec feugiat metus sit amet ante. Vivamus non lorem vitae odio sagittis semper. Nam tempor diam dictum sapien. Aenean massa. Integer vitae nibh. Donec est mauris, rhoncus id, mollis nec, cursus a, enim. Suspendisse aliquet, sem ut cursus luctus, ipsum leo elementum sem, vitae aliquam');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (73,101,'Read','ipsum primis in','sem, vitae aliquam eros turpis non enim. Mauris quis turpis vitae purus gravida sagittis. Duis gravida. Praesent eu nulla at sem molestie sodales.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (52,103,'Read','metus facilisis lorem tristique aliquet. Phasellus fermentum convallis','dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus quis massa. Mauris vestibulum, neque sed dictum eleifend, nunc risus varius orci, in consequat enim diam vel arcu. Curabitur ut odio vel est tempor bibendum. Donec felis orci, adipiscing non, luctus sit amet, faucibus ut, nulla. Cras eu tellus eu augue porttitor interdum. Sed auctor odio a purus. Duis elementum, dui quis accumsan convallis, ante lectus convallis est, vitae sodales nisi magna sed dui. Fusce aliquam, enim nec tempus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (99,102,'Read','a mi fringilla mi lacinia mattis. Integer eu lacus.','Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (22,101,'Read','luctus aliquet odio. Etiam ligula','aliquet, sem ut cursus luctus, ipsum leo elementum sem, vitae aliquam eros turpis non enim. Mauris quis turpis vitae');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (39,101,'Read','montes, nascetur ridiculus mus. Donec dignissim magna a','In at pede. Cras vulputate velit eu sem. Pellentesque ut ipsum ac mi eleifend');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (5,102,'Read','adipiscing elit. Aliquam auctor, velit eget laoreet posuere, enim','pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (66,103,'Read','Sed id risus quis diam luctus lobortis. Class','massa non ante bibendum ullamcorper. Duis cursus, diam at pretium aliquet, metus urna convallis erat, eget tincidunt dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus id, libero. Donec consectetuer mauris id sapien. Cras dolor dolor, tempus non, lacinia at, iaculis quis, pede. Praesent eu dui. Cum sociis natoque penatibus et magnis dis');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (97,102,'Read','quis diam. Pellentesque habitant morbi tristique senectus et','ante lectus convallis est, vitae sodales nisi magna sed dui. Fusce aliquam, enim nec tempus scelerisque, lorem ipsum sodales purus, in molestie tortor');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (87,101,'Read','Nunc mauris elit, dictum eu, eleifend nec, malesuada ut,','lectus, a sollicitudin orci sem eget massa. Suspendisse eleifend. Cras sed leo. Cras vehicula aliquet libero. Integer in magna. Phasellus dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus quis massa.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (31,103,'Read','risus. Donec','pede blandit congue. In scelerisque scelerisque dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc nulla vulputate dui, nec tempus mauris erat eget ipsum. Suspendisse sagittis. Nullam vitae diam. Proin dolor. Nulla semper tellus id nunc interdum feugiat. Sed nec metus facilisis lorem tristique aliquet. Phasellus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (99,101,'Read','rhoncus id, mollis nec, cursus a,','natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean eget magna. Suspendisse tristique neque venenatis lacus. Etiam bibendum fermentum metus. Aenean sed pede nec ante blandit viverra. Donec tempus, lorem fringilla ornare placerat, orci lacus vestibulum lorem, sit amet ultricies sem magna nec quam. Curabitur vel lectus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec dignissim magna a tortor. Nunc commodo auctor velit. Aliquam nisl. Nulla eu neque pellentesque massa lobortis ultrices. Vivamus rhoncus. Donec est. Nunc ullamcorper, velit in aliquet lobortis, nisi nibh lacinia orci, consectetuer euismod est arcu ac orci. Ut');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (92,101,'Read','mi enim, condimentum eget, volutpat ornare, facilisis eget,','nisl sem, consequat nec, mollis vitae, posuere at, velit. Cras lorem lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien imperdiet ornare. In faucibus. Morbi vehicula. Pellentesque tincidunt tempus risus. Donec egestas. Duis ac arcu. Nunc mauris. Morbi non sapien molestie orci tincidunt adipiscing. Mauris molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (7,101,'Read','aliquet libero. Integer in','nulla. In tincidunt congue turpis. In condimentum. Donec at arcu. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec tincidunt. Donec vitae erat vel pede blandit congue. In scelerisque scelerisque dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc nulla vulputate dui, nec tempus mauris erat eget ipsum. Suspendisse sagittis. Nullam vitae diam. Proin dolor. Nulla semper tellus id nunc interdum feugiat. Sed nec metus facilisis lorem tristique aliquet. Phasellus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (100,103,'Read','Donec consectetuer mauris id sapien. Cras dolor dolor, tempus','ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec tincidunt. Donec vitae erat vel pede blandit congue. In scelerisque scelerisque dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc nulla vulputate dui, nec tempus mauris erat eget ipsum. Suspendisse sagittis. Nullam vitae diam. Proin dolor. Nulla semper tellus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (18,102,'Read','sem semper erat, in consectetuer ipsum nunc','mollis. Phasellus libero mauris, aliquam eu, accumsan sed, facilisis vitae, orci. Phasellus dapibus quam quis diam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce aliquet magna a neque. Nullam ut nisi a odio semper cursus. Integer mollis. Integer tincidunt aliquam arcu. Aliquam ultrices iaculis odio. Nam interdum enim non nisi.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (7,102,'Read','sit','purus mauris a nunc. In at pede. Cras vulputate velit eu sem. Pellentesque ut ipsum ac mi eleifend egestas. Sed pharetra, felis eget varius ultrices, mauris ipsum porta elit, a feugiat tellus lorem eu metus. In lorem. Donec elementum,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (55,102,'Read','lacus, varius et, euismod et, commodo at, libero. Morbi','sit amet nulla. Donec non justo. Proin non massa non ante bibendum ullamcorper. Duis cursus, diam at pretium aliquet, metus urna convallis erat, eget tincidunt dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus id, libero. Donec consectetuer mauris id sapien. Cras dolor dolor, tempus non, lacinia at, iaculis quis, pede. Praesent eu dui. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean eget magna. Suspendisse tristique neque venenatis lacus. Etiam bibendum fermentum metus. Aenean sed pede nec ante');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (1,101,'Read','pede nec ante blandit viverra. Donec tempus, lorem fringilla','molestie dapibus ligula. Aliquam erat volutpat. Nulla dignissim. Maecenas ornare egestas ligula. Nullam feugiat placerat velit. Quisque varius. Nam porttitor');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (42,102,'Read','sit amet, consectetuer adipiscing elit.','scelerisque sed, sapien. Nunc pulvinar arcu et pede. Nunc sed orci lobortis augue scelerisque mollis. Phasellus libero mauris, aliquam eu, accumsan sed, facilisis vitae, orci. Phasellus dapibus quam quis diam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce aliquet magna');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (83,103,'Read','ac mattis','Curae; Donec tincidunt. Donec vitae erat vel pede blandit congue. In scelerisque scelerisque dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc nulla vulputate dui, nec tempus mauris erat eget ipsum. Suspendisse sagittis. Nullam vitae diam. Proin dolor. Nulla semper tellus id nunc interdum feugiat. Sed nec metus facilisis lorem tristique aliquet. Phasellus fermentum convallis');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (22,101,'Read','dictum. Proin eget','massa. Quisque porttitor eros nec tellus. Nunc lectus pede, ultrices a, auctor non, feugiat nec, diam. Duis mi enim, condimentum eget, volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing ligula. Aenean gravida nunc sed pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam a felis ullamcorper viverra. Maecenas iaculis aliquet');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (56,103,'Read','metus.','nunc sed libero. Proin sed turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit. Donec porttitor tellus non magna. Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in, hendrerit consectetuer, cursus et, magna. Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna tellus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (49,101,'Read','at,','nunc sed pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam a felis ullamcorper viverra. Maecenas iaculis aliquet diam. Sed diam lorem, auctor quis, tristique ac, eleifend vitae, erat. Vivamus nisi. Mauris');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (56,103,'Read','porttitor eros nec tellus. Nunc lectus pede, ultrices a,','tempor, est ac mattis semper, dui lectus rutrum urna, nec luctus felis purus ac tellus. Suspendisse sed dolor. Fusce mi lorem, vehicula et, rutrum eu, ultrices sit amet, risus. Donec nibh enim, gravida sit amet, dapibus id, blandit at, nisi. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel nisl. Quisque fringilla euismod enim. Etiam gravida molestie');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (58,103,'Read','et arcu imperdiet ullamcorper. Duis at lacus. Quisque purus sapien,','eu elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit nonummy. Fusce fermentum fermentum arcu. Vestibulum ante ipsum primis in');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (22,103,'Read','enim consequat purus. Maecenas libero est, congue a,','ac risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam a felis ullamcorper viverra. Maecenas iaculis');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (65,101,'Read','sem mollis dui, in sodales elit','Nulla eget metus eu erat semper rutrum. Fusce dolor quam, elementum at, egestas a, scelerisque sed, sapien. Nunc pulvinar arcu et pede. Nunc sed orci lobortis augue');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (44,102,'Read','id enim. Curabitur massa. Vestibulum accumsan neque et','arcu iaculis enim, sit amet ornare lectus justo eu arcu. Morbi sit amet massa. Quisque porttitor eros nec tellus. Nunc lectus pede, ultrices a, auctor non, feugiat nec, diam. Duis mi enim, condimentum eget, volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing ligula. Aenean gravida nunc sed pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (49,103,'Read','augue id ante dictum cursus.','parturient montes, nascetur ridiculus mus. Proin vel nisl. Quisque fringilla euismod enim. Etiam gravida molestie arcu. Sed eu nibh vulputate mauris sagittis placerat. Cras dictum ultricies ligula. Nullam enim. Sed nulla ante, iaculis nec, eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (50,103,'Read','eu odio tristique pharetra.','sem mollis dui, in sodales elit erat vitae risus. Duis a mi fringilla mi lacinia mattis. Integer eu lacus. Quisque imperdiet, erat nonummy ultricies ornare, elit elit fermentum risus, at fringilla purus mauris a nunc. In at pede. Cras vulputate velit eu sem. Pellentesque ut ipsum ac mi eleifend egestas. Sed pharetra, felis eget varius ultrices, mauris ipsum porta elit, a feugiat tellus lorem eu metus. In lorem. Donec elementum, lorem ut aliquam iaculis, lacus pede');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (93,102,'Read','et netus et malesuada fames ac turpis egestas.','vestibulum, neque sed dictum eleifend, nunc risus varius orci, in consequat enim diam vel arcu. Curabitur ut odio vel est tempor bibendum. Donec felis orci, adipiscing non, luctus sit amet, faucibus ut, nulla. Cras eu tellus eu augue porttitor interdum. Sed auctor odio a purus. Duis elementum, dui quis accumsan convallis, ante lectus convallis est, vitae sodales nisi magna sed dui. Fusce');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (12,101,'Read','Sed neque. Sed eget lacus. Mauris non dui','vehicula aliquet libero. Integer in magna. Phasellus dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus quis massa. Mauris vestibulum, neque sed dictum eleifend, nunc risus varius orci, in consequat enim diam vel arcu. Curabitur ut odio vel est tempor bibendum. Donec felis orci, adipiscing non, luctus sit amet, faucibus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (100,103,'Read','Integer sem elit, pharetra ut, pharetra sed, hendrerit a,','a sollicitudin orci sem eget massa. Suspendisse eleifend. Cras sed leo. Cras vehicula aliquet libero. Integer in magna. Phasellus dolor elit, pellentesque a, facilisis non,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (22,101,'Read','aliquet. Phasellus fermentum convallis ligula. Donec luctus aliquet odio.','elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit nonummy. Fusce fermentum fermentum arcu. Vestibulum ante');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (42,101,'Read','Nulla eu neque pellentesque massa lobortis','nulla. In tincidunt congue turpis. In condimentum. Donec at arcu. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec tincidunt. Donec vitae erat vel pede blandit congue. In scelerisque scelerisque dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc nulla vulputate dui, nec');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (91,102,'Read','ultricies ornare, elit','a tortor. Nunc commodo auctor velit. Aliquam nisl. Nulla eu neque pellentesque massa lobortis ultrices. Vivamus rhoncus. Donec est. Nunc ullamcorper, velit in aliquet lobortis, nisi nibh lacinia orci, consectetuer euismod');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (33,101,'Unread','orci. Phasellus','egestas a, dui. Cras pellentesque. Sed dictum. Proin eget odio. Aliquam vulputate ullamcorper magna. Sed eu eros. Nam consequat dolor vitae dolor. Donec fringilla. Donec feugiat metus sit amet ante. Vivamus non lorem vitae odio sagittis semper. Nam tempor diam dictum sapien. Aenean massa. Integer vitae nibh. Donec est mauris, rhoncus id, mollis nec,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (66,103,'Unread','vitae dolor.','amet diam eu dolor egestas rhoncus. Proin nisl sem, consequat nec, mollis vitae, posuere at, velit. Cras lorem lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien imperdiet ornare. In faucibus. Morbi vehicula. Pellentesque tincidunt tempus risus. Donec egestas. Duis ac arcu. Nunc mauris. Morbi non sapien molestie orci tincidunt adipiscing. Mauris molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl arcu iaculis enim, sit amet ornare lectus justo eu arcu. Morbi sit');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (36,103,'Unread','magnis dis parturient montes, nascetur ridiculus mus. Donec dignissim magna','netus et malesuada fames ac turpis egestas. Aliquam fringilla cursus purus. Nullam scelerisque neque sed sem egestas blandit. Nam nulla magna,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (39,101,'Unread','Suspendisse eleifend. Cras sed','metus. Aliquam erat volutpat. Nulla facilisis. Suspendisse commodo tincidunt nibh. Phasellus nulla. Integer vulputate, risus a ultricies adipiscing, enim mi tempor lorem, eget mollis lectus pede et risus. Quisque libero lacus, varius et, euismod et, commodo at, libero. Morbi accumsan laoreet ipsum. Curabitur consequat, lectus sit amet luctus vulputate, nisi sem semper erat, in consectetuer ipsum nunc id enim. Curabitur massa. Vestibulum accumsan neque et nunc. Quisque ornare tortor at risus. Nunc ac sem ut dolor dapibus gravida. Aliquam tincidunt, nunc ac mattis');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (2,102,'Unread','quis, pede. Suspendisse dui. Fusce','dolor egestas rhoncus. Proin nisl sem, consequat nec, mollis vitae, posuere at, velit. Cras lorem lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien imperdiet ornare. In faucibus. Morbi vehicula. Pellentesque tincidunt tempus risus. Donec egestas.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (42,101,'Unread','dignissim tempor arcu.','In ornare sagittis felis. Donec tempor, est ac mattis semper, dui lectus rutrum urna, nec luctus felis purus ac tellus. Suspendisse sed dolor. Fusce mi lorem, vehicula et, rutrum eu, ultrices sit amet, risus.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (78,103,'Unread','lacus. Quisque imperdiet, erat nonummy ultricies ornare, elit','eget, volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing ligula. Aenean gravida nunc sed pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin vel arcu eu odio tristique pharetra.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (18,103,'Unread','sodales nisi','nunc ac mattis ornare, lectus ante dictum mi, ac mattis velit justo nec ante. Maecenas mi felis, adipiscing fringilla, porttitor vulputate, posuere vulputate, lacus. Cras interdum. Nunc sollicitudin commodo ipsum. Suspendisse non leo. Vivamus nibh dolor, nonummy ac, feugiat non, lobortis quis, pede. Suspendisse dui. Fusce diam nunc, ullamcorper eu, euismod ac, fermentum vel,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (89,101,'Unread','Nunc pulvinar arcu et pede. Nunc sed orci lobortis augue','magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna tellus faucibus leo, in lobortis tellus justo sit amet nulla. Donec non justo. Proin non massa non ante bibendum ullamcorper. Duis cursus, diam at pretium aliquet, metus urna convallis erat, eget tincidunt dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (1,102,'Unread','fames ac turpis egestas. Fusce aliquet','odio semper cursus. Integer mollis. Integer tincidunt aliquam arcu. Aliquam ultrices iaculis odio. Nam interdum enim non nisi. Aenean eget metus. In nec orci. Donec nibh. Quisque nonummy ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (28,102,'Unread','eu, accumsan sed, facilisis vitae, orci.','eros nec tellus. Nunc lectus pede, ultrices a, auctor non, feugiat nec, diam. Duis mi enim, condimentum eget, volutpat ornare, facilisis eget, ipsum.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (37,101,'Unread','Curabitur massa. Vestibulum accumsan neque','risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien imperdiet ornare. In faucibus. Morbi vehicula. Pellentesque tincidunt tempus risus. Donec egestas. Duis ac arcu. Nunc mauris. Morbi non sapien molestie orci tincidunt adipiscing. Mauris molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl arcu iaculis enim, sit amet ornare lectus justo eu arcu.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (71,101,'Unread','ullamcorper, nisl','eu odio tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam a felis ullamcorper viverra. Maecenas iaculis aliquet diam. Sed diam lorem, auctor quis, tristique');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (27,102,'Unread','ultrices. Duis volutpat nunc sit amet metus. Aliquam erat volutpat.','mollis dui, in sodales elit erat vitae risus. Duis a mi fringilla mi lacinia mattis. Integer eu lacus. Quisque imperdiet, erat nonummy ultricies ornare, elit elit fermentum risus, at fringilla purus mauris a nunc. In at pede. Cras vulputate velit eu sem. Pellentesque ut ipsum ac mi eleifend egestas. Sed pharetra, felis eget varius ultrices, mauris ipsum porta elit, a feugiat tellus lorem eu metus. In lorem. Donec elementum, lorem ut aliquam iaculis, lacus pede sagittis augue, eu');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (87,102,'Unread','ultrices,','et magnis dis parturient montes, nascetur ridiculus mus. Donec dignissim magna a tortor. Nunc commodo auctor velit. Aliquam nisl. Nulla eu neque pellentesque massa lobortis ultrices. Vivamus rhoncus. Donec est. Nunc ullamcorper, velit in aliquet lobortis, nisi nibh lacinia orci, consectetuer euismod est arcu ac orci. Ut semper pretium neque. Morbi quis urna. Nunc quis arcu vel quam dignissim pharetra. Nam ac nulla. In tincidunt congue turpis. In condimentum. Donec at arcu. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec tincidunt. Donec vitae');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (12,103,'Unread','a,','odio sagittis semper. Nam tempor diam dictum sapien. Aenean massa. Integer vitae nibh. Donec est mauris, rhoncus id, mollis nec, cursus a, enim. Suspendisse aliquet, sem ut cursus luctus, ipsum leo elementum sem, vitae aliquam eros turpis non enim. Mauris quis turpis vitae purus gravida sagittis. Duis gravida. Praesent eu nulla at sem molestie sodales. Mauris blandit enim consequat purus. Maecenas libero est, congue a,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (23,101,'Unread','eu eros. Nam consequat','non arcu. Vivamus sit amet risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque. Sed dictum. Proin eget odio. Aliquam vulputate ullamcorper magna. Sed eu eros. Nam consequat dolor vitae dolor. Donec fringilla. Donec feugiat metus sit amet ante. Vivamus non lorem vitae odio sagittis semper. Nam tempor diam dictum sapien. Aenean massa. Integer vitae nibh. Donec est mauris, rhoncus id, mollis nec, cursus a, enim. Suspendisse aliquet, sem ut');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (96,102,'Unread','enim mi tempor','velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (26,102,'Unread','dictum mi, ac','dapibus quam quis diam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce aliquet magna a neque. Nullam ut nisi a odio semper cursus. Integer mollis. Integer tincidunt aliquam arcu. Aliquam ultrices iaculis odio. Nam interdum enim non nisi. Aenean eget metus. In nec orci. Donec nibh. Quisque nonummy ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc est, mollis non, cursus non, egestas a, dui. Cras pellentesque. Sed dictum. Proin eget odio. Aliquam');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (75,102,'Unread','ornare, elit elit fermentum risus, at fringilla purus','ipsum ac mi eleifend egestas. Sed pharetra, felis eget varius ultrices, mauris ipsum porta elit, a feugiat tellus lorem eu metus. In lorem. Donec elementum, lorem ut aliquam iaculis, lacus pede');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (64,103,'Unread','Ut sagittis lobortis mauris. Suspendisse','dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam a felis ullamcorper viverra. Maecenas');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (11,102,'Unread','velit justo nec','in, hendrerit consectetuer, cursus et, magna. Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna tellus faucibus leo, in lobortis tellus justo sit amet nulla. Donec non justo. Proin non massa non ante');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (97,102,'Unread','et, eros. Proin ultrices.','iaculis nec, eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit. Donec porttitor tellus non magna. Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in, hendrerit consectetuer, cursus et, magna. Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (21,102,'Unread','primis in faucibus','turpis egestas. Aliquam fringilla cursus purus. Nullam scelerisque neque sed sem egestas blandit. Nam nulla magna, malesuada vel, convallis in,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (99,102,'Unread','aliquet','Duis elementum, dui quis accumsan convallis, ante lectus convallis est, vitae sodales nisi magna sed dui. Fusce aliquam, enim nec tempus scelerisque, lorem ipsum sodales purus, in molestie tortor nibh sit amet orci. Ut sagittis lobortis mauris. Suspendisse aliquet molestie tellus. Aenean egestas hendrerit neque. In ornare sagittis felis. Donec tempor, est ac mattis semper, dui lectus rutrum urna, nec luctus felis purus ac tellus. Suspendisse sed dolor. Fusce mi lorem, vehicula et, rutrum eu, ultrices sit amet, risus. Donec nibh enim, gravida sit amet, dapibus id, blandit at, nisi. Cum sociis natoque penatibus et magnis dis parturient montes,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (18,103,'Unread','lobortis tellus justo sit amet','purus mauris a nunc. In at pede. Cras vulputate velit eu sem. Pellentesque ut ipsum ac mi eleifend egestas. Sed pharetra, felis eget varius ultrices, mauris ipsum porta elit, a');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (46,101,'Unread','erat, eget tincidunt dui augue','tristique pharetra. Quisque ac libero nec ligula consectetuer rhoncus. Nullam velit dui, semper et, lacinia vitae, sodales at, velit. Pellentesque ultricies dignissim lacus. Aliquam rutrum lorem ac risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam a felis ullamcorper viverra. Maecenas iaculis aliquet diam. Sed diam lorem, auctor quis, tristique ac, eleifend vitae, erat. Vivamus nisi. Mauris nulla. Integer urna. Vivamus molestie dapibus ligula. Aliquam erat volutpat. Nulla dignissim. Maecenas ornare egestas ligula. Nullam feugiat placerat velit. Quisque varius.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (51,101,'Unread','Nunc mauris. Morbi non','nec, eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus vestibulum.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (20,101,'Unread','risus. Nulla eget metus eu erat semper rutrum. Fusce','in faucibus orci luctus et ultrices posuere cubilia Curae; Phasellus ornare. Fusce mollis. Duis sit amet diam eu dolor egestas rhoncus. Proin nisl sem, consequat nec, mollis vitae, posuere at, velit. Cras lorem lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien imperdiet ornare. In faucibus. Morbi vehicula. Pellentesque tincidunt tempus risus. Donec egestas. Duis ac arcu. Nunc mauris. Morbi non sapien molestie orci tincidunt adipiscing. Mauris molestie pharetra nibh. Aliquam ornare,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (10,102,'Unread','hendrerit id, ante. Nunc mauris sapien, cursus','et, magna. Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (96,102,'Unread','pede sagittis augue, eu tempor erat neque','dui. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean eget magna. Suspendisse tristique neque venenatis lacus. Etiam bibendum fermentum metus. Aenean sed pede nec ante blandit viverra. Donec tempus, lorem fringilla ornare placerat, orci lacus vestibulum lorem, sit amet ultricies sem magna nec quam. Curabitur vel');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (13,101,'Unread','tristique neque venenatis lacus. Etiam bibendum fermentum metus. Aenean','viverra. Donec tempus, lorem fringilla ornare placerat, orci lacus vestibulum lorem, sit amet ultricies sem magna nec quam. Curabitur vel lectus.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (56,103,'Unread','tincidunt nibh.','tincidunt vehicula risus. Nulla eget metus eu erat semper rutrum. Fusce dolor quam, elementum at, egestas a, scelerisque sed, sapien. Nunc pulvinar arcu et pede. Nunc sed orci lobortis augue scelerisque mollis. Phasellus libero mauris, aliquam eu, accumsan sed, facilisis vitae, orci. Phasellus dapibus quam');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (33,103,'Unread','eu sem. Pellentesque ut ipsum ac','turpis. Nulla aliquet. Proin velit. Sed malesuada augue ut lacus. Nulla tincidunt, neque vitae semper egestas, urna justo faucibus lectus, a sollicitudin orci sem eget massa. Suspendisse eleifend. Cras sed leo. Cras vehicula aliquet libero. Integer in magna. Phasellus dolor elit, pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus quis massa. Mauris vestibulum, neque sed dictum eleifend, nunc risus varius orci, in consequat enim diam vel arcu. Curabitur ut odio vel est tempor bibendum. Donec felis orci, adipiscing non, luctus sit amet, faucibus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (35,103,'Unread','id sapien.','enim commodo hendrerit. Donec porttitor tellus non magna. Nam ligula elit, pretium et, rutrum non, hendrerit id, ante. Nunc mauris sapien, cursus in, hendrerit');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (29,101,'Unread','faucibus id,','felis ullamcorper viverra. Maecenas iaculis aliquet diam. Sed diam lorem, auctor quis, tristique ac, eleifend vitae, erat. Vivamus nisi. Mauris nulla. Integer urna. Vivamus molestie dapibus ligula. Aliquam erat volutpat. Nulla dignissim. Maecenas ornare egestas ligula. Nullam feugiat placerat velit. Quisque varius. Nam porttitor scelerisque neque. Nullam nisl. Maecenas malesuada fringilla est. Mauris eu turpis. Nulla aliquet. Proin velit. Sed malesuada augue ut lacus. Nulla tincidunt, neque vitae semper');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (2,101,'Unread','Donec egestas. Aliquam','ipsum. Suspendisse sagittis. Nullam vitae diam. Proin dolor. Nulla semper tellus id nunc interdum feugiat. Sed nec metus facilisis lorem tristique aliquet. Phasellus fermentum convallis ligula. Donec luctus aliquet odio. Etiam ligula tortor, dictum eu, placerat eget, venenatis a, magna. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam laoreet, libero et tristique pellentesque, tellus sem mollis dui, in sodales elit erat vitae risus. Duis a mi fringilla mi lacinia mattis. Integer eu lacus. Quisque imperdiet, erat nonummy ultricies ornare, elit elit fermentum risus, at fringilla purus mauris a nunc. In at pede.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (7,101,'Unread','augue id ante dictum cursus.','lorem, luctus ut, pellentesque eget, dictum placerat, augue. Sed molestie. Sed id risus quis diam luctus lobortis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Mauris ut quam vel sapien imperdiet ornare. In faucibus. Morbi vehicula. Pellentesque tincidunt tempus risus. Donec egestas. Duis ac arcu. Nunc mauris. Morbi non sapien molestie orci tincidunt adipiscing. Mauris molestie pharetra nibh. Aliquam ornare, libero at');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (84,103,'Unread','nec, malesuada','metus. Aliquam erat volutpat. Nulla facilisis. Suspendisse commodo tincidunt nibh. Phasellus nulla. Integer vulputate, risus a ultricies adipiscing, enim mi tempor lorem, eget mollis lectus pede et risus. Quisque libero lacus, varius et, euismod et, commodo at, libero. Morbi accumsan laoreet ipsum. Curabitur consequat, lectus sit amet luctus vulputate, nisi sem semper erat, in consectetuer ipsum nunc id enim.');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (91,103,'Unread','adipiscing.','Aliquam ornare, libero at auctor ullamcorper, nisl arcu iaculis enim, sit amet ornare lectus justo eu arcu. Morbi sit amet massa. Quisque porttitor eros nec tellus. Nunc lectus pede, ultrices a, auctor non, feugiat nec, diam. Duis mi enim, condimentum eget, volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing ligula. Aenean gravida nunc sed pede. Cum sociis natoque penatibus et magnis dis parturient montes,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (26,103,'Unread','ut, pellentesque','vel turpis. Aliquam adipiscing lobortis risus. In mi pede, nonummy ut, molestie in, tempus eu, ligula. Aenean euismod mauris eu elit. Nulla facilisi. Sed neque. Sed eget lacus. Mauris non dui nec urna suscipit nonummy. Fusce fermentum fermentum arcu. Vestibulum ante ipsum primis in faucibus');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (18,102,'Unread','tellus eu augue porttitor interdum.','id, erat. Etiam vestibulum massa rutrum magna. Cras convallis convallis dolor. Quisque tincidunt pede ac urna. Ut tincidunt vehicula risus. Nulla eget metus eu erat semper rutrum. Fusce dolor quam, elementum at, egestas a, scelerisque sed, sapien. Nunc pulvinar arcu et pede. Nunc sed orci lobortis');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (85,102,'Unread','justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed','Sed nulla ante, iaculis nec, eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed turpis nec mauris blandit mattis. Cras eget nisi dictum augue malesuada malesuada. Integer id magna et ipsum cursus vestibulum. Mauris magna. Duis dignissim tempor arcu. Vestibulum ut eros non enim commodo hendrerit. Donec porttitor tellus non');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (3,102,'Unread','arcu. Nunc mauris. Morbi non sapien molestie orci tincidunt','ac nulla. In tincidunt congue turpis. In condimentum. Donec at arcu. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec tincidunt. Donec vitae erat vel pede blandit congue. In scelerisque scelerisque dui. Suspendisse ac metus vitae velit egestas lacinia. Sed congue, elit sed consequat auctor, nunc nulla vulputate dui, nec tempus mauris erat eget ipsum. Suspendisse sagittis. Nullam vitae diam. Proin dolor. Nulla semper tellus id nunc interdum feugiat. Sed nec metus facilisis lorem tristique aliquet. Phasellus fermentum convallis');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (6,102,'Unread','fermentum vel, mauris. Integer sem elit, pharetra ut,','Donec elementum, lorem ut aliquam iaculis, lacus pede sagittis augue, eu tempor erat neque non quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam fringilla cursus purus. Nullam scelerisque neque sed sem egestas blandit. Nam nulla magna, malesuada vel, convallis in, cursus et,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (93,102,'Unread','ac facilisis facilisis, magna tellus faucibus leo, in lobortis','mollis. Integer tincidunt aliquam arcu. Aliquam ultrices iaculis odio. Nam interdum enim non nisi. Aenean eget metus. In nec orci. Donec nibh. Quisque nonummy ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam nec enim. Nunc ut erat. Sed nunc est, mollis');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (54,103,'Unread','odio. Etiam ligula','molestie arcu. Sed eu nibh vulputate mauris sagittis placerat. Cras dictum ultricies ligula. Nullam enim. Sed nulla ante, iaculis nec, eleifend');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (67,103,'Unread','elit, pretium et, rutrum','in, hendrerit consectetuer, cursus et, magna. Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna tellus faucibus leo, in lobortis tellus justo sit amet nulla. Donec non justo. Proin non massa non ante bibendum ullamcorper. Duis cursus, diam at pretium aliquet, metus urna convallis erat, eget tincidunt dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus id, libero. Donec consectetuer mauris id sapien. Cras dolor dolor,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (7,103,'Unread','aliquet, metus urna convallis erat, eget tincidunt dui','in molestie tortor nibh sit amet orci. Ut sagittis lobortis mauris. Suspendisse aliquet molestie tellus. Aenean egestas hendrerit neque. In ornare sagittis felis. Donec tempor, est ac mattis semper, dui lectus rutrum urna, nec luctus felis purus ac tellus. Suspendisse sed dolor. Fusce mi lorem, vehicula et, rutrum eu, ultrices sit amet, risus. Donec nibh enim, gravida sit amet, dapibus id,');
        INSERT INTO PrivateMessage (idUser,idAdmin,state,subject,content) VALUES (16,103,'Unread','nisi dictum','ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Phasellus ornare. Fusce mollis. Duis sit amet diam eu dolor egestas rhoncus. Proin nisl sem, consequat nec,');

        --  #####################  BuyerAddress  ################################
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (1,1,'Kato Barlow');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (2,2,'Clare L. Fischer');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (3,3,'Jessamine Q. Tate');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (4,4,'Xandra U. Horne');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (5,5,'Declan U. Ballard');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (6,6,'Meredith Berg');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (7,7,'Graham B. Bolton');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (8,8,'Tanisha T. Maynard');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (9,9,'Sigourney Witt');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (10,10,'Fritz Quinn');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (11,11,'September Wiggins');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (12,12,'Hedley Cortez');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (13,13,'Kiara T. Knox');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (14,14,'Zeus Raymond');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (15,15,'Justine R. Rojas');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (16,16,'Elvis H. Bolton');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (17,17,'Macon D. Duffy');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (18,18,'Lois X. Valencia');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (19,19,'Kieran W. Compton');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (20,20,'Athena Hart');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (21,21,'Axel Hunter');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (22,22,'Priscilla U. Ramirez');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (23,23,'Aphrodite H. Malone');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (24,24,'Macy Downs');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (25,25,'Xander Carrillo');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (26,26,'Odysseus Hale');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (27,27,'Elvis I. Puckett');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (28,28,'Teegan F. Cummings');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (29,29,'Myles I. Floyd');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (30,30,'Penelope Arnold');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (31,31,'Emery M. Mathews');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (32,32,'Zenia B. Barnes');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (33,33,'Laura Wilcox');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (34,34,'Leigh H. Jacobs');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (35,35,'Sharon Richard');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (36,36,'Benjamin Q. Merrill');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (37,37,'Elaine Phelps');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (38,38,'Cherokee P. Russell');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (39,39,'Germaine Fry');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (40,40,'Astra Cannon');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (41,41,'Ima W. Nunez');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (42,42,'Kaye T. Welch');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (43,43,'Prescott Wise');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (44,44,'Samson E. Harper');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (45,45,'Jasper C. Donaldson');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (46,46,'Jasmine Crosby');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (47,47,'Vernon A. Macias');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (48,48,'Blythe Mercado');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (49,49,'Lev E. Garrett');
        INSERT INTO BuyerAddress (idBuyer,idAddress,fullname) VALUES (50,50,'Kathleen R. Marsh');


        -- ################## BuyerInfo #####################
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (1,1,1);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (2,2,2);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (3,3,3);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (4,4,4);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (5,5,5);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (6,6,6);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (7,7,7);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (8,8,8);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (9,9,9);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (10,10,10);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (11,11,11);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (12,12,12);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (13,13,13);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (14,14,14);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (15,15,15);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (16,16,16);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (17,17,17);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (18,18,18);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (19,19,19);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (20,20,20);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (21,21,21);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (22,22,22);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (23,23,23);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (24,24,24);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (25,25,25);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (26,26,26);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (27,27,27);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (28,28,28);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (29,29,29);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (30,30,30);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (31,31,31);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (32,32,32);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (33,33,33);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (34,34,34);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (35,35,35);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (36,36,36);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (37,37,37);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (38,38,38);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (39,39,39);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (40,40,40);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (41,41,41);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (42,42,42);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (43,43,43);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (44,44,44);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (45,45,45);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (46,46,46);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (47,47,47);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (48,48,48);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (49,49,49);
        INSERT INTO BuyerInfo (idShippingAddress,idBillingAddress,idCreditCard) VALUES (50,50,50);


        -- ################### WantToSell #####################
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (63,1,72.18,37487.74);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (97,2,25.56,25278.41);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (90,3,73.68,02473.70);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (73,4,48.96,64647.78);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (81,5,80.26,98586.95);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (81,6,75.13,96012.72);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (78,7,80.77,16105.14);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (91,8,60.25,03719.24);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (66,9,96.53,30888.01);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (72,10,4.96,80390.43);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (75,11,69.17,60488.92);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (96,12,45.60,96273.45);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (60,13,0.83,20945.48);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (54,14,24.33,51766.44);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (86,15,60.40,48186.63);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (74,16,28.36,92558.03);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (85,17,38.21,20503.22);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (96,18,5.79,19069.35);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (74,19,84.38,43296.79);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (66,20,17.25,81589.85);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (55,21,52.57,48440.41);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (74,22,55.09,98398.53);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (82,23,71.95,78307.25);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (57,24,58.02,61727.11);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (78,25,36.65,86612.58);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (62,26,85.11,70505.53);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (76,27,8.64,40308.41);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (58,28,75.79,62989.28);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (81,29,80.91,9417.68);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (85,30,82.42,49736.43);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (69,31,20.72,38895.33);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (59,32,95.99,50401.38);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (72,33,95.13,80499.46);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (99,34,83.32,26923.36);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (73,35,92.29,95818.22);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (92,36,92.13,76956.33);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (88,37,16.91,66254.94);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (86,38,66.31,34130.39);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (68,39,44.06,46596.77);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (76,40,70.28,98934.83);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (89,41,23.84,34782.27);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (77,42,76.60,88073.04);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (93,43,28.39,57398.06);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (53,44,2.67,40303.39);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (67,45,96.54,64048.46);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (100,46,2.74,18535.72);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (87,47,40.82,49689.62);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (72,48,49.79,70221.23);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (71,49,50.74,22651.50);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (75,50,79.36,68240.35);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (87,51,15.05,15928.02);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (56,52,43.10,36326.86);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (89,53,39.10,63917.81);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (97,54,99.34,84534.91);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (81,55,63.68,57547.88);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (73,56,59.36,05603.23);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (59,57,81.59,65276.91);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (61,58,62.56,35959.76);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (75,59,17.75,79792.32);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (66,60,41.66,88885.84);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (85,61,84.19,70483.55);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (93,62,29.72,91407.86);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (91,63,42.62,37372.56);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (85,64,32.30,97708.79);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (92,65,53.10,25325.26);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (67,66,77.25,82074.02);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (70,67,63.38,73150.61);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (99,68,12.67,83316.87);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (51,69,81.34,51431.18);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (85,70,60.17,13591.55);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (57,71,77.97,24180.56);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (90,72,11.19,55943.84);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (78,73,67.11,70159.82);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (84,74,24.25,77003.82);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (74,75,98.80,08174.89);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (83,76,77.26,23939.05);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (54,77,46.56,80460.73);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (90,78,63.83,75734.41);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (79,79,94.85,97307.60);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (82,80,14.01,64523.71);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (75,81,74.13,66336.86);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (80,82,38.15,71024.63);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (63,83,72.83,07693.59);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (85,84,8.11,49221.75);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (100,85,98.94,21046.16);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (53,86,60.82,88430.04);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (53,87,57.45,10036.49);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (70,88,93.03,31852.80);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (58,89,46.07,85755.50);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (69,90,86.95,85285.32);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (64,91,3.93,39036.38);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (84,92,86.97,19904.95);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (82,93,54.71,92975.78);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (54,94,28.91,51932.93);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (58,95,98.65,61798.44);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (86,96,63.31,79106.40);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (87,97,5.24,66477.60);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (97,98,46.87,20554.19);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (56,99,91.56,71355.64);
        INSERT INTO WantsToSell (idSeller,idProduct,minimumPrice,averagePrice) VALUES (93,100,29.11,01715.24);


        --  #######################  Deal  #############################
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',39,64,1,'31-01-2014','27-09-2015','In Hand',1,2,'eget, volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing ligula.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',16,66,2,'06-11-2014','08-12-2016','In Hand',2,2,'dictum sapien. Aenean massa. Integer vitae nibh. Donec');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',41,71,3,'25-07-2014','28-08-2015','In Hand',3,0,'tristique pellentesque, tellus sem mollis');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',22,79,4,'15-10-2014','30-03-2016','In Hand',4,4,'pellentesque,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',12,92,5,'05-07-2013','01-06-2016','In Hand',5,4,'quis diam. Pellentesque habitant morbi tristique senectus et');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',9,51,6,'10-09-2014','07-02-2017','In Hand',6,1,'Etiam ligula tortor, dictum eu, placerat eget, venenatis a, magna.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',30,60,7,'14-03-2014','27-04-2016','In Hand',7,3,'tincidunt');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',27,84,8,'11-12-2013','28-11-2015','In Hand',8,1,'In mi pede, nonummy ut, molestie in, tempus eu,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',38,80,9,'16-04-2013','01-05-2015','In Hand',9,3,'pede ac urna. Ut tincidunt vehicula risus.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',1,94,10,'12-10-2013','09-05-2015','In Hand',10,3,'risus. Duis a mi');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',15,67,11,'26-09-2014','18-03-2016','In Hand',11,1,'Aenean massa. Integer vitae nibh. Donec');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',33,90,12,'23-10-2013','14-06-2016','In Hand',12,3,'ac mi eleifend egestas. Sed pharetra, felis eget varius ultrices,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',17,59,13,'05-04-2013','13-11-2015','In Hand',13,3,'lobortis. Class aptent taciti sociosqu ad litora torquent');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',20,66,14,'29-07-2014','26-05-2015','In Hand',14,0,'est ac mattis semper, dui lectus rutrum urna, nec');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',16,74,15,'23-05-2013','02-04-2017','In Hand',15,5,'tempor arcu. Vestibulum');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',41,98,16,'11-10-2014','07-03-2017','In Hand',16,4,'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam auctor,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',20,88,17,'25-04-2014','18-09-2015','In Hand',17,4,'quis arcu vel quam dignissim pharetra. Nam ac nulla.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',7,62,18,'08-11-2014','08-12-2015','In Hand',18,1,'natoque penatibus et magnis dis parturient montes, nascetur');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',14,53,19,'25-08-2014','09-05-2015','In Hand',19,0,'a, dui. Cras pellentesque. Sed dictum. Proin eget');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',40,75,20,'03-09-2014','01-10-2015','In Hand',20,2,'lectus. Nullam suscipit, est ac facilisis facilisis,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',40,76,21,'31-07-2014','11-08-2015','In Hand',21,5,'Nulla eget metus eu erat');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',22,54,22,'16-02-2015','06-05-2016','In Hand',22,4,'Cum sociis');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',10,78,23,'27-11-2014','12-02-2017','In Hand',23,2,'enim,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',1,71,24,'25-07-2013','04-06-2015','In Hand',24,4,'sit amet diam eu dolor');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Pending',32,62,25,'09-01-2015','01-11-2016','In Hand',25,1,'vel est tempor bibendum. Donec felis');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',7,51,26,'08-12-2014','14-12-2016','In Hand',26,2,'pretium');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',37,66,27,'26-03-2015','11-08-2015','In Hand',27,2,'tincidunt orci quis');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',28,83,28,'03-11-2014','07-04-2016','In Hand',28,4,'blandit. Nam nulla');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',4,81,29,'08-06-2014','22-08-2016','In Hand',29,3,'venenatis lacus. Etiam bibendum fermentum metus.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',13,54,30,'14-10-2014','26-03-2017','In Hand',30,0,'a odio semper cursus. Integer mollis. Integer tincidunt aliquam arcu.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',21,97,31,'25-04-2014','18-10-2016','In Hand',31,5,'Nulla dignissim. Maecenas ornare egestas');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',32,98,32,'16-08-2014','05-03-2017','In Hand',32,5,'at, velit. Cras lorem lorem, luctus ut, pellentesque eget, dictum');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',8,65,33,'20-11-2014','15-02-2016','In Hand',33,1,'amet metus. Aliquam erat volutpat. Nulla facilisis.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',43,76,34,'05-08-2014','19-02-2017','In Hand',34,4,'Etiam imperdiet dictum magna. Ut tincidunt orci quis lectus.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',14,100,35,'18-03-2014','17-08-2016','In Hand',35,4,'ante lectus convallis est, vitae sodales nisi magna');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',9,91,36,'06-10-2014','07-08-2016','In Hand',36,3,'Etiam ligula');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',5,80,37,'01-05-2014','03-01-2017','In Hand',37,5,'amet metus. Aliquam erat volutpat.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',17,60,38,'26-05-2013','28-10-2016','In Hand',38,5,'euismod est arcu ac orci. Ut semper pretium neque.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',25,53,39,'31-12-2013','27-09-2015','In Hand',39,3,'adipiscing elit. Etiam laoreet, libero et');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',11,76,40,'12-03-2015','24-05-2016','In Hand',40,5,'consectetuer, cursus');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',16,59,41,'08-11-2014','16-08-2015','In Hand',41,2,'lacinia. Sed congue, elit sed consequat auctor, nunc');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',24,91,42,'11-03-2015','20-05-2016','In Hand',42,3,'Morbi metus. Vivamus euismod urna.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',7,90,43,'30-12-2013','13-05-2016','In Hand',43,1,'auctor non, feugiat nec, diam. Duis mi');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',46,63,44,'18-08-2014','11-01-2016','In Hand',44,1,'In ornare sagittis felis. Donec');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',25,64,45,'27-07-2013','03-01-2017','In Hand',45,1,'enim.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',33,80,46,'14-10-2014','21-07-2015','In Hand',46,2,'Cras pellentesque.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',12,90,47,'10-06-2014','02-01-2016','In Hand',47,1,'metus sit amet ante. Vivamus non lorem');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',3,61,48,'16-07-2013','06-02-2016','In Hand',48,2,'est tempor bibendum. Donec felis orci, adipiscing non, luctus');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',7,71,49,'21-12-2014','18-01-2017','In Hand',49,5,'lacus, varius et, euismod et, commodo');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Unsuccessful',26,59,50,'23-12-2013','17-02-2017','In Hand',50,3,'nec tempus mauris erat eget ipsum. Suspendisse sagittis.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',28,80,51,'14-09-2014','21-01-2017','Shipping',1,1,'eleifend non, dapibus rutrum, justo. Praesent luctus. Curabitur egestas');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',27,95,52,'30-03-2015','16-04-2016','Shipping',2,2,'congue a, aliquet vel, vulputate eu, odio. Phasellus at');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',19,52,53,'31-05-2014','04-01-2016','Shipping',3,0,'risus. Morbi metus. Vivamus euismod urna. Nullam lobortis quam');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',20,88,54,'05-04-2013','25-04-2015','Shipping',4,5,'Donec est. Nunc ullamcorper, velit in');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',9,94,55,'14-11-2013','17-04-2015','Shipping',5,0,'Suspendisse commodo tincidunt nibh. Phasellus nulla.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',3,59,56,'10-11-2013','12-08-2016','Shipping',6,2,'dui quis accumsan convallis, ante lectus convallis');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',26,56,57,'23-09-2013','02-04-2017','Shipping',7,1,'Aliquam nec');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',20,62,58,'29-12-2013','29-04-2016','Shipping',8,1,'vitae sodales nisi magna');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',7,100,59,'12-09-2014','27-02-2016','Shipping',9,4,'Cras sed leo.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',35,89,60,'28-02-2015','22-01-2016','Shipping',10,3,'odio semper cursus. Integer mollis. Integer tincidunt aliquam arcu. Aliquam');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',13,55,61,'28-05-2013','23-01-2017','Shipping',11,4,'vestibulum.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',50,55,62,'15-05-2013','28-11-2016','Shipping',12,3,'sagittis lobortis mauris. Suspendisse aliquet molestie');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',40,53,63,'20-07-2014','16-07-2016','Shipping',13,1,'nunc est, mollis non, cursus non, egestas a, dui. Cras');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',49,55,64,'27-08-2014','27-09-2016','Shipping',14,3,'diam vel arcu. Curabitur');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',14,98,65,'10-07-2014','06-03-2017','Shipping',15,4,'elementum at, egestas a, scelerisque sed,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',50,82,66,'03-07-2014','07-07-2016','Shipping',16,0,'eleifend vitae, erat. Vivamus nisi. Mauris nulla. Integer urna.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',20,59,67,'08-05-2014','05-02-2017','Shipping',17,3,'sed, facilisis vitae, orci.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',35,66,68,'12-07-2013','27-10-2016','Shipping',18,1,'cursus et, magna. Praesent interdum ligula eu');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',6,100,69,'15-08-2014','09-01-2017','Shipping',19,1,'vulputate, posuere vulputate, lacus. Cras interdum. Nunc sollicitudin commodo ipsum.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',41,72,70,'23-08-2014','30-11-2016','Shipping',20,4,'mauris a nunc. In at pede. Cras vulputate velit eu');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',5,73,71,'07-11-2014','08-06-2016','Shipping',21,5,'non, luctus sit');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',10,87,72,'30-08-2014','09-09-2015','Shipping',22,5,'In at pede. Cras vulputate velit');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',19,65,73,'24-09-2014','05-11-2016','Shipping',23,4,'adipiscing ligula. Aenean');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',27,85,74,'31-10-2014','16-12-2015','Shipping',24,0,'Nullam lobortis quam a felis ullamcorper');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Successful',4,63,75,'23-07-2014','05-02-2017','Shipping',25,0,'Nunc');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',42,58,76,'17-09-2013','06-07-2015','Shipping',26,0,'mi, ac mattis');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',37,70,77,'21-02-2015','20-07-2015','Shipping',27,3,'a nunc. In at pede. Cras vulputate velit eu');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',45,93,78,'16-02-2014','06-04-2015','Shipping',28,0,'In');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',13,63,79,'02-04-2014','03-01-2017','Shipping',29,3,'in, dolor.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',36,60,80,'20-12-2013','17-12-2016','Shipping',30,5,'condimentum eget, volutpat ornare, facilisis eget,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',26,72,81,'19-01-2015','20-10-2015','Shipping',31,0,'Quisque fringilla euismod enim. Etiam gravida molestie arcu.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',25,60,82,'13-09-2013','31-10-2016','Shipping',32,3,'lectus pede, ultrices a, auctor non, feugiat nec, diam. Duis');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',12,100,83,'03-06-2014','15-10-2016','Shipping',33,1,'pharetra. Quisque ac libero');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',13,71,84,'10-01-2014','29-05-2015','Shipping',34,2,'Nunc mauris elit, dictum eu, eleifend nec, malesuada');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',26,58,85,'16-01-2015','30-07-2016','Shipping',35,0,'molestie');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',16,75,86,'20-06-2013','29-04-2015','Shipping',36,2,'vehicula risus. Nulla');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',13,93,87,'06-04-2013','17-09-2015','Shipping',37,4,'malesuada augue ut lacus. Nulla tincidunt, neque vitae');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',48,76,88,'09-09-2013','02-07-2015','Shipping',38,2,'dolor dapibus gravida. Aliquam tincidunt, nunc ac');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',12,100,89,'07-03-2014','30-04-2015','Shipping',39,2,'augue. Sed molestie.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',17,80,90,'02-06-2013','21-06-2015','Shipping',40,3,'ut cursus luctus, ipsum leo elementum sem,');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',46,79,91,'18-05-2013','15-09-2016','Shipping',41,4,'lacus. Aliquam');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',37,71,92,'29-07-2013','12-03-2016','Shipping',42,4,'ultrices posuere cubilia Curae;');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',36,59,93,'10-03-2015','13-07-2016','Shipping',43,1,'nibh. Donec est');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',50,88,94,'10-09-2013','25-08-2016','Shipping',44,2,'ac orci. Ut semper pretium neque. Morbi');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',43,66,95,'05-04-2014','08-07-2016','Shipping',45,0,'Vivamus non lorem vitae odio sagittis semper. Nam');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',35,70,96,'09-02-2015','18-04-2016','Shipping',46,3,'odio sagittis semper. Nam tempor diam');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',1,66,97,'03-03-2014','07-02-2016','Shipping',47,1,'Maecenas ornare egestas ligula. Nullam feugiat placerat velit. Quisque varius.');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',39,68,98,'25-11-2014','02-07-2016','Shipping',48,5,'euismod in, dolor. Fusce feugiat. Lorem ipsum dolor');
        INSERT INTO Deal (dealState,idBuyer,idSeller,idProduct,beginningDate,endDate,deliveryMethod,idBuyerInfo,sellerRating,buyerComment) VALUES ('Delivered',20,90,99,'18-11-2013','31-05-2016','Shipping',49,1,'pede.');


        -- ################## Interaction ####################
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (1,525.77,'2013-04-21T12:45:42-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (2,994.19,'2014-10-27T07:04:10-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (3,326.08,'2013-08-22T04:38:11-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (4,663.52,'2013-10-16T05:24:13-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (5,75.53,'2014-11-06T08:42:04-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (6,375.14,'2014-02-23T18:55:59-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (7,271.02,'2014-06-21T17:08:56-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (8,348.25,'2014-09-30T06:16:30-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (9,475.15,'2014-09-19T22:49:20-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (10,894.19,'2013-05-21T04:27:57-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (11,492.31,'2015-03-22T11:08:59-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (12,327.50,'2014-06-15T14:35:30-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (13,191.11,'2013-08-19T18:52:48-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (14,491.90,'2013-04-27T05:23:14-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (15,372.92,'2013-05-14T04:44:18-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (16,28.28,'2014-06-18T09:09:22-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (17,111.81,'2014-11-07T04:10:29-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (18,808.41,'2014-07-21T15:52:03-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (19,491.84,'2013-07-20T00:49:39-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (20,891.29,'2014-05-12T10:18:37-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (21,397.39,'2015-01-16T12:40:07-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (22,562.24,'2013-10-16T10:51:02-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (23,698.86,'2014-01-31T11:19:31-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (24,465.78,'2013-09-20T17:51:27-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (25,612.27,'2013-08-04T07:00:38-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (26,948.19,'2013-08-22T00:51:26-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (27,401.65,'2013-10-07T22:34:04-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (28,235.88,'2013-06-10T03:30:35-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (29,978.65,'2014-02-13T08:13:40-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (30,799.01,'2014-10-27T01:42:54-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (31,215.85,'2014-09-28T18:10:45-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (32,365.12,'2014-09-15T02:11:14-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (33,864.36,'2015-02-25T18:00:35-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (34,249.56,'2014-02-09T18:37:38-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (35,51.98,'2014-06-27T10:43:01-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (36,179.47,'2014-02-03T16:08:33-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (37,9.46,'2014-11-12T14:46:49-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (38,176.63,'2013-09-21T21:16:47-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (39,230.59,'2013-12-05T02:02:22-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (40,338.59,'2013-08-30T00:51:13-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (41,184.24,'2013-06-08T02:52:40-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (42,87.26,'2013-09-26T19:34:23-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (43,306.38,'2013-10-16T05:12:16-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (44,313.22,'2014-11-28T01:05:42-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (45,731.94,'2013-08-26T12:17:43-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (46,381.60,'2013-04-15T06:13:05-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (47,444.80,'2013-08-28T22:31:48-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (48,674.98,'2013-07-29T19:37:16-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (49,204.11,'2014-11-24T20:00:12-08:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (50,767.78,'2013-09-23T04:46:57-07:00','Offer');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (51,923.80,'2013-11-06T08:40:45-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (52,892.94,'2013-09-05T06:20:29-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (53,508.50,'2015-02-25T16:22:42-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (54,181.05,'2014-09-24T12:51:28-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (55,207.54,'2015-03-11T03:46:40-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (56,310.07,'2013-09-14T11:41:48-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (57,24.01,'2014-11-12T19:42:38-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (58,948.42,'2014-02-10T12:18:15-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (59,98.76,'2013-08-24T11:49:47-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (60,752.47,'2013-12-03T11:41:01-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (61,994.66,'2014-04-06T17:38:40-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (62,195.50,'2014-12-16T00:51:25-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (63,223.82,'2013-11-14T10:30:54-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (64,479.91,'2013-10-25T12:27:04-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (65,606.69,'2014-07-20T02:13:48-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (66,150.94,'2014-12-14T03:43:27-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (67,725.67,'2014-03-29T07:43:25-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (68,766.91,'2014-07-18T03:46:00-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (69,496.19,'2015-03-21T20:25:00-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (70,187.84,'2013-11-02T20:46:33-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (71,77.95,'2013-10-15T22:33:59-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (72,184.36,'2014-03-09T23:06:36-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (73,702.64,'2014-08-22T00:24:08-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (74,362.31,'2015-01-18T21:46:59-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (75,638.33,'2015-03-30T18:39:37-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (76,817.19,'2014-05-03T08:45:59-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (77,22.18,'2013-06-08T09:55:27-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (78,80.31,'2014-01-26T05:13:14-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (79,564.23,'2013-07-22T07:40:16-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (80,415.56,'2014-06-07T19:51:55-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (81,908.40,'2014-10-11T13:44:47-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (82,9.48,'2013-09-04T15:02:05-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (83,604.82,'2013-06-18T10:54:34-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (84,918.20,'2013-06-22T02:00:59-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (85,167.18,'2013-10-30T05:35:46-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (86,909.45,'2015-01-02T10:36:45-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (87,268.09,'2014-05-05T09:14:00-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (88,97.51,'2014-10-12T02:02:37-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (89,470.74,'2014-05-13T13:12:29-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (90,164.56,'2013-07-07T07:40:10-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (91,770.02,'2014-03-21T02:38:24-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (92,827.18,'2014-06-05T11:22:15-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (93,360.55,'2013-09-20T12:42:15-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (94,71.81,'2014-04-06T19:34:49-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (95,70.33,'2014-10-10T16:06:28-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (96,202.82,'2014-05-28T13:26:17-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (97,530.27,'2014-07-21T03:52:59-07:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (98,726.81,'2013-11-14T19:44:17-08:00','Proposal');
        INSERT INTO Interaction (idDeal,amount,date,interactionType) VALUES (99,533.58,'2014-02-15T06:35:25-08:00','Proposal');