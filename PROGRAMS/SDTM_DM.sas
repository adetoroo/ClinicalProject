*****************************************
Filename: Extract_raw.sas
Author: Moses Adetoro
Date: 04 April 2019
SAS: SAS 9.4 (TS2M0)
Platform: Windows XP
Project/Study: 765/15
Description: <To develop the SDTM DM and SUPP DM Datasets>
Input: Raw.Demo_Raw1
Output: SDTM.DM
Macros Used: <No macros used>
------------------------------------------
MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>
******************************************;
libname Raw "C:\PROJECT\QPS3\RAW";
libname SDTM "C:\PROJECT\QPS3\SDTM";

/*derive the sdtm dm variables, first step*/

DATA DM1;
SET Raw.Demo_raw1;
STUDYID="765/15";
Domain="DM";
SUBJID=strip(SUBJID);
SITEID="001";
USUBJID=strip(STUDYID)||"-"||strip(SITEID)||"-"||strip(SUBJID);
x= input(ENRDT,mmddyy10.);
FORMAT x mmddyy10.;
RFSTDTC=put(x, is8601da.)||"T"||put(ENRTM,tod8.);
RFENDTC="";
RFPENDTC="";
RFICDTC=put(x, is8601da.)||"T"||put(ENRTM,tod8.);
DROP x;
RUN;

/*Deriving other CDISC/SDTM variables as per spec*/

DATA DM2;
SET DM1;
RFPENDTC="";
DTHDTC="";
DTHFL="";
INVNAM="Dr. A. Samanlata";
AGE=AGEU;
FORMAT AGE 2.0;
RUN;

DATA DM3;
SET DM2 (DROP=AGEU);
IF AGE ne . THEN AGEU="YEARS";
RUN;

DATA DM4;
SET DM3;
SEX=GEN;
IF GEN="Male" THEN SEX="M";
IF GEN="Female" THEN SEX="F";
ELSE IF GEN="" THEN SEX="U";
RACE=upcase(ETH);
RUN;

/*Creating derived variable from Exposure datatsets*/

DATA EX1;
SET Raw.Exposure_Raw;
STUDYID="765/15";
Domain="DM";
SUBJID=strip(SUBJID);
SITEID="001";
USUBJID=strip(STUDYID)||"-"||strip(SITEID)||"-"||strip(SUBJID);
x= input(DSDT,mmddyy10.);
FORMAT x mmddyy10.;
RFXSTDTC=put(x, is8601da.)||"T"||put(DSDTM,tod8.);
DROP x;
RFXENDTC="";
KEEP STUDYID  Domain SUBJID SITEID USUBJID RFXSTDTC RFXENDTC;
RUN;

/*Merging clean-up exposure dataset with Clean-up Demo_Raw Datasets*/

PROC SORT DATA=DM4;
BY USUBJID;
RUN;

PROC SORT DATA=EX1;
BY USUBJID;
RUN;

DATA DM5;
MERGE DM4 (in=a) EX1 (in=b);
BY USUBJID;
If a;
RUN;

/*one to one proc sql could be used to create the DM7 above*/

/*PROC SQL;*/
/*CREATE TABLE DM8 as*/
/*SELECT **/
/*FROM DM6, EX1*/
/*WHERE DM6.USUBJID=EX1.USUBJID*/
/*ORDER BY DM6.USUBJID;*/
/*QUIT;*/

/*Merging Randomized datasets with the raw datasets*/

PROC SORT DATA=DM5;
BY SUBJID;
RUN;

PROC SORT DATA=raw.rnd;
BY SUBJID;
RUN;

DATA DM6;
MERGE DM5 (in=a) raw.rnd(in=b);
BY SUBJID;
IF a;
RUN;

DATA DM7;
SET DM6;
ARMCD=ARMDP;
ARM=ARMP;
ACTARMCD=ARMDA;
ACTARM=ARMA;
COUNTRY="IND";
KEEP STUDYID Domain USUBJID SUBJID SITEID RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFICDTC RFPENDTC DTHDTC	DTHFL INVNAM AGE AGEU SEX RACE ARMCD ARM ACTARMCD ACTARM COUNTRY;
RUN;
/*Creating labeling for the final DM SDTM datasets*/
PROC SQL;
CREATE TABLE DM_Final AS
SELECT
STUDYID  	"Study Identifier" 							length=8,
Domain   	"Domain Abbreviation" 						length=2,
USUBJID  	"Unique Subject Identifier" 				length=50,
SUBJID  	"Subject Identifier for the Study" 			length=50,
SITEID  	"Study Site Identifier" 					length=20,
RFSTDTC  	"Subject Reference Start Date/Time" 		length=25,
RFENDTC  	"Subject Reference End Date/Time" 			length=25,
RFXSTDTC  	"Date/Time of First Study Treatment"  		length=25,
RFXENDTC  	"Date/Time of Last Study Treatment" 		length=25,
RFICDTC 	"Date/Time of Informed Consent" 			length=25,
RFPENDTC 	"Date/Time of End of Participation " 		length=25,
DTHDTC 		"Date/Time of Death " 						length=25,
DTHFL  		"Subject Death Flag " 						length=2,
INVNAM  	"Investigator Name " 						length=100,
AGE  		"Age " 										length=8,
AGEU  		"Age Units " 								length=6,
SEX  		"Sex " 										length=2,
RACE  		"Race " 									length=100,
ARMCD  		"Planned Arm Code " 						length=100,
ARM  		"Description of Planned Arm " 				length=200,
ACTARMCD  	"Actual Arm Code " 							length=100,
ACTARM  	"Description of Actual " 					length=200,
COUNTRY  	"Country " 									length=50
FROM DM7;
QUIT;	

DATA SDTM.DM (label="Demographics");
SET DM_Final;
RUN;

libname xpt xport "C:\PROJECT\QPS3\SDTM\XPT\XPT_SDTM\DM.xpt";

DATA XPT.DM;
SET DM_Final;
RUN;

/*Creating the supplementary (SUPPDM) datasets for remaining variables*/

DATA SUPPDM;
SET DM5;
IF ETHOT NE "";
RDOMAIN="DM";
IDVAR="";
IDVARVAL="";
QNAM="RACEOTH";
QLABEL="Race, Other";
QVAL=compress(ETHOT);
QORIG="CRF";
QEVAL="";
KEEP STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL;
RUN;

/*Create label for the supp DM Datasets*/
PROC SQL;
CREATE TABLE SUPPDM1 AS 
SELECT
STUDYID "Study Identifier" Length=8,
RDOMAIN "Related Domain Abbreviation" Length=2,
USUBJID "Unique Subject Identifier" Length=50,
IDVAR "Identifying Variable" Length=8,
IDVARVAL "Identifying Variable Value" Length=40,
QNAM "Qualifier Variable Name" Length=8,
QLABEL "Qualifier Variable Label" Length=40,
QVAL "Data Value" Length=200,
QORIG "Origin" Length=20,
QEVAL "Evaluator" Length=40
FROM SUPPDM;
QUIT;

/*Creating the datasets lable using data-step*/
/*DATA SUPPDM1;*/
/*SET SUPPDM;*/
/*attrib*/
/*STUDYID label='Study Identifier' Length=$8.*/
/*RDOMAIN label='Related Domain Abbreviation' Length=$2.*/
/*USUBJID label='Unique Subject Identifier' Length=$50.*/
/*IDVAR label='Identifying Variable' Length=$8.*/
/*IDVARVAL label='Identifying Variable Value' Length=$40.*/
/*QNAM label= 'Qualifier Variable Name' Length=$8.*/
/*QLABEL label='Qualifier Variable Label' Length=$40.*/
/*QVAL label='Data Value' Length=$200.*/
/*QORIG label='Origin' Length=$20.*/
/*QEVAL label="Evaluator" Length=$40.;*/
/*;*/
/*RUN;*/

/*Move the supp dm dataset to SDTM folder*/

DATA SDTM.SUPPDM (label="Supplemental Demographic");
SET SUPPDM1;
RUN;

libname xpt xport "C:\PROJECT\QPS3\SDTM\XPT\XPT_SDTM\SUPPDM.xpt";

DATA XPT.SUPPDM;
SET SUPPDM1;
RUN;

