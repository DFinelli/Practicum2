SELECT E.parentTconst, MAX(E.seasonNumber)
FROM title AS T, episode AS E
WHERE T.titleType = "tvSeries"
AND E.parentTconst = T.titleID
GROUP BY E.parentTconst;
