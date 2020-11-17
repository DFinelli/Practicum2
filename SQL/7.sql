
CREATE VIEW actorView AS
SELECT P.PrimaryName, P.age,
CASE
	WHEN deathYear IS NOT NULL THEN 'dead'
    ELSE 'alive'
END
AS 'whether dead',
numMovies AS 'movies known for'
FROM person AS P;
