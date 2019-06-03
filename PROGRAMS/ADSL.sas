*****************************************
Filename: ADSL.sas
Author: Moses Adetoro
Date: 3 June 2019
SAS: SAS 9.4 (TS2M0)
Platform: Windows XP
Project/Study: 765/15
Description: <To develop the SDTM VS Datasets>
Input: SDTM.DM SDTM.EX SDTM.VS
Output: ADAM.ADSL
Macros Used: <No macros used>
------------------------------------------
MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>
******************************************;
libname Raw "C:\PROJECT\QPS3\RAW";
libname SDTM "C:\PROJECT\QPS3\SDTM";
libname ADAM "C:\PROJECT\QPS3\ADAM";

/* COPY ALL VARIABLES FROM SDTM.DM DATASETS */;

DATA DM1;
SET SDTM.DM;
BY USUBJID;
RUN;

/*WE NEED TO MERGE WITH SUPPDM IF THERE IS ANY. TRANSPONSE SUPPDM DATASETS */;

PROC SORT DATA=SDTM.SUPPDM;
BY STUDYID USUBJID;
RUN;

PROC TRANSPOSE DATA=SDTM.SUPPDM OUT=SUPPDMT PREFIX= RACEOTH;
BY STUDYID USUBJID;
VAR QVAL;
RUN;

DATA SUPPDMT1;
SET SUPPDMT;
DROP _NAME_ _LABEL_ RACEOTH2;
RUN;

DATA DM2 (RENAME=(RACEOTH1=RACEOTH));
MERGE DM1(IN=A) SUPPDMT1(IN=B);
BY STUDYID USUBJID;
IF A OR B;
RUN;
