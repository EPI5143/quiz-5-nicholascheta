libname classdat "C:\Users\nicho\Dropbox\class_data"; *create folders for data;
libname ex "C:\Users\nicho\Documents\Epidemiology\Winter 2020\Large Databases\work folder\data";
data ex.abstracts; *acquire modifiable abstract dataset;
set classdat.Nhrabstracts;
run;
data ex.spine; *create spine dataset;
set ex.abstracts;
where datepart(hraadmdtm) between '01Jan2003'd and'31dec2004'd;
keep hraAdmDtm hraencwid;
run;
proc sql;    *sql alternative to creating spine dataset;
create table ex.sqlspine as
select hraencwid, hraadmdtm
from ex.abstracts
where datepart(hraadmdtm) between '01Jan2003'd and '31dec2004'd;
run;
data ex.diagnosis; *acquire modifiable diagnosis dataset;
set classdat.Nhrdiagnosis;
run;
data ex.diabetes; *creates diagnosis code variable;
set ex.diagnosis; 
by hdghraencwid;
if hdgcd in: ('250', 'E11', 'E10') then DM=1;
else DM=.;
keep hdghraencwid dm;
run;
proc sort data=ex.diabetes;
by hdghraencwid;
run;
proc transpose data=ex.diabetes out=ex.flat; *flatten dataset;
by hdghraencwid;
var DM;
run;
data ex.fixedflat; *organizes dm;
set ex.flat;
if col1=1 or col2=1 or col3=1 or col4=1 or col5=1
or col6=1 or col7=1 or col8=1 or col9=1 or col10=1
or col11=1 or col12=1 or col13=1 or col14=1 or col15=1
or col16=1 or col17=1 or col18=1 or col19=1 or col20=1
or col21=1 or col22=1 or col23=1 or col24=1 then dm=1;
else dm=0;
run;
proc sql; *merge dataset;
create table ex.linked as
select s.hraencwid as id, f.dm
from ex.spine as s
left join ex.fixedflat as f
on s.hraencwid = f.hdghraencwid;
quit;
data ex.finallinked; *adds missing data to the denominator;
set ex.linked;
if dm=. then dm=0;
run;
proc freq data=ex.finallinked; *generated frequency table;
table dm;
run;

