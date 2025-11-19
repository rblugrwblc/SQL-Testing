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

------------------------------------------------------------
-- Schedule
-- PK Format:    YYYYMMZZZZ
    -- YYYY: current year
    -- MM:   current month 
    -- ZZZZ: identifying sequence of numbers (auto incremented)  
-- Example: 2025010001, 2025010002, 2025010067, 2025010068
------------------------------------------------------------
CREATE TABLE Schedule (
    Schedule_ID INT PRIMARY KEY AUTO_INCREMENT,
    Flight_ID VARCHAR(6) NOT NULL,
    Date_of_Flight DATE NOT NULL,
    FOREIGN KEY (Flight_ID) REFERENCES Flight(Flight_ID)
);

-- populate airport and flight routes -- 

INSERT AIRPORT (Airport_ID, City, Country)
VALUES ("TOY", "Tokyo", "Japan"); 

INSERT AIRPORT (Airport_ID, City, Country)
VALUES ("MNL", "Manila", "Philippines"); 

INSERT INTO FLIGHT_ROUTES(origin_Airport, destination_Airport)
VALUES("TOY", "MNL");

INSERT INTO FLIGHT(Flight_ID, Arrival_Time, Departure_Time, Base_Cost, Route_ID)
VALUES("MA 800", "2:30:00", "23:00:00", 1000.50, 1);

-- check if populated correctly -- 
SELECT * FROM AIRPORT; 
SELECT * FROM FLIGHT_ROUTES; 
SELECT * FROM FLIGHT; 



INSERT INTO SCHEDULE(Schedule_ID, Flight_ID, Date_of_Flight) 
VALUES (2025110001, "MA 800", "2026-01-01"); 

INSERT INTO SCHEDULE(Flight_ID, Date_of_Flight)
VALUES ("MA 800", "2026-01-02");

INSERT INTO SCHEDULE(Schedule_ID, Flight_ID, Date_of_Flight)
Values(2025120001, "MA 800", "2026-03-01");

INSERT INTO SCHEDULE(Flight_ID, Date_of_Flight)
VALUES ("MA 800", "2026-03-02");