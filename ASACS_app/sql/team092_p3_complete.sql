DROP DATABASE IF EXISTS cs6400_sp17_team092;
CREATE DATABASE cs6400_sp17_team092;

USE cs6400_sp17_team092;

DROP TABLE IF EXISTS Users;
CREATE TABLE Users
(
  username varchar(250) NOT NULL PRIMARY KEY,
  email varchar(250) NOT NULL UNIQUE,
  password varchar(250) NOT NULL,
  firstname varchar(250) NOT NULL,
  lastname varchar(250) NOT NULL,
  siteid int(16) NOT NULL
);

DROP TABLE IF EXISTS Site;
CREATE TABLE Site
(
  siteid int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  sitename varchar(250) NOT NULL UNIQUE,
  phone varchar(250) NOT NULL,
  address1 varchar(250) NOT NULL,
  address2 varchar(250) NOT NULL,
  city varchar(250) NOT NULL,
  state varchar(250) NOT NULL,
  zip varchar(250) NOT NULL
);

DROP TABLE IF EXISTS Service;
CREATE TABLE Service
(
  serviceid int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  siteid int(16) NOT NULL
);

DROP TABLE IF EXISTS Shelter;
CREATE TABLE Shelter
(
  serviceid int(16) NOT NULL PRIMARY KEY,
  description varchar(250) NOT NULL
);

DROP TABLE IF EXISTS FoodPantry;
CREATE TABLE FoodPantry
(
  serviceid int(16) NOT NULL PRIMARY KEY,
  description varchar(250) NOT NULL
);

DROP TABLE IF EXISTS HoursOfOperation;
CREATE TABLE HoursOfOperation
(
  id int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  serviceid int(16) NOT NULL,
  day varchar(250) NOT NULL,
  open time NOT NULL,
  closed time NOT NULL
);

DROP TABLE IF EXISTS Conditions;
CREATE TABLE Conditions
(
  serviceid int(16) NOT NULL PRIMARY KEY,
  conditions varchar(250) NOT NULL
);

DROP TABLE IF EXISTS FamilyRoom;
CREATE TABLE FamilyRoom
(
  serviceid int(16) NOT NULL PRIMARY KEY,
  available int(16) NOT NULL DEFAULT 0,
  maxrooms int(16) NOT NULL DEFAULT 0
);

DROP TABLE IF EXISTS Waitlist;
CREATE TABLE Waitlist
(
  waitlistid int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  rankorder int(16) NOT NULL,
  clientid int(16) NOT NULL,
  serviceid int(16) NOT NULL
);

DROP TABLE IF EXISTS Bunks;
CREATE TABLE Bunks
(
  serviceid int(16) NOT NULL PRIMARY KEY,
  maleavailable int(16) NOT NULL DEFAULT 0,
  femaleavailable int(16) NOT NULL DEFAULT 0,
  mixavailable int(16) NOT NULL DEFAULT 0,
  malemax int(16) NOT NULL DEFAULT 0,
  femalemax int(16) NOT NULL DEFAULT 0,
  mixmax int(16) NOT NULL DEFAULT 0
);

DROP TABLE IF EXISTS SoupKitchen;
CREATE TABLE SoupKitchen
(
  serviceid int(16) NOT NULL PRIMARY KEY,
  seat int(16) NOT NULL DEFAULT 0,
  description varchar(250) NOT NULL
);

DROP TABLE IF EXISTS Items;
CREATE TABLE Items
(
  itemid int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name varchar(250) NOT NULL,
  expdate date NOT NULL,
  units int(16) NOT NULL,
  storagetype varchar(250) NOT NULL,
  serviceid int(16) NOT NULL,
  itemtypeid int(16) NOT NULL
);

DROP TABLE IF EXISTS ItemType;
CREATE TABLE ItemType
(
  itemtypeid int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  typename varchar(250) NOT NULL,
  isfood BOOLEAN NOT NULL
);

DROP TABLE IF EXISTS FoodBank;
CREATE TABLE FoodBank
(
  serviceid int(16) NOT NULL PRIMARY KEY
);

DROP TABLE IF EXISTS ItemRequests;
CREATE TABLE ItemRequests
(
  requestid int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  serviceidapproving int(16) NOT NULL,
  username varchar(250) NOT NULL,
  itemid int(16) NOT NULL,
  unitsrequested int(16) NOT NULL,
  unitsapproved int(16) DEFAULT NULL
);

DROP TABLE IF EXISTS Clients;
CREATE TABLE Clients
(
  clientid int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  firstname varchar(250) NOT NULL,
  lastname varchar(250) NOT NULL,
  phone varchar(250) NOT NULL,
  iddescription varchar(250) NOT NULL,
  headofhousehold BOOLEAN NOT NULL
);

DROP TABLE IF EXISTS ClientLog;
CREATE TABLE ClientLog
(
  clientlogid int(16) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  clientid int(16) NOT NULL,
  timestp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  siteid int(16) NOT NULL,
  description varchar(250) NOT NULL,
  username varchar(250) NOT NULL
);

-- Foreign Keys:
ALTER TABLE Users
	ADD CONSTRAINT fkUsersSiteID FOREIGN KEY(siteid) REFERENCES Site(siteid);

ALTER TABLE Service
	ADD CONSTRAINT fkServiceSiteID FOREIGN KEY(siteid) REFERENCES Site(siteid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Shelter
	ADD CONSTRAINT fkShelterServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE FoodPantry
	ADD CONSTRAINT fkFoodPantryServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE HoursOfOperation
	ADD CONSTRAINT fkHOOServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Conditions
	ADD CONSTRAINT fkConditionsServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE FamilyRoom
	ADD CONSTRAINT fkFamilyRoomServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Waitlist
	ADD CONSTRAINT fkWaitlistClientID FOREIGN KEY(clientid) REFERENCES Clients(clientid),
    ADD CONSTRAINT fkWaitlistServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Bunks
	ADD CONSTRAINT fkBunksServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE SoupKitchen
	ADD CONSTRAINT fkSoupKitchenServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE FoodBank
	ADD CONSTRAINT fkFoodBankServiceID FOREIGN KEY(serviceid) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Items
	ADD CONSTRAINT fkItemsServiceID FOREIGN KEY(serviceid) REFERENCES FoodBank(serviceid) ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fkItemsItemTypeID FOREIGN KEY(itemtypeid) REFERENCES ItemType(itemtypeid);

ALTER TABLE ItemRequests
	ADD CONSTRAINT fkItemReqUsername FOREIGN KEY(username) REFERENCES Users(username),
    ADD CONSTRAINT fkItemReqServiceIDApproving FOREIGN KEY(serviceidapproving) REFERENCES Service(serviceid) ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fkItemReqItemID FOREIGN KEY(itemid) REFERENCES Items(itemid) ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE ClientLog
	ADD CONSTRAINT fkClientLogClientID FOREIGN KEY(clientid) REFERENCES Clients(clientid),
	ADD CONSTRAINT fkClientLogSiteID FOREIGN KEY(siteid) REFERENCES Site(siteid) ON DELETE CASCADE ON UPDATE CASCADE,
	ADD CONSTRAINT fkClientLogUsername FOREIGN KEY(username) REFERENCES Users(username) ON DELETE NO ACTION ON UPDATE CASCADE;


-- Sites
INSERT INTO Site(sitename, phone, address1, address2, city, state, zip)
    VALUES ('site1', '770-111-1111', '123 street', '', 'Atlanta', 'GA', '300111');
INSERT INTO Site(sitename, phone, address1, address2, city, state, zip)
    VALUES ('site2', '770-222-2222', '22 Macon Street', 'Suite 200', 'Atlanta', 'GA', '300111');
INSERT INTO Site(sitename, phone, address1, address2, city, state, zip)
    VALUES ('site3', '770-333-3333', '333 Peachtree St', '', 'Atlanta', 'GA', '300111');

-- Users
INSERT INTO Users(username, email, password, firstname, lastname, siteid)
    VALUES ('emp1', 'emp1@gatech.edu', 'gatech123', 'Site1', 'Employee1', 1);
INSERT INTO Users(username, email, password, firstname, lastname, siteid)
    VALUES ('emp2', 'emp2@gatech.edu', 'gatech123', 'Site2', 'Employee2', 2);
INSERT INTO Users(username, email, password, firstname, lastname, siteid)
    VALUES ('emp3', 'emp3@gatech.edu', 'gatech123', 'Site3', 'Employee3', 3);
INSERT INTO Users(username, email, password, firstname, lastname, siteid)
    VALUES ('vol1', 'vol1@gatech.edu', 'gatech123', 'Site1', 'Volunteer1', 1);
INSERT INTO Users(username, email, password, firstname, lastname, siteid)
    VALUES ('vol2', 'vol2@gatech.edu', 'gatech123', 'Site2', 'Volunteer2', 2);
INSERT INTO Users(username, email, password, firstname, lastname, siteid)
    VALUES ('vol3', 'vol3@gatech.edu', 'gatech123', 'Site3', 'Volunteer3', 3);

-- Clients
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Joe', 'client1', '001-111-1111', '001', True);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Jane', 'client2', '002-111-1111', '002', True);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Joe', 'client3', '003-11-1111', '003', True);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Jane', 'client4', '004-111-1111', '004', True);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Joe', 'client5', '005-111-1111', '005', True);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Jane', 'client6', '006-111-1111', '006', True);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Joe', 'client7', '007-111-1111', '007', True);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Jane', 'client8', '008-111-1111', '008', True);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Joe', 'client9', '009-111-1111', '009', False);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Jane', 'client10', '010-111-1111', '010', False);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Joe', 'client11', '011-111-1111', '011', False);
INSERT INTO Clients(firstname, lastname, phone, iddescription, headofhousehold)
  VALUES ('Jane', 'client12', '012-111-1111', '012', False);

-- Services
------------
-- Site 1 - bank1, pantry1
INSERT INTO Service(siteid) VALUES (1);
INSERT INTO FoodBank(serviceid) VALUES(1);
INSERT INTO Service(siteid) VALUES (1);
INSERT INTO FoodPantry(serviceid, description) VALUES(2, 'pantry1');


-- Site 2 - pantry2, shelter2, bank2
INSERT INTO Service(siteid) VALUES (2);
INSERT INTO SoupKitchen(serviceid, description) VALUES(3, 'soup2');

INSERT INTO Service(siteid) VALUES (2);
INSERT INTO Shelter(serviceid, description) VALUES(4,'shelter2');

INSERT INTO Service(siteid) VALUES (2);
INSERT INTO FoodBank(serviceid) VALUES(5);

-- Site 3 - pantry3, soup3, shelter3, bank3
INSERT INTO Service(siteid) VALUES (3);
INSERT INTO FoodPantry(serviceid, description) VALUES(6, 'pantry3');

INSERT INTO Service(siteid) VALUES (3);
INSERT INTO Shelter(serviceid, description) VALUES(7,'shelter3');

INSERT INTO Service(siteid) VALUES (3);
INSERT INTO SoupKitchen(serviceid, seat, description) VALUES(8, 20, 'soup3');

INSERT INTO Service(siteid) VALUES (3);
INSERT INTO FoodBank(serviceid) VALUES(9);

-- Pantry 1 - Site 1 (serviceid = 2)
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (2, 'Monday', '11:00', '05:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (2, 'Tuesday', '11:00', '02:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (2, 'Wednesday', '11:00', '02:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (2, 'Thursday', '11:00', '02:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (2, 'Friday', '11:00', '02:00');
INSERT INTO Conditions(serviceid, conditions) VALUES (2, 'Conditions for Pantry 1');

-- Soup Kitchen 2 - Site 2 (serviceid = 3)
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (3, 'Monday', '11:00', '05:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (3, 'Tuesday', '11:00', '02:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (3, 'Wednesday', '11:00', '02:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (3, 'Thursday', '11:00', '02:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (3, 'Friday', '11:00', '02:00');
INSERT INTO Conditions(serviceid, conditions) VALUES (3, 'Conditions for Soup Kitchen 2');

-- Shelter 2 - Site 2 (serviceid = 4)
INSERT INTO Bunks(serviceid, maleavailable, femaleavailable, mixavailable, malemax, femalemax, mixmax)
    VALUES(4, 4,4,4, 4, 4, 4);
INSERT INTO FamilyRoom(serviceid, available, maxrooms) VALUES(4, 0, 10);
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (4, 'Monday', '11:00', '05:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (4, 'Tuesday', '11:00', '02:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (4, 'Wednesday', '11:00', '02:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (4, 'Friday', '11:00', '02:00');
INSERT INTO Waitlist(rankorder, clientid, serviceid) VALUES (1, 1, 4);
INSERT INTO Waitlist(rankorder, clientid, serviceid) VALUES (2, 4, 4);
INSERT INTO Waitlist(rankorder, clientid, serviceid) VALUES (3, 3, 4);
INSERT INTO Waitlist(rankorder, clientid, serviceid) VALUES (4, 2, 4);
INSERT INTO Conditions(serviceid, conditions) VALUES (4, 'Conditions for Shelter 2');

-- Pantry 3 - Site 3 (serviceid = 6)
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (6, 'Monday', '10:00', '08:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (6, 'Tuesday', '10:00', '08:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (6, 'Wednesday', '10:00', '08:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (6, 'Thursday', '10:00', '08:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (6, 'Friday', '10:00', '08:00');
INSERT INTO Conditions(serviceid, conditions) VALUES (6, 'Conditions for Pantry 3');

-- Shelter 3 - Site 3 (serviceid = 7)
INSERT INTO Bunks(serviceid, maleavailable, femaleavailable, mixavailable, malemax, femalemax, mixmax)
    VALUES(7, 4,4,4, 4, 4, 4);
INSERT INTO FamilyRoom(serviceid, available, maxrooms) VALUES(7, 0, 10);
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (7, 'Monday', '09:00', '05:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (7, 'Tuesday', '09:00', '07:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (7, 'Wednesday', '2:00', '06:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (7, 'Friday', '3:00', '09:00');
INSERT INTO Waitlist(rankorder, clientid, serviceid) VALUES (1, 1, 7);
INSERT INTO Waitlist(rankorder, clientid, serviceid) VALUES (2, 4, 7);
INSERT INTO Waitlist(rankorder, clientid, serviceid) VALUES (3, 3, 7);
INSERT INTO Waitlist(rankorder, clientid, serviceid) VALUES (4, 2, 7);
INSERT INTO Conditions(serviceid, conditions) VALUES (7, 'Conditions for Shelter 3');

-- Soup Kitchen 3 - Site 3 (serviceid = 8)
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (8, 'Monday', '10:00', '08:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (8, 'Tuesday', '10:00', '08:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (8, 'Wednesday', '10:00', '08:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (8, 'Thursday', '10:00', '08:00');
INSERT INTO HoursOfOperation(serviceid, day, open, closed) VALUES (8, 'Friday', '10:00', '08:00');
INSERT INTO Conditions(serviceid, conditions) VALUES (8, 'Conditions for Soup Kitchen 3');


-- Client Activity
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (1, 1, 'Profile Created', 'emp1');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (1, 1, 'Visit Pantry1', 'emp1');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (1, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (2, 1, 'Profile Created', 'emp1');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (2, 1, 'Visit Pantry1', 'emp1');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (2, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (3, 1, 'Profile Created', 'emp1');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (3, 1, 'Visit Pantry1', 'emp1');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (3, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (4, 1, 'Profile Created', 'emp1');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (4, 1, 'Visit Pantry1', 'emp1');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (4, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (5, 2, 'Profile Created', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (5, 2, 'Visit Soup2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (5, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (6, 2, 'Profile Created', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (6, 2, 'Visit Soup2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (6, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (7, 2, 'Profile Created', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (7, 2, 'Visit Soup2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (7, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (8, 2, 'Profile Created', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (8, 2, 'Visit Soup2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (8, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (9, 3, 'Profile Created', 'emp3');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (9, 3, 'Visit Soup3', 'emp3');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (9, 3, 'Vist Shelter3', 'emp3');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (10, 3, 'Profile Created', 'emp3');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (10, 3, 'Visit Soup3', 'emp3');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (10, 3, 'Vist Shelter3', 'emp3');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (11, 3, 'Profile Created', 'emp3');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (11, 2, 'Visit Soup2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (11, 2, 'Vist Shelter2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (12, 2, 'Profile Created', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (12, 2, 'Visit Soup2', 'emp2');
INSERT INTO ClientLog(clientid, siteid, description, username) VALUES (12, 3, 'Vist Pantry3', 'emp3');

-- Initialize ItemType
INSERT INTO ItemType(typename, isFood) VALUES ('Personal hygiene',0);
INSERT INTO ItemType(typename, isFood) VALUES ('Clothing',0);
INSERT INTO ItemType(typename, isFood) VALUES ('Shelter',0);
INSERT INTO ItemType(typename, isFood) VALUES ('Other',0);
INSERT INTO ItemType(typename, isFood) VALUES ('Vegetables',1);
INSERT INTO ItemType(typename, isFood) VALUES ('Nuts/Grains/Beans',1);
INSERT INTO ItemType(typename, isFood) VALUES ('Meat/Seafood',1);
INSERT INTO ItemType(typename, isFood) VALUES ('Dairy/Eggs',1);
INSERT INTO ItemType(typename, isFood) VALUES ('Sauce/Condiment/Seasoning',1);
INSERT INTO ItemType(typename, isFood) VALUES ('Juice/Drink',1);
-- Food Bank 1  - Site 1 (serviceid = 1)
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Dark Green Lettuce', concat(CURDATE() + INTERVAL 8 DAY), 50, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Dark Green Lettuce', concat(CURDATE() + INTERVAL 10 DAY), 40, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Dark Green Lettuce', concat(CURDATE() + INTERVAL 5 DAY), 70, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Romaine Lettuce', concat(CURDATE() + INTERVAL 10 DAY), 50, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Romaine Lettuce', concat(CURDATE() + INTERVAL 20 DAY), 30, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Green Leaf Lettuce', concat(CURDATE() + INTERVAL 8 DAY), 80, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Green Leaf Lettuce', concat(CURDATE() + INTERVAL 10 DAY), 60, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Green Leaf Lettuce', concat(CURDATE() + INTERVAL 5 DAY), 40, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Spinach', concat(CURDATE() + INTERVAL 5 DAY), 30, 'Refrigerated', 1, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Spinach', concat(CURDATE() + INTERVAL 10 DAY), 90, 'Refrigerated', 1, 5);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Almonds', concat(CURDATE() + INTERVAL 20 DAY), 5, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Almonds', concat(CURDATE() + INTERVAL 10 DAY), 4, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Pine Nuts', concat(CURDATE() + INTERVAL 11 DAY), 7, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Pine Nuts', concat(CURDATE() + INTERVAL 10 DAY), 5, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Peanuts', concat(CURDATE() + INTERVAL 4 DAY), 3, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Peanuts', concat(CURDATE() + INTERVAL 10 DAY), 8, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Walnuts', concat(CURDATE() + INTERVAL 22 DAY), 6, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Walnuts', concat(CURDATE() + INTERVAL 10 DAY), 4, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Brazil Nuts', concat(CURDATE() + INTERVAL 15 DAY), 3, 'Dry Good', 1, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Brazil Nuts', concat(CURDATE() + INTERVAL 10 DAY), 9, 'Dry Good', 1, 6);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mayonnaise', concat(CURDATE() + INTERVAL 1 DAY), 5, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mayonnaise', concat(CURDATE() + INTERVAL 10 DAY), 4, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mayonnaise', concat(CURDATE() + INTERVAL 22 DAY), 8, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mustard', concat(CURDATE() + INTERVAL 24 DAY), 3, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mustard', concat(CURDATE() + INTERVAL 10 DAY), 8, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mustard', concat(CURDATE() + INTERVAL 5 DAY), 4, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Ketchup', concat(CURDATE() + INTERVAL 30 DAY), 9, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Ketchup', concat(CURDATE() + INTERVAL 23 DAY), 6, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Ketchup', concat(CURDATE() + INTERVAL 14 DAY), 4, 'Dry Good', 1, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Ketchup', concat(CURDATE() + INTERVAL 10 DAY), 5, 'Dry Good', 1, 9);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Bottled Water', concat(CURDATE() + INTERVAL 10 DAY), 5, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Bottled Water', concat(CURDATE() + INTERVAL 11 DAY), 4, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Bottled Water', concat(CURDATE() + INTERVAL 2 DAY), 8, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Cold Brew Coffee', concat(CURDATE() + INTERVAL 4 DAY), 3, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Cold Brew Coffee', concat(CURDATE() + INTERVAL 3 DAY), 8, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Cold Brew Coffee', concat(CURDATE() + INTERVAL 10 DAY), 4, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Tea', concat(CURDATE() + INTERVAL 10 DAY), 9, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Tea', concat(CURDATE() + INTERVAL 9 DAY), 6, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Iced Tea', concat(CURDATE() + INTERVAL 10 DAY), 4, 'Refrigerated', 1, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Iced Tea', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 1, 10);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Chicken', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Chicken', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Chicken', concat(CURDATE() + INTERVAL 1 DAY), 8, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Turkey', concat(CURDATE() + INTERVAL 4 DAY), 3, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Turkey', concat(CURDATE() + INTERVAL 5 DAY), 8, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Turkey', concat(CURDATE() + INTERVAL 10 DAY), 4, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Beef', concat(CURDATE() + INTERVAL 4 DAY), 9, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Beef', concat(CURDATE() + INTERVAL 4 DAY), 6, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Lamb', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Frozen', 1, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Lamb', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Frozen', 1, 7);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Milk 2%', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Milk 2%', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Whole Milk', concat(CURDATE() + INTERVAL 4 DAY), 8, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Whole Milk', concat(CURDATE() + INTERVAL 4 DAY), 3, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Whole Milk', concat(CURDATE() + INTERVAL 3 DAY), 8, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Strawberry Yogurt', concat(CURDATE() + INTERVAL 6 DAY), 4, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Strawberry Yogurt', concat(CURDATE() + INTERVAL 4 DAY), 9, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Strawberry Yogurt', concat(CURDATE() + INTERVAL 20 DAY), 6, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Peach Yogurt', concat(CURDATE() + INTERVAL 1 DAY), 4, 'Refrigerated', 1, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Peach Yogurt', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 1, 8);


INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Toothbrush', '9999-01-01', 5, 'Dry Good', 1, 1);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Toothpaste', '9999-01-01', 4, 'Dry Good', 1, 1);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Shampoo', '9999-01-01', 8, 'Dry Good', 1, 1);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Deodorant', '9999-01-01', 3, 'Dry Good', 1, 1);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Soap', '9999-01-01', 5, 'Dry Good', 1, 1);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Sm Shirts', '9999-01-01', 5, 'Dry Good', 1, 2);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Lg Shirts', '9999-01-01', 8, 'Dry Good', 1, 2);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Sm Pants', '9999-01-01', 9, 'Dry Good', 1, 2);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Lg Pants', '9999-01-01', 4, 'Dry Good', 1, 2);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Underwear', '9999-01-01', 5, 'Dry Good', 1, 2);


-- Food Bank 2  - Site 2  (serviceid = 5)

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Carrot', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Carrot', concat(CURDATE() + INTERVAL 5 DAY), 4, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Carrot', concat(CURDATE() + INTERVAL 7 DAY), 7, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Parsnip', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Parsnip', concat(CURDATE() + INTERVAL 2 DAY), 3, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Turnip', concat(CURDATE() + INTERVAL 10 DAY), 8, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Turnip', concat(CURDATE() + INTERVAL 24 DAY), 6, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Celery', concat(CURDATE() + INTERVAL 14 DAY), 4, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Celery', concat(CURDATE() + INTERVAL 4 DAY), 3, 'Refrigerated', 5, 5);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Celery', concat(CURDATE() + INTERVAL 3 DAY), 9, 'Refrigerated', 5, 5);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Tortillas', concat(CURDATE() + INTERVAL 3 DAY), 5, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Tortillas', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Whole Grain Bread', concat(CURDATE() + INTERVAL 10 DAY), 7, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Whole Grain Bread', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Pasta', concat(CURDATE() + INTERVAL 10 DAY), 3, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Pasta', concat(CURDATE() + INTERVAL 4 DAY), 8, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('White Bread', concat(CURDATE() + INTERVAL 10 DAY), 6, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('White Bread', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Rye Bread', concat(CURDATE() + INTERVAL 10 DAY), 3, 'Dry Good', 5, 6);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Rye Bread', concat(CURDATE() + INTERVAL 4 DAY), 9, 'Dry Good', 5, 6);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mayonnaise', concat(CURDATE() + INTERVAL 5 DAY), 5, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mayonnaise', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mayonnaise', concat(CURDATE() + INTERVAL 4 DAY), 8, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mustard', concat(CURDATE() + INTERVAL 5 DAY), 3, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mustard', concat(CURDATE() + INTERVAL 4 DAY), 8, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Mustard', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Ketchup', concat(CURDATE() + INTERVAL 45 DAY), 9, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Ketchup', concat(CURDATE() + INTERVAL 4 DAY), 6, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Ketchup', concat(CURDATE() + INTERVAL 3 DAY), 4, 'Dry Good', 5, 9);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Ketchup', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Dry Good', 5, 9);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Grape Juice', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Grape Juice', concat(CURDATE() + INTERVAL 9 DAY), 4, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Grape Juice', concat(CURDATE() + INTERVAL 7 DAY), 8, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Orange Juice', concat(CURDATE() + INTERVAL 4 DAY), 3, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Orange Juice', concat(CURDATE() + INTERVAL 3 DAY), 8, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Orange Juice', concat(CURDATE() + INTERVAL 14 DAY), 4, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Apple Juice', concat(CURDATE() + INTERVAL 4 DAY), 9, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Apple Juice', concat(CURDATE() + INTERVAL 3 DAY), 6, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Apple Cider', concat(CURDATE() + INTERVAL 14 DAY), 4, 'Refrigerated', 5, 10);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Apple Cider', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 5, 10);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Salmon', concat(CURDATE() + INTERVAL 14 DAY), 5, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Salmon', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Tuna', concat(CURDATE() + INTERVAL 4 DAY), 8, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Tuna', concat(CURDATE() + INTERVAL 5 DAY), 3, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Trout', concat(CURDATE() + INTERVAL 4 DAY), 8, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Trout', concat(CURDATE() + INTERVAL 5 DAY), 4, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Bass', concat(CURDATE() + INTERVAL 8 DAY), 9, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Bass', concat(CURDATE() + INTERVAL 4 DAY), 6, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Lobsters', concat(CURDATE() + INTERVAL 2 DAY), 4, 'Frozen', 5, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Lobsters', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Frozen', 5, 7);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Extra Large Eggs', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Extra Large Eggs', concat(CURDATE() + INTERVAL 5 DAY), 4, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Large Eggs', concat(CURDATE() + INTERVAL 3 DAY), 8, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Large Eggs', concat(CURDATE() + INTERVAL 4 DAY), 3, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Organic Eggs', concat(CURDATE() + INTERVAL 22 DAY), 8, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Organic Eggs', concat(CURDATE() + INTERVAL 4 DAY), 4, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Liquid Eggs', concat(CURDATE() + INTERVAL 14 DAY), 9, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Liquid Eggs', concat(CURDATE() + INTERVAL 4 DAY), 6, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Liquid Eggs Whites', concat(CURDATE() + INTERVAL 5 DAY), 4, 'Refrigerated', 5, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Liquid Eggs Whites', concat(CURDATE() + INTERVAL 4 DAY), 5, 'Refrigerated', 5, 8);


INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Tent', '9999-01-01', 5, 'Dry Good', 5, 3);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Sleeping Bags', '9999-01-01', 4, 'Dry Good', 5, 3);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Blankets', '9999-01-01', 8, 'Dry Good', 5, 3);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Rain Coat', '9999-01-01', 3, 'Dry Good', 5, 3);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Winter Jacket', '9999-01-01', 5, 'Dry Good', 5, 3);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Toilet Paper', '9999-01-01', 5, 'Dry Good', 5, 4);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Pet Food', '9999-01-01', 8, 'Dry Good', 5, 4);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Batteries', '9999-01-01', 9, 'Dry Good', 5, 4);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Pen', '9999-01-01', 4, 'Dry Good', 5, 4);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid)  VALUES ('Paper', '9999-01-01', 5, 'Dry Good', 5, 4);


-- Food Bank 3  - Site 3 (serviceid = 9)
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Chicken', concat(CURDATE() - INTERVAL 10 DAY), 5, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Chicken', concat(CURDATE() - INTERVAL 10 DAY), 4, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Chicken', concat(CURDATE() - INTERVAL 10 DAY), 8, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Turkey', concat(CURDATE() - INTERVAL 10 DAY), 3, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Turkey', concat(CURDATE() - INTERVAL 10 DAY), 8, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Turkey', concat(CURDATE() - INTERVAL 10 DAY), 4, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Beef', concat(CURDATE() - INTERVAL 10 DAY), 9, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Beef', concat(CURDATE() - INTERVAL 10 DAY), 6, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Lamb', concat(CURDATE() - INTERVAL 10 DAY), 4, 'Frozen', 9, 7);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Lamb', concat(CURDATE() - INTERVAL 10 DAY), 5, 'Frozen', 9, 7);

INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Milk 2%', concat(CURDATE() - INTERVAL 10 DAY), 5, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Milk 2%', concat(CURDATE() - INTERVAL 10 DAY), 4, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Whole Milk', concat(CURDATE() - INTERVAL 10 DAY), 8, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Whole Milk', concat(CURDATE() - INTERVAL 4 DAY), 3, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Whole Milk', concat(CURDATE() - INTERVAL 10 DAY), 8, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Strawberry Yogurt', concat(CURDATE() - INTERVAL 10 DAY), 4, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Strawberry Yogurt', concat(CURDATE() - INTERVAL 3 DAY), 9, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Strawberry Yogurt', concat(CURDATE() - INTERVAL 11 DAY), 6, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Peach Yogurt', concat(CURDATE() - INTERVAL 10 DAY), 4, 'Refrigerated', 9, 8);
INSERT INTO Items(name, expdate, units, storagetype, serviceid, itemtypeid) VALUES ('Peach Yogurt', concat(CURDATE() - INTERVAL 11 DAY), 5, 'Refrigerated', 9, 8);

-- Item Requests emp1
-- Food requests to site 2
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 71, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 74, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 80, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 83, 7);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 85, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 89, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 99, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 107, 7);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 109, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 120, 5);
-- food requests to site 3
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'emp1', 141, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'emp1', 142, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'emp1', 145, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'emp1', 150, 5);
-- closed requests
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'emp1', 71, 5, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'emp1', 72, 5, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'emp1', 73, 5, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(9, 'emp1', 141, 5, 5);


-- Item Requests emp2
-- Food requests to site 1
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 1, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 4, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 9, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 11, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 13, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 17, 6);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 42, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 50, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 41, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 56, 2);
-- food requests to site 3
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'emp2', 151, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'emp2', 157, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'emp2', 160, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'emp2', 159, 4);
-- supply requests to site 1
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 61, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 62, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 63, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 64, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 65, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 66, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 67, 1);
-- closed requests
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(1, 'emp2', 71, 1, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(1, 'emp2', 73, 2, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(9, 'emp2', 151, 5, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(9, 'emp2', 157, 3, 1);


-- Item Requests emp3
-- food requests to site 1
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 2, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 9, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 29, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 31, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 40, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 41, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 44, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 47, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 48, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 50, 5);
-- food requests to site 2
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 121, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 125, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 127, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 129, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 111, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 112, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 113, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 114, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 115, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 116, 2);
-- supply request to site 1
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 70, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 69, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 68, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 67, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 66, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 65, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 64, 4);
-- supply request to site 2
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 131, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 132, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 133, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 134, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 135, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 136, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp3', 137, 8);
-- closed requests
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(1, 'emp3', 2, 1, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(1, 'emp3', 3, 1, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'emp3', 131, 1, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'emp3', 132, 5, 3);

-- Item Requests vol1
-- Food requests to site 2
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 71, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 74, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 80, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 83, 7);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 85, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 89, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 99, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 107, 7);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 109, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol1', 120, 5);
-- food requests to site 3
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'vol1', 141, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'vol1', 142, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'vol1', 145, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'vol1', 150, 5);
-- closed requests
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'vol1', 71, 5, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'vol1', 72, 5, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'vol1', 73, 5, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(9, 'vol1', 141, 5, 5);


-- Item Requests vol2
-- Food requests to site 1
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 1, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 4, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 9, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 11, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 13, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 17, 6);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 42, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 50, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 41, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 56, 2);
-- food requests to site 3
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'vol2', 151, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'vol2', 157, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'vol2', 160, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(9, 'vol2', 159, 4);
-- supply requests to site 1
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 61, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 62, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 63, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 64, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 65, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 66, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol2', 67, 1);
-- closed requests
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(1, 'vol2', 71, 1, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(1, 'vol2', 73, 2, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(9, 'vol2', 151, 5, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(9, 'vol2', 157, 3, 1);


-- Item Requests vol3
-- food requests to site 1
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 2, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 9, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 29, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 31, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 40, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 41, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 44, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 47, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 48, 2);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 50, 5);
-- food requests to site 2
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 121, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 125, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 127, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 129, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 111, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 112, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 113, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 114, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 115, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 116, 2);
-- supply request to site 1
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 70, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 69, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 68, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 67, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 66, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 65, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'vol3', 64, 4);
-- supply request to site 2
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 131, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 132, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 133, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 134, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 135, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 136, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'vol3', 137, 8);
-- closed requests
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(1, 'vol3', 2, 1, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(1, 'vol3', 3, 1, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'vol3', 131, 1, 1);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'vol3', 132, 5, 3);

-- 5-10 extra requests
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 113, 8);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 57, 9);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp2', 58, 6);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(5, 'emp1', 114, 3);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested) VALUES(1, 'emp3', 58, 6);

INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'emp1', 113, 5, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'emp1', 114, 5, 4);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'emp1', 115, 5, 5);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'vol1', 116, 5, 0);
INSERT INTO ItemRequests(serviceidapproving, username, itemid, unitsrequested, unitsapproved) VALUES(5, 'vol1', 117, 5, 2);

SET GLOBAL sql_mode = '';

DROP TRIGGER IF EXISTS updateItemsUpdateRequest;
DELIMITER $$
CREATE TRIGGER updateItemsUpdateRequest

AFTER UPDATE ON Items FOR EACH ROW
BEGIN
	IF NEW.units = 0 THEN
		UPDATE ItemRequests SET ItemRequests.unitsapproved = 0 WHERE ItemRequests.unitsapproved IS NULL AND ItemRequests.itemid = OLD.itemid;
	END IF;
END$$
DELIMITER ;