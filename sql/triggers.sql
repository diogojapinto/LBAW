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

CREATE OR REPLACE FUNCTION update_selling_product_trigger() RETURNS TRIGGER AS '
BEGIN
	IF (SELECT idProduct 
		FROM Deal
		WHERE dealState = \'Pending\'
			AND idSeller = NEW.idSeller) = idProduct
	THEN
		RETURN OLD;
	ELSE
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

DROP TRIGGER IF EXISTS update_selling_product_trigger ON Deal;
CREATE TRIGGER update_selling_product_trigger
	BEFORE INSERT ON Deal
	FOR EACH ROW EXECUTE PROCEDURE update_selling_product_trigger();