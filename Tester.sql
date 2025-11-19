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
VALUES ("TOY", "Tokyo", "Japan"); 

INSERT AIRPORT (Airport_ID, City, Country)
VALUES ("MNL", "Manila", "Philippines"); 

INSERT INTO FLIGHT_ROUTES(origin_Airport, destination_Airport)
VALUES("TOY", "MNL");

INSERT INTO FLIGHT(Flight_ID, Arrival_Time, Departure_Time, Base_Cost, Route_ID)
VALUES("MA 800", "2:30:00", "23:00:00", 1000.50, 1);

INSERT INTO SCHEDULE(Schedule_ID, Flight_ID, Date_of_Flight) 
VALUES (2025110001, "MA 800", "2026-01-01"); 

INSERT INTO SCHEDULE(Flight_ID, Date_of_Flight)
VALUES ("MA 800", "2026-01-02");

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
    Booking_ID INT PRIMARY KEY AUTO_INCREMENT=1000,
    Passenger_ID INT NOT NULL,
    Date_of_Booking TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Cost DECIMAL(10, 2) NOT NULL,
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
    Description VARCHAR(50) NOT NULL
);

CREATE TABLE Inclusion (
    Booking_ID INT,
    Item_ID INT,
    Cost DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (Booking_ID, Item_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Booking(Booking_ID),
    FOREIGN KEY (Item_ID) REFERENCES Additional_Item(Item_ID)
);

INSERT INTO Passenger(Last_Name, First_Name, Middle_Initial, Gender, Date_of_Birth)
VALUES ("Carlito", "Francisco", "P", "Male", "12-21-2025"); 

INSERT INTO BOOKING(Date_of_Booking)
VALUES ("Date_of_Booking")

