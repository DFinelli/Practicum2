UPDATE person
SET age = deathYear-birthYear;

UPDATE PERSON P INNER JOIN
(SELECT personID, count(personID) cnt FROM knownFor GROUP BY personID) pcnt USING (personID)
SET P.numMovies = pcnt.cnt;

