*****************************************
Filename: LB.sas
Author: Moses Adetoro
Date: 13 MAY 2019
SAS: SAS 9.4 (TS2M0)
Platform: Windows XP
Project/Study: 765/15
Description: <To develop the SDTM LB Datasets>
Input: Raw.LB
Output: SDTM.LB
Macros Used: <No macros used>
------------------------------------------
MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>
******************************************;
libname Raw "C:\PROJECT\QPS3\RAW";
libname SDTM "C:\PROJECT\QPS3\SDTM";

DATA LB1;
SET RAW.LB;
LENGTH USUBJID $50.;
STUDYID="765/15";
Domain="LB";
SUBJID=STRIP(SUBJID);
SITEID="001";
USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID);
LBTESTCD=UPCASE(TESTCD);
LBTEST=PROPCASE(TEST);
LBCAT=CAT;
LBORRES=STRIP(VAL);
LBORRESU=STRIP(UNIT);
LBORNRLO=STRIP(PUT(LO, BEST.));
LBORNRHI=STRIP(PUT(UP, BEST.));
LBSTRESC=UPCASE(STD_VAL);
LBSTRESN=INPUT(N_STD_VAL, BEST.);
LBSTRESU=STRIP(STD_UNIT);
LBSTNRLO=INPUT(STD_LO, BEST.);
LBSTNRHI=INPUT(STD_UP, BEST.); 
LBSTNRC=C_STD_VAL;
LBNRIND=UPCASE(INDI);
LBFAST="Y";

IF VISIT="Screening" THEN DO;
VISITNUM=0;
VISIT=UPCASE(VISIT);
END;

IF VISIT="PERIOD-1" THEN DO;
VISITNUM=1;
VISIT=UPCASE(VISIT);
END;

IF VISIT="PERIOD-2" THEN DO;
VISITNUM=2;
VISIT=UPCASE(VISIT);
END;

LBDTC=PUT(DATE, IS8601DA.);
LBDTN=INPUT(LBDTC, IS8601DA.);
FORMAT LBDTN DATE9.;
RUN;

/*IMPORT DM DATASET FOR RFSTDTC*/;

DATA DM;
SET SDTM.DM;
RFSTDTN=DATEPART(INPUT(RFSTDTC, IS8601DT.));
FORMAT RFSTDTN DATE10.;
KEEP USUBJID RFSTDTC RFSTDTN;
RUN;

PROC SORT DATA=DM;
BY USUBJID;
RUN;

PROC SORT DATA=LB1;
BY USUBJID;
RUN;

DATA LB_DM;
MERGE LB1(IN=A) DM(IN=B);
BY USUBJID;
IF A;
RUN;

DATA LB2;
SET LB_DM;
IF RFSTDTN > . AND LBDTN > . THEN DO;
IF LBDTN < RFSTDTN THEN LBDY=LBDTN-RFSTDTN;
ELSE LBDY=LBDTN-RFSTDTN+1;
END;

IF VISITNUM=0 AND LBORRES NE "" THEN LBBLFL="Y";

RUN;

PROC SORT DATA=LB2;
BY USUBJID VISITNUM VISIT;
RUN;


DATA LB3;
SET LB2;
BY USUBJID VISITNUM VISIT;
IF FIRST.USUBJID=1 THEN LBSEQ=1;
ELSE LBSEQ+1;
RUN;

DATA LB4;
SET LB3;
KEEP STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES LBORRESU LBORNRLO
LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBBLFL LBFAST VISITNUM VISIT 
LBDTC LBDY
;
RUN;

PROC SQL;
CREATE TABLE LB5 AS
SELECT	
STUDYID 					"Study Identifier"						LENGTH=8,
DOMAIN						"Domain Abbreviation"					LENGTH=2,
USUBJID						"Unique Subject Identifier"				LENGTH=50,
LBSEQ						"Sequence Number"						LENGTH=8,
LBTESTCD					"Lab Test or Examination Short Name"		LENGTH=8,
LBTEST						"Lab Test or Examination Name"				LENGTH=40,
LBCAT						"Category for Lab Test"						LENGTH=100,
LBORRES						"Result or Finding in Original Units"		LENGTH=200,
LBORRESU					"Original Units"LENGTH=40,
LBORNRLO					"Reference Range Lower Limit in Orig Unit"	LENGTH=200,
LBORNRHI					"Reference Range Upper Limit in Orig Unit"	LENGTH=200,
LBSTRESC					"Character Result/Finding in Std Format"	LENGTH=200,
LBSTRESN					"Numeric Result/Finding in Standard Units"	LENGTH=8,
LBSTRESU					"Standard Units"							LENGTH=40,
LBSTNRLO					"Reference Range Lower Limit-Std Units"		LENGTH=8,
LBSTNRHI					"Reference Range Upper Limit-Std Units"		LENGTH=8,
LBSTNRC						"Reference Range for Char Rslt-Std Units"	LENGTH=200,
LBNRIND						"Reference Range Indicator"					LENGTH=25,
LBBLFL						"Baseline Flag"								LENGTH=2,
LBFAST						"Fasting Status"							LENGTH=2,
VISITNUM					"Visit Number"								LENGTH=8,
VISIT						"Visit Name"								LENGTH=200,
LBDTC						"Date/Time of Specimen Collection"			LENGTH=25,
LBDY						"Study Day of Specimen Collection"			LENGTH=8

FROM LB4;

QUIT;

DATA SDTM.LB(LABEL="Laboratory Test Results");
SET LB5;
RUN;

LIBNAME XPT XPORT "C:\PROJECT\QPS3\SDTM\XPT\XPT_SDTM\LB.XPT";

DATA XPT.LB;
SET LB5;
RUN;
