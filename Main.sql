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

------------------------------------------------------------
-- Airport
-- PK Format:    AAA 
    -- valid 3-letter IATA airport code
-- Example: MNL, CEB, HKG
------------------------------------------------------------
CREATE TABLE Airport (
    Airport_ID VARCHAR(3) PRIMARY KEY,
    City VARCHAR(50) NOT NULL, 
    Country VARCHAR(50) NOT NULL
);

------------------------------------------------------------
-- Flight Routes
-- PK Format:    XXXX
    -- Auto-Incrementing Route Numbers
-- Example: 1, 2, 3...
------------------------------------------------------------
CREATE TABLE Flight_Routes (
    Route_ID INT PRIMARY KEY AUTO_INCREMENT,
    origin_Airport VARCHAR(3) NOT NULL,
    destination_Airport VARCHAR(3) NOT NULL,

    FOREIGN KEY (origin_Airport) REFERENCES Airport(Airport_ID),
    FOREIGN KEY (destination_Airport) REFERENCES Airport(Airport_ID)
);

------------------------------------------------------------
-- Flight
-- PK Format:    MA XXXX
    -- MA:  denotes "Magis Air"
    -- XXX: denotes a unique identifying aircraft number 
-- Example: MA 017, MA 800, MA 167
-- Notes: 
    -- Duration takes into account if overlfow in time 
------------------------------------------------------------
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

------------------------------------------------------------
-- Schedule
-- PK Format:    YYYYMMZZZZZ
    -- YYYY: current year
    -- MM:   current month 
    -- ZZZZZ: identifying sequence of numbers (auto incremented)  
-- Example: 20250100001, 20250100002, 20250100067, 20250100068
------------------------------------------------------------
CREATE TABLE Schedule (
    Schedule_ID INT PRIMARY KEY AUTO_INCREMENT,
    Flight_ID VARCHAR(6) NOT NULL,
    Date_of_Flight DATE NOT NULL,
    FOREIGN KEY (Flight_ID) REFERENCES Flight(Flight_ID)
);

------------------------------------------------------------
-- Passenger
-- PK Format:   XXX
    -- XXX:  identifying sequence of numbers (Auto Incrementing) 
-- Example: 001, 002, 003, 067 
------------------------------------------------------------
CREATE TABLE Passenger (
    Passenger_ID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    Last_Name VARCHAR(50) NOT NULL,
    First_Name VARCHAR(50) NOT NULL,
    Middle_Initial CHAR(2),
    Gender VARCHAR(10),
    Date_of_Birth DATE NOT NULL
);

------------------------------------------------------------
-- Booking
-- PK Format:    XXXX
--   XXXX: identifying sequence of numbers (Auto Incrementing)
-- Example: 1000, 1067, 2032, 1088
------------------------------------------------------------
CREATE TABLE Booking (
    Booking_ID INT PRIMARY KEY AUTO_INCREMENT,
    Passenger_ID INT NOT NULL,
    Date_of_Booking DATE NOT NULL DEFAULT (CURRENT_DATE),    
    FOREIGN KEY (Passenger_ID) REFERENCES Passenger(Passenger_ID)
);

------------------------------------------------------------
-- Flight Booking (Join Table)
-- Composite Key: (Booking_ID, Schedule_ID)
------------------------------------------------------------
CREATE TABLE Flight_Booking (
    Booking_ID INT,
    Schedule_ID INT,
    PRIMARY KEY (Booking_ID, Schedule_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Booking(Booking_ID),
    FOREIGN KEY (Schedule_ID) REFERENCES Schedule(Schedule_ID)
);

------------------------------------------------------------
-- Additional Item
-- PK Format:    XXX
    -- XXX: identifying sequence of numbers (Auto Incrementing)
-- Example: 001, 002, 003, 067
------------------------------------------------------------
CREATE TABLE Additional_Item (
    Item_ID INT PRIMARY KEY AUTO_INCREMENT,
    Description VARCHAR(50) NOT NULL, 
    Cost DECIMAL(10, 2) NULL
);

------------------------------------------------------------
-- Inclusion (Join Table)
-- Composite Key: (Booking_ID, Item_ID)
------------------------------------------------------------
CREATE TABLE Inclusion (
    Booking_ID INT,
    Item_ID INT,
    Quantity DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (Booking_ID, Item_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Booking(Booking_ID),
    FOREIGN KEY (Item_ID) REFERENCES Additional_Item(Item_ID)
);

------------------------------------------------------------
-- Crew
-- PK Format:  XXX
    -- XXX: identifying sequence of numbers (Auto Incrementing) 
-- Example: 001, 002, 067, 235
------------------------------------------------------------
CREATE TABLE Crew ( 
    Crew_ID INT PRIMARY KEY AUTO_INCREMENT,
    Last_Name VARCHAR(50) NOT NULL,
    First_Name VARCHAR(50) NOT NULL,
    Role VARCHAR(50) NOT NULL
);

------------------------------------------------------------
-- Flight Assignment
-- PK FORMAT: XXX
    -- XXX: identifying sequence of numbers (Auto Incrementing) 
-- Example: 067, 235, 729, 1092
------------------------------------------------------------
CREATE TABLE Assignment (
    Assignment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Schedule_ID INT NOT NULL, -- should this be FLIGHT_ID?
    Date_of_Departure TIMESTAMP NOT NULL,
    FOREIGN KEY (Schedule_ID) REFERENCES Schedule(Schedule_ID)
);

------------------------------------------------------------
-- Crew Assignment (Join Table)
-- Composite Key: (Crew_ID, Assignment_ID)
------------------------------------------------------------
CREATE TABLE Crew_Assignment (
    Crew_ID INT,
    Assignment_ID INT,
    PRIMARY KEY (Crew_ID, Assignment_ID),
    FOREIGN KEY (Crew_ID) REFERENCES Crew(Crew_ID),
    FOREIGN KEY (Assignment_ID) REFERENCES Flight_Assignment(Assignment_ID)
);