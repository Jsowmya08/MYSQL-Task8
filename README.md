-- 1) Pack table
CREATE TABLE IF NOT EXISTS Pack (   //start defination of new table
    pack_id INT AUTO_INCREMENT PRIMARY KEY,   //pack_id will be auto incremented 
    pack_name VARCHAR(50) NOT NULL  // pack_name should not be null
);

-- 2) User table
CREATE TABLE IF NOT EXISTS User (   //start defination of new table
    user_id INT AUTO_INCREMENT PRIMARY KEY,  //user_id is an interger column
    full_name VARCHAR(100) NOT NULL,  //full_name should not be null
    pack_id INT,  // pack_id should be interger
    mobile_id INT,  //mobile_id should be integer
    FOREIGN KEY (pack_id) REFERENCES Pack(pack_id)  //pack_id must match an existing pack_id in Pack. This enforces referential integrity for pack membership.
);

-- 3) Mobile table
CREATE TABLE IF NOT EXISTS Mobile (   // starts defination of new table
    mobile_id INT AUTO_INCREMENT PRIMARY KEY, //mobile_id is the auto-increment primary key for mobiles.
    user_id INT,  //intended to refer back to the user who owns the mobile.
    mobile_number VARCHAR(15),  //mobile_number up to 15 characters; comment clarifies purpose. VARCHAR(15) accommodates country codes or formatting; it does not enforce numeric-only data.
    FOREIGN KEY (user_id) REFERENCES User(user_id)  //Adds a foreign key constraint: user_id in Mobile must exist in User.user_id. This creates a referential link from mobile
);

/* inserting rows into Pack*/
INSERT INTO Pack (pack_name) VALUES
('Mobile'),
('Super'),
('Premium'),
('Free');    -- Added Free pack for Sowmya


/*Inserting rows into User*/
INSERT INTO User (full_name, pack_id, mobile_id) VALUES
('Rajesh', 1, NULL),
('Varun',  3, NULL),
('Saikiran', 2, NULL);


/*Inserting rows into Mobile*/
INSERT INTO Mobile (user_id, mobile_number) VALUES
(1, '9999999999'),  -- Rajesh’s number (placeholder)
(2, '8888888888'),  -- Varun’s number
(3, '7777777777');  -- Saikiran’s number

SELECT * FROM Pack;  //useful to verify inserted pack rows and their pack_id values.
SELECT * FROM User;  //Show current User table rows.
SELECT * FROM Mobile;  //Show Mobile table rows.


UPDATE User SET mobile_id = 1 WHERE user_id = 1;  //Set User.mobile_id = 1 for user_id = 1. This links Rajesh's mobile_id to the Mobile row with mobile_id = 1.
UPDATE User SET mobile_id = 2 WHERE user_id = 2;  //Link Varun (user_id = 2) to mobile_id = 2.
UPDATE User SET mobile_id = 3 WHERE user_id = 3;  //Link Saikiran to mobile_id = 3.

CREATE OR REPLACE VIEW UserDetails AS   //Create a view named UserDetails or replace it if it already exists. A view is a stored
SELECT     //it updates automatically when underlying tables change.
    u.user_id AS userId,  //exposes user_id named userId.
    u.full_name AS userName,  //user name
    m.mobile_number AS mobileNumber,  //mobile number from Mobile.
    p.pack_name AS packName   //pack name.
FROM User u  // uses alias u.
JOIN Pack p ON u.pack_id = p.pack_id  //p.pck_id is an INNER JOIN — only users with a matching pack will appear.
JOIN Mobile m ON u.mobile_id = m.mobile_id;  //JOIN Mobile m ON u.mobile_id = m.mobile_id is also an INNER JOIN — users without a mobile_id or with no matching mobile row will be excluded. If you want to include users even when mobile is missing, use LEFT JOIN Mobile m ....

DELIMITER $$

/*Changes the client delimiter to $$ so you can use ; inside the stored procedure body without ending the CREATE PROCEDURE prematurely. This is required in MySQL CLI/scripts when defining procedures/functions.*/


/*Start creating a stored procedure named UpdateRajeshAndAddSowmya that accepts an input parameter newNumber (VARCHAR 15). BEGIN starts the procedure body.*/

CREATE PROCEDURE UpdateRajeshAndAddSowmya(  
    IN newNumber VARCHAR(15)
)
BEGIN
    -- 1. Declare variables first
    DECLARE freePackId INT;   //freePackId will hold the pack_id for the 'Free' pack.
    DECLARE sowmyaUserId INT;  //sowmyaUserId will hold the newly inserted Sowmya's user_id.

    -- 2. Get Free Pack ID

    /*Selects the pack_id of the pack with name 'Free' and stores it into freePackId.If no row matches, freePackId becomes NULL.If multiple rows match, this will produce an error (“subquery returned more than 1 row”). 
    Safer to use LIMIT 1 or ensure pack_name is UNIQUE.*/
    
    SELECT pack_id INTO freePackId FROM Pack WHERE pack_name = 'Free';  

    -- 3. Update Rajesh’s mobile number

    /*Updates the mobile_number in Mobile for the mobile row whose user_id equals the user_id of the user named 'Rajesh'.
    If multiple Users named 'Rajesh' exist, the subquery may return more than one row → error.If Rajesh does not exist, the WHERE compares to NULL and nothing updates.
    Alternative safer approach: UPDATE Mobile m JOIN User u ON m.user_id = u.user_id SET m.mobile_number = newNumber WHERE u.full_name = 'Rajesh';*/
    
    UPDATE Mobile
    SET mobile_number = newNumber
    WHERE user_id = (SELECT user_id FROM User WHERE full_name = 'Rajesh');

    -- 4. Insert Sowmya with Free pack

    /*Inserts a new user row with full_name='Sowmya', pack_id set from freePackId, and mobile_id = NULL (mobile will be added next).*/
    
    INSERT INTO User (full_name, pack_id, mobile_id)
    VALUES ('Sowmya', freePackId, NULL);

    -- 5. Get Sowmya's user_id

    /*Retrieves user_id for the user named 'Sowmya' into sowmyaUserId.If there are multiple Sowmya rows, the SELECT returns multiple rows → error.
    Safer approaches:Immediately after INSERT use SET sowmyaUserId = LAST_INSERT_ID(); (gives the auto-generated user_id for this session).
    Or SELECT user_id INTO ... FROM User WHERE full_name='Sowmya' ORDER BY user_id DESC LIMIT 1;*/
    
    SELECT user_id INTO sowmyaUserId FROM User WHERE full_name = 'Sowmya';

    -- 6. Insert Sowmya's mobile number

    /*Inserts a Mobile row for Sowmya, linking by user_id and storing the number '6666666666'.*/
    
    INSERT INTO Mobile (user_id, mobile_number)
    VALUES (sowmyaUserId, '6666666666');

    -- 7. Link Sowmya's mobile_id to User table

    /*Updates the User row for Sowmya to set mobile_id to the mobile_id that was just inserted in Mobile. Assumes the subquery returns a single mobile_id row.*/
    UPDATE User
    SET mobile_id = (SELECT mobile_id FROM Mobile WHERE user_id = sowmyaUserId)
    WHERE user_id = sowmyaUserId;

END $$  //Ends the procedure body. The $$ terminator matches DELIMITER $$ used earlier.

DELIMITER ;  //Resets the delimiter back to the default.

/*Executes the stored procedure, passing '9999912345' as newNumber. Effects:
Rajesh’s Mobile.mobile_number will be updated to 9999912345 (if Rajesh exists and mobile row exists).
A new User named Sowmya is inserted, she gets the Free pack, a mobile row 6666666666 is inserted for her, and her user.mobile_id is linked.*/

CALL UpdateRajeshAndAddSowmya('9999912345');

/*Selects all rows from the UserDetails view (the combined rows of user + pack + mobile), showing userId, userName, mobileNumber, packName per user (only rows where User.pack_id and User.mobile_id map to existing Pack and Mobile rows because the view uses INNER JOINs).*/
SELECT * FROM UserDetails;
