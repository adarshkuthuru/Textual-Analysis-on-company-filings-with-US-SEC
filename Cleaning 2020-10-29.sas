proc datasets lib=work kill nolist memtype=data;
quit;

libname RA 'C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-3'; run;
libname RA1 'C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-1'; run;
libname RA2 'C:\Users\KUTHURU\Desktop\Downloaded Files'; run;
libname RA4 'C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-4'; run;


***Cleaning results for first 50000 observations;
**Import csv;
PROC IMPORT OUT=matches
            DATAFILE= "C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-4\matches_50000.csv" 
            DBMS=CSV REPLACE;
RUN;

data WORK.MATCHES    ;
      %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
      infile 'C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA
 work\Iteration-4\matches_50000.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;
				informat V1 $38. ;
				informat V2 DATE11. ;
				informat V3 $9. ;
				informat V4 $26. ;
				informat V5 $500.;
				informat V6 $500.;
				informat V7 $500. ;
				informat V8 $500. ;
				informat V9 $500. ;
				informat V10 $500. ;
				informat V11 $500. ;
				informat V12 $500. ;
				informat V13 $500. ;
				informat V14 $500. ;
				informat V15 $500. ;
				informat V16 $500. ;
				informat V17 $500. ;
				informat V18 $500. ;
				informat V19 $500. ;
				informat V20 $500. ;
				informat V21 $500. ;
				informat V22 $500. ;
				informat V23 $500. ;
				informat V24 $500. ;
				format V1 $38. ;
				format V2 DATE11. ;
				format V3 $9. ;
				format V4 $26. ;
				format V5 $496. ;
				format V6 $341. ;
				format V7 $500. ;
				format V8 $500. ;
				format V9 $500. ;
				format V10 $500. ;
				format V11 $500. ;
				format V12 $500. ;
				format V13 $500. ;
				format V14 $500. ;
				format V15 $500. ;
				format V16 $500. ;
				format V17 $500. ;
				format V18 $500. ;
				format V19 $500. ;
				format V20 $500. ;
				format V21 $500. ;
				format V22 $500. ;
				format V23 $500. ;
				format V24 $500. ;
      input
                  V1  $
                  V2
                  V3  $
                  V4  $
                  V5  $
                  V6  $
                  V7  $
                  V8  $
                  V9  $
                  V10  $
                  V11  $
                  V12  $
                  V13  $
                  V14  $
                  V15  $
                  V16  $
                  V17  $
                  V18  $
                  V19  $
                  V20  $
                  V21  $
                  V22  $
                  V23  $
                  V24  $
      ;
      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
      run;


*sort the dataset;
data matches; set matches; format v2 date9.; run;
proc sort data=matches; by v3 v2; run;

data matches; set matches; year=year(v2); nrow=_N_;run;
*1085 obs;

*add lag year variable;
proc sql;
	create table matches1 as
	select distinct a.*,b.year as lag_year
	from matches as a left join matches as b
	on a.v3=b.v3 and a.nrow=b.nrow+1
	order by v3, v2;
quit;

*find difference between current and lag year;
data matches1; set matches1; diff=year-lag_year; run;
proc sort data=matches1; by v3 v2; run;

*keep the first observation and delete other duplicates by firm;
proc sort data=matches1 nodupkey; by v3 v5 v6; run;
*875 obs;
proc sort data=matches1; by v3 v2; run;

*Export csv;
proc export data=matches1 outfile="C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Ran Duchin\Results_50000.csv" 
dbms=csv replace;
run;
