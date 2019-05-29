*****************************************
Filename: Extract_raw.sas
Author: Moses Adetoro
Date: 02 April 2019
SAS: SAS 9.4 (TS2M0)
Platform: Windows XP
Project/Study: 765/15
Description: <To Extract the raw Datasets>
Input: Raw data excel sheets
Output: Raw data SAS datasets
Macros Used: <No macros used>
------------------------------------------
MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>
******************************************;
/*Create a library to store Demographic datasets created*/
libname Raw "/home/adetoroseyi0/mylib/Clinical Project/QPS3/Raw";

/*Import excel dataset and convert it to sas datasets*/

PROC IMPORT datafile = "/home/adetoroseyi0/mylib/Clinical Project/QPS3/Raw/Demo_Raw.xlsx" out=raw.demo_raw dbms=xlsx replace;
RUN;

/*round up some variables*/

DATA Demo_raw1;
SET raw.demo_raw;
FORMAT AGEU 2.0 HT 3.0 WT 3.0;
RUN;

PROC PRINT DATA=Raw.Demo_raw1;
RUN;


/* Import Exposure datasets */

PROC IMPORT DATAFILE = "/home/adetoroseyi0/mylib/Clinical Project/QPS3/Raw/Exposure_Raw.xlsx" out=raw.exposure_raw dbms=xlsx replace;
RUN;

/* Import randomized datasets */

PROC IMPORT DATAFILE = "/home/adetoroseyi0/mylib/Clinical Project/QPS3/Raw/RND.xlsx" out=Raw.rnd dbms=xlsx replace;
RUN;


PROC IMPORT DATAFILE = "/home/adetoroseyi0/mylib/Clinical Project/QPS3/Raw/Vital_Signs.xlsx" out=Raw.Vital_Signs dbms=xlsx replace;
RUN;

PROC IMPORT DATAFILE = "/home/adetoroseyi0/mylib/Clinical Project/QPS3/Raw/vital_signs11.xlsx" out=Raw.Vital_Signs2 dbms=xlsx replace;
RUN;


