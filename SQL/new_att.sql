/**** Attribute, titleAttribute, AttributeHelper ******/
SELECT * FROM titleInfo;
SELECT * FROM akas_tsv;

Create Table attributehelper (
	titleInfoId varchar(40),
    ordering int,
    attribute1 varchar(40),
    attribute2 varchar(40),
    attribute3 varchar(40)
);

INSERT INTO attributehelper(titleInfoId, ordering, attribute1, attribute2, attribute3)
SELECT titleInfoId, ordering, SUBSTRING_INDEX(attributes, ' ', 1) AS attribute1,
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
