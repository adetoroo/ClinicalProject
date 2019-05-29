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
libname Raw "C:\Users\User\Google Drive\SAS Programming Training\Indian-Online Training\Clinical\LIVE PROJECT\QPS3\RAW";
libname SDTM "C:\Users\User\Google Drive\SAS Programming Training\Indian-Online Training\Clinical\LIVE PROJECT\QPS3\SDTM";

/*derive the sdtm dm variables*/

data DM1;
set raw.demo_raw1;
STUDYID="765/15";
Domain="DM";
SUBJID=strip(SUBJID);
SITEID="001";
USUBJID=strip(STUDYID)||"-"||strip(SITEID)||"-"||strip(SUBJID);
run;

