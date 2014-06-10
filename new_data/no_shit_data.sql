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
        approved BOOLEAN NOT NULL DEFAULT TRUE
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
        /*todo: change to BuyerAddress*/
        idShippingAddress INTEGER NOT NULL REFERENCES Address(idAddress),
        idBillingAddress INTEGER NOT NULL REFERENCES Address(idAddress),
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
        minSaleValue Amount,
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
        ADD CONSTRAINT ct_valid_deal_dates CHECK (endDate::date >= beginningDate::date);

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
        IF NEW.DealState = 'Delivered' AND NEW.deliveryMethod IS NULL
        THEN
            RAISE EXCEPTION 'When a Deal is successful, a Delivery Method must be set';
        END IF;
        
        IF NEW.deliveryMethod = 'Shipping' AND NEW.idBuyerInfo IS NULL
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

INSERT INTO Country (name) VALUES ('Alemanha');
INSERT INTO Country (name) VALUES ('Áustria');
INSERT INTO Country (name) VALUES ('Bélgica');
INSERT INTO Country (name) VALUES ('Bulgaria');
INSERT INTO Country (name) VALUES ('Chipre');
INSERT INTO Country (name) VALUES ('Croácia');
INSERT INTO Country (name) VALUES ('Dinamarca');
INSERT INTO Country (name) VALUES ('Eslováquia');
INSERT INTO Country (name) VALUES ('Eslovénia');
INSERT INTO Country (name) VALUES ('Espanha');
INSERT INTO Country (name) VALUES ('Estónia');
INSERT INTO Country (name) VALUES ('Finlândia');
INSERT INTO Country (name) VALUES ('França');
INSERT INTO Country (name) VALUES ('Grécia');
INSERT INTO Country (name) VALUES ('Holanda');
INSERT INTO Country (name) VALUES ('Hungria');
INSERT INTO Country (name) VALUES ('Irlanda');
INSERT INTO Country (name) VALUES ('Itália');
INSERT INTO Country (name) VALUES ('Letónia');
INSERT INTO Country (name) VALUES ('Lituânia');
INSERT INTO Country (name) VALUES ('Luxemburgo');
INSERT INTO Country (name) VALUES ('Malta');
INSERT INTO Country (name) VALUES ('Polónia');
INSERT INTO Country (name) VALUES ('Portugal');
INSERT INTO Country (name) VALUES ('Reino Unido');
INSERT INTO Country (name) VALUES ('República Checa');
INSERT INTO Country (name) VALUES ('Roménia');
INSERT INTO Country (name) VALUES ('Suécia');

        -- ######################  ProductCategory ####################
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Jogos Digitais e Software');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Livros');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Filmes, TV, Música');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Eletrónica e computadores');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Casa, Jardim, Animais de Estimação e DIY');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Brinquedos');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Roupa, Calçado e Joalharia');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Desporto e ar livre');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Mercearia, Beleza e Bem-Estar');
        INSERT INTO ProductCategory (idParent,name) VALUES ( NULL, 'Carro e Motociclo');
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


-- Jogos Digitais e Software
INSERT INTO Product (name, description) VALUES ('Duke Nukem Forever', 'O jogo mais antecipado desde a criação do universo chegou finalmente para desiludir todos os gamers do mundo com uma experiência no todo sub-par. De comprar e chorar pelo dinheiro');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (1, 1);
INSERT INTO Product (name, description) VALUES ('FIFA 14', 'De volta para surpreender os fãs da "peladinha" com uma nova experiência 100% igual à anterior. Nada como gastar o seu dinheiro bem ganho em algo exactamente igual ao que comprou ano passado.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (2, 1);
INSERT INTO Product (name, description) VALUES ('Wii U', 'Convencido que jogos são unicamente para crianças? Então aqui tem a consola perfeita para si! Com gráficos inferiores às consolas concorrentes e jogos claramente antiquados vai conseguir realmente despertar a sua infância.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (3, 1);
INSERT INTO Product (name, description) VALUES ('Vida Própria', 'Pronto para impressionar os seus amigos virtuais? Pronto para fingir que realmente tem amigos? Este novo produto da GetALife permite convencer todos os seus amigos que é mais popular do que realmente é. Faça com que os outros pensem que é radical e popular em festas! Seja fixe!');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (4, 1);
 
-- Livros
INSERT INTO Product (name, description) VALUES ('Segredinhos', 'O livro mais popular para pessoas desesperadas sem mais nada para fazer. Convença-se que todos os problemas da sua vida são fruto da sua "energia" negativa. Finja que todos os seus problemas já não existem. Viva no mundo dos sonhos. Vençedor de 3 prémios de organizações que nunca ninguém ouviu falar.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (5, 2);
INSERT INTO Product (name, description) VALUES ('O Jogo dos Bancos', 'Um conto épico de aventura que o vai deixar colado à poltrona. Viva num mundo de aventura em que as suas personagens favoritas são mortas de 10 em 10 páginas.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (6, 2);
INSERT INTO Product (name, description) VALUES ('O Hobbit', 'Obra prima de J. R. R. Tolkien. Tanto uma história de crianças como um conto épico apra adultos. Bastante melhor do que a versão em filme.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (7, 2);
INSERT INTO Product (name, description) VALUES ('Os Lusíadas', 'Das obras portuguesas mais famosas, escrita pelo nosso amigo Luís "Zarolho" Camões. Conta a história dos navegadores portugueses na descoberta do caminho marítimo para a Índia');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (8, 2);
 
-- Filmes, TV, Música
INSERT INTO Product (name, description) VALUES ('Os Condenados de Shawshank', '"Os Condenados de Shawshank", Baseado na novela "Rita Hayworth and Shawshank Redemption", de Stephen King, o filme retrata a história de Andy Dufresne, um banqueiro que passa quase duas décadas na fictícia prisão estadual de Shawshank, condenado pelo assassinato de sua esposa e do seu amante, apesar de Andy afirmar sua inocência. Durante seu tempo na prisão, ele se torna amigo de Ellis "Red" Redding, e se torna protegido pelos guardas após o agente penitenciário passar a utilizá-lo em operações de lavagem de dinheiro. Lançado em 23 de setembro de 1994, o filme teve fraca recepção nos cinemas {carece de fontes}, arrecadando pouco mais de 28 milhões de dólares - apenas 3 milhões de dólares de lucro em relação ao orçamento. Apesar disso, Um Sonho de Liberdade recebeu resenhas favoráveis dos críticos, múltiplas indicações à prêmios, além da inclusão na lista dos melhores filmes estadunidenses do American Film Institute. The Shawshank Redemption foi indicado para sete Óscars, incluindo Melhor Filme e Melhor Ator (Morgan Freeman).');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (9, 3);
INSERT INTO Product (name, description) VALUES ('Top Gear - The Burma Special', 'Os três apresentadores são desafiados com a construção de uma ponte sobre o rio Kwai. A viagem começa com uma unidade através de Burma para a Tailândia, onde seguem o caminho errado e acabam por ter que passar por uma passagem de montanha. Jeremy queixa-se constantemente da sua Isuzu dizendo o quão má é a caixa de velocidades e o nível de conforto. Hammond e James também têm problemas com seus veículos. Os três então fazer modificações em seus carros; Jeremy acrescenta azul e branco pintura Shelby, emblemas Mercedes AMG ao lado, uma cama, uma cadeira e faz com que seja um camião descapotável através da remoção do telhado na cabine. Hammond acrescenta uma plataforma de observação, dois escapes de camião altos, uma rede, equipamentos de cozinha e um chuveiro. May adiciona um sistema de refrigeração a água e uma tenda que ele está pendurado na grua do caminhão dele. Os três apresentadores têm uma arrancada nas vastas ruas, vazias de Naypyidaw, capital da Birmânia, após o que prosseguir no Estado de Shan.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (10, 3);
INSERT INTO Product (name, description) VALUES ('Queens Of The Stone Age - ...Like Clockwork', '...Like Clockwork é o sexto álbum de estúdio da banda americana de stoner rock Queens of the Stone Age, lançado a 3 de junho de 2013 no Reino Unido e a 4 de junho nos Estados Unidos. Elton John definiu o álbum como um dos melhores álbuns de rock alternativo de todos os tempos. Foi produzido pela banda, além de ser o primeiro de Queens of the Stone Age com contribuições totais dos membros Michael Shuman e Dean Fertita, respectivamente teclista e baixista da banda, que se uniram à mesma em 2007 para a turnê de apoio do quinto álbum de estúdio da banda, Era Vulgaris, no qual gravaram suas faixas bónus.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (11, 3);
INSERT INTO Product (name, description) VALUES ('Led Zeppelin - Houses of the Holy', 'Houses of the Holy é o quinto álbum de estúdio da banda britânica de rock Led Zeppelin, lançado pela Atlantic Records em 28 de março de 1973. O título do álbum é uma dedicação da banda aos seus fãs que apareceram em locais que eles batizaram de "Casa do sagrado". Representa um ponto de viragem musical para Led Zeppelin, pois começaram a usar mais camadas e técnicas de produção a gravar suas canções.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (12, 3);
 
-- Eletrónica e Computadores
INSERT INTO Product (name, description) VALUES ('Asus VivoPC VM40B-S088R', 'Imagine todas as funcionalidades de um PC desktop tradicional numa caixa chique e compacta com uma dimensão pouco maior que uma caixa de DVDs. Conheça o ASUS VivoPC. Equipado por um processador Intel® e com tecnologia SonicMaster, o VivoPC abre caminho a uma computação completa para o dia-a-dia e experiência cinematográfica multimédia realista. Sente-se e desfrute enquanto a sua placa de rede Wi-Fi 802.11ac atinge velocidades até três vezes superiores às das velocidades da norma Wireless N standard e ligações estáveis para navegação web online, difusão multimédia e jogos online.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (13, 4);
INSERT INTO Product (name, description) VALUES ('LG TV LED 42LB630V Smart TV 107cm', 'A LG Smart TV introduz mais uma inovação, o webOS, uma nova interface de utilizador que agrega todo o acesso ao entretenimento em sua casa de uma forma ainda mais simples que consegue descomplicar ainda mais a tecnologia Smart TV. Desfrute de uma qualidade de imagem superior à oferecida por outras tecnologias de imagem, com muito mais brilho e contraste para que não perca o mínimo detalhe daquilo que está a ver. As cores são tão reais que terá a sensação que está a viver o filme ou programa que está a ver, graças a uma mairo regularidade e menor variação na temperatura da cor. O segredo? Está na nossa tecnologia IPS com 100% de pixeis activos.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (14, 4);
INSERT INTO Product (name, description) VALUES ('B&W Coluna Z2 AirPlay', 'Obtenha som perfeito e conectividade sem fios num produto que se adapta à sua vida, com a coluna e estação de ligação Z2 da Bowers & Wilkins. Ligue o seu iPhone ou iPod de última geração, utilizando o conector Lightning, ou utilize AirPlay para transmitir qualquer faixa da sua biblioteca do iTunes onde quer que esteja. O design e estilo elegante da Z2 tornam-na numa coluna versátil que se adapta a praticamente qualquer ambiente doméstico. O conector Lightning desaparece quando não está a ser utilizado, a unidade é construída a partir de uma combinação elegante e altamente durável de borracha e aço inoxidável e está disponível em branco ou preto.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (15, 4);
INSERT INTO Product (name, description) VALUES ('HP Rato Wireless X3500', 'A HP convida-o a melhorar a forma como se liga e comunica, trabalha e se diverte. Construído sob normas e linhas orientadoras restritas da HP, o Rato sem fios HP X3500 de classe mundial une sem qualquer esforço o design fino e moderno com características duradouras e avançadas. O Rato sem fios HP elegante e moderno X3500 adiciona um toque instantâneo de estilo a qualquer espaço de trabalho. O preto lustroso e o cinzento metálico brilham com sofisticação. Além disso, a sua silhueta curvilínea dá-lhe um formato sedutor. O HP X3500 apresenta a mais recente tecnologia que você tanto deseja. A ligação sem fios 2,4GHz liberta-o. A vida útil da bateria é de 12 meses. A roda do rato voa na Web e nos documentos. O sensor ótico ajustável funciona na maioria das superfícies.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (16, 4);
 
-- Casa, Jardim, Animais de Estimação e DIY
INSERT INTO Product (name, description) VALUES ('Fogareiro ZéQuim', 'Para aquecer essas patorras de lenhador num Inverno bem geladinho. Tire essas botas cheias de lama e pouse esses pés num banquito em frente ao Fogareiro ZéQuim para ver esses calos a fritar com o agrdável calor por este emitido');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (17, 5);
INSERT INTO Product (name, description) VALUES ('Chafariz Esguichos', 'Para aqueles dias de sol onde não há vontade para regar a relva, o chafariz Esguichos espalha uniformemente uma camada de água pelo seu relvado com o mínimo de esforço. Para além disso é uma desculpa e uma alternativa àquela piscina que prometeu aos seus filhos.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (18, 5);
INSERT INTO Product (name, description) VALUES ('Jaula de Aço inoxidável', 'O seu tigre de estimação anda a causar o caos nas suas festas? Então seja amigo dos seus amigos. Enjaule a poderosa besta nesta impecável jaula de aço inox (não que faça diferença, visto que o objetivo é tratar mal o bicho) para que ele deixe de incomodar. Vem com duas tacinhas para lhe deixar o que considerar comida.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (19, 5);
INSERT INTO Product (name, description) VALUES ('Kit de Guitarra Academic', 'Para aqueles que acham que fazem melhor que um profissional, o que querem dispender de seu tempo num projeto engraçado chega o kit de guitarras Academic. Com todas as peças necessárias para construir uma guitarra a sério.');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (20, 5);
INSERT INTO Product (name, description) VALUES ('Nenuco', 'O novo amigo da sua filha. Agora com ainda mais funcionalidades, como uma cabeça de fácil remoção.');
INSERT INTO Product (name, description) VALUES ('Mesa Das Palavras CHICCO', 'Mesa com imensas atividades para a sua criança. Garantia vitalícia, até ao momento em que a sua criança põe as mãos em cima disto)');
INSERT INTO Product (name, description) VALUES ('Barbie Vai À Praia', 'Barbie chateia-se com o Ken. Viva todas as emoções da bárbie com o seu carocha rosa e a sua mansão de praia após esta pedir um tempo ao seu amado. Modelos masculinos vendidos em separado em "Escapadelas da Bárbie".');
INSERT INTO Product (name, description) VALUES ('Monopolio', 'Em economia, monopólio (do grego monos, um + polein, vender) designa uma situação particular de concorrência imperfeita, em que uma única empresa detém o mercado de um determinado produto ou serviço, conseguindo portanto influenciar o preço do bem que comercializa.');
INSERT INTO Product (name, description) VALUES ('Anel Forretice', 'Impressione a sua cara metade com esta réplica digna de Neal Caffrey. Deixe nos comentários como correu ;)');
INSERT INTO Product (name, description) VALUES ('Sapatilhas do Bip-Bip', 'Já quis fugir dos gunas da areosa? Não tinha nenhum meio de locomoção por perto? Se já se viu nesta situação, não procure mais, a suspensão destas sapatilhas permitem-no soltar o Usain Bolt dentro de si, e deixar os gunas a comer pó.');
INSERT INTO Product (name, description) VALUES ('Bikini Borat', 'Esta relíquia no mundo da moda está já disponível, por tempo limitado (enquanto que o governo do Cataziquistão não der pelos contentores perdidos).');
INSERT INTO Product (name, description) VALUES ('T-Shirt Nerd', 'Sempre quis entrar neste grupo restrito de pessoas que levam ao expoente máximo a intelectualidade e o raciocínio lógico. Não??? Como pode dizer que não, só tem que querer, caso não tenha percebido são o futuro da humanidade. Mas você é que sabe da sua vida... Enfim...');
INSERT INTO Product (name, description) VALUES ('Mesa de pique-nique', 'Aproveite o melhor que a vida lhe pode oferecer. Os momentos familiares que desfrutará nesta mesa de pique-nique dar-lhe-ão um novo alento para enfrentar o seu chefe no dia seguinte. Sim, estamos só a recorrer a argumentos vazios numa tentativa fútil de comprar este monte de plástico totalmente inútil. Mas não se queixe, se tiver melhor solução de fazer dinheiro nos dias que correm faça favor...');
INSERT INTO Product (name, description) VALUES ('Raquete genérica', 'Funciona para badminton, ténis, ping-pongue, moscas e mosquitos, e ainda cabeças de gunas da areosa.');
INSERT INTO Product (name, description) VALUES ('Guarda-sol individual', 'Sempre achei isto ridículo, daí ter incluido na base de dados. Era só isto.');
INSERT INTO Product (name, description) VALUES ('Gases de vaca enlatado', 'Reuna-se à natureza com esta fragrância natural, sem corantes nem conservantes. Uma dose de metano por dia nem sabe o bem que lhe fazia.');
INSERT INTO Product (name, description) VALUES ('Maçãs Podridão', 'Não se deixe enganar pelo nome destas maçãs. Com todos os químicos que lhes metemos, não tenha dúvidas do quão suculentas estas maçãs se mantém, por mais de 5 anos. Acredite. PS:Após ingestão, comunique para beta_testers@werealytrulycare.com');
INSERT INTO Product (name, description) VALUES ('Creme de pepino e ácido sulfúrico', 'Remove tudo o que é rugas, calos, e dores em geral. You name it');
INSERT INTO Product (name, description) VALUES ('Adaptador ComoÉSuposto', 'Sabia que a evolução preparou o nosso organismo para excretar de um modo completamente diferente do que estamos habituados? Isto tem os seus malefícios. Inverta a tendência, compre já!');
INSERT INTO Product (name, description) VALUES ('Refeição Vegetariana Enlatada', 'Nem é preciso fazer propaganda pois não? A imagem diz tudo...');
INSERT INTO Product (name, description) VALUES ('Lambreta Rater', 'Pá-pá-pá-pá trá-trá-trá-trá vrum-vrummmmmm');
INSERT INTO Product (name, description) VALUES ('Proteção voltante PimpMyRide', 'Proteção oficial da série de TV. Limited edition');
INSERT INTO Product (name, description) VALUES ('Óleo do Tone', 'Com este óleo o seu motor vai ficar oleado.');
INSERT INTO Product (name, description) VALUES ('Carro dos Flingstones', 'Finalmente chegou. Após intensa investigação conseguiu-se através de técnicas avançadíssimas de reverse-engineering obter um protótipo funcional, o qual pode obter desde já');
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (21, 6);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (22, 6);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (23, 6);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (24, 6);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (25, 7);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (26, 7);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (27, 7);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (28, 7);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (29, 8);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (30, 8);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (31, 8);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (32, 8);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (33, 9);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (34, 9);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (35, 9);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (36, 9);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (37, 10);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (38, 10);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (39, 10);
INSERT INTO ProductCategoryProduct (idProduct, idCategory) VALUES (40, 10);

INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Rua da Amargura nº 666','3214-564','Lisboa', 24);
INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Rua Nacional da Guitarra Clássica Portuguesa nº 88','2788-545','Gouda', 24);
INSERT INTO Address (addressLine,postalCode,city,idCountry) VALUES ('Travessa Estás com Pressa nº 12','7456-645','Siena', 24);

INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('ManuelAlmeida','malmeida','manuel@gmail.com',FALSE);
INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('JorgePalma','japalma','jorginho@gmail.com',FALSE);
INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('FernandoMendes','gordinho','fmender@outlook.com',FALSE);
INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('RuiVeloso','alcool','veloso@gmail.com',FALSE);
INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('AmaliaRodrigues','kelfado','amalia@gmail.com',FALSE);
INSERT INTO RegisteredUser (username,password,email,isBanned) VALUES ('LenaDAgua','forgotten','leninha@hotmail.com',FALSE);

INSERT INTO Buyer (idBuyer) VALUES (1);
INSERT INTO Buyer (idBuyer) VALUES (2);
INSERT INTO Buyer (idBuyer) VALUES (3);

INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (4,1,'Veloso Musica e Cenas','912564289','Vendedor de prestígio. Famoso. De confiança. Bebe um pouco. Sem figado.',TRUE);
INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (5,2,'Livros Amália','912315423','Livros favoritos da fadista morta mais famosa do mundo. Coleção grande. Resposta rápida.',TRUE);
INSERT INTO Seller (idSeller,idAddress,companyName,cellPhone,description,isVisibleToAPI) VALUES (6,3,'Música sem Lúsica','962541236','Música no coração de um dos sucessos mais esquecidos de Portugal.',TRUE);

INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (1,1,5,'Gostei.');
INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (23,2,5,'Gostei.');
INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (10,3,5,'Gostei.');
INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (25,1,5,'Gostei.');
INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (40,2,5,'Gostei.');
INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (33,3,5,'Gostei.');
INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (8,1,5,'Gostei.');
INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (5,2,5,'Gostei.');
INSERT INTO ProductRating (idProduct,idBuyer,rating,comment) VALUES (26,3,5,'Gostei.');
