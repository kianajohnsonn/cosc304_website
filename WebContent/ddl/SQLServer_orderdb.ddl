CREATE DATABASE orders;
go

USE orders;
go

DROP TABLE review;
DROP TABLE shipment;
DROP TABLE productinventory;
DROP TABLE warehouse;
DROP TABLE orderproduct;
DROP TABLE incart;
DROP TABLE product;
DROP TABLE category;
DROP TABLE ordersummary;
DROP TABLE paymentmethod;
DROP TABLE customer;


CREATE TABLE customer (
    customerId          INT IDENTITY,
    firstName           VARCHAR(40),
    lastName            VARCHAR(40),
    email               VARCHAR(50),
    phonenum            VARCHAR(20),
    address             VARCHAR(50),
    city                VARCHAR(40),
    state               VARCHAR(20),
    postalCode          VARCHAR(20),
    country             VARCHAR(40),
    userid              VARCHAR(20),
    password            VARCHAR(30),
    PRIMARY KEY (customerId)
);

CREATE TABLE paymentmethod (
    paymentMethodId     INT IDENTITY,
    paymentType         VARCHAR(20),
    paymentNumber       VARCHAR(30),
    paymentExpiryDate   DATE,
    customerId          INT,
    PRIMARY KEY (paymentMethodId),
    FOREIGN KEY (customerId) REFERENCES customer(customerid)
        ON UPDATE CASCADE ON DELETE CASCADE 
);

CREATE TABLE ordersummary (
    orderId             INT IDENTITY,
    orderDate           DATETIME,
    totalAmount         DECIMAL(10,2),
    shiptoAddress       VARCHAR(50),
    shiptoCity          VARCHAR(40),
    shiptoState         VARCHAR(20),
    shiptoPostalCode    VARCHAR(20),
    shiptoCountry       VARCHAR(40),
    customerId          INT,
    PRIMARY KEY (orderId),
    FOREIGN KEY (customerId) REFERENCES customer(customerid)
        ON UPDATE CASCADE ON DELETE CASCADE 
);

CREATE TABLE category (
    categoryId          INT IDENTITY,
    categoryName        VARCHAR(50),    
    PRIMARY KEY (categoryId)
);

CREATE TABLE product (
    productId           INT IDENTITY,
    productName         VARCHAR(40),
    productPrice        DECIMAL(10,2),
    productImageURL     VARCHAR(100),
    productImage        VARBINARY(MAX),
    productDesc         VARCHAR(1000),
    categoryId          INT,
    PRIMARY KEY (productId),
    FOREIGN KEY (categoryId) REFERENCES category(categoryId)
);

CREATE TABLE orderproduct (
    orderId             INT,
    productId           INT,
    quantity            INT,
    price               DECIMAL(10,2),  
    PRIMARY KEY (orderId, productId),
    FOREIGN KEY (orderId) REFERENCES ordersummary(orderId)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (productId) REFERENCES product(productId)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE incart (
    orderId             INT,
    productId           INT,
    quantity            INT,
    price               DECIMAL(10,2),  
    PRIMARY KEY (orderId, productId),
    FOREIGN KEY (orderId) REFERENCES ordersummary(orderId)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (productId) REFERENCES product(productId)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE warehouse (
    warehouseId         INT IDENTITY,
    warehouseName       VARCHAR(30),    
    PRIMARY KEY (warehouseId)
);

CREATE TABLE shipment (
    shipmentId          INT IDENTITY,
    shipmentDate        DATETIME,   
    shipmentDesc        VARCHAR(100),   
    warehouseId         INT, 
    PRIMARY KEY (shipmentId),
    FOREIGN KEY (warehouseId) REFERENCES warehouse(warehouseId)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE productinventory ( 
    productId           INT,
    warehouseId         INT,
    quantity            INT,
    price               DECIMAL(10,2),  
    PRIMARY KEY (productId, warehouseId),   
    FOREIGN KEY (productId) REFERENCES product(productId)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (warehouseId) REFERENCES warehouse(warehouseId)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE review (
    reviewId            INT IDENTITY,
    reviewRating        INT,
    reviewDate          DATETIME,   
    customerId          INT,
    productId           INT,
    reviewComment       VARCHAR(1000),          
    PRIMARY KEY (reviewId),
    FOREIGN KEY (customerId) REFERENCES customer(customerId)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (productId) REFERENCES product(productId)
        ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE UserInteraction (
    interactionId INT IDENTITY PRIMARY KEY,
    customerId INT NOT NULL,
    productId INT NOT NULL,
    interactionType VARCHAR(20) NOT NULL, -- 'view', 'cart_add', 'purchase'
    interactionDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (customerId) REFERENCES customer(customerId) ON DELETE CASCADE,
    FOREIGN KEY (productId) REFERENCES product(productId) ON DELETE CASCADE
);
CREATE INDEX idx_user_interaction ON UserInteraction(customerId, interactionType, interactionDate);
CREATE INDEX idx_product_interaction ON UserInteraction(productId, interactionType);

INSERT INTO category(categoryName) VALUES ('Coffee Beans Whole');
INSERT INTO category(categoryName) VALUES ('Coffee Beans Ground');
INSERT INTO category(categoryName) VALUES ('Coffee Makers');
INSERT INTO category(categoryName) VALUES ('Accessories');

  --Coffee Beans Whole
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Colombia Supremo Whole', 1, '12 oz bag, Medium Roast', 18.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Brazil Santos Whole', 1, '12 oz bag, Medium Dark Roast', 19.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Ethiopia Yirgacheffe Whole', 1, '12 oz bag, Light Floral Roast', 21.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Guatemala Antigua Whole', 1, '12 oz bag, Medium Roast', 20.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Sumatra Mandheling Whole', 1, '12 oz bag, Dark Earthy Roast', 22.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Costa Rica Tarrazu Whole', 1, '12 oz bag, Bright Medium Roast', 19.50);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Colombia Decaf Whole', 1, '12 oz bag, Medium Roast', 17.50);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Costa Rica Decaf Whole', 1, '12 oz bag, Dark Roast Decaf', 19.50);


  --Coffee Beans Ground
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Colombia Supremo Ground', 2, '12 oz bag, Medium Roast', 19.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Brazil Santos Ground', 2, '12 oz bag, Medium Dark Roast', 20.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Ethiopia Yirgacheffe Ground', 2, '12 oz bag - Light Floral Roast', 22.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Guatemala Antigua Ground', 2, '12 oz bag, Medium Roast', 21.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Sumatra Mandheling Ground', 2, '12 oz bag, Dark Earthy Roast', 23.00);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Costa Rica Tarrazu Ground', 2, '12 oz bag, Bright Medium Roast', 20.50);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Colombia Decaf Ground', 2, '12 oz bag, Medium Roast', 18.50);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Costa Rica Decaf Ground', 2, '12 oz bag, Dark Roast Decaf', 20.50);

  --Coffee Machines
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Nadiana Single Shot Espresso Machine', 3, 'Compact home espresso maker', 129.99);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Nadiana Dual Shot Espresso Maker', 3, 'Dual shot extraction with milk frother', 189.99);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Nadiana French Press 1L', 3, 'Stainless steel French press (1 liter)', 34.99);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Nadiana Classic Drip Coffee Maker', 3, '12 cup programmable drip brewer', 59.99);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Nadiana Mokapot', 3, 'Stovetop espresso maker', 39.99);


  --Accessories
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Reusable Cotton Coffee Filters (Pack of 3)', 4, 'Eco friendly pour over filters', 14.99);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Milk Frother Wand', 4, 'Handheld frother for lattes/cappuccinos', 12.99);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Digital Coffee Scale', 4, 'Precision scale for pour over & espresso', 24.99);
INSERT product(productName, categoryId, productDesc, productPrice) VALUES ('Insulated Travel Mug', 4, 'Portable coffee tumbler', 29.99);


INSERT INTO warehouse(warehouseName) VALUES ('Main warehouse');
INSERT INTO productInventory(productId, warehouseId, quantity, price) VALUES (1, 1, 5, 18);
INSERT INTO productInventory(productId, warehouseId, quantity, price) VALUES (2, 1, 10, 19);
INSERT INTO productInventory(productId, warehouseId, quantity, price) VALUES (3, 1, 3, 10);

INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES ('Arnold', 'Anderson', 'a.anderson@gmail.com', '204 111 2222', '103 AnyWhere Street', 'Winnipeg', 'MB', 'R3X 45T', 'Canada', 'arnold' , '304Arnold!');
INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES ('Bobby', 'Brown', 'bobby.brown@hotmail.ca', '572 342 8911', '222 Bush Avenue', 'Boston', 'MA', '22222', 'United States', 'bobby' , '304Bobby!');
INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES ('Candace', 'Cole', 'cole@charity.org', '333 444 5555', '333 Central Crescent', 'Chicago', 'IL', '33333', 'United States', 'candace' , '304Candace!');
INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES ('Darren', 'Doe', 'oe@doe.com', '250 807 2222', '444 Dover Lane', 'Kelowna', 'BC', 'V1V 2X9', 'Canada', 'darren' , '304Darren!');
INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES ('Elizabeth', 'Elliott', 'engel@uiowa.edu', '555 666 7777', '555 Everwood Street', 'Iowa City', 'IA', '52241', 'United States', 'beth' , '304Beth!');


  Order 1 can be shipped as have enough inventory
DECLARE @orderId int
INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (1, '2019 10 15 10:25:55', 91.70)
SELECT @orderId = @@IDENTITY
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 1, 1, 18)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 5, 2, 21.35)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 10, 1, 31);

INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (2, '2019 10 16 18:00:00', 106.75)
SELECT @orderId = @@IDENTITY
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 5, 5, 21.35);

  Order 3 cannot be shipped as do not have enough inventory for item 7
INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (3, '2019 10 15 3:30:22', 140)
SELECT @orderId = @@IDENTITY
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 6, 2, 25)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 7, 3, 30);

INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (2, '2019 10 17 05:45:11', 327.85)
SELECT @orderId = @@IDENTITY
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 3, 4, 10)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 8, 3, 40)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 13, 3, 23.25)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 28, 2, 21.05)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 29, 4, 14);

INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (5, '2019 10 15 10:25:55', 277.40)
SELECT @orderId = @@IDENTITY
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 5, 4, 21.35)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 19, 2, 81)
INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (@orderId, 20, 3, 10);

  New SQL DDL 
UPDATE Product SET productImageURL = 'img/wholebeans.jpg' WHERE productId BETWEEN 1 AND 8;
UPDATE Product SET productImageURL = 'img/groundcoffee.jpg' WHERE productId BETWEEN 9 AND 16;
UPDATE Product SET productImageURL = 'img/singleshot.jpeg' WHERE productId = 17;
UPDATE Product SET productImageURL = 'img/doubleshot.jpeg' WHERE productId = 18;
UPDATE Product SET productImageURL = 'img/frenchpress.jpeg' WHERE productId = 19;
UPDATE Product SET productImageURL = 'img/drip.jpeg' WHERE productId = 20;
UPDATE Product SET productImageURL = 'img/mokapot.jpeg' WHERE productId = 21;
UPDATE Product SET productImageURL = 'img/filters.jpeg' WHERE productId = 22;
UPDATE Product SET productImageURL = 'img/frother.png' WHERE productId = 23;
UPDATE Product SET productImageURL = 'img/scale.png' WHERE productId = 24;
UPDATE Product SET productImageURL = 'img/travelmug.png' WHERE productId = 25;




