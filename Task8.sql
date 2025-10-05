USE elevatelabs;

-- 1) Pack table
CREATE TABLE IF NOT EXISTS Pack (
    pack_id INT AUTO_INCREMENT PRIMARY KEY,
    pack_name VARCHAR(50) NOT NULL
);

-- 2) User table
CREATE TABLE IF NOT EXISTS User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    pack_id INT,
    mobile_id INT,
    FOREIGN KEY (pack_id) REFERENCES Pack(pack_id)
);

-- 3) Mobile table
CREATE TABLE IF NOT EXISTS Mobile (
    mobile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    mobile_number VARCHAR(15),  -- to store phone number
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);
INSERT INTO Pack (pack_name) VALUES
('Mobile'),
('Super'),
('Premium'),
('Free');    -- Added Free pack for Sowmya

INSERT INTO User (full_name, pack_id, mobile_id) VALUES
('Rajesh', 1, NULL),
('Varun',  3, NULL),
('Saikiran', 2, NULL);

INSERT INTO Mobile (user_id, mobile_number) VALUES
(1, '9999999999'),  -- Rajesh’s number (placeholder)
(2, '8888888888'),  -- Varun’s number
(3, '7777777777');  -- Saikiran’s number

SELECT * FROM Pack;
SELECT * FROM User;
SELECT * FROM Mobile;

UPDATE User SET mobile_id = 1 WHERE user_id = 1;
UPDATE User SET mobile_id = 2 WHERE user_id = 2;
UPDATE User SET mobile_id = 3 WHERE user_id = 3;

CREATE OR REPLACE VIEW UserDetails AS
SELECT 
    u.user_id AS userId,
    u.full_name AS userName,
    m.mobile_number AS mobileNumber,
    p.pack_name AS packName
FROM User u
JOIN Pack p ON u.pack_id = p.pack_id
JOIN Mobile m ON u.mobile_id = m.mobile_id;

DELIMITER $$

CREATE PROCEDURE UpdateRajeshAndAddSowmya(
    IN newNumber VARCHAR(15)
)
BEGIN
    -- 1. Declare variables first
    DECLARE freePackId INT;
    DECLARE sowmyaUserId INT;

    -- 2. Get Free Pack ID
    SELECT pack_id INTO freePackId FROM Pack WHERE pack_name = 'Free';

    -- 3. Update Rajesh’s mobile number
    UPDATE Mobile
    SET mobile_number = newNumber
    WHERE user_id = (SELECT user_id FROM User WHERE full_name = 'Rajesh');

    -- 4. Insert Sowmya with Free pack
    INSERT INTO User (full_name, pack_id, mobile_id)
    VALUES ('Sowmya', freePackId, NULL);

    -- 5. Get Sowmya's user_id
    SELECT user_id INTO sowmyaUserId FROM User WHERE full_name = 'Sowmya';

    -- 6. Insert Sowmya's mobile number
    INSERT INTO Mobile (user_id, mobile_number)
    VALUES (sowmyaUserId, '6666666666');

    -- 7. Link Sowmya's mobile_id to User table
    UPDATE User
    SET mobile_id = (SELECT mobile_id FROM Mobile WHERE user_id = sowmyaUserId)
    WHERE user_id = sowmyaUserId;

END $$

DELIMITER ;

CALL UpdateRajeshAndAddSowmya('9999912345');

SELECT * FROM UserDetails;

