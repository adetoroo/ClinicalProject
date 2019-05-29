*****************************************
Filename: Exposure_raw.sas
Author: Moses Adetoro
Date: 17 April 2019
SAS: SAS 9.4 (TS2M0)
Platform: Windows XP
Project/Study: 765/15
Description: <To develop the SDTM EX Datasets>
Input: Raw.Exposure_Raw
Output: SDTM.EX
Macros Used: <No macros used>
------------------------------------------
MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>
******************************************;
libname Raw "C:\PROJECT\QPS3\RAW";
libname SDTM "C:\PROJECT\QPS3\SDTM";

DATA EX_1;
SET Raw.Exposure_Raw;
STUDYID="765/15";
Domain="EX";
SUBJID=strip(SUBJID);
SITEID="001";
USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID);
EXTRT=STRIP(TRT);
EXDOSE=INPUT(SUBSTR(DOSE, 1,2), best.);
EXDOSTXT=STRIP(DOSEN);
EXDOSU=LOWCASE(STRIP(SUBSTR(DOSE,3)));
EXDOSFRM=UPCASE(STRIP(DOSTP));	
EXDOSFRQ=UPCASE("ONCE");
EXROUTE=UPCASE("ORAL");
EXFAST=UPCASE("Y");
EPOCH="TREATMENT";
x=input(DSDT, mmddyy10.);
FORMAT x mmddyy10.;
EXSTDTC=PUT(x, is8601da.)||"T"||PUT(DSDTM, tod8.);
EXENDTC=PUT(x, is8601da.)||"T"||PUT(DSDTM, tod8.);
DROP X;
EXSTDTN=DATEPART(INPUT(EXSTDTC,IS8601DT.));
FORMAT EXSTDTN DATE10.;

EXENDTN=DATEPART(INPUT(EXENDTC,IS8601DT.));
FORMAT EXENDTN DATE10.;
   
RUN;

DATA DM1;
SET SDTM.DM;
RFSTDTN=DATEPART(INPUT(RFSTDTC, IS8601DT.));
FORMAT RFSTDTN DATE10.;
KEEP USUBJID RFSTDTC RFSTDTN;
RUN;


PROC SORT DATA=DM1;
BY USUBJID;
RUN;

PROC SORT DATA=EX_1;
BY USUBJID;
RUN;

DATA DM_EX;
MERGE DM1(IN=A) EX_1 (IN=B);
BY USUBJID;
IF B;
RUN;

DATA EX_2;
SET DM_EX;

IF EXSTDTN > . AND RFSTDTN > . THEN DO;
IF EXSTDTN < RFSTDTN THEN EXSTDY=EXSTDTN-RFSTDTN;
ELSE EXSTDY=EXSTDTN-RFSTDTN +1;
END;

IF EXENDTN > . AND RFSTDTN > . THEN DO;
IF EXENDTN < RFSTDTN THEN EXENDY=EXENDTN-RFSTDTN;
ELSE EXENDY=EXENDTN-RFSTDTN+1;
END;

RUN;

DATA EX_3;
SET EX_2;
EXDUR1=EXENDY-EXSTDY+1;
EXDUR=COMPRESS("P"||PUT(EXDUR1, BEST.)||"D");
RUN;

DATA EX_4;
SET EX_3;

DATA EX_5;
SET EX_4;
BY USUBJID EXSTDTC;
IF FIRST.USUBJID=1 THEN EXSEQ=1;
ELSE EXSEQ+1;
RUN;

DATA EX_6;
SET EX_5;
KEEP STUDYID	DOMAIN	USUBJID	EXSEQ	EXTRT	EXDOSE	EXDOSTXT	EXDOSU	EXDOSFRM	EXDOSFRQ	EXROUTE	EXFAST	EPOCH	EXSTDTC	EXENDTC	EXSTDY	EXENDY	EXDUR
;
RUN;

PROC SQL;
CREATE TABLE EX_7 AS
SELECT
STUDYID		"Study Identifier"					Length=	8,
DOMAIN		"Domain Abbreviation"				LENGTH=	2,
USUBJID		"Unique Subject Identifier"			LENGTH=	50,
EXSEQ		"Sequence Number"					LENGTH=	8,
EXTRT		"Name of Treatment"					LENGTH=	200,
EXDOSE		"Dose"								LENGTH=	8,
EXDOSTXT	"Dose Description"					LENGTH=	40,
EXDOSU		"Dose Units"						LENGTH=	40,
EXDOSFRM	"Dose Form"							LENGTH=	80,
EXDOSFRQ	"Dosing Frequency per Interval"		LENGTH=	40,
EXROUTE		"Route of Administration"			LENGTH=	40,
EXFAST		"Fasting Status"					LENGTH=	2,
EPOCH	 	"Epoch	"							LENGTH=	40,
EXSTDTC		"Start Date/Time of Treatment"		LENGTH=	25,
EXENDTC	"	End Date/Time of Treatment	"	LENGTH=	25	,
EXSTDY	"	Study Day of Start of Treatment	"	LENGTH=	8	,
EXENDY	"	Study Day of End of Treatment	"	LENGTH=	8	,
EXDUR	"	Duration of Treatment	"	LENGTH=	25

FROM EX_6;
QUIT;


DATA SDTM.EX_FINAL(LABEL=Exposure);
SET EX_7;
RUN;

LIBNAME XPT XPORT "C:\PROJECT\QPS3\SDTM\XPT\XPT_SDTM\EX.XPT";

DATA XPT.EX;
SET EX_7;
RUN;










