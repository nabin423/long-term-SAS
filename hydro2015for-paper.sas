/*
*---- subset the data by species and reorg-------------;
proc sort data=seedlings4; by plot;

data pita; set seedlings4; if sspp="PITAx"; 
  if heig=1 then npita1 = num; if heig=2 then npita2 = num;
  if heig=3 then npita3 = num; if heig=4 then npita4 = num;
  if heig=5 then npita5 = num; 
proc print data=pita; title 'pita';  * N = 185 obs;
run;
proc means data=pita sum noprint; by plot bcat hydr; 
 var npita1-npita5;
 output out=pita2 sum = spita1-spita5;
proc print data=pita2; title 'pita2';  * N = 36 non-zero plots;
run;
proc freq data=pita2; tables bcat*hydr;
run;

data quma; set seedlings4; if sspp="QUMAx"; 
  if heig=1 then nquma1 = num; if heig=2 then nquma2 = num;
  if heig=3 then nquma3 = num; if heig=4 then nquma4 = num;
  if heig=5 then nquma5 = num; 
proc print data=quma; title 'quma';  * N = 181 obs;
run;
proc means data=quma sum noprint; by plot bcat hydr; 
 var nquma1-nquma5;
 output out=quma2 sum = squma1-squma5;
proc print data=quma2; title 'quma2';  * N = 31 plots;
run;
proc freq data=quma2; tables bcat*hydr;
run;

data empty; set seedlings4; if sspp="XXXXx";
 holder = 0; * N = 10;
proc print data=empty; title 'empty';
run;

data datreorg; merge pita2 quma2 empty; by plot;
  drop num heig;
proc print data=datreorg; title 'datreorg';
run; *N=47;

*---- analysis of total number --------------;
data dattotn; set datreorg;
  if (spita1=.) then spita1=0; if (spita2=.) then spita2=0; 
  if (spita3=.) then spita3=0; if (spita4=.) then spita4=0; 
  if (spita5=.) then spita5=0; 
  if (squma1=.) then squma1=0; if (squma2=.) then squma2=0; 
  if (squma3=.) then squma3=0; if (squma4=.) then squma4=0; 
  if (squma5=.) then squma5=0;
  totpita = spita1 + spita2 + spita3 + spita4 + spita5;
  totquma = squma1 + squma2 + squma3 + squma4 + squma5;
*/

* --- analyze only plots without mulch, no pooling----;
data nomulch; set seedsmerge2; if hydr = '0';  
proc print data=nomulch; title 'nomulch';
run; * N = 44;

/* *old models from orig. analyses;
* pita - ols;
proc glm data=nomulch; class bcat;
  model totpita = bcat;
  output out=gout1 r=ehat;
proc univariate data=gout1 normal plot; var ehat;
run;
* pita - genmod;
proc genmod data=nomulch; class bcat;
  model totpita = bcat/ dist = negbin link=log type1 type3;
run;
* dispersion =  2.2050; 
* bcat  df=4, X2 = 9.85, P = 0.0430;  * df issues!;
* quma - genmod;
proc genmod data=nomulch; class bcat;
  model totquma = bcat/ dist = negbin link=log type1 type3;
run; * NS;
*/

proc glimmix data=nomulch; title 'effect of bcat w/ no mulch';
  class bcat;
  model pita12 =  bcat / distribution=negbin link=log solution DDFM=bw; 
  *model quma15 = pltd / distribution=negbin link=log solution DDFM=bw;
  *model qum315 = pltd / distribution=negbin link=log solution DDFM=bw;
  *model ilvo15 = pltd / distribution=negbin link=log solution DDFM=bw;
  *lsmeans pltd / ilink cl; 
  output out=glmout2 resid=ehat;
run;
proc freq data=nomulch; tables hydr*bcat; run;

* ---- analyze only plots without mulch, pooling unburned/scorch/light;
data nomulchpool; set nomulch;
  if (bcat=0|bcat=1) then burn='L1';
*  if (bcat='l') then burn='L2';
*  if (bcat='m'|bcat='h') then burn='L3'; * not used;
  if (bcat=2) then burn='L2';
*  if (bcat='h') then burn='L4';
run;
proc freq data=nomulchpool; tables hydr*burn; run; *L1:21, L2:23;

/*
* pita - genmod;
proc genmod data=nomulchpool; class burn;
  model pita12 = burn/ dist = negbin link=log type1 type3;
run;
* dispersion =  2.7647;
* burn df=3 X2 = 7.17  P = 0.0666;
*/

proc glimmix data=nomulchpool; title 'effect of bcat w/ no mulch';
  class burn;
  model pita12 =  burn / distribution=negbin link=log solution DDFM=bw; 
  *model quma15 = pltd / distribution=negbin link=log solution DDFM=bw;
  *model qum315 = pltd / distribution=negbin link=log solution DDFM=bw;
  *model ilvo15 = pltd / distribution=negbin link=log solution DDFM=bw;
  *lsmeans pltd / ilink cl; 
  output out=glmout2 resid=ehat;
run;

/*
proc genmod data=nomulchpool; class burn;
  model totquma = burn/ dist = negbin link=log type1 type3;
run; * NS;
*/

* ---- analyze only burned plots ------;
data burnplots; set seedsmerge2;
  if (bcat=1|bcat=2); 
proc print data=burnplots; title 'burnplots';
run; * N = 53;

proc glimmix data=burnplots; title 'effect of bcat & hydr in burned plots only';
  class bcat hydr;
  *model pita12 =  bcat / distribution=negbin link=log solution DDFM=bw;  
  *model pita12 =  bcat hydr/ distribution=negbin link=log solution DDFM=bw; 
  model pita12 =  bcat hydr bcat*hydr/ distribution=negbin link=log solution DDFM=bw; 
  *model quma15 = pltd / distribution=negbin link=log solution DDFM=bw;
  *model qum315 = pltd / distribution=negbin link=log solution DDFM=bw;
  *model ilvo15 = pltd / distribution=negbin link=log solution DDFM=bw;
  lsmeans bcat*hydr / ilink cl; 
  output out=glmout2 resid=ehat;
run;

/*
* pita;
proc genmod data=allburn; class bcat hydr;
  model totpita = bcat hydr / dist = negbin link=log type1 type3;
run;
* dispersion =  1.7247
  type 1
  bcat df=2 X2=4.00 P = 0.1351 hydr df=2 X2 = 14.34 P = 0.0008
  hydr df=2 X2=7.32 P = 0.0257 bcat df=2 X2=11.02 P = 0.0040
  type 3 - use these - order does not matter for type3 -  
  bcat df=2, X2 = 11.02 P = 0.0040
  hydr df=2 X2 = 14.34  P = 0.0008;
proc genmod data=allburn; class bcat hydr;
  model totpita =  hydr bcat / dist = negbin link=log type1 type3;
run;

proc genmod data=allburn; class bcat hydr;
  model totpita =  hydr bcat hydr*bcat/
     dist = negbin link=log type1 type3;
* interaction NS;
run;
* oak; 
proc genmod data=allburn; class bcat hydr;
  model totquma = bcat hydr / dist = poisson link=log type1 type3;
run;
* type 3 bcat df=2 X2=3.71 P = 0.1567
         hydr  df=2  X2=10.91 P=0.0043;

proc genmod data=allburn; class bcat hydr;
  model totquma = bcat hydr  bcat*hydr/ dist = poisson link=log type1 type3;
run;
* use this - note type 1 not type 3 - no type3 reported.
* type 1 bcat df=2 X2=3.66 P = 0.1603
         hydr  df=2  X2=10.91 P=0.0043
         int df=3 X2=17.59 P = 0.0005;
*/
