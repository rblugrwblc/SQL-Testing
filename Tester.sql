-- RESET
DROP TABLE IF EXISTS Crew_Assignment;
DROP TABLE IF EXISTS Flight_Assignment;
DROP TABLE IF EXISTS Crew;
DROP TABLE IF EXISTS Inclusion;
DROP TABLE IF EXISTS Additional_Item;
DROP TABLE IF EXISTS Flight_Booking;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Passenger;
DROP TABLE IF EXISTS Schedule;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS Flight_Routes;
DROP TABLE IF EXISTS Airport;
DROP DATABASE IF EXISTS MAGIS_AIR;

CREATE DATABASE MAGIS_AIR;
USE MAGIS_AIR;

CREATE TABLE Airport (
    Airport_ID VARCHAR(3) PRIMARY KEY,
    City VARCHAR(50) NOT NULL, 
    Country VARCHAR(50) NOT NULL
);

CREATE TABLE Flight_Routes (
    Route_ID INT PRIMARY KEY AUTO_INCREMENT,
    origin_Airport VARCHAR(3) NOT NULL,
    destination_Airport VARCHAR(3) NOT NULL,
    FOREIGN KEY (origin_Airport) REFERENCES Airport(Airport_ID),
    FOREIGN KEY (destination_Airport) REFERENCES Airport(Airport_ID)
);

CREATE TABLE Flight (
    Flight_ID VARCHAR(6) PRIMARY KEY NOT NULL,  
    Arrival_Time TIME NOT NULL, 
    Departure_Time TIME NOT NULL,

    -- https://stackoverflow.com/questions/79436842/return-time-difference-in-the-format-hhmmss-in-sql  
    Duration TIME GENERATED ALWAYS AS (
        CASE 
            WHEN TIMEDIFF(Arrival_Time, Departure_Time) < 0 
                THEN ADDTIME(TIMEDIFF(Arrival_Time, Departure_Time), '24:00:00')
            ELSE TIMEDIFF(Arrival_Time, Departure_Time)
        END
    ) VIRTUAL,

    Base_Cost DECIMAL(10, 2) NOT NULL,
    Route_ID INT NOT NULL,

    FOREIGN KEY (Route_ID) REFERENCES Flight_Routes(Route_ID)
);

CREATE TABLE Schedule (
    Schedule_ID INT PRIMARY KEY AUTO_INCREMENT,
    Flight_ID VARCHAR(6) NOT NULL,
    Date_of_Flight DATE NOT NULL,
    FOREIGN KEY (Flight_ID) REFERENCES Flight(Flight_ID)
);

-- Populate Flight Routes --  

INSERT AIRPORT (Airport_ID, City, Country)
VALUES ("SIN", "Changi", "Singapore"); 

INSERT AIRPORT (Airport_ID, City, Country)
VALUES ("MNL", "Manila", "Philippines"); 

-- route id 1 
INSERT INTO FLIGHT_ROUTES(origin_Airport, destination_Airport)
VALUES("SIN", "MNL");

-- route id 2
INSERT INTO FLIGHT_ROUTES(origin_Airport, destination_Airport)
VALUES("MNL", "SIN");

-- MA 800 = SIN -> MNL
INSERT INTO FLIGHT(Flight_ID, Arrival_Time, Departure_Time, Base_Cost, Route_ID)
VALUES("MA 800", "04:00:00", "00:45:00", 4276.00, 1);

-- MA 801 = MNL -> SIN
INSERT INTO FLIGHT(Flight_ID, Arrival_Time, Departure_Time, Base_Cost, Route_ID)
VALUES("MA 801", "23:55:00", "20:25:00", 2088.00, 2);

-- MA 801 happens on dec 23
INSERT INTO SCHEDULE(Schedule_ID, Flight_ID, Date_of_Flight) 
VALUES (2025120001, "MA 801", "2025-12-23"); 

-- MA 800 happens on dec 24
-- PK: 2025120002
INSERT INTO SCHEDULE(Flight_ID, Date_of_Flight) 
VALUES ("MA 800", "2025-12-25"); 

-- check if populated correctly -- 
SELECT * FROM AIRPORT; 
SELECT * FROM FLIGHT_ROUTES; 
SELECT * FROM FLIGHT; 
SELECT * FROM SCHEDULE; 

-- Flight Booking -- 
CREATE TABLE Passenger (
    Passenger_ID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    Last_Name VARCHAR(50) NOT NULL,
    First_Name VARCHAR(50) NOT NULL,
    Middle_Initial CHAR(2),
    Gender VARCHAR(10),
    Date_of_Birth DATE NOT NULL
);

CREATE TABLE Booking (
    Booking_ID INT PRIMARY KEY AUTO_INCREMENT,
    Passenger_ID INT NOT NULL,
    Date_of_Booking DATE NOT NULL DEFAULT (CURRENT_DATE),    
    FOREIGN KEY (Passenger_ID) REFERENCES Passenger(Passenger_ID)
);

CREATE TABLE Flight_Booking (
    Booking_ID INT,
    Schedule_ID INT,
    PRIMARY KEY (Booking_ID, Schedule_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Booking(Booking_ID),
    FOREIGN KEY (Schedule_ID) REFERENCES Schedule(Schedule_ID)
);

CREATE TABLE Additional_Item (
    Item_ID INT PRIMARY KEY AUTO_INCREMENT,
    Description VARCHAR(50) NOT NULL, 
    Cost DECIMAL(10, 2) NULL
);

CREATE TABLE Inclusion (
    Booking_ID INT,
    Item_ID INT,
    Quantity DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (Booking_ID, Item_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Booking(Booking_ID),
    FOREIGN KEY (Item_ID) REFERENCES Additional_Item(Item_ID)
);

-- insert into flight booking 
INSERT INTO Passenger(Last_Name, First_Name, Middle_Initial, Gender, Date_of_Birth)
VALUES ("Carlito", "Francisco", "P", "Male", "2025-12-21"); 

INSERT INTO Booking(Passenger_ID)
VALUES (1); 

INSERT INTO Flight_Booking(Booking_ID, Schedule_ID)
VALUES(1, 2025120001); 

INSERT INTO Flight_Booking(Booking_ID, Schedule_ID)
VALUES(1, 2025120002); 

INSERT INTO Additional_Item(Description, Cost)
VALUES("Additional Baggage Allownace (5kg)", 474.00); 

INSERT INTO Additional_Item(Description, Cost)
VALUES("Terminal Fees", 273); 

INSERT INTO Additional_Item(Description, Cost)
VALUES("Travel Insurance", 208); 

INSERT INTO INCLUSION(Booking_ID, Item_ID, Quantity)
VALUES(1, 1, 2); 

INSERT INTO INCLUSION(Booking_ID, Item_ID, Quantity)
VALUES(1, 2, 1); 

INSERT INTO INCLUSION(Booking_ID, Item_ID, Quantity)
VALUES(1, 3, 1); 

-- check insertion values -- 
SELECT * FROM PASSENGER; 
SELECT * FROM BOOKING; 
SELECT * FROM Flight_Booking;
SELECT * FROM Additional_Item; 
SELECT * FROM Inclusion; 

-- == i got too lazy to test crew assignment :( --