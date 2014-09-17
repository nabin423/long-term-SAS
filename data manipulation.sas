/* All the following were cut from the import document. This is data manipulation, not importing;

*splitting out just important species--pines and quma, quma3;
data pineoak; set seedlings4;
	if (sspp = "PITA" |sspp = "QUMA" | sspp = "QUMA3");
run;

/* proc freq data=pineoak; tables sspp; title 'pineoak'; run; * N = 626; */
proc sort data=pineoak; by plot;
data pineoak2; merge hist2 pineoak; by plot; year = year(date); run;
data pineoak3; set pineoak2;
   if year < 2011 then prpo = 'pref';
   if year >= 2011 then prpo = 'post';
run;
proc print data=pineoak3; run;
proc contents data = pineoak3; run;
proc freq data=pineoak3; tables sspp*burn; title 'pineoak'; run; * N = 491;

proc sort data=pineoak3; by plot year sspp burn prpo;
proc means data=pineoak3 noprint sum; by plot year sspp burn prpo; var snum; 
  output out=numplantdatapo sum=npersppo;
  *npersppo = number per species for pines and oaks;
proc print data=numplantdatapo; title 'pine oak numplantdata'; 
  var plot year burn prpo sspp npersppo;
run;   * N = 240 plot-year combinations;

proc freq data=numplantdatapo; tables sspp*burn / fisher expected;
run;
*this has different values than pineoak3 table...not sure why yet;

proc sort data=numplantdatapo; by plot burn prpo;
proc means data=numplantdatapo noprint sum; by plot burn prpo; var npersppo; 
  output out=numperplot sum=nperplot;
proc print data=numperplot; title 'totals per plot'; 
  var plot burn prpo nperplot;
run;   * N = 249 plot-year combinations;
proc sort data = numperplot; by plot;
data numperplot2; merge numplantdatapo numperplot; by plot; run;
proc print data = numperplot2; run;
data numperplot3; set numperplot2;
	relabun = npersppo / nperplot;
proc print data = numperplot3; title 'numperplot3'; run;


proc freq data=numperplot3; tables sspp*burn / fisher expected;
run;
proc freq data=numperplot3; tables sspp*prpo / fisher expected;
run;

*merging orig dataset (with all species) with plot history;
proc sort data=seedlings4; by plot;
data seedlings5; merge hist2 seedlings4; by plot; year = year(date); run;
proc print data=seedlings5; title 'seedlings merged with plot history'; run; * N = 659 no seedlings observed in plot 1237; 


* ---- plot-level information -----;
* to compare spp among plots, we need a comparable variable for each plot;
* an obvious comparable variable is number of plants of that spp;
proc sort data=seedlings5; by plot year sspp;
proc means data=seedlings5 noprint sum; by plot year sspp; var snum; 
  output out=numplantdata sum=npersp;
proc print data=numplantdata; title 'numplantdata'; 
  var plot year sspp npersp;
run;   * N = 352;

proc means data=numplantdata noprint sum; by plot year; 
  var npersp;
  output out=seedlings6 sum = sumseedlings;
* sumseedlings = # of all sdlngs in the plot;
proc print data=seedlings6; title 'seedling6';
  run; * n=168 plot-year combinations;

proc univariate data=numplantdatapo plot;
	var npersppo;
run;
* long right tail;

* which are the most common spp?;
proc sort data=numplantdata; by sspp;
proc means data=numplantdata sum noprint; by sspp; var npersp;
  output out=spptotals sum=spptot;
proc print data=spptotals; title 'plants/spp all plots, all year';
run;
*QUMA3: 1027, PITA: 937, QUMA: 725, SANI: 157;
