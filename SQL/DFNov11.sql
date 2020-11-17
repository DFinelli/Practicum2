/********************************************************************************************************************************/

/*********** TITLE *************/
/* run python script to create and load data into tsv table where all values are strings. nulls are correctly inserted */
SELECT * FROM title_tsv;
DESCRIBE title_tsv;

/* create properly formatted table */
Create Table title (
	titleID varchar(40),
    titleType longtext,
    primaryTitle longtext,
    originalTitle longtext,
    isAdult bool,
    startYear int,
    endYear int,
    runtimeMinutes int,
    Constraint PK_titleID Primary Key (titleID)
);

/* Transfer data from title_tsv to title table. */
INSERT INTO title (titleID, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes)
SELECT tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes
FROM title_tsv;
SELECT * FROM title;
DESCRIBE title;
/********************************************************************************************************************************/

/*********** AKAS // TitleInfo *************/
/* run python script to create and load data into tsv table where all values are strings. nulls are correctly inserted */
SELECT * FROM akas_tsv;
DESCRIBE akas_tsv;

Create Table titleInfo (
	titleInfoID int AUTO_INCREMENT,
	titleID varchar(40),
    ordering int,
    title longtext,
    region varchar(40),
    language varchar(40),
    isOriginalTitle bool,
    Constraint PK_titleInfoID Primary Key (titleInfoID),
    Constraint FK_titleID_ti Foreign Key (titleID) REFERENCES title(titleID)
);

/*transfer data from tsv to newly corrected table */
INSERT INTO titleInfo (titleID, ordering, title, region, language, isOriginalTitle)
SELECT atsv.titleID, ordering, title, region, language, isOriginalTitle
FROM akas_tsv atsv INNER JOIN title t ON atsv.titleID = t.titleID;

SELECT * FROM titleInfo;
DESCRIBE titleInfo;
/********************************************************************************************************************************/

/*********** Name / Person *************/
SELECT * FROM name_tsv;

Create Table person (
	personID varchar(40),
    primaryName longtext,
    birthYear int,
    deathYear int,
    Constraint PK_personID Primary Key (personID)
);

ALTER TABLE person
ADD age int;

ALTER TABLE person
ADD numMovies int;



SELECT * FROM person;

INSERT INTO person (personID, primaryName, birthYear, deathYear)
SELECT nconst, primaryName, birthYear, deathYear
FROM name_tsv;
/********************************************************************************************************************************/

/*********** Rating *************/
SELECT * from ratings_tsv;

Create Table rating (
	ratingID int AUTO_INCREMENT,
    titleID varchar(40),
    averageRating int,
    numVotes int,
    Constraint PK_ratingID Primary Key (ratingID),
    Constraint FK_titleID_r Foreign Key (titleID) References title(titleID)
);

INSERT INTO rating (titleID, averageRating, numVotes)
SELECT tconst, averageRating, numVotes
FROM ratings_tsv rtsv INNER JOIN title t ON rtsv.tconst = t.titleID;

SELECT * FROM rating;

/********************************************************************************************************************************/

/*********** Episode *************/
SELECT * from episode_tsv;

Create Table episode (
	episodeID int AUTO_INCREMENT,
    titleID varchar(40),
    parentTconst varchar(40),
    seasonNumber int,
    episodeNumber int,
    Constraint PK_episodeID Primary Key (episodeID),
    Constraint FK_titleID_e Foreign Key (titleID) References title(titleID),
    Constraint FK_parentID_e Foreign Key (parentTconst) References title(titleID)
);

INSERT INTO episode (titleID, parentTconst, seasonNumber, episodeNumber)
SELECT tconst, parentTconst, seasonNumber, episodeNumber
FROM episode_tsv etsv INNER JOIN title t ON etsv.tconst = t.titleID JOIN title t2 ON etsv.parentTconst = t2.titleID;

SELECT * FROM episode;
/********************************************************************************************************************************/



/********************************************************************************************************************************/

/*********** Principals *************/
SELECT * from principals_tsv;

Create Table principals (
	principalID int AUTO_INCREMENT,
    titleID varchar(40),
    ordering int,
    personID varchar(40),
    category longtext,
    job longtext,
    characters longtext,
    Constraint PK_principalID Primary Key (principalID),
	Constraint FK_titleID_p Foreign Key (titleID) References title(titleID),
	Constraint FK_personID_p Foreign Key (personID) References person(personID)
);

INSERT INTO principals (titleID, ordering, personID, category, job, characters)
SELECT tconst, ordering, nconst, category, job, characters
FROM principals_tsv ptsv INNER JOIN title t ON ptsv.tconst = t.titleID INNER JOIN person p ON ptsv.nconst = p.personId;

SELECT * FROM principals;
/********************************************************************************************************************************/


Create Table directors (
	titleID varchar(40),
	personId varchar(40),
    Constraint personID Primary Key (personID)
);

SELECT * FROM directors;

Create Table writers (
	titleID varchar(40),
	personId varchar(40),
    Constraint personID Primary Key (personID)
);

SELECT * FROM writers;

/********************************************************************************************************************************/

/**** Attribute, titleAttribute, AttributeHelper ******/
SELECT * FROM akas_tsv;

Create Table attributehelper (
	titleInfoId varchar(40),
    ordering int,
    attribute1 varchar(40),
    attribute2 varchar(40),
    attribute3 varchar(40)
);

INSERT INTO attributehelper(titleInfoId, ordering, attribute1, attribute2, attribute3)
SELECT titleInfoId, akas_tsv.ordering, SUBSTRING_INDEX(attributes, ' ', 1) AS attribute1,
SUBSTRING_INDEX(SUBSTRING_INDEX(attributes, ' ', 2), ' ', -1) AS attribute2,
SUBSTRING_INDEX(attributes, ' ', -1) AS attribute3
FROM akas_tsv JOIN titleInfo ON (akas_tsv.titleID = titleInfo.titleId AND akas_tsv.ordering = titleInfo.ordering);

SELECT * FROM attributehelper;

Create Table attributes (
	attributeID int AUTO_INCREMENT,
	attributeText varchar(40),
    Constraint PK_attributeID Primary Key (attributeID)
);

INSERT INTO attributes(attributeText)
SELECT DISTINCT AH.attribute1
FROM attributehelper AS AH
WHERE NOT EXISTS (SELECT * FROM attributes AS A WHERE A.attributeText = AH.attribute1);

INSERT INTO attributes(attributeText)
SELECT DISTINCT AH.attribute2
FROM attributehelper AS AH
WHERE NOT EXISTS (SELECT * FROM attributes AS A WHERE A.attributeText = AH.attribute2);

INSERT INTO attributes(attributeText)
SELECT DISTINCT AH.attribute3
FROM attributehelper AS AH
WHERE NOT EXISTS (SELECT * FROM attributes AS A WHERE A.attributeText = AH.attribute3);

SELECT * FROM attributes;

Create Table titleInfoAttribute (
	titleInfoAttributeID int AUTO_INCREMENT,
    titleInfoID int,
    ordering int,
    attributeID int,
    Constraint PK_titleInfoAttributeID Primary Key (titleInfoAttributeID),
    Constraint FK_titleInfoID_tia Foreign Key (titleInfoID) References titleInfo(titleInfoID),
	Constraint FK_attributeID_tia Foreign Key (attributeID) References attributes(attributeID)
);

INSERT INTO titleInfoAttribute(titleInfoID, ordering, attributeID)
SELECT DISTINCT AH.titleInfoId, AH.ordering, A.attributeID
FROM attributehelper AS AH, attributes AS A
WHERE NOT EXISTS (SELECT TIA.titleInfoID, TIA.attributeID FROM attributes AS A, titleInfoAttribute AS TIA
                  WHERE A.attributeID = TIA.attributeID AND AH.titleInfoId = TIA.titleInfoId AND AH.ordering = TIA.ordering)
AND A.attributeText = AH.attribute1;

INSERT INTO titleInfoAttribute(titleInfoID, ordering, attributeID)
SELECT DISTINCT AH.titleInfoId, AH.ordering, A.attributeID
FROM attributehelper AS AH, attributes AS A
WHERE NOT EXISTS (SELECT TIA.titleInfoID, TIA.attributeID FROM attributes AS A, titleInfoAttribute AS TIA
                  WHERE A.attributeID = TIA.attributeID AND AH.titleInfoId = TIA.titleInfoId AND AH.ordering = TIA.ordering)
AND A.attributeText = AH.attribute2;

INSERT INTO titleInfoAttribute(titleInfoID, ordering, attributeID)
SELECT DISTINCT AH.titleInfoId, AH.ordering, A.attributeID
FROM attributehelper AS AH, attributes AS A
WHERE NOT EXISTS (SELECT TIA.titleInfoID, TIA.attributeID FROM attributes AS A, titleInfoAttribute AS TIA
                  WHERE A.attributeID = TIA.attributeID AND AH.titleInfoId = TIA.titleInfoId AND AH.ordering = TIA.ordering)
AND A.attributeText = AH.attribute3;

SELECT * from titleInfoAttribute;
/********************************************/

/**** mediaType // titleInfoMediaType ******/
Create Table mediaType (
	mediaTypeID int AUTO_INCREMENT,
    mediaTypeText varchar(50),
    Constraint PK_mediaTypeID Primary Key (mediaTypeID)
);

Create Table titleInfoMediaType (
	titleInfoMediaTypeID int AUTO_INCREMENT,
    titleInfoID int,
    ordering int,
    mediaTypeID int,
    Constraint PK_titleInfoMediaTypeID Primary Key (titleInfoMediaTypeID),
    Constraint FK_titleInfoID_tit Foreign Key (titleInfoID) REFERENCES titleInfo(titleInfoID),
	Constraint FK_mediaTypeID_tit Foreign Key (mediaTypeID) REFERENCES mediaType(mediaTypeID)
);

Create Table mediaHelper(
	titleInfoID int,
    ordering int,
    media1 varchar(40),
    media2 varchar(40)
);

INSERT INTO mediaHelper(titleInfoId, ordering, media1, media2)
SELECT titleInfo.titleInfoID, titleInfo.ordering, SUBSTRING_INDEX(types, ' ', 1) AS media1,
SUBSTRING_INDEX(types, ' ', -1) AS media2
FROM akas_tsv JOIN titleInfo ON (akas_tsv.titleID = titleInfo.titleID AND akas_tsv.ordering = titleinfo.ordering);

SELECT * FROM mediaHelper;

/*transfer data from tsv to newly corrected table */
INSERT INTO mediaType(mediaTypeText)
SELECT DISTINCT MH.media1
FROM mediaHelper AS MH
WHERE NOT EXISTS (SELECT * FROM mediaType AS MT WHERE MT.mediaTypeText = MH.media1);

INSERT INTO mediaType(mediaTypeText)
SELECT DISTINCT MH.media2
FROM mediaHelper AS MH
WHERE NOT EXISTS (SELECT * FROM mediaType AS MT WHERE MT.mediaTypeText = MH.media2);

SELECT * FROM mediaType;

INSERT INTO titleInfoMediaType(titleInfoID, ordering, mediaTypeID)
SELECT DISTINCT MH.titleInfoId, MH.ordering, MT.mediaTypeID
FROM mediaHelper AS MH, mediaType AS MT
WHERE NOT EXISTS (SELECT TMT.titleInfoID, TMT.ordering, TMT.mediaTypeID FROM mediaType AS MT, titleInfoMediaType AS TMT
                  WHERE MT.mediaTypeID = TMT.mediaTypeID AND MH.titleInfoId = TMT.titleInfoID AND MH.ordering = TMT.ordering)
AND MT.mediaTypeText = MH.media1;

INSERT INTO titleInfoMediaType(titleInfoID, ordering, mediaTypeID)
SELECT DISTINCT MH.titleInfoId, MH.ordering, MT.mediaTypeID
FROM mediaHelper AS MH, mediaType AS MT
WHERE NOT EXISTS (SELECT TMT.titleInfoID, TMT.ordering, TMT.mediaTypeID FROM mediaType AS MT, titleInfoMediaType AS TMT
                  WHERE MT.mediaTypeID = TMT.mediaTypeID AND MH.titleInfoId = TMT.titleInfoID AND MH.ordering = TMT.ordering)
AND MT.mediaTypeText = MH.media2;

SELECT * FROM titleInfoMediaType;
/********************************************/




/********************************************************************************************************************************/

/*********** KnownFor *************/
Create Table knownforhelper (
	nconst varchar(40),
    tconst1 varchar(40),
    tconst2 varchar(40),
    tconst3 varchar(40),
    tconst4 varchar(40)
);

INSERT INTO knownforhelper(nconst, tconst1, tconst2, tconst3, tconst4)
SELECT nconst, SUBSTRING_INDEX(knownForTitles, ',', 1) AS tconst1,
SUBSTRING_INDEX(SUBSTRING_INDEX(knownForTitles, ',', 2), ',', -1) AS tconst2,
SUBSTRING_INDEX(SUBSTRING_INDEX(knownForTitles, ',', 3), ',', -1) AS tconst3,
SUBSTRING_INDEX(knownForTitles, ',', -1) AS tconst4
FROM name_tsv;

SELECT * FROM knownforhelper;

Create Table knownFor (
	knownForID int AUTO_INCREMENT,
    personID varchar(40),
    titleID varchar(40),
    Constraint PK_knownForID Primary Key (knownForID),
    Constraint FK_personID_kf Foreign Key (personID) References person(personID),
	Constraint FK_titleID_kf Foreign Key (titleID) References title(titleID)
);

SELECT * FROM knownforhelper;

INSERT INTO knownFor(personID, titleID)
SELECT DISTINCT nconst, KFH.tconst1
FROM knownforhelper AS KFH INNER JOIN title t ON t.titleID = KFH.tconst1
WHERE NOT EXISTS (SELECT * FROM knownFor AS KF WHERE KF.titleID = KFH.tconst1);

INSERT INTO knownFor(personID, titleID)
SELECT DISTINCT nconst, KFH.tconst2
FROM knownforhelper AS KFH INNER JOIN title t ON t.titleID = KFH.tconst2
WHERE NOT EXISTS (SELECT * FROM knownFor AS KF WHERE KF.titleID = KFH.tconst2);

INSERT INTO knownFor(personID, titleID)
SELECT DISTINCT nconst, KFH.tconst3
FROM knownforhelper AS KFH INNER JOIN title t ON t.titleID = KFH.tconst3
WHERE NOT EXISTS (SELECT * FROM knownFor AS KF WHERE KF.titleID = KFH.tconst3);

INSERT INTO knownFor(personID, titleID)
SELECT DISTINCT nconst, KFH.tconst4
FROM knownforhelper AS KFH INNER JOIN title t ON t.titleID = KFH.tconst4
WHERE NOT EXISTS (SELECT * FROM knownFor AS KF WHERE KF.titleID = KFH.tconst4);

SELECT * FROM knownFor;

/********************************************************************************************************************************/


/*********** Genre, genreTitle, genrehelper *************/
Create Table genrehelper (
	tconst varchar(40),
    genre1 varchar(40),
    genre2 varchar(40),
    genre3 varchar(40)
);

INSERT INTO genrehelper(tconst, genre1, genre2, genre3)
SELECT tconst, SUBSTRING_INDEX(genres, ',', 1) AS genre1,
SUBSTRING_INDEX(SUBSTRING_INDEX(genres, ',', 2), ',', -1) AS genre2,
SUBSTRING_INDEX(genres, ',', -1) AS genre3
FROM title_tsv;

SELECT * FROM genrehelper;

Create Table genres (
	genreID int AUTO_INCREMENT,
	genreText varchar(40),
    Constraint PK_genreID Primary Key (genreID)
);

INSERT INTO genres(genreText)
SELECT DISTINCT GH.genre1
FROM genrehelper AS GH
WHERE NOT EXISTS (SELECT * FROM genres AS G WHERE G.genreText = GH.genre1);

INSERT INTO genres(genreText)
SELECT DISTINCT GH.genre2
FROM genrehelper AS GH
WHERE NOT EXISTS (SELECT * FROM genres AS G WHERE G.genreText = GH.genre2);

INSERT INTO genres(genreText)
SELECT DISTINCT GH.genre3
FROM genrehelper AS GH
WHERE NOT EXISTS (SELECT * FROM genres AS G WHERE G.genreText = GH.genre3);

Create Table titleGenre (
	titleGenreID int AUTO_INCREMENT,
    titleID varchar(40),
    genreID int,
    Constraint PK_titleGenreID Primary Key (titleGenreID),
    Constraint FK_titleID_tg Foreign Key (titleID) References title(titleID),
	Constraint FK_genreID_tg Foreign Key (genreID) References genres(genreID)
);

INSERT INTO titlegenre(titleID, genreID)
SELECT DISTINCT GH.tconst, G.genreID
FROM genrehelper AS GH, genres AS G
WHERE NOT EXISTS (SELECT TG.titleID, TG.genreID FROM genres AS G, titlegenre AS TG
                  WHERE G.genreID = TG.genreID AND  GH.tconst = TG.titleID)
AND G.genreText = GH.genre1;

INSERT INTO titlegenre(titleID, genreID)
SELECT DISTINCT GH.tconst, G.genreID
FROM genrehelper AS GH, genres AS G
WHERE NOT EXISTS (SELECT TG.titleID, TG.genreID FROM genres AS G, titlegenre AS TG
                  WHERE G.genreID = TG.genreID AND  GH.tconst = TG.titleID)
AND G.genreText = GH.genre2;

INSERT INTO titlegenre(titleID, genreID)
SELECT DISTINCT GH.tconst, G.genreID
FROM genrehelper AS GH, genres AS G
WHERE NOT EXISTS (SELECT TG.titleID, TG.genreID FROM genres AS G, titlegenre AS TG
                  WHERE G.genreID = TG.genreID AND  GH.tconst = TG.titleID)
AND G.genreText = GH.genre3;
/********************************************************************************************************************************/

/*********** Profession, personProfession, professionhelper *************/
Create Table professionhelper (
	nconst varchar(40),
    profession1 varchar(40),
    profession2 varchar(40),
    profession3 varchar(40)
);

INSERT INTO professionhelper(nconst, profession1, profession2, profession3)
SELECT nconst, SUBSTRING_INDEX(primaryProfession, ',', 1) AS profession1,
SUBSTRING_INDEX(SUBSTRING_INDEX(primaryProfession, ',', 2), ',', -1) AS profession2,
SUBSTRING_INDEX(primaryProfession, ',', -1) AS profession3
FROM name_tsv;

SELECT * FROM professionhelper;

/* create professions table  and insert unique parsed professions*/

Create Table professions (
	professionsID int AUTO_INCREMENT,
    professionsText varchar(40),
    Constraint PK_personID Primary Key (professionsID)
);

INSERT INTO professions(professionsText)
SELECT DISTINCT PH.profession1
FROM professionhelper AS PH
WHERE NOT EXISTS (SELECT * FROM professions AS P WHERE P.professionsText = PH.profession1);

INSERT INTO professions(professionsText)
SELECT DISTINCT PH.profession2
FROM professionhelper AS PH
WHERE NOT EXISTS (SELECT * FROM professions AS P WHERE P.professionsText = PH.profession2);

INSERT INTO professions(professionsText)
SELECT DISTINCT PH.profession3
FROM professionhelper AS PH
WHERE NOT EXISTS (SELECT * FROM professions AS P WHERE P.professionsText = PH.profession3);

SELECT * FROM professions;


/* create personProfession associaive table that has 2 FKs - personID and professionsID */
Create Table personProfession (
	personProfessionID int AUTO_INCREMENT,
    personID varchar(40),
    professionsID int,
    Constraint PK_personProfessionID Primary Key (personProfessionID),
    Constraint FK_personID_pP Foreign Key (personID) References person(personID),
	Constraint FK_professionsID_pP Foreign Key (professionsID) References professions(professionsID)
);

/* load personProfession. choose the distinct nconst + profession (unique person + unique profession), from prof helper,
where there is NOT any existing (profession in both P and PP -AND-  person thats in both PH and PP),
AND profession text == professionhelper */


INSERT INTO personProfession(personID, professionsID)
SELECT DISTINCT PH.nconst, P.professionsID
FROM professionhelper AS PH, professions AS P
WHERE NOT EXISTS (SELECT PP.personID, PP.professionsID FROM professions AS P, personProfession AS PP
                  WHERE P.professionsID = PP.professionsID AND  PH.nconst = PP.personID)
AND P.professionsText = PH.profession1;

INSERT INTO personProfession(personID, professionsID)
SELECT DISTINCT PH.nconst, P.professionsID
FROM professionhelper AS PH, professions AS P
WHERE NOT EXISTS (SELECT PP.personID, PP.professionsID FROM professions AS P, personProfession AS PP
                  WHERE P.professionsID = PP.professionsID AND  PH.nconst = PP.personID)
AND P.professionsText = PH.profession2;

INSERT INTO personProfession(personID, professionsID)
SELECT DISTINCT PH.nconst, P.professionsID
FROM professionhelper AS PH, professions AS P
WHERE NOT EXISTS (SELECT PP.personID, PP.professionsID FROM professions AS P, personProfession AS PP
                  WHERE P.professionsID = PP.professionsID AND  PH.nconst = PP.personID)
AND P.professionsText = PH.profession3;


SELECT * FROM personProfession;



