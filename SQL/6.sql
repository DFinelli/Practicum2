DELIMITER $$
CREATE TRIGGER insert_age
BEFORE INSERT ON person FOR EACH ROW
BEGIN
    SET NEW.age =
    CASE
    WHEN NEW.deathYear IS NOT NULL THEN NEW.deathYear - NEW.birthYear
    ELSE YEAR(CURDATE()) - NEW.birthYear
    END;
END$$


DELIMITER $$
CREATE TRIGGER insert_num_movies
AFTER INSERT ON knownFor FOR EACH ROW
BEGIN
UPDATE person
SET numMovies =
CASE
	WHEN numMovies IS NULL THEN 1
	ELSE (numMovies + 1)
END
WHERE person.personId = NEW.personId;
END$$


/* test works

INSERT INTO person (personID, primaryName, birthYear, deathYear)
VALUES ('atest', 'danf', '1994', '2020');

SELECT * FROM person;

 */

