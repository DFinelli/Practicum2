
/*********** Attribute, titleAttribute, AttributeHelper *************/
SELECT * FROM titleInfo;
SELECT * FROM akas_tsv;

Create Table attributehelper (
	titleInfoId varchar(40),
    attribute1 varchar(40),
    attribute2 varchar(40),
    attribute3 varchar(40)
);

INSERT INTO attributehelper(titleInfoId, attribute1, attribute2, attribute3)
SELECT titleInfoId, SUBSTRING_INDEX(attributes, ' ', 1) AS attribute1,
SUBSTRING_INDEX(SUBSTRING_INDEX(attributes, ' ', 2), ' ', -1) AS attribute2,
SUBSTRING_INDEX(attributes, ' ', -1) AS attribute3
FROM akas_tsv JOIN titleInfo ON akas_tsv.titleID = titleInfo.titleId;

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
    attributeID int,
    Constraint PK_titleInfoAttributeID Primary Key (titleInfoAttributeID),
    Constraint FK_titleInfoID_tia Foreign Key (titleInfoID) References titleInfo(titleInfoID),
	Constraint FK_attributeID_tia Foreign Key (attributeID) References attributes(attributeID)
);

INSERT INTO titleInfoAttribute(titleInfoID, attributeID)
SELECT DISTINCT AH.titleInfoId, A.attributeID
FROM attributehelper AS AH, attributes AS A
WHERE NOT EXISTS (SELECT TIA.titleInfoID, TIA.attributeID FROM attributes AS A, titleInfoAttribute AS TIA
                  WHERE A.attributeID = TIA.attributeID AND  AH.titleInfoId = TIA.titleInfoId)
AND A.attributeText = AH.attribute1;

INSERT INTO titleInfoAttribute(titleInfoID, attributeID)
SELECT DISTINCT AH.titleInfoId, A.attributeID
FROM attributehelper AS AH, attributes AS A
WHERE NOT EXISTS (SELECT TIA.titleInfoID, TIA.attributeID FROM attributes AS A, titleInfoAttribute AS TIA
                  WHERE A.attributeID = TIA.attributeID AND  AH.titleInfoId = TIA.titleInfoId)
AND A.attributeText = AH.attribute2;

INSERT INTO titleInfoAttribute(titleInfoID, attributeID)
SELECT DISTINCT AH.titleInfoId, A.attributeID
FROM attributehelper AS AH, attributes AS A
WHERE NOT EXISTS (SELECT TIA.titleInfoID, TIA.attributeID FROM attributes AS A, titleInfoAttribute AS TIA
                  WHERE A.attributeID = TIA.attributeID AND  AH.titleInfoId = TIA.titleInfoId)
AND A.attributeText = AH.attribute3;

SELECT * from titleInfoAttribute;
/********************************************************************************************************************************/

/*********** attribute // titleAttribute *************/

-- SELECT * FROM akas_tsv;

-- Create Table attribute (
-- 	attributeID int AUTO_INCREMENT,
--     attributeText varchar(50),
--     Constraint PK_attributeID Primary Key (attributeID)
-- );

-- Create Table titleAttribute (
-- 	titleAttributeID int,
--     titleInfoID int,
--     attributeID int,
--     Constraint PK_titleAttributeID Primary Key (titleAttributeID),
--     Constraint FK_titleInfoID_ta Foreign Key (titleInfoID) REFERENCES titleInfo(titleInfoID),
-- 	Constraint FK_attributeID_ta Foreign Key (attributeID) REFERENCES attribute(attributeID)
-- );

-- /*transfer data from tsv to newly corrected table */
-- INSERT INTO attribute (attributeText)
-- SELECT DISTINCT Akas.attributes
-- FROM akas_tsv AS Akas
-- WHERE NOT EXISTS (SELECT * FROM attribute AS A WHERE A.attributeText = Akas.attributes);

-- INSERT INTO titleAttribute(titleInfoID, attributeID)
-- SELECT Ti.titleInfoID, A.attributeID
-- FROM attribute AS A, titleInfo AS Ti, akas_tsv AS Akas
-- WHERE Akas.titleID = Ti.titleID
-- AND Akas.ordering = Ti.ordering
-- AND A.attributeText = Akas.attributes;

/********************************************************************************************************************************/

SELECT * FROM akas_tsv;

/*********** mediaType // titleInfoMediaType *************/
Create Table mediaType (
	mediaTypeID int AUTO_INCREMENT,
    mediaTypeText varchar(50),
    Constraint PK_mediaTypeID Primary Key (mediaTypeID)
);

Create Table titleInfoMediaType (
	titleInfoMediaTypeID int AUTO_INCREMENT,
    titleInfoID int,
    mediaTypeID int,
    Constraint PK_titleInfoMediaTypeID Primary Key (titleInfoMediaTypeID),
    Constraint FK_titleInfoID_tit Foreign Key (titleInfoID) REFERENCES titleInfo(titleInfoID),
	Constraint FK_mediaTypeID_tit Foreign Key (mediaTypeID) REFERENCES mediaType(mediaTypeID)
);

Create Table mediaHelper(
	titleInfoID int,
    media1 varchar(40),
    media2 varchar(40)
);

INSERT INTO mediaHelper(titleInfoId, media1, media2)
SELECT titleInfoId, SUBSTRING_INDEX(types, ' ', 1) AS media1,
SUBSTRING_INDEX(types, ' ', -1) AS media2
FROM akas_tsv JOIN titleInfo ON akas_tsv.titleID = titleInfo.titleId;

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

INSERT INTO titleInfoMediaType(titleInfoID, mediaTypeID)
SELECT DISTINCT MH.titleInfoId, MT.mediaTypeID
FROM mediaHelper AS MH, mediaType AS MT
WHERE NOT EXISTS (SELECT TMT.titleInfoID, TMT.mediaTypeID FROM mediaType AS MT, titleInfoMediaType AS TMT
                  WHERE MT.mediaTypeID = TMT.mediaTypeID AND  MH.titleInfoId = TMT.titleInfoID)
AND MT.mediaTypeText = MH.media1;

INSERT INTO titleInfoMediaType(titleInfoID, mediaTypeID)
SELECT DISTINCT MH.titleInfoId, MT.mediaTypeID
FROM mediaHelper AS MH, mediaType AS MT
WHERE NOT EXISTS (SELECT TMT.titleInfoID, TMT.mediaTypeID FROM mediaType AS MT, titleInfoMediaType AS TMT
                  WHERE MT.mediaTypeID = TMT.mediaTypeID AND  MH.titleInfoId = TMT.titleInfoID)
AND MT.mediaTypeText = MH.media2;

SELECT * FROM titleInfoMediaType;
