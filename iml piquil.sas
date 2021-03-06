data piquil4; set piquil3; 	
 	keep aspect bcat covm elev heig hydrn nilvox npitax nquma3 nqumax plot year prpo slope soileb;
run;  * N = 1753;
proc sort data=piquil4; by year prpo plot bcat aspect hydrn soileb; run;
/* proc freq data=piquil4; tables soileb; run; *1395 sand, 358 gravel;
   proc contents data=piquil4; run; 
   proc print data=piquil4; title 'piquil4'; run; */

* Contents:
 				   	   #    Variable    Type    Len    Format     Informat
                       10   aspect      Num       8
                       3    bcat       Num       8
                       5    covm        Num       8
                       8    elev        Num       8    BEST12.    BEST32.
                       6    heig        Num       8    BEST12.    BEST32.
                      11    hydrn       Num       8
                      15    nilvox      Num       8
                      14    npitax      Num       8
                      12    nquma3      Num       8
                      13    nqumax      Num       8
                       1    plot        Num       8    BEST12.    BEST32.
                       4    prpo        Num       8
                       9    slope       Num       8    BEST12.    BEST32.
                       7    soileb      Num       8    BEST12.    BEST32.
                       2    year        Num       8    BEST12.    BEST32
;

proc means data=piquil4 mean noprint; by year plot bcat aspect hydrn soileb;
  var nilvox npitax nquma3 nqumax covm elev slope heig;
  output out=piquil5 mean = milvox mpitax mquma3 mqumax mcov elev slope mhgt;
run;
data piquil6; set piquil5; drop _TYPE_; 
*proc print data=piquil6; title 'piquil6'; run; *N=202;

/* 
*Just messing around with dataset;
data piquil7; set piquil6; if year >2011; run;
proc plot data=piquil6; plot mcoun*mcov; run;
proc glm data=piquil6; title 'post';  
	model mcoun = year;
	output out=glmout2 r=ehat;
run; 
*/

proc iml;

inputyrs = {2002, 2003, 2005, 2006, 2008, 2010, 2011, 2012, 2013, 2014};
nyrs = nrow(inputyrs);  * print nyrs; *10 yrs;

use piquil6; read all into mat1;
* print mat1;

nrecords = nrow(mat1);   *print nrecords; *N = 191;

mat2 = j(nrecords,23,.); * create mat2 has 191 rows, 25 columns, each element=0;
do i = 1 to nrecords;    * record by record loop;
  do j = 1 to nyrs;      * yr by yr loop;
    if (mat1[i,1] = inputyrs[j]) then mat2[i,1] = j;  * pref in col 1;
  end;                   * end yr by yr loop;
end;                     * end yr by yr loop;
* print mat2;

mattemp = j(nrecords,2,0);
do i = 1 to nrecords;
  if mat2[i,1] = 1     then mattemp[i,1] = 1;
  if mat2[i,1] = nyrs  then mattemp[i,2] = 1;
end;
* print mattemp;
nyr1obs = sum(mattemp[,1]); *print nyr1obs;  * how many year1? (3);
nyr2obs = sum(mattemp[,2]); *print nyr2obs;  * how many year2? (43);

* variables the same each year: aspect, bcat, elev, hydrn, plot, slope, soileb, 
  variables that change each year: _FREQ_, covm, mhgt, year, milvox, mpitax, mqumax,
								mquma3;

*order of variables in mat1: year, prpo, plot, bcat,  aspect, hydr, soileb, _FREQ_, ilvo, pita, quma3, qumax, 
	mcov, elev, slope, mhgt	;

* fill mat2; * col1 already has first yr;
do i = 1 to nrecords;    * record by record loop;
  time1 = mat2[i,1];
  time2 = time1 + 1;
  mat2[i,2] = time2;	
  mat2[i,3] = mat1[i,1];   * year1;
  mat2[i,5] = mat1[i,2];   * plot;
  mat2[i,6] = mat1[i,3];   * bcat;
  mat2[i,7] = mat1[i,4];   * aspect;
  mat2[i,8] = mat1[i,5];   * hydrn;
  mat2[i,9] = mat1[i,6];   * soileb;
  mat2[i,10] = mat1[i,13]; * elev;
  mat2[i,11] = mat1[i,14]; * slope;
  mat2[i,12] = mat1[i,8];  * milvo1;
  mat2[i,14] = mat1[i,9];  * mpita1;
  mat2[i,16] = mat1[i,10]; * mqum31;
  mat2[i,18] = mat1[i,11]; * mqumx1;
  mat2[i,20] = mat1[i,12]; * covm1;
  mat2[i,22] = mat1[i,15]; * mhgt1;
end;
* print mat2;

do i = 1 to nrecords;
  plot = mat2[i,5]; time2 = mat2[i,2];
  do j = 1 to nrecords;
    if (mat2[j,5] = plot & mat2[j,1] = time2) then do;
	  *print i,j;
  	  mat2[i,4]  = mat2[j,3];  * year2;
	  mat2[i,13] = mat2[j,12]; * milvo2;
  	  mat2[i,15] = mat2[j,14]; * mpita2;
  	  mat2[i,17] = mat2[j,16]; * mqum32;
  	  mat2[i,19] = mat2[j,18]; * mqumx2;
	  mat2[i,21] = mat2[j,20]; * covm2;
	  mat2[i,23] = mat2[j,22]; * mhgt2;
	                                                  end;
  end;  * end j loop;
end;    * end i loop;
* print mat2;

cnames1 = {'time1', 'time2', 'year1', 'year2', 'plot', 'bcat', 'aspect', 'hydr', 'soil', 'elev', 
			'slope', 'ilvo1', 'ilvo2', 'pita1', 'pita2', 'qum31', 'qum32', 'quma1', 'quma2', 
			'covm1', 'covm2', 'mhgt1', 'mhgt2'};
create seedpairs from mat2 [colname = cnames1];
append from mat2;
 
quit; run;

/* 
proc print data=seedpairs; title 'seedpairs'; run; *N=202;
proc freq data=seedpairs; tables soil; run; 	   * 156 sand, 46 gravel;
*/
*******Need to fix height---right now, just one mean height for all species/plot/year;


*reorganizing seedpairs;
data seedpairspp; set seedpairs;
	if (year1<2011)  then yrcat='pref'; 
	if (year1>=2011) then yrcat='post';	
	drop time1 time2 year2 ilvo2 pita2 qum32 quma2 covm2 mhgt2; 
	rename year1=year covm1=caco ilvo1=ilvo pita1=pita qum31=qum3 quma1=quma mhgt1=heig;
run;
data seedspref;  set seedpairspp;
	if yrcat='pref';
run; *N=78;
data seedspost; set seedpairspp;
	if yrcat='post'; 
run; *N=124;
*pooling data in seedspre;
proc sort  data=seedspref; by plot bcat elev hydr slope soil aspect;
proc means data=seedspref n mean noprint; by plot bcat elev hydr slope soil aspect;
	var ilvo pita qum3 quma caco heig;
	output out=mseedspref n=nilv npit nqm3 nqma ncov nhgt 
		   			  mean=milv mpit mqm3 mqma mcov mhgt;
run;
*proc print data=mseedspref; title 'mseedspref'; run; *N=40;

*structure 1;
proc sort data=seedspost; by plot bcat elev hydr slope soil aspect;
proc sort data=mseedspref; by plot bcat elev hydr slope soil aspect; run;
data seedsmerge1; merge seedspost mseedspref; by plot bcat elev hydr slope soil aspect; 	
	drop _TYPE_ _FREQ_ yrcat; 
run;
*proc print data=seedsmerge1; title 'seedsmerge1'; run;	*N=133;
*proc contents data=seedsmerge1; run;


*structure 2;
proc sort data=seedspost; by plot year;	run;
data dat2012; set seedspost; if year=2012; 
	 rename pita=pita12 quma=quma12 ilvo=ilvo12 qum3=qum312 caco=cov12;  
data dat2013; set seedspost; if year=2013; 
	 rename pita=pita13 quma=quma13 ilvo=ilvo13 qum3=qum313 caco=cov13; 
data dat2014; set seedspost; if year=2014; 
	 rename pita=pita14 quma=quma14 ilvo=ilvo14 qum3=qum314 caco=cov14; 
data prefavg; set mseedspref; 
	 rename nilv=nilvopre npit=npitapre nqm3=nquma3pre nqma=nqumapre ncov=ncovpre nhgt=nhgtpre 
		   	milv=milvopre mpit=mpitapre mqm3=mquma3pre mqma=mqumapre mcov=mcovpre mhgt=mhgtpre;
run;
data seedsmerge2; merge prefavg dat2012 dat2013 dat2014; by plot; drop year; run;
*proc print data=seedsmerge2; title 'seedsmerge2'; run; *N=55;

/*
proc export data=seedsmerge2
   outfile='\\austin.utexas.edu\disk\eb23667\ResearchSASFiles\seedsmerge2.csv'
   dbms=csv
   replace;
run;
*/












