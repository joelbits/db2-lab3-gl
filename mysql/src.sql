-- Author: Joel Åkerblom joak.dev@gmail.com

USE `MYSQL_DATABASE`;

-- Lab 3 - 1 - a - Skriv en query som visar vilken veckodag det kommer vara på den sista dagen nuvarande månad.
SELECT DAYNAME(LAST_DAY(NOW()));

-- Lab 3 - 1 - b - Skriv en query som visar vilken veckordag det kommer vara på den första dagen nästa månad.
SELECT DAYNAME(LAST_DAY(NOW())+INTERVAL 1 day);

-- Lab 3 - 2 - Skriv en query som visar hur många dagar det gått sen 2000-01-01.
SELECT DATEDIFF(NOW(), '2000-01-01');

-- Lab 3 - 3 - Skriv en query som visar hur många minuter det är kvar till midnatt.
SELECT TIMESTAMPDIFF(SECOND, TIMESTAMP(CURDATE()), TIMESTAMP(NOW()));

-- Lab 3 - 4 - Skriv en query som visar alla users som är födda i februari. (users.sql)
SELECT * FROM `users` WHERE MONTH(`birthdate`) = 2;

-- Lab 3 - 5 - Skriv en query som visar alla users som har födelsedag idag (om någon).
SELECT * FROM `users` WHERE DATEDIFF(YEAR, DATE(NOW()), DATE(`birthdate`)) > 18;

-- Lab 3 - 6 - För users skriv en procedure, young_users(), som som visar förnamn, efternamn och på alla users som är under 18 år (när queryn körs).
DROP PROCEDURE IF EXISTS young_users;
DELIMITER //
CREATE PROCEDURE young_users()
BEGIN
SELECT u.fname, u.lname
FROM users u
WHERE (SELECT TIMESTAMPDIFF(YEAR, DATE(u.birthdate), DATE(NOW()))) < 18;
END //
DELIMITER ;

-- Lab 3 - 6 - young_users - Usage: Returns a list of young users : 
-- call young_users();

-- Lab 3 - 7 - För users gör en funktion, age(birthdate), som räknar ut ålder utifrån ett födelsedatum. Ska kunna användas med t ex SELECT fname, lname, birthdate, age(birthdate) FROM users ORDER BY birthdate;
DROP FUNCTION IF EXISTS age;
DELIMITER //
CREATE FUNCTION age(birthdate DATE)
RETURNS int
BEGIN
RETURN TIMESTAMPDIFF(YEAR, birthdate, DATE(NOW()));
END //
DELIMITER ;

-- Lab 3 - 7 - age : Usage: Returns user age in years.
-- SELECT fname, lname, birthdate, age(birthdate)
-- FROM users
-- ORDER BY birthdate;

-- Lab 3 - 8 - För orders skriv en query som visar order-id för alla orders som är skickade men inte mottagna av kund.
SELECT id FROM `orders` WHERE `sent` IS NOT NULL AND `arrived_at_customer` IS NULL;

-- Lab 3 - 9 - För orders skriv en query som visar order-id för alla orders som är mottagna och skickade inom 48 h.
SELECT id FROM `orders` WHERE (TIMESTAMPDIFF(HOUR, TIMESTAMP(`received`), TIMESTAMP(`sent`)) < 48);

-- Lab 3 - 10 - (VG) För users skriv triggers så att det inte går att lägga in, eller ändra till födelsedatum som ligger framåt i tiden.
DROP TRIGGER IF EXISTS birthdate_check_insert;
DELIMITER //
CREATE TRIGGER birthdate_check_insert
BEFORE INSERT ON users FOR EACH ROW
BEGIN
    CALL validate_birthdate(NEW.birthdate);
END //
DELIMITER ;

DROP TRIGGER IF EXISTS birthdate_check_update;
DELIMITER //
CREATE TRIGGER birthdate_check_update
BEFORE UPDATE ON users FOR EACH ROW
BEGIN
    CALL validate_birthdate(NEW.birthdate);
END //
DELIMITER ;

-- Used by Lab 3 - 10 - Trigger birthday_check_insert
DROP PROCEDURE IF EXISTS validate_birthdate;
DELIMITER //
CREATE PROCEDURE validate_birthdate(IN birthdate VARCHAR(20))
BEGIN
    IF ( DATE(NOW()) < DATE(birthdate) ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Birthdate is in the future!';
    END IF;
END //
DELIMITER ;

-- Lab 3 - 10 - Usage : Will abort query because birthdate is in the future
-- UPDATE `users` SET `birthdate`='2018-12-24' WHERE `id` = 1
-- INSERT INTO `users`(`fname`, `lname`, `birthdate`) VALUES ('NEW', 'USER' , '2018-12-24');