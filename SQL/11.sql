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
