/* 5 */
UPDATE person
SET age = deathYear-birthYear;

UPDATE PERSON P INNER JOIN
(SELECT personID, count(personID) cnt FROM knownFor GROUP BY personID) pcnt USING (personID)
SET P.numMovies = pcnt.cnt;

/*6*/

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

/*7*/

CREATE VIEW actorView AS
SELECT P.PrimaryName, P.age,
CASE
	WHEN deathYear IS NOT NULL THEN 'dead'
    ELSE 'alive'
END
AS 'whether dead',
numMovies AS 'movies known for'
FROM person AS P;

/*8*/

SELECT E.parentTconst, MAX(E.seasonNumber)
FROM title AS T, episode AS E
WHERE T.titleType = "tvSeries"
AND E.parentTconst = T.titleID
GROUP BY E.parentTconst;


/*9*/


DROP PROCEDURE IF EXISTS addActor;

DELIMITER $$
CREATE PROCEDURE addActor(personID varchar(40), primaryName varchar(40), birthYear int, deathYear int, primaryProfession varchar(50), knownForTitles varchar(100))
BEGIN
	DECLARE profession1 VARCHAR(40);
	DECLARE profession2 VARCHAR(40);
	DECLARE profession3 VARCHAR(40);

    DECLARE professionID1 int;
    DECLARE professionID2 int;
    DECLARE professionID3 int;

    DECLARE knownFor1 VARCHAR(40);
    DECLARE knownFor2 VARCHAR(40);
    DECLARE knownFor3 VARCHAR(40);
    DECLARE knownFor4 VARCHAR(40);

    SET profession1 = SUBSTRING_INDEX(primaryProfession, ',', 1);
    SET profession2 = SUBSTRING_INDEX(SUBSTRING_INDEX(primaryProfession, ',', 2), ',', -1);
    SET profession3 = SUBSTRING_INDEX(primaryProfession, ',', -1);

    INSERT INTO person(personID, primaryName, birthYear, deathYear)
	VALUES (personID, primaryName, birthYear, deathYear);

    INSERT INTO professions(professionsText)
    SELECT profession1
    WHERE NOT EXISTS (SELECT 1 FROM professions AS P WHERE P.professionsText = profession1);

    INSERT INTO professions(professionsText)
    SELECT profession2
    WHERE NOT EXISTS (SELECT 1 FROM professions AS P WHERE P.professionsText = profession2);

    INSERT INTO professions(professionsText)
    SELECT profession3
    WHERE NOT EXISTS (SELECT 1 FROM professions AS P WHERE P.professionsText = profession3);

    SELECT P.professionsID FROM professions AS P WHERE P.professionsText = profession1 INTO professionID1;
    SELECT P.professionsID FROM professions AS P WHERE P.professionsText = profession2 INTO professionID2;
    SELECT P.professionsID FROM professions AS P WHERE P.professionsText = profession3 INTO professionID3;

    INSERT INTO personprofession(personID, professionsID)
    SELECT personID, professionID1
	WHERE NOT EXISTS (SELECT 1 FROM personprofession AS Pp WHERE Pp.personID = personID AND Pp.professionsID = professionID1);

    INSERT INTO personprofession(personID, professionsID)
    SELECT personID, professionID2
	WHERE NOT EXISTS (SELECT 1 FROM personprofession AS Pp WHERE Pp.personID = personID AND Pp.professionsID = professionID2);

    INSERT INTO personprofession(personID, professionsID)
    SELECT personID, professionID3
	WHERE NOT EXISTS (SELECT 1 FROM personprofession AS Pp WHERE Pp.personID = personID AND Pp.professionsID = professionID3);

    SET knownFor1 = SUBSTRING_INDEX(knownForTitles, ',', 1);
	SET knownFor2 = SUBSTRING_INDEX(SUBSTRING_INDEX(knownForTitles, ',', 2), ',', -1);
	SET knownFor3 = SUBSTRING_INDEX(SUBSTRING_INDEX(knownForTitles, ',', 3), ',', -1);
	SET knownFor4 = SUBSTRING_INDEX(knownForTitles, ',', -1);

    INSERT INTO knownFor(personID, titleID)
	SELECT personID, knownFor1
    WHERE
    EXISTS (SELECT * FROM title WHERE title.titleID = knownFor1)
    AND
	NOT EXISTS (SELECT * FROM knownFor AS KF WHERE KF.personID = personID AND KF.titleID = knownFor1);

	INSERT INTO knownFor(personID, titleID)
	SELECT personID, knownFor2
    WHERE
    EXISTS (SELECT * FROM title WHERE title.titleID = knownFor2)
    AND
	NOT EXISTS (SELECT * FROM knownFor AS KF WHERE KF.personID = personID AND KF.titleID = knownFor2);

	INSERT INTO knownFor(personID, titleID)
	SELECT personID, knownFor3
    WHERE
    EXISTS (SELECT * FROM title WHERE title.titleID = knownFor3)
    AND
	NOT EXISTS (SELECT * FROM knownFor AS KF WHERE KF.personID = personID AND KF.titleID = knownFor3);

	INSERT INTO knownFor(personID, titleID)
	SELECT personID, knownFor4
    WHERE
    EXISTS (SELECT * FROM title WHERE title.titleID = knownFor1)
    AND
	NOT EXISTS (SELECT * FROM knownFor AS KF WHERE KF.personID = personID AND KF.titleID = knownFor4);
END$$


/*10*/

DROP PROCEDURE IF EXISTS deleteActor;

DELIMITER $$
CREATE PROCEDURE deleteActor(personID varchar(50))
BEGIN
    DELETE FROM knownFor AS KF
    WHERE KF.personID = personID;

    DELETE FROM personprofession AS PP
    WHERE PP.personID = personID;

    DELETE FROM principals AS PR
    WHERE PR.personID = personID;

    DELETE FROM directors AS D
    WHERE D.personID = personID;

    DELETE FROM writers AS W
    WHERE W.personID = personID;

    DELETE FROM person AS P
    WHERE P.personID = personID;

END$$


/*11*/

SELECT P.primaryName, P.age, Count(*)
FROM person AS P, rating AS R, principals AS Pr, title AS T
WHERE R.averageRating > 5
AND T.titleID = R.titleID
AND T.titleType = "movie"
AND Pr.titleID = T.titleID
AND (Pr.category = "actor" OR Pr.category = "actress")
AND P.personID = Pr.personID
GROUP BY P.personID
HAVING COUNT(*) > 2


/*12*/

SELECT * FROM person WHERE primaryName = 'Frank Sinatra';
/* 0.040 sec / 0.000011 sec */

CREATE INDEX primaryName_index
ON person(primaryName(40));

SELECT * FROM person WHERE primaryName = 'Frank Sinatra';
/* # 0.00056 sec / 0.000028 sec  */


