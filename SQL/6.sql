DELIMITER $$
CREATE TRIGGER insert_age
BEFORE INSERT ON person FOR EACH ROW
BEGIN
    SET NEW.age = YEAR(CURDATE()) - OLD.birthYear;
END$$

CREATE TRIGGER insert_num_movies
BEFORE INSERT ON person FOR EACH ROW
BEGIN
	SELECT COUNT(*) FROM principals AS P
    WHERE P.personID = OLD.personID;
END$$