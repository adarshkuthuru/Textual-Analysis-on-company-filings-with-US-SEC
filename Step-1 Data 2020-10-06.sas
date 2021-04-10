proc datasets lib=work kill nolist memtype=data;
quit;

libname RA 'C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3'; run;
libname RA1 'C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-1'; run;
libname RA2 'C:\Users\KUTHURU\Desktop\Downloaded Files'; run;


/*************************************************************************************/
/*                  Step 1. select all SEC filings from ra.filings                   */
/*************************************************************************************/


proc sort data=ra1.filings; by date coname formtype; run;
*1,919,271 obs;

*include only 10-k related filings;
proc sql;
    create table a_10k as
    select distinct *
    from ra1.filings 
    where formtype IN ("10-K", "10-K/A", "10-K405", "10-K405/A", 
        "10-KSB", "10-KSB/A", "10-KT", "10-KT/A", "10KSB", 
        "10KSB/A", "10KSB40", "10KSB40/A", "10KT405", 
        "10KT405/A");
quit;
*310405 obs;

*prepend the html path;
DATA a_10k;
        SET a_10k;
		path='https'||':'||'//'||'www'||'.'||'sec'||'.'||'gov'||'/'||'Archives'||'/'||TRIM(filename);
		filename1=SCAN(filename,-1,'/');
        n=_N_;;
RUN;
DATA a_10k;
        SET a_10k;
		path=TRIM(path);
RUN;
*change directory path;
DATA a_10k;
        SET a_10k;
		filename2='C'||':'||'/'||'Users'||'/'||'KUTHURU'||'/Desktop'||'/'||'Downloaded Files'||'/'||'Full'||'/'||TRIM(filename1);
		n=_N_;
RUN;

DATA ra2.a_10k;
        SET a_10k;
run;

*Group number of firms by year;
proc sql;
	create table year as
	select distinct year(date) as year, count(distinct cik) as nfirm
	from a_10k
	group by year(date);
quit;

**Generate macdonald_header3 file with code from Iteration-2 folder and merge with a_10k;
proc sql;
	create table a_10k1 as
	select distinct a.*, b.*
	from a_10k as a, macdonald_header3 as b
	where a.cik=b.cik and a.date=b.newdate;
quit;
*11398 obs;
proc sort data=a_10k1 nodupkey;by cik date form_type; run;
*11193 obs;


*********************************************************************************
		Create random sample of 500 obs and download files
*********************************************************************************;
*create a random sample which contains 500 of the firms from full sample; 
PROC SURVEYSELECT DATA=a_10k1 noprint OUT=random METHOD=SRS
SAMPSIZE=500 SEED=11193;
RUN;
*500 obs;

Data random;
        Set random;
		n=_N_;
run;

/* Store the number of files in a macro variable "num" */
proc sql noprint;
        select count(*) into :num from random;
quit;

**instead of printing log, it saves log file at mentioned location;
proc printto log="C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\log.log";
run;

/* Create a macro to iterate over the filenames and download txt files from EDGAR.*/
options mcompilenote=ALL;
options SYMBOLGEN MPRINT MLOGIC;
%LET k=1;
%macro doit;
    %do j=1 %to &num;

        proc sql noprint;
            select path into :path from random where n=&j;
        quit;

		proc sql noprint;
            select filename1 into :filename1 from random where n=&j;
        quit;

**Downloads text file from web;
filename out "C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\Downloaded Files\&filename1";
 
proc http
 url="%trim(&path)" /*trims trailing blanks after url link */
 method="get" out=out;
run;

%end;
%mend doit;
%doit

*re-enabling the log;
PROC PRINTTO PRINT=PRINT LOG=LOG ;
RUN;


*Export csv;
proc export data=random outfile="C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\Data.csv" 
dbms=csv replace;
run;


*********************************************************************************
		Importing verified sample from R and checking for false positives
*********************************************************************************;
***Import xlsx;
PROC IMPORT OUT= sample
            DATAFILE= "C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\sample.xlsx" 
            DBMS=EXCEL REPLACE;
sheet="sample";
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

**Import csv with random sample data generated earlier;
PROC IMPORT OUT= data
            DATAFILE= "C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\Data.csv" 
            DBMS=CSV REPLACE;
RUN;

*Merge the above datasets;
proc sql;
	create table data as
	select distinct a.*,b.*
	from data as a left join sample as b
	on a.cik=b.cik and a.date=b.Date_of_Filing;
quit;

*Merge above dataset with a_10k1;
proc sql;
	create table data as
	select distinct a.*,b.*
	from data as a left join a_10k1 as b
	on a.cik=b.cik and a.date=b.date;
quit;

*Include lag filename in above dataset;
proc sql;
	create table data as
	select distinct a.*,b.filename as filename_1, b.filename1 as filename1_1, b.filename2 as filename2_1
	from data as a left join a_10k as b
	on a.cik=b.cik and a.lag_date=b.date;
quit;
proc sort data=data nodupkey; by cik date; run;

*prepend the html path;
DATA data;
        SET data;
		path_1='https'||':'||'//'||'www'||'.'||'sec'||'.'||'gov'||'/'||'Archives'||'/'||TRIM(filename_1);
		filename1=SCAN(filename,-1,'/');
        n=_N_;;
RUN;
DATA a_10k;
        SET a_10k;
		path_1=TRIM(path_1);
		filename2_1='C'||':'||'/'||'Users'||'/'||'KUTHURU'||'/Downloads'||'/'||'Laptop'||'/'||'Semester 3'||'/'||'RA work'||'/'||'Iteration-3'||'/'||'Downloaded Files'||'/'||TRIM(filename1_1);
RUN;
**Download lag filenames from EDGAR;
Data data;
        Set data;
		n=_N_;
run;

/* Store the number of files in a macro variable "num" */
proc sql noprint;
        select count(*) into :num from data;
quit;

**instead of printing log, it saves log file at mentioned location;
proc printto log="C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\log.log";
run;

/* Create a macro to iterate over the filenames and download txt files from EDGAR.*/
options mcompilenote=ALL;
options SYMBOLGEN MPRINT MLOGIC;
%LET k=1;
%macro doit;
    %do j=1 %to &num;

        proc sql noprint;
            select path_1 into :path from data where n=&j;
        quit;

		proc sql noprint;
            select filename1_1 into :filename1 from data where n=&j;
        quit;

**Downloads text file from web;
filename out "C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\Downloaded Files\&filename1";
 
proc http
 url="%trim(&path)" /*trims trailing blanks after url link */
 method="get" out=out;
run;

%end;
%mend doit;
%doit

*re-enabling the log;
PROC PRINTTO PRINT=PRINT LOG=LOG ;
RUN;

*Export csv;
proc export data=data outfile="C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\sample_final.csv" 
dbms=csv replace;
run;


*********************************************************************************
		Download files for all 11193 companies;
*********************************************************************************;

Data a_10k1;
        Set a_10k1;
		n=_N_;
run;

/* Store the number of files in a macro variable "num" */
proc sql noprint;
        select count(*) into :num from a_10k1;
quit;

**instead of printing log, it saves log file at mentioned location;
proc printto log="C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\log.log";
run;

/* Create a macro to iterate over the filenames and download txt files from EDGAR.*/
options mcompilenote=ALL;
options SYMBOLGEN MPRINT MLOGIC;
%LET k=1;
%macro doit;
    %do j=1 %to &num;

        proc sql noprint;
            select path into :path from a_10k1 where n=&j;
        quit;

		proc sql noprint;
            select filename1 into :filename1 from a_10k1 where n=&j;
        quit;

**Downloads text file from web;
filename out "C:\Users\KUTHURU\Desktop\Downloaded files\&filename1";
 
proc http
 url="%trim(&path)" /*trims trailing blanks after url link */
 method="get" out=out;
run;

%end;
%mend doit;
%doit

*re-enabling the log;
PROC PRINTTO PRINT=PRINT LOG=LOG ;
RUN;

*change directory path;
DATA a_10k1;
        SET a_10k1;
		filename2='C'||':'||'/'||'Users'||'/'||'KUTHURU'||'/Desktop'||'/'||'Downloaded Files'||'/'||TRIM(filename1);
RUN;

*Export csv;
proc export data=a_10k1 outfile="C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3\data1.csv" 
dbms=csv replace;
run;
