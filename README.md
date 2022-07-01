# INFO-430-lab3
 
## Canvas Assignment Instructions

This Lab is designed for students to practice several sophisticated tasks as presented during lecture. 

1) coding the CREATE TABLE statements

2) importing data into a new database 

3) Populating look-up tables with distinct values from the imported data set

4) writing the 'getID' nested stored procedures

5) writing the SQL script to read each row of the imported data set and populate up to 4 look-up tables as well as the base 'transactional' table in a WHILE loop.

ASSIGNMENT DETAILS:

1) Create a brand new database with the following structure on IS-HAY10.iSchool.uw.edu: yourNETID_Lab3.

2) Use this new database: (example USE gthay_Lab3)

3) Code the following tables into this database in 3NF with proper PK/FK (save the creation script as it is part of your deliverable):

* PET (PetID, PetName, PetTypeID, CountryID, TempID. DOB, GenderID)

* PET_TYPE (PetTypeID, PetTypeName)

* COUNTRY (CountryID, CountryName)

* TEMPERAMENT (TempID, TempName)

* GENDER (GenderID, GenderName)

4) Data set will be provided during Lab

5) Launch IMPORT Wizard (right-click on your database and navigate through TASKS and find "Import Data")

6) Source will be Excel

7) Destination will be SQL Server Native Client

8) The first row will have column headers

9) Name your new table: RAW_PetData

10) the process by which to build a script requires that distinct values from all look-up tables are populated first. This includes PetType, Gender, Temperament and Country. Simple INSERT INTO tableName SELECT Distinct(columnName) FROM RAW_PetData should suffice.

11) Once the look-up tables have been populated, we will need to add a PK on the RAW_PetData table. Copy the schema (right-click the table name and navigate "Script Table As" followed by CREATE to) into a new query editor window; modify the resulting script by making a new name (perhaps RAW_PetData_PK) adding PK_ID with IDENTITY(1,1) as the primary key. The last step is to INSERT INTO this new table as follows:

INSERT INTO RAW_PetData_PK (PetName, PetTypeName, Temperament, Country, DateOfBirth, Gender)

SELECT PetName, PetTypeName, Temperament, Country, DateOfBirth, Gender

FROM RAW_PetData

12) After the above steps are completed, the fun begins! Code the 'GetID' stored procedures for each look-up table, then build a WHILE loop to roll through a COPY(!!!!) of RAW_PetData_PK row-by-row to capture each FK value in a variable to be passed to the GetID stored procedures.

Be sure to delete rows as they are processed and decrement the WHILE Loop.

Be sure to turn in ALL of the code you wrote for this lab.

Good luck :-)