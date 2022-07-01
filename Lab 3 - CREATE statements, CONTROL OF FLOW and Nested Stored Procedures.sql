-- Lab 3: CREATE statements, CONTROL OF FLOW and Nested Stored Procedures

Use master
go


-- (1)
If Exists(Select Name from SysDatabases Where Name = 'israelma_Lab3')
 Begin 
  Alter Database [israelma_Lab3] set Single_user With Rollback Immediate;
  Drop Database israelma_Lab3;
 End
go

CREATE DATABASE israelma_Lab3
go



-- (2)
Use israelma_Lab3;
go



-- (3)
CREATE TABLE tblPET
(PetID INTEGER IDENTITY(1,1) primary key
,PetName varchar(100) not null
,PetTypeID int not null
,CountryID int not null
,TempID int not null
,DOB date not null
,GenderID int not null
)
go

CREATE TABLE tblPET_TYPE
(PetTypeID INTEGER IDENTITY(1,1) primary key
,PetTypeName varchar(100) not null
)
go

CREATE TABLE tblCOUNTRY
(CountryID INTEGER IDENTITY(1,1) primary key
,CountryName varchar(100) not null
)
go

CREATE TABLE tblTEMPERAMENT
(TempID INTEGER IDENTITY(1,1) primary key
,TempName varchar(100) not null
)
go

CREATE TABLE tblGENDER
(GenderID INTEGER IDENTITY(1,1) primary key
,GenderName varchar(100) not null
)
go

ALTER TABLE tblPET
ADD CONSTRAINT FK_tblPET_PetTypeID
FOREIGN KEY (PetTypeID)
REFERENCES tblPET_TYPE (PetTypeID)
go
ALTER TABLE tblCOUNTRY
ADD CONSTRAINT FK_tblCOUNTRY_CountryID
FOREIGN KEY (CountryID)
REFERENCES tblCOUNTRY (CountryID)
go
ALTER TABLE tblTEMPERAMENT
ADD CONSTRAINT FK_tblTEMPERAMENT_TempID
FOREIGN KEY (TempID)
REFERENCES tblTEMPERAMENT (TempID)
go
ALTER TABLE tblGENDER
ADD CONSTRAINT FK_tblGENDER_GenderID
FOREIGN KEY (GenderID)
REFERENCES tblGENDER (GenderID)
go



-- (10)
INSERT INTO tblPET_TYPE (PetTypeName)
SELECT DISTINCT PET_TYPE
FROM RAW_PetData
WHERE PET_TYPE IS NOT NULL


INSERT INTO tblCOUNTRY (CountryName)
SELECT DISTINCT Country
FROM RAW_PetData
WHERE COUNTRY IS NOT NULL

INSERT INTO tblTEMPERAMENT(TempName)
SELECT DISTINCT Temperament
FROM RAW_PetData
WHERE TEMPERAMENT IS NOT NULL

INSERT INTO tblGENDER (GenderName)
SELECT DISTINCT Gender
FROM RAW_PetData
WHERE GENDER IS NOT NULL



-- (11)
CREATE TABLE PK_PET_RAW
(PK_ID INT IDENTITY(1,1) primary key,
PetName varchar(100) null,
Pet_Type varchar(100) null,
Temperament varchar(100) null,
Country varchar(100) null,
Date_Birth Date NULL,
Gender varchar(100)
)

INSERT INTO PK_PET_RAW
(PetName, Pet_Type, Temperament, Country, Date_Birth, Gender)
SELECT PetName, Pet_Type, Temperament, Country, Date_Birth, Gender
FROM RAW_PetData
WHERE TEMPERAMENT IS NOT NULL
go



-- (12)
CREATE PROCEDURE uspGetPetTypeID
@Pet_Type varchar(100),
@Pet_ID INT OUTPUT
AS
SET @Pet_ID = (SELECT PetTypeID FROM tblPET_TYPE WHERE PetTypeName = @Pet_Type)
go

CREATE PROCEDURE uspGetCountryID
@Country_Name varchar(100),
@Country_ID INT OUTPUT
AS
SET @Country_ID = (SELECT CountryID FROM tblCOUNTRY WHERE CountryName = @Country_Name)
go

CREATE PROCEDURE uspGetTemperamentID
@Temp_Name varchar(100),
@Temp_ID INT OUTPUT
AS
SET @Temp_ID = (SELECT TempID FROM tblTEMPERAMENT WHERE TempName = @Temp_Name)
go


CREATE PROCEDURE uspGetGenderID
@Gender_Name varchar(100),
@Gender_ID INT OUTPUT
AS
SET @Gender_ID = (SELECT GenderID FROM tblGENDER WHERE GenderName = @Gender_Name)
go

select * from tblPET
GO

CREATE PROCEDURE israelmaINSERT_PET
@P varchar(100),
@P_Type varchar(100),
@C_Name varchar(100),
@T_Name varchar(100),
@BDay Date,
@G_Name varchar(100)
AS
DECLARE @PT_ID INT, @C_ID INT, @T_ID INT, @G_ID INT

EXEC uspGetPetTypeID
@Pet_Type = @P_Type,
@Pet_ID = @PT_ID OUTPUT
-- check for NULL
IF @PT_ID IS NULL
	BEGIN
        PRINT 'Hi...I like hot cheetos..there is an error with @PT_ID being NULL'
        RAISERROR ('@PT_ID cannot be null', 11,1)
        RETURN
    END

EXEC uspGetCountryID
@Country_Name = @C_Name,
@Country_ID = @C_ID OUTPUT
-- check for NULL
IF @C_ID IS NULL
	BEGIN
        PRINT 'Hi...I like regular cheetos..there is an error with @C_ID being NULL'
        RAISERROR ('@C_ID cannot be null', 11,1)
        RETURN
    END

EXEC uspGetTemperamentID
@Temp_Name = @T_Name,
@Temp_ID = @T_ID OUTPUT
-- check for NULL
IF @T_ID IS NULL
	BEGIN
        PRINT 'Hi...I like extra hot hot cheetos..there is an error with @T_ID being NULL'
        RAISERROR ('@T_ID cannot be null', 11,1)
        RETURN
    END

EXEC uspGetGenderID
@Gender_Name = @G_Name,
@Gender_ID = @G_ID OUTPUT
-- check for NULL
IF @G_ID IS NULL
	BEGIN
        PRINT 'Hi...I eat hot chip..there is an error with @G_ID being NULL'
        RAISERROR ('@G_ID cannot be null', 11,1)
        RETURN
    END

BEGIN TRAN G1
INSERT INTO tblPET (PetName, PetTypeID, CountryID, TempID, DOB, GenderID)
VALUES (@P, @PT_ID, @C_ID, @T_ID, @BDay, @G_ID)
IF @@ERROR <> 0
    BEGIN
        PRINT 'Hey...there is an error up ahead and I am pulling over'
        ROLLBACK TRAN G1

    END
ELSE
    COMMIT TRAN G1


IF EXISTS (SELECT * FROM sys.sysobjects WHERE NAME = 'PK_PET_RAW')
 BEGIN
  PRINT 'ahhh...working_copy_PK_PET_RAW is in the system...dropping it now'
  DROP TABLE PK_PET_RAW
  SELECT * INTO PK_PET_RAW FROM RAW_PetData
 END

DECLARE @Run INT = (SELECT COUNT(*) FROM PK_PET_RAW)
WHILE @Run > 0
BEGIN
-- read 1 row --> populate 4 variables --> calling Nested 'GetID' procedures
	DECLARE @Pname varchar(100)
	DECLARE @Ptype varchar(100)
	DECLARE @Cname varchar(100)
	DECLARE @Tname varchar(100)
	DECLARE @Birthday Date
	DECLARE @Gname varchar(100)
	SET @Pname = (SELECT TOP 1 PETNAME FROM PK_PET_RAW)
	SET @Ptype = (SELECT TOP 1 PET_TYPE FROM PK_PET_RAW)
	SET @Cname = (SELECT TOP 1 COUNTRY FROM PK_PET_RAW)
	SET @Tname = (SELECT TOP 1 TEMPERAMENT FROM PK_PET_RAW)
	SET @Birthday = (SELECT TOP 1 DATE_BIRTH FROM PK_PET_RAW)
	SET @Gname = (SELECT TOP 1 GENDER FROM PK_PET_RAW)
-- INSERT into tblPET with the 4 variables and birthDate
	EXEC israelmaINSERT_PET
		@P = @Pname,
		@P_Type = @Ptype,
		@C_Name = @Cname,
		@T_Name = @Tname,
		@BDay = @Birthday,
		@G_Name = @Gname
-- delete same exact row from working_copy_PK_PET_RAW
	DELETE TOP (1) FROM PK_PET_RAW
-- decrement the @Run value
	SET @Run = @Run - 1
-- rinse and repeat
END

DROP TABLE PK_PET_RAW
