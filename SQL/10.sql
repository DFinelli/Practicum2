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
