
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*";

* if processes get too slow, run this to free up memory;
* proc datasets library=work kill noprint; run; 

*import herb data;
proc import datafile="D:\Werk\Research\FMH Raw Data, SAS, Tables\FFI long-term data\herb6.csv"
out=herb6 dbms=csv replace; getnames=yes; run;  * N = 4620;
*proc print data=herb6 (firstobs=1 obs=15); title 'herb6'; run;
*proc contents data=herb6; run;
*proc freq data=herb6; *tables fungroup*burn; run;
*3008 forb obs, 1611 gram obs, 1 plot with no plants;

*Variables:
	plot: FMH plot ID
	plotnum: renumbered 1-55
	aspect: 0=flat 1=N 2=E 3=S 4=W
	burn: 1=unburned 2=scorched 3=light 4=moderate 5=heavy
    count/mcount: stem count of each species per plot/year (post-fire/pre-fire)
	counter: line
	fungroup: functional group. 1=forb, 2=gram, 3=no plants in plot
	cov/mcov: cover post/pre-fire
	elev, slope: continuous
	hydr: 1=no, 2=yes
	soil: 1=sand, 2=gravel
	sspp: species ID
	year: year. Pre-fire years are marked as '1111'
	yearnum: prefire=1, 2012=2, 2013=3, 2014=4, 2015=5
-->for count/mcount and cov/mcov: any pre-fire data is also in the regular columns. I kept
the mcount and mcov columns in case they would be useful anyway
;

proc glimmix data=herb6  method=laplace; by year; title 'herb6'; 
class plot fungroup burn soil hydr aspect sspp;
	*model count = fungroup burn soil / dist=negbin solution; 
		*good model;
		**pre-fire: x2 ok. fungroup sig. 						  AIC 3390**
		*2012: x2 ok. fungroup sig. 							  AIC 3989**
		*2013: x2 ok. fungroup, burn, soil sig. 				  AIC 9247**
		*2014: x2 high (2.12). fungroup, burn sig.  			  AIC 11516
		*2015: x2 high (2.4). fungroup, burn, soil sig. 		  AIC 13215;
	*model count = fungroup burn soil burn*soil / dist=negbin solution; 
		*interaction NS/non-estimable;
	model count = fungroup burn soil hydr aspect elev / dist=negbin solution;
		**pre-fire: x2 ok. fungroup, elev sig.					  AIC 3394
		*2012: x2 ok. fungroup sig.								  AIC 3996
		*2013: x2 ok. fungroup, burn, soil sig.					  AIC 9251
		**2014: x2 high (2.18). fungroup, burn, soil, aspect sig. AIC 11514*
		**2015: x2 high (2.45). fungroup, burn, soil, aspect sig. AIC 13215;
	*model count = fungroup burn soil hydr aspect sspp elev slope cov / dist=negbin solution;
		*estimated G-matrix not PD;
	random plot / subject = burn*soil;
	*lsmeans fungroup burn soil / ilink cl;
	output out=glmout resid=ehat;
run;

/* Using PROC SQL to count the number of levels for a variable.
proc sql;
   create table new as 
     select count(distinct(sspp)) as speciescount
            from herb6;
quit;
proc print;
   title 'Number of distinct values for each variable'; 
run;	*315 species;

*total count;
proc means data=herb6 sum mean noprint; var count;
	output out=herbsum sum=sumcount mean=mcount;
run;	
proc print data=herbsum; title 'herbsum'; run; 
*freq=4620 observations, sumcount=258696.5 stems, mean stems=55.99;
*/

*************HPRIME AND EVENNESS***********;
*sum of stem counts per plot/year/fungroup;
proc sort data=herb6; by plotnum year fungroup sspp; run;
proc means data=herb6 noprint sum mean; by plotnum yearnum fungroup ; 
	var count aspect burn soil cov elev slope hydr;
	output out=herbsumsp sum=scount saspect sburn ssoil scov selev sslope shydr
						mean=mcount aspect burn soil cov elev slope hydr;
run;	*n=419;
data herb7; set herbsumsp; 
	*drop mcount saspect sburn ssoil sfun scov selev sslope shydr;
	keep plotnum yearnum fungroup _FREQ_ scount;
run;
*proc print data=herb7 (firstobs=1 obs=15); title 'herb7'; run; 
*proc contents data=herb7; run;

*merging total stem counts back to og dataset;
proc sort data=herb6; by plotnum yearnum fungroup; run;
proc sort data=herb7; by plotnum yearnum fungroup; run;
data herb8; merge herb7 herb6; by plotnum yearnum fungroup; run;
*proc print data=herb8 (firstobs=1 obs=10); title 'herb8'; run;

*beginning h' and j' calcuations;
data herb9; set herb8;
	*one plot has no individuals, removing it for division;
	if scount=0 then scount=.;
	relabund=count/scount;
	logrelabund=log(relabund);
	relabundxlogrelabund=relabund*logrelabund;
run;
*proc print data=herb9 (firstobs=1 obs=10); title 'herb9'; run;

*calcluting h';
proc means data=herb9 sum noprint; by plotnum yearnum fungroup; var relabundxlogrelabund;
	output out=herb10 sum=hprime;
run;
*proc print data=herb10 (firstobs=1 obs=10); title 'herb10'; run;

*merging h' back to og dataset and getting evenness (j');
proc sort data=herb6; by plotnum yearnum fungroup; run;
proc sort data=herb10; by plotnum yearnum fungroup; run;
data herbdiv; merge herb10 herb9 herb6; by plotnum yearnum fungroup; 
	hmax=log(_FREQ_);
	*for some, hmax is 0 (because there was only one individual with one stem);
	if hmax=0 then hmax=.;
	evenness=hprime/hmax;
	drop _TYPE_ counter mcount mcov logrelabund relabundxlogrelabund;
run;
*proc print data=herbdiv (firstobs=1 obs=10); title 'herbdiv'; run;

/*
proc export data=herbdiv
   outfile='D:\Werk\Research\FMH Raw Data, SAS, Tables\FFI long-term data\herbdiv.csv'
   dbms=csv
   replace;
run;
*/

proc sort data=herbdiv; by year; run;
proc glimmix data=herbdiv; by year; title 'hprime';
	class burn fungroup;
	model hprime=burn fungroup / solution ;
	random plot / subject=burn;
	lsmeans burn fungroup;
	output out=glmout resid=ehat;
run;

*prepping for an ordination of just forbs vs grams;
proc sort data=herbdiv; by plotnum yearnum burn soil elev slope aspect hydr cov;
proc means data=herbdiv noprint mean; by plotnum yearnum burn soil elev slope aspect hydr cov fungroup; var hprime evenness;
	output out=ordifungroup mean=hprime jprime;
run;													*n=419;
*proc print data=ordifungroup (firstobs=1 obs=10); title 'ordifungroup'; run;

*reorganizing to have fungroup 1 and 2 as columns, each with their own beta diversity;
**plotnum yearnum fungroup _FREQ_ hprime jprime;
data ordifungroup2; set ordifungroup; drop _TYPE_ _FREQ_ jprime; run;
proc sort data=ordifungroup2; by plotnum yearnum burn soil elev slope aspect hydr cov; run;												*n=419;
*proc print data=ordifungroup2 (firstobs=1 obs=10); title 'ordifungroup2'; run;
proc transpose data=ordifungroup2
   out=fundiv;
   var hprime;
   by plotnum yearnum burn soil elev slope aspect hydr cov;
run;
data fundiv2; set fundiv; drop _NAME_; rename col1=forbdiv; rename col2=gramdiv; run;
*proc print data=fundiv2 (firstobs=1 obs=10) noobs; title 'Diversity for each functional group'; run;

/*
proc export data=fundiv2
   outfile='D:\Werk\Research\FMH Raw Data, SAS, Tables\FFI long-term data\fundiv2.csv'
   dbms=csv
   replace;
run;
*/

******big transpose--each species will have a column filled with it's relative abundance value;
proc sort data=herbdiv; by plotnum yearnum fungroup sspp _FREQ_ scount burn soil elev slope aspect hydr cov relabund; run;		
data herbdiv1; set herbdiv; rename _FREQ_=numspperplot;
proc transpose data=herbdiv1 out=herbdivbysp; 
   by plotnum yearnum fungroup sspp numspperplot scount burn soil elev slope aspect hydr cov;
   id sspp;
   var relabund;
 run;
data herbdivbysp2; set herbdivbysp; drop _NAME_ sspp; run;
*proc print data=herbdivbysp2 (firstobs=1 obs=10) noobs; title 'relative abundance for each sp'; run;

*plot-year combos. NOTE that this eliminates fungroup;
proc sort data=herbdivbysp2; by plotnum yearnum;
proc means data=herbdivbysp2 noprint mean; 
by plotnum yearnum ;
var numspperplot scount burn soil elev slope aspect hydr cov CEVI2 CLMA4 EUCO1 GAREx PTAQx DIOLx COCA5 DADRx EUCO7 GAAN1 GAAR1 GAPE2 HEGEx LEMU3 MEPE3 POPR4 CYEC2 CYRE5 DISP2 ELIN3 SCCIx CITE2 HELA5 PHCI4 CYHYx CHPI8 EUSEx NUTEx OXDI2 SCSCx AMAR2 TRPE4 DIAN4 LIEL1 TRUR2 VETE3 SPCLx ACGR2 COERx LEHI2 PSOB3 SOOLx MOPUx ANGL2 SOASx TRBI2 ANVI2 ARERx CRGL2 CRSA4 FAREx HYAR3 LERE2 PYCA2 PYMU2 PASE5 HERO2 LETEx POPEx CYLU2 DIAC2 DIOVx RHHAx CYCR6 ERSPx PAPL3 DELA2 RHMI4 STLE5 VILE2 AIEL4 DIACx JUDIx JUMA4 ASNU4 NUCAx RHLAx SPVAx CRCA6 HEAN3 HYGEx TRFL2 CYRE1 DICO6 DILI2 SCOL2 CRMO6 TRRA5 LEDUx HYDRx GIINx HYGL2 SPINx DICO1 DIRAx GAPI2 LESPE LIASx RUHU6 STBI2 CRRI3 PHTEx JUTEx HEAMx HYSEx DISC3 BUCIx GECA5 LURE2 AGHYx JUVA2 PLVIx CYRE2 CAMI8 PHHE5 RUHA2 KRVIx EUSE2 PHAM4 PLODx VISOx EUDE1 SOAL6 GOGO2 HYHI2 OXSTx SYPA1 DILA9 AMPSx SOAM4 SORAx HEDE4 PAPE5 SOPYx GAPU3 PALU2 RHGL2 CAMI5 LIARx SPCO1 ERHI2 PABR2 JUBRx CRDI1 RUHI2 GYAMx CAMU4 ARLA6 GAST2 PHMO9 SOEL3 LEST4 CALE6 AGFA2 GAPUx SIAN2 MOVEx LAHIx POTEx VEARx PASEC PAANx LALUx LASEx XXXXx OLBOx STHE4 STUM2 OELAx STLE6 CEMIx PTVI2 ERSEx KROCx DRAN3 ARLO1 CHCO1 FRFLx PHABx SEARx STPI3 TRPU4 ARDE3 BOHI2 DITE2 DIVI7 CHIMx COBA2 STSYx EVCAx GAAEx LIELx PLHOx VUOCx CHAN5 DECA3 ERMU4 SCCA4 CESP4 ERHI9 TRFLF SONU2 ALCA3 MINU6 SPOBx BABR2 EUHE1 LEST5 TRHIx PAHOx ERLO5 HIGR3 TAOFx ARAL3 RUAL4 ASTUx CHAMx CIHO2 CNTEx COTI3 CRHOH EUPI3 FRGR3 LOPUx MADE3 TEONx ARPU8 CENCH UNGR3 SACA1 DEAC3 EVSEx EVVEx NELU2 SICIx SILIx ARPUP BOLAT CYPER ERCUx ERINx ERSE2 CAFAx GAAMx LOSQx MOCIx PADRx POERx TRBE4 VIMIx CYSUx CRWI5 CRMI8 HEGR1 PLWRx NOBI2 TRBE3 ERST3 LEAR3 TRBEx DESEx CYPL3 SOCA6 CAIN2 GABR2 HELA6 BRMI2 DIOLS PANO2 ASOEx BRTRx URCIx BRJAx TRFLC RUABx FIPUx ELAN5 WAMAx BUCA2 DILI5 PAROx PHHE4 FIAU2 JUCO1 ERGEx OELIx CHSE2 DECIx JATAx RUCO2 CHMA1 KRDAx TYDOx GACA6 HECR9 TRDI2 HENI4 CHTE1 COWR3 LEVI7 PHAN5 POPOx CYFI2 LIME2 SACA3 BOLA2 CYFI4 ERHIx MOCAx DICA3 SIABx PAHI1 SIRHx HYMI2 POVEx ;
output out=herbdivbysp3 mean=numspperplot scount burn soil elev slope aspect hydr cov CEVI2 CLMA4 EUCO1 GAREx PTAQx DIOLx COCA5 DADRx EUCO7 GAAN1 GAAR1 GAPE2 HEGEx LEMU3 MEPE3 POPR4 CYEC2 CYRE5 DISP2 ELIN3 SCCIx CITE2 HELA5 PHCI4 CYHYx CHPI8 EUSEx NUTEx OXDI2 SCSCx AMAR2 TRPE4 DIAN4 LIEL1 TRUR2 VETE3 SPCLx ACGR2 COERx LEHI2 PSOB3 SOOLx MOPUx ANGL2 SOASx TRBI2 ANVI2 ARERx CRGL2 CRSA4 FAREx HYAR3 LERE2 PYCA2 PYMU2 PASE5 HERO2 LETEx POPEx CYLU2 DIAC2 DIOVx RHHAx CYCR6 ERSPx PAPL3 DELA2 RHMI4 STLE5 VILE2 AIEL4 DIACx JUDIx JUMA4 ASNU4 NUCAx RHLAx SPVAx CRCA6 HEAN3 HYGEx TRFL2 CYRE1 DICO6 DILI2 SCOL2 CRMO6 TRRA5 LEDUx HYDRx GIINx HYGL2 SPINx DICO1 DIRAx GAPI2 LESPE LIASx RUHU6 STBI2 CRRI3 PHTEx JUTEx HEAMx HYSEx DISC3 BUCIx GECA5 LURE2 AGHYx JUVA2 PLVIx CYRE2 CAMI8 PHHE5 RUHA2 KRVIx EUSE2 PHAM4 PLODx VISOx EUDE1 SOAL6 GOGO2 HYHI2 OXSTx SYPA1 DILA9 AMPSx SOAM4 SORAx HEDE4 PAPE5 SOPYx GAPU3 PALU2 RHGL2 CAMI5 LIARx SPCO1 ERHI2 PABR2 JUBRx CRDI1 RUHI2 GYAMx CAMU4 ARLA6 GAST2 PHMO9 SOEL3 LEST4 CALE6 AGFA2 GAPUx SIAN2 MOVEx LAHIx POTEx VEARx PASEC PAANx LALUx LASEx XXXXx OLBOx STHE4 STUM2 OELAx STLE6 CEMIx PTVI2 ERSEx KROCx DRAN3 ARLO1 CHCO1 FRFLx PHABx SEARx STPI3 TRPU4 ARDE3 BOHI2 DITE2 DIVI7 CHIMx COBA2 STSYx EVCAx GAAEx LIELx PLHOx VUOCx CHAN5 DECA3 ERMU4 SCCA4 CESP4 ERHI9 TRFLF SONU2 ALCA3 MINU6 SPOBx BABR2 EUHE1 LEST5 TRHIx PAHOx ERLO5 HIGR3 TAOFx ARAL3 RUAL4 ASTUx CHAMx CIHO2 CNTEx COTI3 CRHOH EUPI3 FRGR3 LOPUx MADE3 TEONx ARPU8 CENCH UNGR3 SACA1 DEAC3 EVSEx EVVEx NELU2 SICIx SILIx ARPUP BOLAT CYPER ERCUx ERINx ERSE2 CAFAx GAAMx LOSQx MOCIx PADRx POERx TRBE4 VIMIx CYSUx CRWI5 CRMI8 HEGR1 PLWRx NOBI2 TRBE3 ERST3 LEAR3 TRBEx DESEx CYPL3 SOCA6 CAIN2 GABR2 HELA6 BRMI2 DIOLS PANO2 ASOEx BRTRx URCIx BRJAx TRFLC RUABx FIPUx ELAN5 WAMAx BUCA2 DILI5 PAROx PHHE4 FIAU2 JUCO1 ERGEx OELIx CHSE2 DECIx JATAx RUCO2 CHMA1 KRDAx TYDOx GACA6 HECR9 TRDI2 HENI4 CHTE1 COWR3 LEVI7 PHAN5 POPOx CYFI2 LIME2 SACA3 BOLA2 CYFI4 ERHIx MOCAx DICA3 SIABx PAHI1 SIRHx HYMI2 POVEx ;
run;
data herbdivbysp4; set herbdivbysp3; drop _TYPE_ _FREQ_; run;
proc print data=herbdivbysp4 (firstobs=1 obs=100); title 'herbdivbysp4'; run;

/*
proc export data=herbdivbysp4
   outfile='D:\Werk\Research\FMH Raw Data, SAS, Tables\FFI long-term data\herbdivbysp4.csv'
   dbms=csv
   replace;
run;
*/
