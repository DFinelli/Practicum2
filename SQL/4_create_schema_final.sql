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

Create Table person (
	personID varchar(40),
    primaryName longtext,
    birthYear int,
    deathYear int,
    Constraint PK_personID Primary Key (personID)
);

Create Table rating (
	ratingID int AUTO_INCREMENT,
    titleID varchar(40),
    averageRating int,
    numVotes int,
    Constraint PK_ratingID Primary Key (ratingID),
    Constraint FK_titleID_r Foreign Key (titleID) References title(titleID)
);

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

Create Table directors (
	titleID varchar(40),
	personId varchar(40),
    Constraint personID Primary Key (personID)
);

Create Table writers (
	titleID varchar(40),
	personId varchar(40),
    Constraint personID Primary Key (personID)
);

Create Table attributes (
	attributeID int AUTO_INCREMENT,
	attributeText varchar(40),
    Constraint PK_attributeID Primary Key (attributeID)
);

Create Table titleInfoAttribute (
	titleInfoAttributeID int AUTO_INCREMENT,
    titleInfoID int,
    ordering int,
    attributeID int,
    Constraint PK_titleInfoAttributeID Primary Key (titleInfoAttributeID),
    Constraint FK_titleInfoID_tia Foreign Key (titleInfoID) References titleInfo(titleInfoID),
	Constraint FK_attributeID_tia Foreign Key (attributeID) References attributes(attributeID)
);

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

Create Table knownFor (
	knownForID int AUTO_INCREMENT,
    personID varchar(40),
    titleID varchar(40),
    Constraint PK_knownForID Primary Key (knownForID),
    Constraint FK_personID_kf Foreign Key (personID) References person(personID),
	Constraint FK_titleID_kf Foreign Key (titleID) References title(titleID)
);

Create Table genrehelper (
	tconst varchar(40),
    genre1 varchar(40),
    genre2 varchar(40),
    genre3 varchar(40)
);

Create Table genres (
	genreID int AUTO_INCREMENT,
	genreText varchar(40),
    Constraint PK_genreID Primary Key (genreID)
);

Create Table titleGenre (
	titleGenreID int AUTO_INCREMENT,
    titleID varchar(40),
    genreID int,
    Constraint PK_titleGenreID Primary Key (titleGenreID),
    Constraint FK_titleID_tg Foreign Key (titleID) References title(titleID),
	Constraint FK_genreID_tg Foreign Key (genreID) References genres(genreID)
);

Create Table professions (
	professionsID int AUTO_INCREMENT,
    professionsText varchar(40),
    Constraint PK_personID Primary Key (professionsID)
);

Create Table personProfession (
	personProfessionID int AUTO_INCREMENT,
    personID varchar(40),
    professionsID int,
    Constraint PK_personProfessionID Primary Key (personProfessionID),
    Constraint FK_personID_pP Foreign Key (personID) References person(personID),
	Constraint FK_professionsID_pP Foreign Key (professionsID) References professions(professionsID)
);
