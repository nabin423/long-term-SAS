/* *if running from alld;
data herbx; set alld;
	if (subp = 'herb'); 
run;  *N=12544;
*/

data herb1; set herbx;
	keep aspect bcat coun quad covm elev hydrn plot slope soileb sspp year prpo; 
run;

proc sort data=herb1; by plot quad year sspp bcat covm coun soileb elev slope aspect hydrn prpo; run; *N=12548;
*proc print data=herb1 (firstobs=1 obs=20); title 'herb1'; run;

*numeric dataset;   data dat1n; set herb1; keep aspect bcat plot quad coun covm elev hydrn slope soileb year prpo; 
*character dataset; data dat1c; set herb1; keep sspp;	run;		

*proc contents data=dat1n; run;
*proc print    data=dat1n (firstobs=1 obs=20); title 'dat1n'; run;
*proc contents data=dat1c; run;
*proc print    data=dat1c (firstobs=1 obs=20); title 'dat1c'; run;

proc iml;

*reading in numeric data;
use dat1n; read all into matnum;				*print (matnum[1:20,]);	 *12 columns, 12548 rows (150,576 cells);
nrecords = nrow(matnum);

*reading in character data;
use dat1c; read all var _char_ into matchar;	*print matchar;	 *1 column, 12548 rows (12,548 cells);

nquads=10*56; 	*number of quadrats (10/plot, 56 plots);
nsp=315;	  	*number of species;

matcount=j(nquads,nsp,9999); 					*print matcount; *315 columns, 560 rows (176,400 cells);
nobs=nrow(matcount);							*print nobs; 	 *N=560;

do i=1 to nobs;
	*assigning a numeric id to each species;
	uniquad=10*(matnum[i,1]-1)+ matnum[i,2];	*unique quadrat id;
    if (matchar[i,1]='ACGR2') then spid=1;        
    if (matchar[i,1]='AGFA2') then spid=2;
    if (matchar[i,1]='AGHYx') then spid=3;
    if (matchar[i,1]='AIEL4') then spid=4;
    if (matchar[i,1]='ALCA3') then spid=5;
    if (matchar[i,1]='AMAR2') then spid=6;
    if (matchar[i,1]='AMPSx') then spid=7;
    if (matchar[i,1]='ANGL2') then spid=8;
    if (matchar[i,1]='ANVI2') then spid=9;
    if (matchar[i,1]='ARAL3') then spid=10;
    if (matchar[i,1]='ARDE3') then spid=11;
    if (matchar[i,1]='ARERx') then spid=12;
    if (matchar[i,1]='ARLA6') then spid=13;
    if (matchar[i,1]='ARLO1') then spid=14;
    if (matchar[i,1]='ARPU8') then spid=15;
    if (matchar[i,1]='ARPUP') then spid=16;
    if (matchar[i,1]='ASNU4') then spid=17;
    if (matchar[i,1]='ASOEx') then spid=18;
    if (matchar[i,1]='ASTUx') then spid=19;
    if (matchar[i,1]='BABR2') then spid=20;
    if (matchar[i,1]='BOHI2') then spid=21;
    if (matchar[i,1]='BOLA2') then spid=22;
    if (matchar[i,1]='BOLAT') then spid=23;
    if (matchar[i,1]='BRJAx') then spid=24;
    if (matchar[i,1]='BRMI2') then spid=25;
    if (matchar[i,1]='BRTRx') then spid=26;
    if (matchar[i,1]='BUCA2') then spid=27;
    if (matchar[i,1]='BUCIx') then spid=28;
    if (matchar[i,1]='CAFAx') then spid=29;
    if (matchar[i,1]='CAIN2') then spid=30;
    if (matchar[i,1]='CALE6') then spid=31;
    if (matchar[i,1]='CAMI5') then spid=32;
    if (matchar[i,1]='CAMI8') then spid=33;
    if (matchar[i,1]='CAMU4') then spid=34;
    if (matchar[i,1]='CEMIx') then spid=35;
    if (matchar[i,1]='CENCH') then spid=36;
    if (matchar[i,1]='CESP4') then spid=37;
    if (matchar[i,1]='CEVI2') then spid=38;
    if (matchar[i,1]='CHAMx') then spid=39;
    if (matchar[i,1]='CHAN5') then spid=40;
    if (matchar[i,1]='CHCO1') then spid=41;
    if (matchar[i,1]='CHIMx') then spid=42;
    if (matchar[i,1]='CHMA1') then spid=43;
    if (matchar[i,1]='CHPI8') then spid=44;
    if (matchar[i,1]='CHSE2') then spid=45;
    if (matchar[i,1]='CHTE1') then spid=46;
    if (matchar[i,1]='CIHO2') then spid=47;
    if (matchar[i,1]='CITE2') then spid=48;
    if (matchar[i,1]='CLMA4') then spid=49;
    if (matchar[i,1]='CNTEx') then spid=50;
    if (matchar[i,1]='COBA2') then spid=51;
    if (matchar[i,1]='COCA5') then spid=52;
    if (matchar[i,1]='COERx') then spid=53;
    if (matchar[i,1]='COTI3') then spid=54;
    if (matchar[i,1]='COWR3') then spid=55;
    if (matchar[i,1]='CRCA6') then spid=56;
    if (matchar[i,1]='CRDI1') then spid=57;
    if (matchar[i,1]='CRGL2') then spid=58;
    if (matchar[i,1]='CRHOH') then spid=59;
    if (matchar[i,1]='CRMI8') then spid=60;
    if (matchar[i,1]='CRMO6') then spid=61;
    if (matchar[i,1]='CRRI3') then spid=62;
    if (matchar[i,1]='CRSA4') then spid=63;
    if (matchar[i,1]='CRWI5') then spid=64;
    if (matchar[i,1]='CYCR6') then spid=65;
    if (matchar[i,1]='CYEC2') then spid=66;
    if (matchar[i,1]='CYFI2') then spid=67;
    if (matchar[i,1]='CYFI4') then spid=68;
    if (matchar[i,1]='CYHYx') then spid=69;
    if (matchar[i,1]='CYLU2') then spid=70;
    if (matchar[i,1]='CYPER') then spid=71;
    if (matchar[i,1]='CYPL3') then spid=72;
    if (matchar[i,1]='CYRE1') then spid=73;
    if (matchar[i,1]='CYRE2') then spid=74;
    if (matchar[i,1]='CYRE5') then spid=75;
    if (matchar[i,1]='CYSUx') then spid=76;
    if (matchar[i,1]='DADRx') then spid=77;
    if (matchar[i,1]='DEAC3') then spid=78;
    if (matchar[i,1]='DECA3') then spid=79;
    if (matchar[i,1]='DECIx') then spid=80;
    if (matchar[i,1]='DELA2') then spid=81;
    if (matchar[i,1]='DESEx') then spid=82;
    if (matchar[i,1]='DIAC2') then spid=83;
    if (matchar[i,1]='DIACx') then spid=84;
    if (matchar[i,1]='DIAN4') then spid=85;
    if (matchar[i,1]='DICA3') then spid=86;
    if (matchar[i,1]='DICO1') then spid=87;
    if (matchar[i,1]='DICO6') then spid=88;
    if (matchar[i,1]='DILA9') then spid=89;
    if (matchar[i,1]='DILI2') then spid=90;
    if (matchar[i,1]='DILI5') then spid=91;
    if (matchar[i,1]='DIOLS') then spid=92;
    if (matchar[i,1]='DIOLx') then spid=93;
    if (matchar[i,1]='DIOVx') then spid=94;
    if (matchar[i,1]='DIRAx') then spid=95;
    if (matchar[i,1]='DISC3') then spid=96;
    if (matchar[i,1]='DISP2') then spid=97;
    if (matchar[i,1]='DITE2') then spid=98;
    if (matchar[i,1]='DIVI7') then spid=99;
    if (matchar[i,1]='DRAN3') then spid=100;
    if (matchar[i,1]='ELAN5') then spid=101;
    if (matchar[i,1]='ELIN3') then spid=102;
    if (matchar[i,1]='ERCUx') then spid=103;
    if (matchar[i,1]='ERGEx') then spid=104;
    if (matchar[i,1]='ERHI2') then spid=105;
    if (matchar[i,1]='ERHI9') then spid=106;
    if (matchar[i,1]='ERHIx') then spid=107;
    if (matchar[i,1]='ERINx') then spid=108;
    if (matchar[i,1]='ERLO5') then spid=109;
    if (matchar[i,1]='ERMU4') then spid=110;
    if (matchar[i,1]='ERSE2') then spid=111;
    if (matchar[i,1]='ERSEx') then spid=112;
    if (matchar[i,1]='ERSPx') then spid=113;
    if (matchar[i,1]='ERST3') then spid=114;
    if (matchar[i,1]='EUCO1') then spid=115;
    if (matchar[i,1]='EUCO7') then spid=116;
    if (matchar[i,1]='EUDE1') then spid=117;
    if (matchar[i,1]='EUHE1') then spid=118;
    if (matchar[i,1]='EUPI3') then spid=119;
    if (matchar[i,1]='EUSE2') then spid=120;
    if (matchar[i,1]='EUSEx') then spid=121;
    if (matchar[i,1]='EVCAx') then spid=122;
    if (matchar[i,1]='EVSEx') then spid=123;
    if (matchar[i,1]='EVVEx') then spid=124;
    if (matchar[i,1]='FAREx') then spid=125;
    if (matchar[i,1]='FIAU2') then spid=126;
    if (matchar[i,1]='FIPUx') then spid=127;
    if (matchar[i,1]='FRFLx') then spid=128;
    if (matchar[i,1]='FRGR3') then spid=129;
    if (matchar[i,1]='GAAEx') then spid=130;
    if (matchar[i,1]='GAAMx') then spid=131;
    if (matchar[i,1]='GAAN1') then spid=132;
    if (matchar[i,1]='GAAR1') then spid=133;
    if (matchar[i,1]='GABR2') then spid=134;
    if (matchar[i,1]='GACA6') then spid=135;
    if (matchar[i,1]='GAPE2') then spid=136;
    if (matchar[i,1]='GAPI2') then spid=137;
    if (matchar[i,1]='GAPU3') then spid=138;
    if (matchar[i,1]='GAPUx') then spid=139;
    if (matchar[i,1]='GAREx') then spid=140;
    if (matchar[i,1]='GAST2') then spid=141;
    if (matchar[i,1]='GECA5') then spid=142;
    if (matchar[i,1]='GIINx') then spid=143;
    if (matchar[i,1]='GOGO2') then spid=144;
    if (matchar[i,1]='GYAMx') then spid=145;
    if (matchar[i,1]='HEAMx') then spid=146;
    if (matchar[i,1]='HEAN3') then spid=147;
    if (matchar[i,1]='HECR9') then spid=148;
    if (matchar[i,1]='HEDE4') then spid=149;
    if (matchar[i,1]='HEGEx') then spid=150;
    if (matchar[i,1]='HEGR1') then spid=151;
    if (matchar[i,1]='HELA5') then spid=152;
    if (matchar[i,1]='HELA6') then spid=153;
    if (matchar[i,1]='HENI4') then spid=154;
    if (matchar[i,1]='HERO2') then spid=155;
    if (matchar[i,1]='HIGR3') then spid=156;
    if (matchar[i,1]='HYAR3') then spid=157;
    if (matchar[i,1]='HYDRx') then spid=158;
    if (matchar[i,1]='HYGEx') then spid=159;
    if (matchar[i,1]='HYGL2') then spid=160;
    if (matchar[i,1]='HYHI2') then spid=161;
    if (matchar[i,1]='HYMI2') then spid=162;
    if (matchar[i,1]='HYSEx') then spid=163;
    if (matchar[i,1]='JATAx') then spid=164;
    if (matchar[i,1]='JUBRx') then spid=165;
    if (matchar[i,1]='JUCO1') then spid=166;
    if (matchar[i,1]='JUDIx') then spid=167;
    if (matchar[i,1]='JUMA4') then spid=168;
    if (matchar[i,1]='JUTEx') then spid=169;
    if (matchar[i,1]='JUVA2') then spid=170;
    if (matchar[i,1]='KRDAx') then spid=171;
    if (matchar[i,1]='KROCx') then spid=172;
    if (matchar[i,1]='KRVIx') then spid=173;
    if (matchar[i,1]='LAHIx') then spid=174;
    if (matchar[i,1]='LALUx') then spid=175;
    if (matchar[i,1]='LASEx') then spid=176;
    if (matchar[i,1]='LEAR3') then spid=177;
    if (matchar[i,1]='LEDUx') then spid=178;
    if (matchar[i,1]='LEHI2') then spid=179;
    if (matchar[i,1]='LEMU3') then spid=180;
    if (matchar[i,1]='LERE2') then spid=181;
    if (matchar[i,1]='LESPE') then spid=182;
    if (matchar[i,1]='LEST4') then spid=183;
    if (matchar[i,1]='LEST5') then spid=184;
    if (matchar[i,1]='LETEx') then spid=185;
    if (matchar[i,1]='LEVI7') then spid=186;
    if (matchar[i,1]='LIARx') then spid=187;
    if (matchar[i,1]='LIASx') then spid=188;
    if (matchar[i,1]='LIEL1') then spid=189;
    if (matchar[i,1]='LIELx') then spid=190;
    if (matchar[i,1]='LIME2') then spid=191;
    if (matchar[i,1]='LOPUx') then spid=192;
    if (matchar[i,1]='LOSQx') then spid=193;
    if (matchar[i,1]='LURE2') then spid=194;
    if (matchar[i,1]='MADE3') then spid=195;
    if (matchar[i,1]='MEPE3') then spid=196;
    if (matchar[i,1]='MINU6') then spid=197;
    if (matchar[i,1]='MOCAx') then spid=198;
    if (matchar[i,1]='MOCIx') then spid=199;
    if (matchar[i,1]='MOPUx') then spid=200;
    if (matchar[i,1]='MOVEx') then spid=201;
    if (matchar[i,1]='NELU2') then spid=202;
    if (matchar[i,1]='NOBI2') then spid=203;
    if (matchar[i,1]='NUCAx') then spid=204;
    if (matchar[i,1]='NUTEx') then spid=205;
    if (matchar[i,1]='OELAx') then spid=206;
    if (matchar[i,1]='OELIx') then spid=207;
    if (matchar[i,1]='OLBOx') then spid=208;
    if (matchar[i,1]='OXDI2') then spid=209;
    if (matchar[i,1]='OXSTx') then spid=210;
    if (matchar[i,1]='PAANx') then spid=211;
    if (matchar[i,1]='PABR2') then spid=212;
    if (matchar[i,1]='PADRx') then spid=213;
    if (matchar[i,1]='PAHI1') then spid=214;
    if (matchar[i,1]='PAHOx') then spid=215;
    if (matchar[i,1]='PALU2') then spid=216;
    if (matchar[i,1]='PANO2') then spid=217;
    if (matchar[i,1]='PAPE5') then spid=218;
    if (matchar[i,1]='PAPL3') then spid=219;
    if (matchar[i,1]='PAROx') then spid=220;
    if (matchar[i,1]='PASE5') then spid=221;
    if (matchar[i,1]='PASEC') then spid=222;
    if (matchar[i,1]='PHABx') then spid=223;
    if (matchar[i,1]='PHAM4') then spid=224;
    if (matchar[i,1]='PHAN5') then spid=225;
    if (matchar[i,1]='PHCI4') then spid=226;
    if (matchar[i,1]='PHHE4') then spid=227;
    if (matchar[i,1]='PHHE5') then spid=228;
    if (matchar[i,1]='PHMO9') then spid=229;
    if (matchar[i,1]='PHTEx') then spid=230;
    if (matchar[i,1]='PLHOx') then spid=231;
    if (matchar[i,1]='PLODx') then spid=232;
    if (matchar[i,1]='PLVIx') then spid=233;
    if (matchar[i,1]='PLWRx') then spid=234;
    if (matchar[i,1]='POERx') then spid=235;
    if (matchar[i,1]='POPEx') then spid=236;
    if (matchar[i,1]='POPOx') then spid=237;
    if (matchar[i,1]='POPR4') then spid=238;
    if (matchar[i,1]='POTEx') then spid=239;
    if (matchar[i,1]='POVEx') then spid=240;
    if (matchar[i,1]='PSOB3') then spid=241;
    if (matchar[i,1]='PTAQx') then spid=242;
    if (matchar[i,1]='PTVI2') then spid=243;
    if (matchar[i,1]='PYCA2') then spid=244;
    if (matchar[i,1]='PYMU2') then spid=245;
    if (matchar[i,1]='RHGL2') then spid=246;
    if (matchar[i,1]='RHHAx') then spid=247;
    if (matchar[i,1]='RHLAx') then spid=248;
    if (matchar[i,1]='RHMI4') then spid=249;
    if (matchar[i,1]='RUABx') then spid=250;
    if (matchar[i,1]='RUAL4') then spid=251;
    if (matchar[i,1]='RUCO2') then spid=252;
    if (matchar[i,1]='RUHA2') then spid=253;
    if (matchar[i,1]='RUHI2') then spid=254;
    if (matchar[i,1]='RUHU6') then spid=255;
    if (matchar[i,1]='SACA1') then spid=256;
    if (matchar[i,1]='SACA3') then spid=257;
    if (matchar[i,1]='SCCA4') then spid=258;
    if (matchar[i,1]='SCCIx') then spid=259;
    if (matchar[i,1]='SCOL2') then spid=260;
    if (matchar[i,1]='SCSCx') then spid=261;
    if (matchar[i,1]='SEARx') then spid=262;
    if (matchar[i,1]='SIABx') then spid=263;
    if (matchar[i,1]='SIAN2') then spid=264;
    if (matchar[i,1]='SICIx') then spid=265;
    if (matchar[i,1]='SILIx') then spid=266;
    if (matchar[i,1]='SIRHx') then spid=267;
    if (matchar[i,1]='SOAL6') then spid=268;
    if (matchar[i,1]='SOAM4') then spid=269;
    if (matchar[i,1]='SOASx') then spid=270;
    if (matchar[i,1]='SOCA6') then spid=271;
    if (matchar[i,1]='SOEL3') then spid=272;
    if (matchar[i,1]='SONU2') then spid=273;
    if (matchar[i,1]='SOOLx') then spid=274;
    if (matchar[i,1]='SOPYx') then spid=275;
    if (matchar[i,1]='SORAx') then spid=276;
    if (matchar[i,1]='SPCLx') then spid=277;
    if (matchar[i,1]='SPCO1') then spid=278;
    if (matchar[i,1]='SPINx') then spid=279;
    if (matchar[i,1]='SPOBx') then spid=280;
    if (matchar[i,1]='SPVAx') then spid=281;
    if (matchar[i,1]='STBI2') then spid=282;
    if (matchar[i,1]='STHE4') then spid=283;
    if (matchar[i,1]='STLE5') then spid=284;
    if (matchar[i,1]='STLE6') then spid=285;
    if (matchar[i,1]='STPI3') then spid=286;
    if (matchar[i,1]='STSYx') then spid=287;
    if (matchar[i,1]='STUM2') then spid=288;
    if (matchar[i,1]='SYPA1') then spid=289;
    if (matchar[i,1]='TAOFx') then spid=290;
    if (matchar[i,1]='TEONx') then spid=291;
    if (matchar[i,1]='TRBE3') then spid=292;
    if (matchar[i,1]='TRBE4') then spid=293;
    if (matchar[i,1]='TRBEx') then spid=294;
    if (matchar[i,1]='TRBI2') then spid=295;
    if (matchar[i,1]='TRDI2') then spid=296;
    if (matchar[i,1]='TRFL2') then spid=297;
    if (matchar[i,1]='TRFLC') then spid=298;
    if (matchar[i,1]='TRFLF') then spid=299;
    if (matchar[i,1]='TRHIx') then spid=300;
    if (matchar[i,1]='TRPE4') then spid=301;
    if (matchar[i,1]='TRPU4') then spid=302;
    if (matchar[i,1]='TRRA5') then spid=303;
    if (matchar[i,1]='TRUR2') then spid=304;
    if (matchar[i,1]='TYDOx') then spid=305;
    if (matchar[i,1]='UNGR3') then spid=306;
    if (matchar[i,1]='URCIx') then spid=307;
    if (matchar[i,1]='VEARx') then spid=308;
    if (matchar[i,1]='VETE3') then spid=309;
    if (matchar[i,1]='VILE2') then spid=310;
    if (matchar[i,1]='VIMIx') then spid=311;
    if (matchar[i,1]='VISOx') then spid=312;
    if (matchar[i,1]='VUOCx') then spid=313;
    if (matchar[i,1]='WAMAx') then spid=314;
    if (matchar[i,1]='XXXXx') then spid=315;
	matcount[uniquad,spid]=matnum[i,3];
end;

datids=matnum;
do i=1 to nquads;						*why are we doing this?;
	datids[i,3]=10*(datids[i,1]-1)*datids[i,2];
end;
*print datids;

mat3=datids//mat1n; *sticks the 2 together;
matpa=mat3;

do i=1 to nquads;
	do j=1 to nsp;
		colno=j+3;
		matpa[i,colno]=99;
			if (mat3[i,colno]=0) then matpa[i,colno]=0;
			if (mat3[i,colno]>0) then matpa[i,colno]=1;
	end;
end;
quit;
