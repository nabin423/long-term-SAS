proc sort data=piquil2; by prpo plot burn aspect hydrn soiln; run; *N=207;

  keep plot sspp burn coun prpo covm heig elev slope aspect hydrn soiln subp;


proc means data=piquil2 mean noprint; by prpo plot burn aspect hydrn soiln;	
  var covm elev heig slope; 
  output out=piquil3 mean = mcoun covm elev mhgt slope;
* proc print data=piquil3; title 'piquil3';
run; *N=83;
data piquil4; set piquil3; drop _TYPE_; run;

/*
proc print data=piquil4; run;
proc contents data=piquil4; run;
 					   #    Variable    Type    Len    Format     Informat
         			   9    aspect      Char      4
                       3    burn        Num       8
                       5    covm        Num       8
                       7    elev        Num       8    BEST12.    BEST32.
                      10    hydr        Char      1    $1.        $1.
                      14    nilvox      Num       8
                      13    npitax      Num       8
                      11    nquma3      Num       8
                      12    nqumax      Num       8
                      18    pailvox     Num       8
                      17    papitax     Num       8
                      15    paquma3     Num       8
                      16    paqumax     Num       8
                       1    plot        Num       8    BEST12.    BEST32.
                       4    prpo        Num       8
                       8    slope       Num       8    BEST12.    BEST32.
                       6    soil        Char      4
                       2    year        Num       8    BEST12.    BEST32.

*/

proc iml;

inputyrs = {1,2};
nyrs = nrow(inputyrs);  * print nyrs; *2 yrs;

use sandpost2; read all into mat1;
* print mat1;

nrecords = nrow(mat1); *print nrecords; *N = 46;

mat2 = j(nrecords,16,.); * create mat2 has 46 rows, 16 columns, each element=0;
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
nyr1obs = sum(mattemp[,1]); *print nyr1obs;  * how many in 1st yr? (23);
nyr2obs = sum(mattemp[,2]); *print nyr2obs;  * how many in last yr? (23);

* variables same each year: burn, elev, hydr, plot, slope, soil, sspp, subp,
  variables change each year: covm, mcoun, mhgt, prpo, freq

prpo, plot, burn, hydrn, soiln, freq, mcoun, covm, elev, mhgt, slope
;

* fill mat2; * col1 already has first yr;
do i = 1 to nrecords;    * record by record loop;
  time1 = mat2[i,1];
  time2 = time1 + 1;
  mat2[i,2] = time2;	
  mat2[i,3] = mat1[i,2];   * plot;
  mat2[i,4] = mat1[i,3];   * burn;
  mat2[i,5] = mat1[i,4];   * hydrn;
  mat2[i,6] = mat1[i,5];   * soiln;
  mat2[i,7] = mat1[i,9];  * elev;
  mat2[i,8] = mat1[i,11];  * slope;
  mat2[i,9] = mat1[i,8];   * covm1;
  mat2[i,11] = mat1[i,7];   * mcoun1;
  mat2[i,13] = mat1[i,10];  * mhgt1;
  mat2[i,15] = mat1[i,6];   * _FREQ_1;
end;
* print mat2;

do i = 1 to nrecords;
  plot = mat2[i,3]; time2 = mat2[i,2];
  do j = 1 to nrecords;
    if (mat2[j,3] = plot & mat2[j,1] = time2) then do;
	  *print i,j;
	  mat2[i,10] = mat2[j,9];   * variable covm2;
	  mat2[i,12] = mat2[j,11];	 * variable mcoun2;
	  mat2[i,14] = mat2[j,13];	 * variable mhgt2;
	  mat2[i,16] = mat2[j,15];	 * variable _FREQ_2;
	                                                  end;
  end;  * end j loop;
end;    * end i loop;
* print mat2;

cnames1 = {'time1', 'time2', 'plot', 'burn', 'hydrn', 'soiln', 'elev', 'slope', 
			'covm1', 'covm2', 'mcoun1', 'mcoun2', 'mhgt1', 'mhgt2', '_FREQ_1', '_FREQ_2'};
create oakpairs from mat2 [colname = cnames1];
append from mat2;
 
quit; run;

proc print data=oakpairs; title 'oakpairs';
run;

proc glm data=oakpairs;	title 'oakpairs glm';  * N = 128 because 2010 & 2011 dropped; 
	class burn;
	model mcoun2 = mcoun1 burn mcoun1*burn;
	output out=glmout2 r=ehat;
run;
proc univariate data=glmout2 plot normal; var ehat mcoun2; run;

proc glimmix data=oakpairs; title 'oakpairs glimmix';
  class plot burn;
  model mcoun2 = mcoun1 covm1/ distribution=normal; *removed interaction term;
  random plot(burn);
  output out=glmout2 resid=ehat;
run;