proc datasets lib=work kill nolist memtype=data;
quit;

libname RA 'C:\Users\KUTHURU\Downloads\Semester 3\RA work\Iteration-2'; run;
libname RA1 'C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-1'; run;

/*************************************************************************************/
/*                  Step 1. select all SEC filings                                   */
/*************************************************************************************/


proc sort data=ra1.filings; by date coname formtype; run;

**Import csv;
PROC IMPORT OUT=macdonald_header
            DATAFILE= "C:\Users\KUTHURU\Downloads\Laptop\Semester 3\RA work\Iteration-2\LM_EDGAR_10X_Header_1994_2018.csv" 
            DBMS=CSV REPLACE;
RUN;
*1,285,447 obs;

*convert numeric date format;
data macdonald_header1;
	set macdonald_header;
	newdate = input(put(file_date,8.),yymmdd8.);
	format newdate date9.;
run;

proc sort data=macdonald_header1; by cik form_type newdate; run;

*add lag zipcodes;
data macdonald_header1;
	set macdonald_header1;
    count=_N_;
	/* else lag_date=lag(newdate) and ba_zip9_1=lag(ba_zip9) and ma_zip9_1=lag(ma_zip9);*/
run;
	
proc sql;
	create table macdonald_header2 as 
	select distinct a.cik, a. comp_conf_name as comp_name, a.former_name, a.date_of_name_chg, a.form_type, a.ba_zip9, a.ba_street1, a.ba_street2, a.ba_city, a.ba_state, a.ma_zip9, a.ma_street1, a.ma_street2, a.ma_city, a.ma_state, a.file_date, a.newdate, 
	b.file_date as lag_file_date, b.newdate as lag_date, b.ba_zip9 as ba_zip9_1, b.ba_street1 as ba_street1_1, b.ba_street2 as ba_street2_1, b.ba_city as ba_city_1, b.ba_state as ba_state_1, 
	b.ma_zip9 as ma_zip9_1, b.ma_street1 as ma_street1_1, b.ma_street2 as ma_street2_1, b.ma_city as ma_city_1, b.ma_state as ma_state_1, a.count
	from macdonald_header1 as a left join macdonald_header1 as b
	on a.cik=b.cik and a.form_type=b.form_type and a.count=b.count+1;
quit;
*1,285,447 obs;

*delete first observations;
data macdonald_header2;
	set macdonald_header2;
	if missing(lag_date)=1 then delete;
run;
*1,152,914 obs, 130k obs deleted;


*distinct file-types available;
proc sql;
	create table filings as
	select distinct form_type
	from macdonald_header1;
quit;
*18 types;

*include only 10-kx filings;
data macdonald_header2;
	set macdonald_header2;
	where form_type in ("10-K");
	/*, "10-K/A", "10-K40", "10-K405/A", 
        "10-KSB", "10-KSB/", "10-KT", "10-KT/", "10KSB", 
        "10KSB/A", "10KSB4", "10KSB40/A", "10KT40", 
        "10KT405/A"); */
run;
*210552 obs;

*Companies whose business address changed;
*1. By business address;

data macdonald_header3;
	set macdonald_header2;
	if missing(ba_zip9)=0 and missing(ba_zip9_1)=0;
run;

data macdonald_header3;
	set macdonald_header3;
	if ba_zip9 = ba_zip9_1 then delete;
run;
*12338 obs;
 
proc sort data=macdonald_header3; by count; run;

*convert zipcodes to 5 digits;
data macdonald_header3;
	set macdonald_header3;
	format ba_zip9 $5. ba_zip9_1 $5.;
run;

*converts characters to numbers;
data macdonald_header3;
	set macdonald_header3;
	ba_zip9_new = input(ba_zip9,5.);
	ba_zip9_new1 = input(ba_zip9_1,5.);
run;
*12338 obs;

data macdonald_header3;
	set macdonald_header3;
	if missing(ba_zip9_new)=1 or ba_zip9_new=0 then delete;
	if missing(ba_zip9_new1)=1 or ba_zip9_new1=0 then delete;
run;
*11193 obs;

*unique firms;
proc sql;
	create table firm as
	select distinct cik
	from macdonald_header3
	group by cik;
quit;
*7999 rows;

*number of obs by year;
proc sql;
	create table by_year as
	select distinct year(newdate) as year, count(distinct cik) as firms
	from macdonald_header3
	group by year(newdate);
quit;

/*data macdonald_header4;
	format cik form_type newdate ba_zip9 lag_date ba_zip9_1;
	set macdonald_header3;
	if year(newdate)=2018;
	drop count ma_zip9 ma_zip9_1 ba_zip9_new ba_zip9_new1;
run;

proc sort data=macdonald_header4 nodupkey; by cik; run; */


















