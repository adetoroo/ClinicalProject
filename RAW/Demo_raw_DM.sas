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
libname Raw "C:\PROJECT\QPS3\RAW";

/*Import excel dataset and convert it to sas datasets*/

proc import datafile = "C:\PROJECT\QPS3\RAW\Demo_Raw.xlsx" out=raw.demo_raw dbms=xlsx replace;
run;

/*round up some variables*/

data Raw.Demo_raw1;
set Raw.Demo_raw;
format AGEU 2.0 HT 3.0 WT 3.0;
output;
run;

proc import datafile = "C:\PROJECT\QPS3\RAW\exposure_Raw.xlsx" out=raw.exposure_raw dbms=xlsx replace;
run;

proc import datafile = "C:\PROJECT\QPS3\RAW\rnd.xlsx" out=raw.rnd dbms=xlsx replace;
run;

