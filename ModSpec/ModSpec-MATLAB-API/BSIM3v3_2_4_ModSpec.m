function MOD = BSIM3v3_2_4_ModSpec(uniqID)
%function MOD = BSIM3v3_2_4_ModSpec(uniqID)
% ModSpec implementation of BSIM3v3.2.4 model
%/**** BSIM3v3.2.4, Released by Xuemei Xi 12/21/2001 ****/
%/**********
% * Copyright 2001 Regents of the University of California. All rights reserved.
% * File: b3ld.c of BSIM3v3.2.4
% * Author: 1991 JianHui Huang and Min-Chie Jeng.
% * Modified by Mansun Chan (1995).
% * Author: 1997-1999 Weidong Liu.
% * Author: 2001 Xuemei Xi
% * Modified by Xuemei Xi, 10/05, 12/21, 2001.
% **********/
%
% Converted to ModSpec format: JR, 2012/07/18.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%change log:
%-----------
%2014/05/13: Bichen Wu <bichen@berkeley.edu> Added the function handle of fqei
%          and fqeiJ to reduce redundant calling of f/q functions and to
%          improve efficiency


%
% use the common ModSpec skeleton, sets up fields and defaults
   MOD = ModSpec_common_skeleton();

% set up data members defined in ModSpec_common_skeleton. These are
% used by the API functions defined there.

% uniqID
   if nargin < 1
      MOD.uniqID = '';
   else
      MOD.uniqID = uniqID;
   end

   MOD.model_name = 'BSIM3v3_2_4';
   MOD.spice_key = 'm';
   MOD.model_description = 'BSIM3 v3.2.4, translated from Ning Dong''s Verilog-A version';

   %//Original Copyright Information 

   %% constants
   % the following constants are from b3set.c
   MAX_EXP=5.834617425e+14;
   MIN_EXP=1.713908431e-15;
   EPSOX=3.453133e-11;
   EPSSI=1.03594e-10;
   PI=3.141592654;
   
   % the following constants are from b3temp.c
   KboQ=8.617087e-5;  % Kb / q  where q = 1.60219e-19 
   EXP_THRESHOLD=34.0;
   Charge_q=1.60219e-19;
   
   % the following constants are from b3ld.c
   DELTA_1=0.02;
   DELTA_3=0.02;
   DELTA_4=0.02;
   
   CONSTroot=sqrt(2.0);
   NOTGIVEN=-9999.9999;
   CKTgmin=1e-12;
   CKTtemp=(27+273.15); %% HACK: should read the temperature
   CONSTvt0=0.025864187;

      % The following parameters are extracted from b3.c
      % The default value of these parameters are extracted from b3set.c
      % For those 'unspecified', set them to NOTGIVEN
      %
      % device parameters (from BSIM3pTable)
   MOD.parm_names = {...
      'l', ... %10e-6;   %Length
      'w', ... %5e-6;   %Width
      'ad', ... %100e-12;   %Drain area
      'as', ... %100e-12;   %Source area
      'pd', ... %40e-6;   %Drain perimeter
      'ps', ... %40e-6;   %Source perimeter
      'nrd', ... %1;   %Number of squares in drain
      'nrs', ... %1;   %Number of squares in source
      'nqsmod', ... %0;   %Non-quasi-static model selector
      'capmod', ... %0;   %Capacitance model selector
      'mobmod', ... %1;   %Mobility model selector
      'noimod', ... %1;   %Noise model selector
      'binunit', ... %1;   %Bin  unit  selector
      'version', ... %3.24;   % parameter for model version
      'tox', ... %1.5e-8;   %Gate oxide thickness in meters
      'toxm', ... %1.5e-8;   %Gate oxide thickness used in extraction
      'cdsc', ... %2.4e-4;   %Drain/Source and channel coupling capacitance
      'cdscb', ... %0.0;   %Body-bias dependence of cdsc
      'cdscd', ... %0.0;   %Drain-bias dependence of cdsc
      'cit', ... %0.0;   %Interface state capacitance
      'nfactor', ... %1.0;   %Subthreshold swing Coefficient
      'xj', ... %0.15e-6;   %Junction depth in meters
      'vsat', ... %8e4;   %Saturation velocity at tnom
      'at', ... %3.3e4;   %Temperature coefficient of vsat
      'a0', ... %1.0;   %Non-uniform depletion width effect coefficient.
      'ags', ... %0.0;   %Gate bias  coefficient of Abulk.
      'a1', ... %0.0;   %Non-saturation effect coefficient
      'a2', ... %1.0;   %Non-saturation effect coefficient
      'keta', ... %-0.047;   %Body-bias coefficient of non-uniform depletion width effect.
      'nsub', ... %6.0e-16;   %Substrate doping concentration
      'nch', ... %1.7e17;   %Channel doping concentration
      'ngate', ... %0;   %Poly-gate doping concentration
      'gamma1', ... %0.0;   %Vth body coefficient
      'gamma2', ... %0.0;   %Vth body coefficient
      'vbx', ... %0.0;   %Vth transition body Voltage
      'vbm', ... %-3.0;   %Maximum body voltage
      'xt', ... %1.55e-7;   %Doping depth
      'k1', ... %NOTGIVEN;   %Bulk effect coefficient 1
      'kt1', ... %-0.11;   %Temperature coefficient of Vth
      'kt1l', ... %0.0;   %Temperature coefficient of Vth
      'kt2', ... %0.022;   %Body-coefficient of kt1
      'k2', ... %NOTGIVEN;   %Bulk effect coefficient 2
      'k3', ... %80;   %Narrow width effect coefficient
      'k3b', ... %0.0;   %Body effect coefficient of k3
      'w0', ... %2.5e-6;   %Narrow width effect parameter
      'nlx', ... %1.74e-7;   %Lateral non-uniform doping effect
      'dvt0', ... %2.2;   %Short channel effect coeff. 0
      'dvt1', ... %0.53;   %Short channel effect coeff. 1
      'dvt2', ... %-0.032;   %Short channel effect coeff. 2
      'dvt0w', ... %0.0;   %Narrow Width coeff. 0
      'dvt1w', ... %5.3e6;   %Narrow Width effect coeff. 1
      'dvt2w', ... %-0.032;   %Narrow Width effect coeff. 2
      'drout', ... %0.56;   %DIBL coefficient of output resistance
      'dsub', ... %0.56;   %DIBL coefficient in the subthreshold region
      'vth0', ... %NOTGIVEN;   %Threshold voltage
      'ua', ... %2.25e-9;   %Linear gate dependence of mobility
      'ua1', ... %4.31e-9;   %Temperature coefficient of ua
      'ub', ... %5.87e-19;   %Quadratic gate dependence of mobility
      'ub1', ... %-7.61e-18;   %Temperature coefficient of ub
      'uc', ... %NOTGIVEN;   %Body-bias dependence of mobility
      'uc1', ... %NOTGIVEN;   %Temperature coefficient of uc
      'u0', ... %NOTGIVEN;   %Low-field mobility at Tn1m
      'ute', ... %-1.5;   %Temperature coefficient of mobility
      'voff', ... %-0.08;   %Threshold voltage offset
      'tnom', ... %0.0;   %Parameter measurement temperature
      'cgso', ... %NOTGIVEN;   %Gate-source overlap capacitance per width
      'cgdo', ... %NOTGIVEN;   %Gate-drain overlap capacitance per width
      'cgbo', ... %NOTGIVEN;   %Gate-bulk overlap capacitance per length
      'xpart', ... %0.0;   %Channel charge partitioning
      'elm', ... %5.0;   %Non-quasi-static Elmore Constant Parameter
      'delta', ... %0.01;   %Effective Vds parameter
      'rsh', ... %0.0;   %Source-drain sheet resistance
      'rdsw', ... %0.0;   %Source-drain resistance per width
      'prwg', ... %0.0;   %Gate-bias effect on parasitic resistance 
      'prwb', ... %0.0;   %Body-effect on parasitic resistance 
      'prt', ... %0.0;   %Temperature coefficient of parasitic resistance 
      'eta0', ... %0.08;   %Subthreshold region DIBL coefficient
      'etab', ... %-0.07;   %Subthreshold region DIBL coefficient
      'pclm', ... %1.3;   %Channel length modulation Coefficient
      'pdiblc1', ... %0.39;   %Drain-induced barrier lowering coefficient
      'pdiblc2', ... %8.6e-3;   %Drain-induced barrier lowering coefficient
      'pdiblcb', ... %0.0;   %Body-effect on drain-induced barrier lowering
      'pscbe1', ... %4.24e8;   %Substrate current body-effect coefficient
      'pscbe2', ... %1e-5;   %Substrate current body-effect coefficient
      'pvag', ... %0.0;   %Gate dependence of output resistance parameter
      'js', ... %1e-4;   %Source/drain junction reverse saturation current density
      'jsw', ... %0.0;   %Sidewall junction reverse saturation current density
      'pb', ... %1.0;   %Source/drain junction built-in potential
      'nj', ... %1.0;   %Source/drain junction emission coefficient
      'xti', ... %3.0;   %Junction current temperature exponent
      'mj', ... %0.5;   %Source/drain bottom junction capacitance grading coefficient
      'pbsw', ... %1.0;   %Source/drain sidewall junction capacitance built in potential
      'mjsw', ... %0.33;   %Source/drain sidewall junction capacitance grading coefficient
      'pbswg', ... %1.0;   %Source/drain (gate side) sidewall junction capacitance built in potential
      'mjswg', ... %0.33;   %Source/drain (gate side) sidewall junction capacitance grading coefficient
      'cj', ... %5e-4;   %Source/drain bottom junction capacitance per unit area
      'vfbcv', ... %-1.0;   %Flat Band Voltage parameter for capmod=0 only
      'vfb', ... %-1;   %Flat Band Voltage
      'cjsw', ... %5e-10;   %Source/drain sidewall junction capacitance per unit periphery
      'cjswg', ... %5e-10;   %Source/drain (gate side) sidewall junction capacitance per unit width
      'tpb', ... %0.0;   %Temperature coefficient of pb
      'tcj', ... %0.0;   %Temperature coefficient of cj
      'tpbsw', ... %0.0;   %Temperature coefficient of pbsw
      'tcjsw', ... %0.0;   %Temperature coefficient of cjsw
      'tpbswg', ... %0.0;   %Temperature coefficient of pbswg
      'tcjswg', ... %0.0;   %Temperature coefficient of cjswg
      'Acde', ... %1.0;   %Exponential coefficient for finite charge thickness
      'moin', ... %15.0;   %Coefficient for gate-bias dependent surface potential
      'noff', ... %1.0;   %C-V turn-on/off parameter
      'voffcv', ... %0.0;   %C-V lateral-shift parameter
      'lint', ... %0.0;   %Length reduction parameter
      'll', ... %0.0;   %Length reduction parameter
      'llc', ... %0.0;   %Length reduction parameter for CV
      'lln', ... %1.0;   %Length reduction parameter
      'lw', ... %0.0;   %Length reduction parameter
      'lwc', ... %0.0;   %Length reduction parameter for CV
      'lwn', ... %1.0;   %Length reduction parameter
      'lwl', ... %0.0;   %Length reduction parameter
      'lwlc', ... %0.0;   %Length reduction parameter for CV
      'lmin', ... %0.0;   %Minimum length for the model
      'lmax', ... %1.0;   %Maximum length for the model
      'wr', ... %1.0;   %Width dependence of rds
      'wint', ... %0.0;   %Width reduction parameter
      'dwg', ... %0.0;   %Width reduction parameter
      'dwb', ... %0.0;   %Width reduction parameter
      'wl', ... %0.0;   %Width reduction parameter
      'wlc', ... %0.0;   %Width reduction parameter for CV
      'wln', ... %1.0;   %Width reduction parameter
      'ww', ... %0.0;   %Width reduction parameter
      'wwc', ... %0.0;   %Width reduction parameter for CV
      'wwn', ... %1.0;   %Width reduction parameter
      'wwl', ... %0.0;   %Width reduction parameter
      'wwlc', ... %0.0;   %Width reduction parameter for CV
      'wmin', ... %0.0;   %Minimum width for the model
      'wmax', ... %1.0;   %Maximum width for the model
      'b0', ... %0.0;   %Abulk narrow width parameter
      'b1', ... %0.0;   %Abulk narrow width parameter
      'cgsl', ... %0.0;   %New C-V model parameter
      'cgdl', ... %0.0;   %New C-V model parameter
      'ckappa', ... %0.6;   %New C-V model parameter
      'cf', ... %NOTGIVEN;   %Fringe capacitance parameter
      'Clc', ... %1e-7;   %Vdsat parameter for C-V model
      'cle', ... %0.6;   %Vdsat parameter for C-V model
      'dwc', ... %0.0;   %Delta W for C-V model
      'dlc', ... %NOTGIVEN;   %Delta L for C-V model
      'alpha0', ... %0.0;   %substrate current model parameter
      'alpha1', ... %0.0;   %substrate current model parameter
      'beta0', ... %30.0;   %substrate current model parameter
      'ijth', ... %0.1;   %Diode limiting current
      'lcdsc', ... %0.0;   %Length dependence of cdsc
      'lcdscb', ... %0.0;   %Length dependence of cdscb
      'lcdscd', ... %0.0;   %Length dependence of cdscd
      'lcit', ... %0.0;   %Length dependence of cit
      'lnfactor', ... %0.0;   %Length dependence of nfactor
      'lxj', ... %0.0;   %Length dependence of xj
      'lvsat', ... %0.0;   %Length dependence of vsat
      'lat', ... %0.0;   %Length dependence of at
      'la0', ... %0.0;   %Length dependence of a0
      'lags', ... %0.0;   %Length dependence of ags
      'la1', ... %0.0;   %Length dependence of a1
      'la2', ... %0.0;   %Length dependence of a2
      'lketa', ... %0.0;   %Length dependence of keta
      'lnsub', ... %0.0;   %Length dependence of nsub
      'lnch', ... %0.0;   %Length dependence of nch
      'lngate', ... %0.0;   %Length dependence of ngate
      'lgamma1', ... %0.0;   %Length dependence of gamma1
      'lgamma2', ... %0.0;   %Length dependence of gamma2
      'lvbx', ... %0.0;   %Length dependence of vbx
      'lvbm', ... %0.0;   %Length dependence of vbm
      'lxt', ... %0.0;   %Length dependence of xt
      'lk1', ... %0.0;   %Length dependence of k1
      'lkt1', ... %0.0;   %Length dependence of kt1
      'lkt1l', ... %0.0;   %Length dependence of kt1l
      'lkt2', ... %0.0;   %Length dependence of kt2
      'lk2', ... %0.0;   %Length dependence of k2
      'lk3', ... %0.0;   %Length dependence of k3
      'lk3b', ... %0.0;   %Length dependence of k3b
      'lw0', ... %0.0;   %Length dependence of w0
      'lnlx', ... %0.0;   %Length dependence of nlx
      'ldvt0', ... %0.0;   %Length dependence of dvt0
      'ldvt1', ... %0.0;   %Length dependence of dvt1
      'ldvt2', ... %0.0;   %Length dependence of dvt2
      'ldvt0w', ... %0.0;   %Length dependence of dvt0w
      'ldvt1w', ... %0.0;   %Length dependence of dvt1w
      'ldvt2w', ... %0.0;   %Length dependence of dvt2w
      'ldrout', ... %0.0;   %Length dependence of drout
      'ldsub', ... %0.0;   %Length dependence of dsub
      'lvth0', ... %0.0;   %Length dependence of vto
      'lua', ... %0.0;   %Length dependence of ua
      'lua1', ... %0.0;   %Length dependence of ua1
      'lub', ... %0.0;   %Length dependence of ub
      'lub1', ... %0.0;   %Length dependence of ub1
      'luc', ... %0.0;   %Length dependence of uc
      'luc1', ... %0.0;   %Length dependence of uc1
      'lu0', ... %0.0;   %Length dependence of u0
      'lute', ... %0.0;   %Length dependence of ute
      'lvoff', ... %0.0;   %Length dependence of voff
      'lelm', ... %0.0;   %Length dependence of elm
      'ldelta', ... %0.0;   %Length dependence of delta
      'lrdsw', ... %0.0;   %Length dependence of rdsw 
      'lprwg', ... %0.0;   %Length dependence of prwg 
      'lprwb', ... %0.0;   %Length dependence of prwb 
      'lprt', ... %0.0;   %Length dependence of prt 
      'leta0', ... %0.0;   %Length dependence of eta0
      'letab', ... %0.0;   %Length dependence of etab
      'lpclm', ... %0.0;   %Length dependence of pclm
      'lpdiblc1', ... %0.0;   %Length dependence of pdiblc1
      'lpdiblc2', ... %0.0;   %Length dependence of pdiblc2
      'lpdiblcb', ... %0.0;   %Length dependence of pdiblcb
      'lpscbe1', ... %0.0;   %Length dependence of pscbe1
      'lpscbe2', ... %0.0;   %Length dependence of pscbe2
      'lpvag', ... %0.0;   %Length dependence of pvag
      'lwr', ... %0.0;   %Length dependence of wr
      'ldwg', ... %0.0;   %Length dependence of dwg
      'ldwb', ... %0.0;   %Length dependence of dwb
      'lb0', ... %0.0;   %Length dependence of b0
      'lb1', ... %0.0;   %Length dependence of b1
      'lcgsl', ... %0.0;   %Length dependence of cgsl
      'lcgdl', ... %0.0;   %Length dependence of cgdl
      'lckappa', ... %0.0;   %Length dependence of ckappa
      'lcf', ... %0.0;   %Length dependence of cf
      'lclc', ... %0.0;   %Length dependence of clc
      'lcle', ... %0.0;   %Length dependence of cle
      'lalpha0', ... %0.0;   %Length dependence of alpha0
      'lalpha1', ... %0.0;   %Length dependence of alpha1
      'lbeta0', ... %0.0;   %Length dependence of beta0
      'lvfbcv', ... %0.0;   %Length dependence of vfbcv
      'lvfb', ... %0.0;   %Length dependence of vfb
      'lacde', ... %0.0;   %Length dependence of acde
      'lmoin', ... %0.0;   %Length dependence of moin
      'lnoff', ... %0.0;   %Length dependence of noff
      'lvoffcv', ... %0.0;   %Length dependence of voffcv
      'wcdsc', ... %0.0;   %Width dependence of cdsc
      'wcdscb', ... %0.0;   %Width dependence of cdscb
      'wcdscd', ... %0.0;   %Width dependence of cdscd
      'wcit', ... %0.0;   %Width dependence of cit
      'wnfactor', ... %0.0;   %Width dependence of nfactor
      'wxj', ... %0.0;   %Width dependence of xj
      'wvsat', ... %0.0;   %Width dependence of vsat
      'wat', ... %0.0;   %Width dependence of at
      'wa0', ... %0.0;   %Width dependence of a0
      'wags', ... %0.0;   %Width dependence of ags
      'wa1', ... %0.0;   %Width dependence of a1
      'wa2', ... %0.0;   %Width dependence of a2
      'wketa', ... %0.0;   %Width dependence of keta
      'wnsub', ... %0.0;   %Width dependence of nsub
      'wnch', ... %0.0;   %Width dependence of nch
      'wngate', ... %0.0;   %Width dependence of ngate
      'wgamma1', ... %0.0;   %Width dependence of gamma1
      'wgamma2', ... %0.0;   %Width dependence of gamma2
      'wvbx', ... %0.0;   %Width dependence of vbx
      'wvbm', ... %0.0;   %Width dependence of vbm
      'wxt', ... %0.0;   %Width dependence of xt
      'wk1', ... %0.0;   %Width dependence of k1
      'wkt1', ... %0.0;   %Width dependence of kt1
      'wkt1l', ... %0.0;   %Width dependence of kt1l
      'wkt2', ... %0.0;   %Width dependence of kt2
      'wk2', ... %0.0;   %Width dependence of k2
      'wk3', ... %0.0;   %Width dependence of k3
      'wk3b', ... %0.0;   %Width dependence of k3b
      'ww0', ... %0.0;   %Width dependence of w0
      'wnlx', ... %0.0;   %Width dependence of nlx
      'wdvt0', ... %0.0;   %Width dependence of dvt0
      'wdvt1', ... %0.0;   %Width dependence of dvt1
      'wdvt2', ... %0.0;   %Width dependence of dvt2
      'wdvt0w', ... %0.0;   %Width dependence of dvt0w
      'wdvt1w', ... %0.0;   %Width dependence of dvt1w
      'wdvt2w', ... %0.0;   %Width dependence of dvt2w
      'wdrout', ... %0.0;   %Width dependence of drout
      'wdsub', ... %0.0;   %Width dependence of dsub
      'wvth0', ... %0.0;   %Width dependence of vto
      'wua', ... %0.0;   %Width dependence of ua
      'wua1', ... %0.0;   %Width dependence of ua1
      'wub', ... %0.0;   %Width dependence of ub
      'wub1', ... %0.0;   %Width dependence of ub1
      'wuc', ... %0.0;   %Width dependence of uc
      'wuc1', ... %0.0;   %Width dependence of uc1
      'wu0', ... %0.0;   %Width dependence of u0
      'wute', ... %0.0;   %Width dependence of ute
      'wvoff', ... %0.0;   %Width dependence of voff
      'welm', ... %0.0;   %Width dependence of elm
      'wdelta', ... %0.0;   %Width dependence of delta
      'wrdsw', ... %0.0;   %Width dependence of rdsw 
      'wprwg', ... %0.0;   %Width dependence of prwg 
      'wprwb', ... %0.0;   %Width dependence of prwb 
      'wprt', ... %0.0;   %Width dependence of prt
      'weta0', ... %0.0;   %Width dependence of eta0
      'wetab', ... %0.0;   %Width dependence of etab
      'wpclm', ... %0.0;   %Width dependence of pclm
      'wpdiblc1', ... %0.0;   %Width dependence of pdiblc1
      'wpdiblc2', ... %0.0;   %Width dependence of pdiblc2
      'wpdiblcb', ... %0.0;   %Width dependence of pdiblcb
      'wpscbe1', ... %0.0;   %Width dependence of pscbe1
      'wpscbe2', ... %0.0;   %Width dependence of pscbe2
      'wpvag', ... %0.0;   %Width dependence of pvag
      'wwr', ... %0.0;   %Width dependence of wr
      'wdwg', ... %0.0;   %Width dependence of dwg
      'wdwb', ... %0.0;   %Width dependence of dwb
      'wb0', ... %0.0;   %Width dependence of b0
      'wb1', ... %0.0;   %Width dependence of b1
      'wcgsl', ... %0.0;   %Width dependence of cgsl
      'wcgdl', ... %0.0;   %Width dependence of cgdl
      'wckappa', ... %0.0;   %Width dependence of ckappa
      'wcf', ... %0.0;   %Width dependence of cf
      'wclc', ... %0.0;   %Width dependence of clc
      'wcle', ... %0.0;   %Width dependence of cle
      'walpha0', ... %0.0;   %Width dependence of alpha0
      'walpha1', ... %0.0;   %Width dependence of alpha1
      'wbeta0', ... %0.0;   %Width dependence of beta0
      'wvfbcv', ... %0.0;   %Width dependence of vfbcv
      'wvfb', ... %0.0;   %Width dependence of vfb
      'wacde', ... %0.0;   %Width dependence of acde
      'wmoin', ... %0.0;   %Width dependence of moin
      'wnoff', ... %0.0;   %Width dependence of noff
      'wvoffcv', ... %0.0;   %Width dependence of voffcv
      'pcdsc', ... %0.0;   %Cross-term dependence of cdsc
      'pcdscb', ... %0.0;   %Cross-term dependence of cdscb
      'pcdscd', ... %0.0;   %Cross-term dependence of cdscd
      'pcit', ... %0.0;   %Cross-term dependence of cit
      'pnfactor', ... %0.0;   %Cross-term dependence of nfactor
      'pxj', ... %0.0;   %Cross-term dependence of xj
      'pvsat', ... %0.0;   %Cross-term dependence of vsat
      'pat', ... %0.0;   %Cross-term dependence of at
      'pa0', ... %0.0;   %Cross-term dependence of a0
      'pags', ... %0.0;   %Cross-term dependence of ags
      'pa1', ... %0.0;   %Cross-term dependence of a1
      'pa2', ... %0.0;   %Cross-term dependence of a2
      'pketa', ... %0.0;   %Cross-term dependence of keta
      'pnsub', ... %0.0;   %Cross-term dependence of nsub
      'pnch', ... %0.0;   %Cross-term dependence of nch
      'pngate', ... %0.0;   %Cross-term dependence of ngate
      'pgamma1', ... %0.0;   %Cross-term dependence of gamma1
      'pgamma2', ... %0.0;   %Cross-term dependence of gamma2
      'pvbx', ... %0.0;   %Cross-term dependence of vbx
      'pvbm', ... %0.0;   %Cross-term dependence of vbm
      'pxt', ... %0.0;   %Cross-term dependence of xt
      'pk1', ... %0.0;   %Cross-term dependence of k1
      'pkt1', ... %0.0;   %Cross-term dependence of kt1
      'pkt1l', ... %0.0;   %Cross-term dependence of kt1l
      'pkt2', ... %0.0;   %Cross-term dependence of kt2
      'pk2', ... %0.0;   %Cross-term dependence of k2
      'pk3', ... %0.0;   %Cross-term dependence of k3
      'pk3b', ... %0.0;   %Cross-term dependence of k3b
      'pw0', ... %0.0;   %Cross-term dependence of w0
      'pnlx', ... %0.0;   %Cross-term dependence of nlx
      'pdvt0', ... %0.0;   %Cross-term dependence of dvt0
      'pdvt1', ... %0.0;   %Cross-term dependence of dvt1
      'pdvt2', ... %0.0;   %Cross-term dependence of dvt2
      'pdvt0w', ... %0.0;   %Cross-term dependence of dvt0w
      'pdvt1w', ... %0.0;   %Cross-term dependence of dvt1w
      'pdvt2w', ... %0.0;   %Cross-term dependence of dvt2w
      'pdrout', ... %0.0;   %Cross-term dependence of drout
      'pdsub', ... %0.0;   %Cross-term dependence of dsub
      'pvth0', ... %0.0;   %Cross-term dependence of vto
      'pua', ... %0.0;   %Cross-term dependence of ua
      'pua1', ... %0.0;   %Cross-term dependence of ua1
      'pub', ... %0.0;   %Cross-term dependence of ub
      'pub1', ... %0.0;   %Cross-term dependence of ub1
      'puc', ... %0.0;   %Cross-term dependence of uc
      'puc1', ... %0.0;   %Cross-term dependence of uc1
      'pu0', ... %0.0;   %Cross-term dependence of u0
      'pute', ... %0.0;   %Cross-term dependence of ute
      'pvoff', ... %0.0;   %Cross-term dependence of voff
      'pelm', ... %0.0;   %Cross-term dependence of elm
      'pdelta', ... %0.0;   %Cross-term dependence of delta
      'prdsw', ... %0.0;   %Cross-term dependence of rdsw 
      'pprwg', ... %0.0;   %Cross-term dependence of prwg 
      'pprwb', ... %0.0;   %Cross-term dependence of prwb 
      'pprt', ... %0.0;   %Cross-term dependence of prt 
      'peta0', ... %0.0;   %Cross-term dependence of eta0
      'petab', ... %0.0;   %Cross-term dependence of etab
      'ppclm', ... %0.0;   %Cross-term dependence of pclm
      'ppdiblc1', ... %0.0;   %Cross-term dependence of pdiblc1
      'ppdiblc2', ... %0.0;   %Cross-term dependence of pdiblc2
      'ppdiblcb', ... %0.0;   %Cross-term dependence of pdiblcb
      'ppscbe1', ... %0.0;   %Cross-term dependence of pscbe1
      'ppscbe2', ... %0.0;   %Cross-term dependence of pscbe2
      'ppvag', ... %0.0;   %Cross-term dependence of pvag
      'pwr', ... %0.0;   %Cross-term dependence of wr
      'pdwg', ... %0.0;   %Cross-term dependence of dwg
      'pdwb', ... %0.0;   %Cross-term dependence of dwb
      'pb0', ... %0.0;   %Cross-term dependence of b0
      'pb1', ... %0.0;   %Cross-term dependence of b1
      'pcgsl', ... %0.0;   %Cross-term dependence of cgsl
      'pcgdl', ... %0.0;   %Cross-term dependence of cgdl
      'pckappa', ... %0.0;   %Cross-term dependence of ckappa
      'pcf', ... %0.0;   %Cross-term dependence of cf
      'pclc', ... %0.0;   %Cross-term dependence of clc
      'pcle', ... %0.0;   %Cross-term dependence of cle
      'palpha0', ... %0.0;   %Cross-term dependence of alpha0
      'palpha1', ... %0.0;   %Cross-term dependence of alpha1
      'pbeta0', ... %0.0;   %Cross-term dependence of beta0
      'pvfbcv', ... %0.0;   %Cross-term dependence of vfbcv
      'pvfb', ... %0.0;   %Cross-term dependence of vfb
      'pacde', ... %0.0;   %Cross-term dependence of acde
      'pmoin', ... %0.0;   %Cross-term dependence of moin
      'pnoff', ... %0.0;   %Cross-term dependence of noff
      'pvoffcv', ... %0.0;   %Cross-term dependence of voffcv
      'noia', ... %1e20;   %Flicker noise parameter
      'noib', ... %5e4;   %Flicker noise parameter
      'noic', ... %-1.4e-12;   %Flicker noise parameter
      'em', ... %4.1e7;   %Flicker noise parameter
      'ef', ... %1.0;   %Flicker noise frequency exponent
      'af', ... %1.0;   %Flicker noise exponent
      'kf', ... %0.0;   %Flicker noise coefficient
      'Type', ... %0;   % 1 for nmos, -1 for pmos
   };

      % device parameters (from BSIM3pTable)
      % model parameters (from BSIM3mPTable)
   MOD.parm_defaultvals = {...
      10e-6, ...   %Length
      5e-6, ...   %Width
      100e-12, ...   %Drain area
      100e-12, ...   %Source area
      40e-6, ...   %Drain perimeter
      40e-6, ...   %Source perimeter
      1, ...   %Number of squares in drain
      1, ...   %Number of squares in source
      0, ...   %Non-quasi-static model selector
      0, ...   %Capacitance model selector
      1, ...   %Mobility model selector
      1, ...   %Noise model selector
      1, ...   %Bin  unit  selector
      3.24, ...   % parameter for model version
      1.5e-8, ...   %Gate oxide thickness in meters
      1.5e-8, ...   %Gate oxide thickness used in extraction
      2.4e-4, ...   %Drain/Source and channel coupling capacitance
      0.0, ...   %Body-bias dependence of cdsc
      0.0, ...   %Drain-bias dependence of cdsc
      0.0, ...   %Interface state capacitance
      1.0, ...   %Subthreshold swing Coefficient
      0.15e-6, ...   %Junction depth in meters
      8e4, ...   %Saturation velocity at tnom
      3.3e4, ...   %Temperature coefficient of vsat
      1.0, ...   %Non-uniform depletion width effect coefficient.
      0.0, ...   %Gate bias  coefficient of Abulk.
      0.0, ...   %Non-saturation effect coefficient
      1.0, ...   %Non-saturation effect coefficient
      -0.047, ...   %Body-bias coefficient of non-uniform depletion width effect.
      6.0e-16, ...   %Substrate doping concentration
      1.7e17, ...   %Channel doping concentration
      0, ...   %Poly-gate doping concentration
      0.0, ...   %Vth body coefficient
      0.0, ...   %Vth body coefficient
      0.0, ...   %Vth transition body Voltage
      -3.0, ...   %Maximum body voltage
      1.55e-7, ...   %Doping depth
      NOTGIVEN, ...   %Bulk effect coefficient 1
      -0.11, ...   %Temperature coefficient of Vth
      0.0, ...   %Temperature coefficient of Vth
      0.022, ...   %Body-coefficient of kt1
      NOTGIVEN, ...   %Bulk effect coefficient 2
      80, ...   %Narrow width effect coefficient
      0.0, ...   %Body effect coefficient of k3
      2.5e-6, ...   %Narrow width effect parameter
      1.74e-7, ...   %Lateral non-uniform doping effect
      2.2, ...   %Short channel effect coeff. 0
      0.53, ...   %Short channel effect coeff. 1
      -0.032, ...   %Short channel effect coeff. 2
      0.0, ...   %Narrow Width coeff. 0
      5.3e6, ...   %Narrow Width effect coeff. 1
      -0.032, ...   %Narrow Width effect coeff. 2
      0.56, ...   %DIBL coefficient of output resistance
      0.56, ...   %DIBL coefficient in the subthreshold region
      NOTGIVEN, ...   %Threshold voltage
      2.25e-9, ...   %Linear gate dependence of mobility
      4.31e-9, ...   %Temperature coefficient of ua
      5.87e-19, ...   %Quadratic gate dependence of mobility
      -7.61e-18, ...   %Temperature coefficient of ub
      NOTGIVEN, ...   %Body-bias dependence of mobility
      NOTGIVEN, ...   %Temperature coefficient of uc
      NOTGIVEN, ...   %Low-field mobility at Tn1m
      -1.5, ...   %Temperature coefficient of mobility
      -0.08, ...   %Threshold voltage offset
      0.0, ...   %Parameter measurement temperature
      NOTGIVEN, ...   %Gate-source overlap capacitance per width
      NOTGIVEN, ...   %Gate-drain overlap capacitance per width
      NOTGIVEN, ...   %Gate-bulk overlap capacitance per length
      0.0, ...   %Channel charge partitioning
      5.0, ...   %Non-quasi-static Elmore Constant Parameter
      0.01, ...   %Effective Vds parameter
      0.0, ...   %Source-drain sheet resistance
      0.0, ...   %Source-drain resistance per width
      0.0, ...   %Gate-bias effect on parasitic resistance 
      0.0, ...   %Body-effect on parasitic resistance 
      0.0, ...   %Temperature coefficient of parasitic resistance 
      0.08, ...   %Subthreshold region DIBL coefficient
      -0.07, ...   %Subthreshold region DIBL coefficient
      1.3, ...   %Channel length modulation Coefficient
      0.39, ...   %Drain-induced barrier lowering coefficient
      8.6e-3, ...   %Drain-induced barrier lowering coefficient
      0.0, ...   %Body-effect on drain-induced barrier lowering
      4.24e8, ...   %Substrate current body-effect coefficient
      1e-5, ...   %Substrate current body-effect coefficient
      0.0, ...   %Gate dependence of output resistance parameter
      1e-4, ...   %Source/drain junction reverse saturation current density
      0.0, ...   %Sidewall junction reverse saturation current density
      1.0, ...   %Source/drain junction built-in potential
      1.0, ...   %Source/drain junction emission coefficient
      3.0, ...   %Junction current temperature exponent
      0.5, ...   %Source/drain bottom junction capacitance grading coefficient
      1.0, ...   %Source/drain sidewall junction capacitance built in potential
      0.33, ...   %Source/drain sidewall junction capacitance grading coefficient
      1.0, ...   %Source/drain (gate side) sidewall junction capacitance built in potential
      0.33, ...   %Source/drain (gate side) sidewall junction capacitance grading coefficient
      5e-4, ...   %Source/drain bottom junction capacitance per unit area
      -1.0, ...   %Flat Band Voltage parameter for capmod=0 only
      -1, ...   %Flat Band Voltage
      5e-10, ...   %Source/drain sidewall junction capacitance per unit periphery
      5e-10, ...   %Source/drain (gate side) sidewall junction capacitance per unit width
      0.0, ...   %Temperature coefficient of pb
      0.0, ...   %Temperature coefficient of cj
      0.0, ...   %Temperature coefficient of pbsw
      0.0, ...   %Temperature coefficient of cjsw
      0.0, ...   %Temperature coefficient of pbswg
      0.0, ...   %Temperature coefficient of cjswg
      1.0, ...   %Exponential coefficient for finite charge thickness
      15.0, ...   %Coefficient for gate-bias dependent surface potential
      1.0, ...   %C-V turn-on/off parameter
      0.0, ...   %C-V lateral-shift parameter
      0.0, ...   %Length reduction parameter
      0.0, ...   %Length reduction parameter
      0.0, ...   %Length reduction parameter for CV
      1.0, ...   %Length reduction parameter
      0.0, ...   %Length reduction parameter
      0.0, ...   %Length reduction parameter for CV
      1.0, ...   %Length reduction parameter
      0.0, ...   %Length reduction parameter
      0.0, ...   %Length reduction parameter for CV
      0.0, ...   %Minimum length for the model
      1.0, ...   %Maximum length for the model
      1.0, ...   %Width dependence of rds
      0.0, ...   %Width reduction parameter
      0.0, ...   %Width reduction parameter
      0.0, ...   %Width reduction parameter
      0.0, ...   %Width reduction parameter
      0.0, ...   %Width reduction parameter for CV
      1.0, ...   %Width reduction parameter
      0.0, ...   %Width reduction parameter
      0.0, ...   %Width reduction parameter for CV
      1.0, ...   %Width reduction parameter
      0.0, ...   %Width reduction parameter
      0.0, ...   %Width reduction parameter for CV
      0.0, ...   %Minimum width for the model
      1.0, ...   %Maximum width for the model
      0.0, ...   %Abulk narrow width parameter
      0.0, ...   %Abulk narrow width parameter
      0.0, ...   %New C-V model parameter
      0.0, ...   %New C-V model parameter
      0.6, ...   %New C-V model parameter
      NOTGIVEN, ...   %Fringe capacitance parameter
      1e-7, ...   %Vdsat parameter for C-V model
      0.6, ...   %Vdsat parameter for C-V model
      0.0, ...   %Delta W for C-V model
      NOTGIVEN, ...   %Delta L for C-V model
      0.0, ...   %substrate current model parameter
      0.0, ...   %substrate current model parameter
      30.0, ...   %substrate current model parameter
      0.1, ...   %Diode limiting current
      0.0, ...   %Length dependence of cdsc
      0.0, ...   %Length dependence of cdscb
      0.0, ...   %Length dependence of cdscd
      0.0, ...   %Length dependence of cit
      0.0, ...   %Length dependence of nfactor
      0.0, ...   %Length dependence of xj
      0.0, ...   %Length dependence of vsat
      0.0, ...   %Length dependence of at
      0.0, ...   %Length dependence of a0
      0.0, ...   %Length dependence of ags
      0.0, ...   %Length dependence of a1
      0.0, ...   %Length dependence of a2
      0.0, ...   %Length dependence of keta
      0.0, ...   %Length dependence of nsub
      0.0, ...   %Length dependence of nch
      0.0, ...   %Length dependence of ngate
      0.0, ...   %Length dependence of gamma1
      0.0, ...   %Length dependence of gamma2
      0.0, ...   %Length dependence of vbx
      0.0, ...   %Length dependence of vbm
      0.0, ...   %Length dependence of xt
      0.0, ...   %Length dependence of k1
      0.0, ...   %Length dependence of kt1
      0.0, ...   %Length dependence of kt1l
      0.0, ...   %Length dependence of kt2
      0.0, ...   %Length dependence of k2
      0.0, ...   %Length dependence of k3
      0.0, ...   %Length dependence of k3b
      0.0, ...   %Length dependence of w0
      0.0, ...   %Length dependence of nlx
      0.0, ...   %Length dependence of dvt0
      0.0, ...   %Length dependence of dvt1
      0.0, ...   %Length dependence of dvt2
      0.0, ...   %Length dependence of dvt0w
      0.0, ...   %Length dependence of dvt1w
      0.0, ...   %Length dependence of dvt2w
      0.0, ...   %Length dependence of drout
      0.0, ...   %Length dependence of dsub
      0.0, ...   %Length dependence of vto
      0.0, ...   %Length dependence of ua
      0.0, ...   %Length dependence of ua1
      0.0, ...   %Length dependence of ub
      0.0, ...   %Length dependence of ub1
      0.0, ...   %Length dependence of uc
      0.0, ...   %Length dependence of uc1
      0.0, ...   %Length dependence of u0
      0.0, ...   %Length dependence of ute
      0.0, ...   %Length dependence of voff
      0.0, ...   %Length dependence of elm
      0.0, ...   %Length dependence of delta
      0.0, ...   %Length dependence of rdsw 
      0.0, ...   %Length dependence of prwg 
      0.0, ...   %Length dependence of prwb 
      0.0, ...   %Length dependence of prt 
      0.0, ...   %Length dependence of eta0
      0.0, ...   %Length dependence of etab
      0.0, ...   %Length dependence of pclm
      0.0, ...   %Length dependence of pdiblc1
      0.0, ...   %Length dependence of pdiblc2
      0.0, ...   %Length dependence of pdiblcb
      0.0, ...   %Length dependence of pscbe1
      0.0, ...   %Length dependence of pscbe2
      0.0, ...   %Length dependence of pvag
      0.0, ...   %Length dependence of wr
      0.0, ...   %Length dependence of dwg
      0.0, ...   %Length dependence of dwb
      0.0, ...   %Length dependence of b0
      0.0, ...   %Length dependence of b1
      0.0, ...   %Length dependence of cgsl
      0.0, ...   %Length dependence of cgdl
      0.0, ...   %Length dependence of ckappa
      0.0, ...   %Length dependence of cf
      0.0, ...   %Length dependence of clc
      0.0, ...   %Length dependence of cle
      0.0, ...   %Length dependence of alpha0
      0.0, ...   %Length dependence of alpha1
      0.0, ...   %Length dependence of beta0
      0.0, ...   %Length dependence of vfbcv
      0.0, ...   %Length dependence of vfb
      0.0, ...   %Length dependence of acde
      0.0, ...   %Length dependence of moin
      0.0, ...   %Length dependence of noff
      0.0, ...   %Length dependence of voffcv
      0.0, ...   %Width dependence of cdsc
      0.0, ...   %Width dependence of cdscb
      0.0, ...   %Width dependence of cdscd
      0.0, ...   %Width dependence of cit
      0.0, ...   %Width dependence of nfactor
      0.0, ...   %Width dependence of xj
      0.0, ...   %Width dependence of vsat
      0.0, ...   %Width dependence of at
      0.0, ...   %Width dependence of a0
      0.0, ...   %Width dependence of ags
      0.0, ...   %Width dependence of a1
      0.0, ...   %Width dependence of a2
      0.0, ...   %Width dependence of keta
      0.0, ...   %Width dependence of nsub
      0.0, ...   %Width dependence of nch
      0.0, ...   %Width dependence of ngate
      0.0, ...   %Width dependence of gamma1
      0.0, ...   %Width dependence of gamma2
      0.0, ...   %Width dependence of vbx
      0.0, ...   %Width dependence of vbm
      0.0, ...   %Width dependence of xt
      0.0, ...   %Width dependence of k1
      0.0, ...   %Width dependence of kt1
      0.0, ...   %Width dependence of kt1l
      0.0, ...   %Width dependence of kt2
      0.0, ...   %Width dependence of k2
      0.0, ...   %Width dependence of k3
      0.0, ...   %Width dependence of k3b
      0.0, ...   %Width dependence of w0
      0.0, ...   %Width dependence of nlx
      0.0, ...   %Width dependence of dvt0
      0.0, ...   %Width dependence of dvt1
      0.0, ...   %Width dependence of dvt2
      0.0, ...   %Width dependence of dvt0w
      0.0, ...   %Width dependence of dvt1w
      0.0, ...   %Width dependence of dvt2w
      0.0, ...   %Width dependence of drout
      0.0, ...   %Width dependence of dsub
      0.0, ...   %Width dependence of vto
      0.0, ...   %Width dependence of ua
      0.0, ...   %Width dependence of ua1
      0.0, ...   %Width dependence of ub
      0.0, ...   %Width dependence of ub1
      0.0, ...   %Width dependence of uc
      0.0, ...   %Width dependence of uc1
      0.0, ...   %Width dependence of u0
      0.0, ...   %Width dependence of ute
      0.0, ...   %Width dependence of voff
      0.0, ...   %Width dependence of elm
      0.0, ...   %Width dependence of delta
      0.0, ...   %Width dependence of rdsw 
      0.0, ...   %Width dependence of prwg 
      0.0, ...   %Width dependence of prwb 
      0.0, ...   %Width dependence of prt
      0.0, ...   %Width dependence of eta0
      0.0, ...   %Width dependence of etab
      0.0, ...   %Width dependence of pclm
      0.0, ...   %Width dependence of pdiblc1
      0.0, ...   %Width dependence of pdiblc2
      0.0, ...   %Width dependence of pdiblcb
      0.0, ...   %Width dependence of pscbe1
      0.0, ...   %Width dependence of pscbe2
      0.0, ...   %Width dependence of pvag
      0.0, ...   %Width dependence of wr
      0.0, ...   %Width dependence of dwg
      0.0, ...   %Width dependence of dwb
      0.0, ...   %Width dependence of b0
      0.0, ...   %Width dependence of b1
      0.0, ...   %Width dependence of cgsl
      0.0, ...   %Width dependence of cgdl
      0.0, ...   %Width dependence of ckappa
      0.0, ...   %Width dependence of cf
      0.0, ...   %Width dependence of clc
      0.0, ...   %Width dependence of cle
      0.0, ...   %Width dependence of alpha0
      0.0, ...   %Width dependence of alpha1
      0.0, ...   %Width dependence of beta0
      0.0, ...   %Width dependence of vfbcv
      0.0, ...   %Width dependence of vfb
      0.0, ...   %Width dependence of acde
      0.0, ...   %Width dependence of moin
      0.0, ...   %Width dependence of noff
      0.0, ...   %Width dependence of voffcv
      0.0, ...   %Cross-term dependence of cdsc
      0.0, ...   %Cross-term dependence of cdscb
      0.0, ...   %Cross-term dependence of cdscd
      0.0, ...   %Cross-term dependence of cit
      0.0, ...   %Cross-term dependence of nfactor
      0.0, ...   %Cross-term dependence of xj
      0.0, ...   %Cross-term dependence of vsat
      0.0, ...   %Cross-term dependence of at
      0.0, ...   %Cross-term dependence of a0
      0.0, ...   %Cross-term dependence of ags
      0.0, ...   %Cross-term dependence of a1
      0.0, ...   %Cross-term dependence of a2
      0.0, ...   %Cross-term dependence of keta
      0.0, ...   %Cross-term dependence of nsub
      0.0, ...   %Cross-term dependence of nch
      0.0, ...   %Cross-term dependence of ngate
      0.0, ...   %Cross-term dependence of gamma1
      0.0, ...   %Cross-term dependence of gamma2
      0.0, ...   %Cross-term dependence of vbx
      0.0, ...   %Cross-term dependence of vbm
      0.0, ...   %Cross-term dependence of xt
      0.0, ...   %Cross-term dependence of k1
      0.0, ...   %Cross-term dependence of kt1
      0.0, ...   %Cross-term dependence of kt1l
      0.0, ...   %Cross-term dependence of kt2
      0.0, ...   %Cross-term dependence of k2
      0.0, ...   %Cross-term dependence of k3
      0.0, ...   %Cross-term dependence of k3b
      0.0, ...   %Cross-term dependence of w0
      0.0, ...   %Cross-term dependence of nlx
      0.0, ...   %Cross-term dependence of dvt0
      0.0, ...   %Cross-term dependence of dvt1
      0.0, ...   %Cross-term dependence of dvt2
      0.0, ...   %Cross-term dependence of dvt0w
      0.0, ...   %Cross-term dependence of dvt1w
      0.0, ...   %Cross-term dependence of dvt2w
      0.0, ...   %Cross-term dependence of drout
      0.0, ...   %Cross-term dependence of dsub
      0.0, ...   %Cross-term dependence of vto
      0.0, ...   %Cross-term dependence of ua
      0.0, ...   %Cross-term dependence of ua1
      0.0, ...   %Cross-term dependence of ub
      0.0, ...   %Cross-term dependence of ub1
      0.0, ...   %Cross-term dependence of uc
      0.0, ...   %Cross-term dependence of uc1
      0.0, ...   %Cross-term dependence of u0
      0.0, ...   %Cross-term dependence of ute
      0.0, ...   %Cross-term dependence of voff
      0.0, ...   %Cross-term dependence of elm
      0.0, ...   %Cross-term dependence of delta
      0.0, ...   %Cross-term dependence of rdsw 
      0.0, ...   %Cross-term dependence of prwg 
      0.0, ...   %Cross-term dependence of prwb 
      0.0, ...   %Cross-term dependence of prt 
      0.0, ...   %Cross-term dependence of eta0
      0.0, ...   %Cross-term dependence of etab
      0.0, ...   %Cross-term dependence of pclm
      0.0, ...   %Cross-term dependence of pdiblc1
      0.0, ...   %Cross-term dependence of pdiblc2
      0.0, ...   %Cross-term dependence of pdiblcb
      0.0, ...   %Cross-term dependence of pscbe1
      0.0, ...   %Cross-term dependence of pscbe2
      0.0, ...   %Cross-term dependence of pvag
      0.0, ...   %Cross-term dependence of wr
      0.0, ...   %Cross-term dependence of dwg
      0.0, ...   %Cross-term dependence of dwb
      0.0, ...   %Cross-term dependence of b0
      0.0, ...   %Cross-term dependence of b1
      0.0, ...   %Cross-term dependence of cgsl
      0.0, ...   %Cross-term dependence of cgdl
      0.0, ...   %Cross-term dependence of ckappa
      0.0, ...   %Cross-term dependence of cf
      0.0, ...   %Cross-term dependence of clc
      0.0, ...   %Cross-term dependence of cle
      0.0, ...   %Cross-term dependence of alpha0
      0.0, ...   %Cross-term dependence of alpha1
      0.0, ...   %Cross-term dependence of beta0
      0.0, ...   %Cross-term dependence of vfbcv
      0.0, ...   %Cross-term dependence of vfb
      0.0, ...   %Cross-term dependence of acde
      0.0, ...   %Cross-term dependence of moin
      0.0, ...   %Cross-term dependence of noff
      0.0, ...   %Cross-term dependence of voffcv
      1e20, ...   %Flicker noise parameter
      5e4, ...   %Flicker noise parameter
      -1.4e-12, ...   %Flicker noise parameter
      4.1e7, ...   %Flicker noise parameter
      1.0, ...   %Flicker noise frequency exponent
      1.0, ...   %Flicker noise exponent
      0.0, ...   %Flicker noise coefficient
      1, ...   % 1 for nmos, -1 for pmos
   };

   MOD.parm_types = {...
      'double', ...   %Length
      'double', ...   %Width
      'double', ...   %Drain area
      'double', ...   %Source area
      'double', ...   %Drain perimeter
      'double', ...   %Source perimeter
      'int', ...   %Number of squares in drain
      'int', ...   %Number of squares in source
      'int', ...   %Non-quasi-static model selector
      'int', ...   %Capacitance model selector
      'int', ...   %Mobility model selector
      'int', ...   %Noise model selector
      'int', ...   %Bin  unit  selector
      'double', ...   % parameter for model version
      'double', ...   %Gate oxide thickness in meters
      'double', ...   %Gate oxide thickness used in extraction
      'double', ...   %Drain/Source and channel coupling capacitance
      'double', ...   %Body-bias dependence of cdsc
      'double', ...   %Drain-bias dependence of cdsc
      'double', ...   %Interface state capacitance
      'double', ...   %Subthreshold swing Coefficient
      'double', ...   %Junction depth in meters
      'double', ...   %Saturation velocity at tnom
      'double', ...   %Temperature coefficient of vsat
      'double', ...   %Non-uniform depletion width effect coefficient.
      'double', ...   %Gate bias  coefficient of Abulk.
      'double', ...   %Non-saturation effect coefficient
      'double', ...   %Non-saturation effect coefficient
      'double', ...   %Body-bias coefficient of non-uniform depletion width effect.
      'double', ...   %Substrate doping concentration
      'double', ...   %Channel doping concentration
      'double', ...   %Poly-gate doping concentration
      'double', ...   %Vth body coefficient
      'double', ...   %Vth body coefficient
      'double', ...   %Vth transition body Voltage
      'double', ...   %Maximum body voltage
      'double', ...   %Doping depth
      'double', ...   %Bulk effect coefficient 1
      'double', ...   %Temperature coefficient of Vth
      'double', ...   %Temperature coefficient of Vth
      'double', ...   %Body-coefficient of kt1
      'double', ...   %Bulk effect coefficient 2
      'double', ...   %Narrow width effect coefficient
      'double', ...   %Body effect coefficient of k3
      'double', ...   %Narrow width effect parameter
      'double', ...   %Lateral non-uniform doping effect
      'double', ...   %Short channel effect coeff. 0
      'double', ...   %Short channel effect coeff. 1
      'double', ...   %Short channel effect coeff. 2
      'double', ...   %Narrow Width coeff. 0
      'double', ...   %Narrow Width effect coeff. 1
      'double', ...   %Narrow Width effect coeff. 2
      'double', ...   %DIBL coefficient of output resistance
      'double', ...   %DIBL coefficient in the subthreshold region
      'double', ...   %Threshold voltage
      'double', ...   %Linear gate dependence of mobility
      'double', ...   %Temperature coefficient of ua
      'double', ...   %Quadratic gate dependence of mobility
      'double', ...   %Temperature coefficient of ub
      'double', ...   %Body-bias dependence of mobility
      'double', ...   %Temperature coefficient of uc
      'double', ...   %Low-field mobility at Tn1m
      'double', ...   %Temperature coefficient of mobility
      'double', ...   %Threshold voltage offset
      'double', ...   %Parameter measurement temperature
      'double', ...   %Gate-source overlap capacitance per width
      'double', ...   %Gate-drain overlap capacitance per width
      'double', ...   %Gate-bulk overlap capacitance per length
      'double', ...   %Channel charge partitioning
      'double', ...   %Non-quasi-static Elmore Constant Parameter
      'double', ...   %Effective Vds parameter
      'double', ...   %Source-drain sheet resistance
      'double', ...   %Source-drain resistance per width
      'double', ...   %Gate-bias effect on parasitic resistance 
      'double', ...   %Body-effect on parasitic resistance 
      'double', ...   %Temperature coefficient of parasitic resistance 
      'double', ...   %Subthreshold region DIBL coefficient
      'double', ...   %Subthreshold region DIBL coefficient
      'double', ...   %Channel length modulation Coefficient
      'double', ...   %Drain-induced barrier lowering coefficient
      'double', ...   %Drain-induced barrier lowering coefficient
      'double', ...   %Body-effect on drain-induced barrier lowering
      'double', ...   %Substrate current body-effect coefficient
      'double', ...   %Substrate current body-effect coefficient
      'double', ...   %Gate dependence of output resistance parameter
      'double', ...   %Source/drain junction reverse saturation current density
      'double', ...   %Sidewall junction reverse saturation current density
      'double', ...   %Source/drain junction built-in potential
      'double', ...   %Source/drain junction emission coefficient
      'double', ...   %Junction current temperature exponent
      'double', ...   %Source/drain bottom junction capacitance grading coefficient
      'double', ...   %Source/drain sidewall junction capacitance built in potential
      'double', ...   %Source/drain sidewall junction capacitance grading coefficient
      'double', ...   %Source/drain (gate side) sidewall junction capacitance built in potential
      'double', ...   %Source/drain (gate side) sidewall junction capacitance grading coefficient
      'double', ...   %Source/drain bottom junction capacitance per unit area
      'double', ...   %Flat Band Voltage parameter for capmod=0 only
      'double', ...   %Flat Band Voltage
      'double', ...   %Source/drain sidewall junction capacitance per unit periphery
      'double', ...   %Source/drain (gate side) sidewall junction capacitance per unit width
      'double', ...   %Temperature coefficient of pb
      'double', ...   %Temperature coefficient of cj
      'double', ...   %Temperature coefficient of pbsw
      'double', ...   %Temperature coefficient of cjsw
      'double', ...   %Temperature coefficient of pbswg
      'double', ...   %Temperature coefficient of cjswg
      'double', ...   %Exponential coefficient for finite charge thickness
      'double', ...   %Coefficient for gate-bias dependent surface potential
      'double', ...   %C-V turn-on/off parameter
      'double', ...   %C-V lateral-shift parameter
      'double', ...   %Length reduction parameter
      'double', ...   %Length reduction parameter
      'double', ...   %Length reduction parameter for CV
      'double', ...   %Length reduction parameter
      'double', ...   %Length reduction parameter
      'double', ...   %Length reduction parameter for CV
      'double', ...   %Length reduction parameter
      'double', ...   %Length reduction parameter
      'double', ...   %Length reduction parameter for CV
      'double', ...   %Minimum length for the model
      'double', ...   %Maximum length for the model
      'double', ...   %Width dependence of rds
      'double', ...   %Width reduction parameter
      'double', ...   %Width reduction parameter
      'double', ...   %Width reduction parameter
      'double', ...   %Width reduction parameter
      'double', ...   %Width reduction parameter for CV
      'double', ...   %Width reduction parameter
      'double', ...   %Width reduction parameter
      'double', ...   %Width reduction parameter for CV
      'double', ...   %Width reduction parameter
      'double', ...   %Width reduction parameter
      'double', ...   %Width reduction parameter for CV
      'double', ...   %Minimum width for the model
      'double', ...   %Maximum width for the model
      'double', ...   %Abulk narrow width parameter
      'double', ...   %Abulk narrow width parameter
      'double', ...   %New C-V model parameter
      'double', ...   %New C-V model parameter
      'double', ...   %New C-V model parameter
      'double', ...   %Fringe capacitance parameter
      'double', ...   %Vdsat parameter for C-V model
      'double', ...   %Vdsat parameter for C-V model
      'double', ...   %Delta W for C-V model
      'double', ...   %Delta L for C-V model
      'double', ...   %substrate current model parameter
      'double', ...   %substrate current model parameter
      'double', ...   %substrate current model parameter
      'double', ...   %Diode limiting current
      'double', ...   %Length dependence of cdsc
      'double', ...   %Length dependence of cdscb
      'double', ...   %Length dependence of cdscd
      'double', ...   %Length dependence of cit
      'double', ...   %Length dependence of nfactor
      'double', ...   %Length dependence of xj
      'double', ...   %Length dependence of vsat
      'double', ...   %Length dependence of at
      'double', ...   %Length dependence of a0
      'double', ...   %Length dependence of ags
      'double', ...   %Length dependence of a1
      'double', ...   %Length dependence of a2
      'double', ...   %Length dependence of keta
      'double', ...   %Length dependence of nsub
      'double', ...   %Length dependence of nch
      'double', ...   %Length dependence of ngate
      'double', ...   %Length dependence of gamma1
      'double', ...   %Length dependence of gamma2
      'double', ...   %Length dependence of vbx
      'double', ...   %Length dependence of vbm
      'double', ...   %Length dependence of xt
      'double', ...   %Length dependence of k1
      'double', ...   %Length dependence of kt1
      'double', ...   %Length dependence of kt1l
      'double', ...   %Length dependence of kt2
      'double', ...   %Length dependence of k2
      'double', ...   %Length dependence of k3
      'double', ...   %Length dependence of k3b
      'double', ...   %Length dependence of w0
      'double', ...   %Length dependence of nlx
      'double', ...   %Length dependence of dvt0
      'double', ...   %Length dependence of dvt1
      'double', ...   %Length dependence of dvt2
      'double', ...   %Length dependence of dvt0w
      'double', ...   %Length dependence of dvt1w
      'double', ...   %Length dependence of dvt2w
      'double', ...   %Length dependence of drout
      'double', ...   %Length dependence of dsub
      'double', ...   %Length dependence of vto
      'double', ...   %Length dependence of ua
      'double', ...   %Length dependence of ua1
      'double', ...   %Length dependence of ub
      'double', ...   %Length dependence of ub1
      'double', ...   %Length dependence of uc
      'double', ...   %Length dependence of uc1
      'double', ...   %Length dependence of u0
      'double', ...   %Length dependence of ute
      'double', ...   %Length dependence of voff
      'double', ...   %Length dependence of elm
      'double', ...   %Length dependence of delta
      'double', ...   %Length dependence of rdsw 
      'double', ...   %Length dependence of prwg 
      'double', ...   %Length dependence of prwb 
      'double', ...   %Length dependence of prt 
      'double', ...   %Length dependence of eta0
      'double', ...   %Length dependence of etab
      'double', ...   %Length dependence of pclm
      'double', ...   %Length dependence of pdiblc1
      'double', ...   %Length dependence of pdiblc2
      'double', ...   %Length dependence of pdiblcb
      'double', ...   %Length dependence of pscbe1
      'double', ...   %Length dependence of pscbe2
      'double', ...   %Length dependence of pvag
      'double', ...   %Length dependence of wr
      'double', ...   %Length dependence of dwg
      'double', ...   %Length dependence of dwb
      'double', ...   %Length dependence of b0
      'double', ...   %Length dependence of b1
      'double', ...   %Length dependence of cgsl
      'double', ...   %Length dependence of cgdl
      'double', ...   %Length dependence of ckappa
      'double', ...   %Length dependence of cf
      'double', ...   %Length dependence of clc
      'double', ...   %Length dependence of cle
      'double', ...   %Length dependence of alpha0
      'double', ...   %Length dependence of alpha1
      'double', ...   %Length dependence of beta0
      'double', ...   %Length dependence of vfbcv
      'double', ...   %Length dependence of vfb
      'double', ...   %Length dependence of acde
      'double', ...   %Length dependence of moin
      'double', ...   %Length dependence of noff
      'double', ...   %Length dependence of voffcv
      'double', ...   %Width dependence of cdsc
      'double', ...   %Width dependence of cdscb
      'double', ...   %Width dependence of cdscd
      'double', ...   %Width dependence of cit
      'double', ...   %Width dependence of nfactor
      'double', ...   %Width dependence of xj
      'double', ...   %Width dependence of vsat
      'double', ...   %Width dependence of at
      'double', ...   %Width dependence of a0
      'double', ...   %Width dependence of ags
      'double', ...   %Width dependence of a1
      'double', ...   %Width dependence of a2
      'double', ...   %Width dependence of keta
      'double', ...   %Width dependence of nsub
      'double', ...   %Width dependence of nch
      'double', ...   %Width dependence of ngate
      'double', ...   %Width dependence of gamma1
      'double', ...   %Width dependence of gamma2
      'double', ...   %Width dependence of vbx
      'double', ...   %Width dependence of vbm
      'double', ...   %Width dependence of xt
      'double', ...   %Width dependence of k1
      'double', ...   %Width dependence of kt1
      'double', ...   %Width dependence of kt1l
      'double', ...   %Width dependence of kt2
      'double', ...   %Width dependence of k2
      'double', ...   %Width dependence of k3
      'double', ...   %Width dependence of k3b
      'double', ...   %Width dependence of w0
      'double', ...   %Width dependence of nlx
      'double', ...   %Width dependence of dvt0
      'double', ...   %Width dependence of dvt1
      'double', ...   %Width dependence of dvt2
      'double', ...   %Width dependence of dvt0w
      'double', ...   %Width dependence of dvt1w
      'double', ...   %Width dependence of dvt2w
      'double', ...   %Width dependence of drout
      'double', ...   %Width dependence of dsub
      'double', ...   %Width dependence of vto
      'double', ...   %Width dependence of ua
      'double', ...   %Width dependence of ua1
      'double', ...   %Width dependence of ub
      'double', ...   %Width dependence of ub1
      'double', ...   %Width dependence of uc
      'double', ...   %Width dependence of uc1
      'double', ...   %Width dependence of u0
      'double', ...   %Width dependence of ute
      'double', ...   %Width dependence of voff
      'double', ...   %Width dependence of elm
      'double', ...   %Width dependence of delta
      'double', ...   %Width dependence of rdsw 
      'double', ...   %Width dependence of prwg 
      'double', ...   %Width dependence of prwb 
      'double', ...   %Width dependence of prt
      'double', ...   %Width dependence of eta0
      'double', ...   %Width dependence of etab
      'double', ...   %Width dependence of pclm
      'double', ...   %Width dependence of pdiblc1
      'double', ...   %Width dependence of pdiblc2
      'double', ...   %Width dependence of pdiblcb
      'double', ...   %Width dependence of pscbe1
      'double', ...   %Width dependence of pscbe2
      'double', ...   %Width dependence of pvag
      'double', ...   %Width dependence of wr
      'double', ...   %Width dependence of dwg
      'double', ...   %Width dependence of dwb
      'double', ...   %Width dependence of b0
      'double', ...   %Width dependence of b1
      'double', ...   %Width dependence of cgsl
      'double', ...   %Width dependence of cgdl
      'double', ...   %Width dependence of ckappa
      'double', ...   %Width dependence of cf
      'double', ...   %Width dependence of clc
      'double', ...   %Width dependence of cle
      'double', ...   %Width dependence of alpha0
      'double', ...   %Width dependence of alpha1
      'double', ...   %Width dependence of beta0
      'double', ...   %Width dependence of vfbcv
      'double', ...   %Width dependence of vfb
      'double', ...   %Width dependence of acde
      'double', ...   %Width dependence of moin
      'double', ...   %Width dependence of noff
      'double', ...   %Width dependence of voffcv
      'double', ...   %Cross-term dependence of cdsc
      'double', ...   %Cross-term dependence of cdscb
      'double', ...   %Cross-term dependence of cdscd
      'double', ...   %Cross-term dependence of cit
      'double', ...   %Cross-term dependence of nfactor
      'double', ...   %Cross-term dependence of xj
      'double', ...   %Cross-term dependence of vsat
      'double', ...   %Cross-term dependence of at
      'double', ...   %Cross-term dependence of a0
      'double', ...   %Cross-term dependence of ags
      'double', ...   %Cross-term dependence of a1
      'double', ...   %Cross-term dependence of a2
      'double', ...   %Cross-term dependence of keta
      'double', ...   %Cross-term dependence of nsub
      'double', ...   %Cross-term dependence of nch
      'double', ...   %Cross-term dependence of ngate
      'double', ...   %Cross-term dependence of gamma1
      'double', ...   %Cross-term dependence of gamma2
      'double', ...   %Cross-term dependence of vbx
      'double', ...   %Cross-term dependence of vbm
      'double', ...   %Cross-term dependence of xt
      'double', ...   %Cross-term dependence of k1
      'double', ...   %Cross-term dependence of kt1
      'double', ...   %Cross-term dependence of kt1l
      'double', ...   %Cross-term dependence of kt2
      'double', ...   %Cross-term dependence of k2
      'double', ...   %Cross-term dependence of k3
      'double', ...   %Cross-term dependence of k3b
      'double', ...   %Cross-term dependence of w0
      'double', ...   %Cross-term dependence of nlx
      'double', ...   %Cross-term dependence of dvt0
      'double', ...   %Cross-term dependence of dvt1
      'double', ...   %Cross-term dependence of dvt2
      'double', ...   %Cross-term dependence of dvt0w
      'double', ...   %Cross-term dependence of dvt1w
      'double', ...   %Cross-term dependence of dvt2w
      'double', ...   %Cross-term dependence of drout
      'double', ...   %Cross-term dependence of dsub
      'double', ...   %Cross-term dependence of vto
      'double', ...   %Cross-term dependence of ua
      'double', ...   %Cross-term dependence of ua1
      'double', ...   %Cross-term dependence of ub
      'double', ...   %Cross-term dependence of ub1
      'double', ...   %Cross-term dependence of uc
      'double', ...   %Cross-term dependence of uc1
      'double', ...   %Cross-term dependence of u0
      'double', ...   %Cross-term dependence of ute
      'double', ...   %Cross-term dependence of voff
      'double', ...   %Cross-term dependence of elm
      'double', ...   %Cross-term dependence of delta
      'double', ...   %Cross-term dependence of rdsw 
      'double', ...   %Cross-term dependence of prwg 
      'double', ...   %Cross-term dependence of prwb 
      'double', ...   %Cross-term dependence of prt 
      'double', ...   %Cross-term dependence of eta0
      'double', ...   %Cross-term dependence of etab
      'double', ...   %Cross-term dependence of pclm
      'double', ...   %Cross-term dependence of pdiblc1
      'double', ...   %Cross-term dependence of pdiblc2
      'double', ...   %Cross-term dependence of pdiblcb
      'double', ...   %Cross-term dependence of pscbe1
      'double', ...   %Cross-term dependence of pscbe2
      'double', ...   %Cross-term dependence of pvag
      'double', ...   %Cross-term dependence of wr
      'double', ...   %Cross-term dependence of dwg
      'double', ...   %Cross-term dependence of dwb
      'double', ...   %Cross-term dependence of b0
      'double', ...   %Cross-term dependence of b1
      'double', ...   %Cross-term dependence of cgsl
      'double', ...   %Cross-term dependence of cgdl
      'double', ...   %Cross-term dependence of ckappa
      'double', ...   %Cross-term dependence of cf
      'double', ...   %Cross-term dependence of clc
      'double', ...   %Cross-term dependence of cle
      'double', ...   %Cross-term dependence of alpha0
      'double', ...   %Cross-term dependence of alpha1
      'double', ...   %Cross-term dependence of beta0
      'double', ...   %Cross-term dependence of vfbcv
      'double', ...   %Cross-term dependence of vfb
      'double', ...   %Cross-term dependence of acde
      'double', ...   %Cross-term dependence of moin
      'double', ...   %Cross-term dependence of noff
      'double', ...   %Cross-term dependence of voffcv
      'double', ...   %Flicker noise parameter
      'double', ...   %Flicker noise parameter
      'double', ...   %Flicker noise parameter
      'double', ...   %Flicker noise parameter
      'double', ...   %Flicker noise frequency exponent
      'double', ...   %Flicker noise exponent
      'double', ...   %Flicker noise coefficient
      'int', ...   % 1 for nmos, -1 for pmos
   };

   MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

   MOD.NIL.node_names = {'d', 'g', 's', 'b'};
   MOD.NIL.refnode_name = 'b';
      % IOs will be: vdb, vgb, vsb, idb, igb, isb
   MOD.explicit_output_names = {'idb', 'igb', 'isb'};
   MOD.internal_unk_names = {'vdi_b', 'vsi_b'};
   MOD.implicit_equation_names = {'di_KCL', 'si_KCL'};
   MOD.u_names = {};

   % MOD.limited_var_names = {'vdisilim', 'vgsilim'};
   % MOD.vecXY_to_limitedvars_matrix = ...
      % [0, 0, 0, 0, 1, -1;
   %  0, 1, 0, 0, 1, -1];  % vecLim = vecXY_to_limitedvars_matrix * [vecX;vecY]

   MOD.support_initlimiting = 1;
   MOD.limited_var_names = {};
   MOD.vecXY_to_limitedvars_matrix = [];

   % MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
   % MOD.NIL.io_nodenames are set up by this helper function
   MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
   MOD.fqei = @fqei_all;

% Newton-Raphson initialization support
   % MOD.initGuess = @initGuess;

% Newton-Raphson limiting support
    % MOD.limiting = @limiting;

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % BSIM3 MOD constructor

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% ANALYSIS-SPECIFIC INPUT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function vecLim = initGuess(u, MOD)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % set up scalar variables for the parms, vecX, vecY and u

   % create variables of the same names as the parameters and assign
   % them the values in MOD.parms
   % ideally, this should be a macro
   %    - could do this using a string and another eval()
   % this use of eval() is convenient but EXTREMELY SLOW, HENCE DEPRECATED
   %

   %{
   pnames = feval(MOD.parmnames,MOD);
   for i = 1:length(pnames)
      evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
      eval(evalstr);
   end
   %}

   mparms = feval(MOD.getparms, MOD);
   [ ...
      l, ...
      w, ...
      ad, ...
      as, ...
      pd, ...
      ps, ...
      nrd, ...
      nrs, ...
      nqsmod, ...
      capmod, ...
      mobmod, ...
      noimod, ...
      binunit, ...
      version, ...
      tox, ...
      toxm, ...
      cdsc, ...
      cdscb, ...
      cdscd, ...
      cit, ...
      nfactor, ...
      xj, ...
      vsat, ...
      at, ...
      a0, ...
      ags, ...
      a1, ...
      a2, ...
      keta, ...
      nsub, ...
      nch, ...
      ngate, ...
      gamma1, ...
      gamma2, ...
      vbx, ...
      vbm, ...
      xt, ...
      k1, ...
      kt1, ...
      kt1l, ...
      kt2, ...
      k2, ...
      k3, ...
      k3b, ...
      w0, ...
      nlx, ...
      dvt0, ...
      dvt1, ...
      dvt2, ...
      dvt0w, ...
      dvt1w, ...
      dvt2w, ...
      drout, ...
      dsub, ...
      vth0, ...
      ua, ...
      ua1, ...
      ub, ...
      ub1, ...
      uc, ...
      uc1, ...
      u0, ...
      ute, ...
      voff, ...
      tnom, ...
      cgso, ...
      cgdo, ...
      cgbo, ...
      xpart, ...
      elm, ...
      delta, ...
      rsh, ...
      rdsw, ...
      prwg, ...
      prwb, ...
      prt, ...
      eta0, ...
      etab, ...
      pclm, ...
      pdiblc1, ...
      pdiblc2, ...
      pdiblcb, ...
      pscbe1, ...
      pscbe2, ...
      pvag, ...
      js, ...
      jsw, ...
      pb, ...
      nj, ...
      xti, ...
      mj, ...
      pbsw, ...
      mjsw, ...
      pbswg, ...
      mjswg, ...
      cj, ...
      vfbcv, ...
      vfb, ...
      cjsw, ...
      cjswg, ...
      tpb, ...
      tcj, ...
      tpbsw, ...
      tcjsw, ...
      tpbswg, ...
      tcjswg, ...
      Acde, ...
      moin, ...
      noff, ...
      voffcv, ...
      lint, ...
      ll, ...
      llc, ...
      lln, ...
      lw, ...
      lwc, ...
      lwn, ...
      lwl, ...
      lwlc, ...
      lmin, ...
      lmax, ...
      wr, ...
      wint, ...
      dwg, ...
      dwb, ...
      wl, ...
      wlc, ...
      wln, ...
      ww, ...
      wwc, ...
      wwn, ...
      wwl, ...
      wwlc, ...
      wmin, ...
      wmax, ...
      b0, ...
      b1, ...
      cgsl, ...
      cgdl, ...
      ckappa, ...
      cf, ...
      Clc, ...
      cle, ...
      dwc, ...
      dlc, ...
      alpha0, ...
      alpha1, ...
      beta0, ...
      ijth, ...
      lcdsc, ...
      lcdscb, ...
      lcdscd, ...
      lcit, ...
      lnfactor, ...
      lxj, ...
      lvsat, ...
      lat, ...
      la0, ...
      lags, ...
      la1, ...
      la2, ...
      lketa, ...
      lnsub, ...
      lnch, ...
      lngate, ...
      lgamma1, ...
      lgamma2, ...
      lvbx, ...
      lvbm, ...
      lxt, ...
      lk1, ...
      lkt1, ...
      lkt1l, ...
      lkt2, ...
      lk2, ...
      lk3, ...
      lk3b, ...
      lw0, ...
      lnlx, ...
      ldvt0, ...
      ldvt1, ...
      ldvt2, ...
      ldvt0w, ...
      ldvt1w, ...
      ldvt2w, ...
      ldrout, ...
      ldsub, ...
      lvth0, ...
      lua, ...
      lua1, ...
      lub, ...
      lub1, ...
      luc, ...
      luc1, ...
      lu0, ...
      lute, ...
      lvoff, ...
      lelm, ...
      ldelta, ...
      lrdsw, ...
      lprwg, ...
      lprwb, ...
      lprt, ...
      leta0, ...
      letab, ...
      lpclm, ...
      lpdiblc1, ...
      lpdiblc2, ...
      lpdiblcb, ...
      lpscbe1, ...
      lpscbe2, ...
      lpvag, ...
      lwr, ...
      ldwg, ...
      ldwb, ...
      lb0, ...
      lb1, ...
      lcgsl, ...
      lcgdl, ...
      lckappa, ...
      lcf, ...
      lclc, ...
      lcle, ...
      lalpha0, ...
      lalpha1, ...
      lbeta0, ...
      lvfbcv, ...
      lvfb, ...
      lacde, ...
      lmoin, ...
      lnoff, ...
      lvoffcv, ...
      wcdsc, ...
      wcdscb, ...
      wcdscd, ...
      wcit, ...
      wnfactor, ...
      wxj, ...
      wvsat, ...
      wat, ...
      wa0, ...
      wags, ...
      wa1, ...
      wa2, ...
      wketa, ...
      wnsub, ...
      wnch, ...
      wngate, ...
      wgamma1, ...
      wgamma2, ...
      wvbx, ...
      wvbm, ...
      wxt, ...
      wk1, ...
      wkt1, ...
      wkt1l, ...
      wkt2, ...
      wk2, ...
      wk3, ...
      wk3b, ...
      ww0, ...
      wnlx, ...
      wdvt0, ...
      wdvt1, ...
      wdvt2, ...
      wdvt0w, ...
      wdvt1w, ...
      wdvt2w, ...
      wdrout, ...
      wdsub, ...
      wvth0, ...
      wua, ...
      wua1, ...
      wub, ...
      wub1, ...
      wuc, ...
      wuc1, ...
      wu0, ...
      wute, ...
      wvoff, ...
      welm, ...
      wdelta, ...
      wrdsw, ...
      wprwg, ...
      wprwb, ...
      wprt, ...
      weta0, ...
      wetab, ...
      wpclm, ...
      wpdiblc1, ...
      wpdiblc2, ...
      wpdiblcb, ...
      wpscbe1, ...
      wpscbe2, ...
      wpvag, ...
      wwr, ...
      wdwg, ...
      wdwb, ...
      wb0, ...
      wb1, ...
      wcgsl, ...
      wcgdl, ...
      wckappa, ...
      wcf, ...
      wclc, ...
      wcle, ...
      walpha0, ...
      walpha1, ...
      wbeta0, ...
      wvfbcv, ...
      wvfb, ...
      wacde, ...
      wmoin, ...
      wnoff, ...
      wvoffcv, ...
      pcdsc, ...
      pcdscb, ...
      pcdscd, ...
      pcit, ...
      pnfactor, ...
      pxj, ...
      pvsat, ...
      pat, ...
      pa0, ...
      pags, ...
      pa1, ...
      pa2, ...
      pketa, ...
      pnsub, ...
      pnch, ...
      pngate, ...
      pgamma1, ...
      pgamma2, ...
      pvbx, ...
      pvbm, ...
      pxt, ...
      pk1, ...
      pkt1, ...
      pkt1l, ...
      pkt2, ...
      pk2, ...
      pk3, ...
      pk3b, ...
      pw0, ...
      pnlx, ...
      pdvt0, ...
      pdvt1, ...
      pdvt2, ...
      pdvt0w, ...
      pdvt1w, ...
      pdvt2w, ...
      pdrout, ...
      pdsub, ...
      pvth0, ...
      pua, ...
      pua1, ...
      pub, ...
      pub1, ...
      puc, ...
      puc1, ...
      pu0, ...
      pute, ...
      pvoff, ...
      pelm, ...
      pdelta, ...
      prdsw, ...
      pprwg, ...
      pprwb, ...
      pprt, ...
      peta0, ...
      petab, ...
      ppclm, ...
      ppdiblc1, ...
      ppdiblc2, ...
      ppdiblcb, ...
      ppscbe1, ...
      ppscbe2, ...
      ppvag, ...
      pwr, ...
      pdwg, ...
      pdwb, ...
      pb0, ...
      pb1, ...
      pcgsl, ...
      pcgdl, ...
      pckappa, ...
      pcf, ...
      pclc, ...
      pcle, ...
      palpha0, ...
      palpha1, ...
      pbeta0, ...
      pvfbcv, ...
      pvfb, ...
      pacde, ...
      pmoin, ...
      pnoff, ...
      pvoffcv, ...
      noia, ...
      noib, ...
      noic, ...
      em, ...
      ef, ...
      af, ...
      kf, ...
      Type] = deal(mparms{:});

   % end setting up scalar variables for the parms, vecX, vecY and u
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   NOTGIVEN=-9999.9999;
   BSIM3type=Type;
   if (vth0 == NOTGIVEN) 
      BSIM3vth0Given=0;
      %BSIM3vth0 = (BSIM3type == 1) ? 0.7 : -0.7; % Default
      vth0 = 0.7*BSIM3type;
   else
      BSIM3vth0Given=1;
   end
   vecLim(1, 1) = 0;   % vdisi
   vecLim(2, 1) = vth0;   % vgsi
end % initGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function vecLim = limiting...
      (vecX,vecY,vecXold,vecYold, u, MOD)
   %OBSOLETE:
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % set up scalar variables for the parms, vecX, vecY and u

   % create variables of the same names as the parameters and assign
   % them the values in MOD.parms
   mparms = feval(MOD.getparms, MOD);
   [ ...
      l, ...
      w, ...
      ad, ...
      as, ...
      pd, ...
      ps, ...
      nrd, ...
      nrs, ...
      nqsmod, ...
      capmod, ...
      mobmod, ...
      noimod, ...
      binunit, ...
      version, ...
      tox, ...
      toxm, ...
      cdsc, ...
      cdscb, ...
      cdscd, ...
      cit, ...
      nfactor, ...
      xj, ...
      vsat, ...
      at, ...
      a0, ...
      ags, ...
      a1, ...
      a2, ...
      keta, ...
      nsub, ...
      nch, ...
      ngate, ...
      gamma1, ...
      gamma2, ...
      vbx, ...
      vbm, ...
      xt, ...
      k1, ...
      kt1, ...
      kt1l, ...
      kt2, ...
      k2, ...
      k3, ...
      k3b, ...
      w0, ...
      nlx, ...
      dvt0, ...
      dvt1, ...
      dvt2, ...
      dvt0w, ...
      dvt1w, ...
      dvt2w, ...
      drout, ...
      dsub, ...
      vth0, ...
      ua, ...
      ua1, ...
      ub, ...
      ub1, ...
      uc, ...
      uc1, ...
      u0, ...
      ute, ...
      voff, ...
      tnom, ...
      cgso, ...
      cgdo, ...
      cgbo, ...
      xpart, ...
      elm, ...
      delta, ...
      rsh, ...
      rdsw, ...
      prwg, ...
      prwb, ...
      prt, ...
      eta0, ...
      etab, ...
      pclm, ...
      pdiblc1, ...
      pdiblc2, ...
      pdiblcb, ...
      pscbe1, ...
      pscbe2, ...
      pvag, ...
      js, ...
      jsw, ...
      pb, ...
      nj, ...
      xti, ...
      mj, ...
      pbsw, ...
      mjsw, ...
      pbswg, ...
      mjswg, ...
      cj, ...
      vfbcv, ...
      vfb, ...
      cjsw, ...
      cjswg, ...
      tpb, ...
      tcj, ...
      tpbsw, ...
      tcjsw, ...
      tpbswg, ...
      tcjswg, ...
      Acde, ...
      moin, ...
      noff, ...
      voffcv, ...
      lint, ...
      ll, ...
      llc, ...
      lln, ...
      lw, ...
      lwc, ...
      lwn, ...
      lwl, ...
      lwlc, ...
      lmin, ...
      lmax, ...
      wr, ...
      wint, ...
      dwg, ...
      dwb, ...
      wl, ...
      wlc, ...
      wln, ...
      ww, ...
      wwc, ...
      wwn, ...
      wwl, ...
      wwlc, ...
      wmin, ...
      wmax, ...
      b0, ...
      b1, ...
      cgsl, ...
      cgdl, ...
      ckappa, ...
      cf, ...
      Clc, ...
      cle, ...
      dwc, ...
      dlc, ...
      alpha0, ...
      alpha1, ...
      beta0, ...
      ijth, ...
      lcdsc, ...
      lcdscb, ...
      lcdscd, ...
      lcit, ...
      lnfactor, ...
      lxj, ...
      lvsat, ...
      lat, ...
      la0, ...
      lags, ...
      la1, ...
      la2, ...
      lketa, ...
      lnsub, ...
      lnch, ...
      lngate, ...
      lgamma1, ...
      lgamma2, ...
      lvbx, ...
      lvbm, ...
      lxt, ...
      lk1, ...
      lkt1, ...
      lkt1l, ...
      lkt2, ...
      lk2, ...
      lk3, ...
      lk3b, ...
      lw0, ...
      lnlx, ...
      ldvt0, ...
      ldvt1, ...
      ldvt2, ...
      ldvt0w, ...
      ldvt1w, ...
      ldvt2w, ...
      ldrout, ...
      ldsub, ...
      lvth0, ...
      lua, ...
      lua1, ...
      lub, ...
      lub1, ...
      luc, ...
      luc1, ...
      lu0, ...
      lute, ...
      lvoff, ...
      lelm, ...
      ldelta, ...
      lrdsw, ...
      lprwg, ...
      lprwb, ...
      lprt, ...
      leta0, ...
      letab, ...
      lpclm, ...
      lpdiblc1, ...
      lpdiblc2, ...
      lpdiblcb, ...
      lpscbe1, ...
      lpscbe2, ...
      lpvag, ...
      lwr, ...
      ldwg, ...
      ldwb, ...
      lb0, ...
      lb1, ...
      lcgsl, ...
      lcgdl, ...
      lckappa, ...
      lcf, ...
      lclc, ...
      lcle, ...
      lalpha0, ...
      lalpha1, ...
      lbeta0, ...
      lvfbcv, ...
      lvfb, ...
      lacde, ...
      lmoin, ...
      lnoff, ...
      lvoffcv, ...
      wcdsc, ...
      wcdscb, ...
      wcdscd, ...
      wcit, ...
      wnfactor, ...
      wxj, ...
      wvsat, ...
      wat, ...
      wa0, ...
      wags, ...
      wa1, ...
      wa2, ...
      wketa, ...
      wnsub, ...
      wnch, ...
      wngate, ...
      wgamma1, ...
      wgamma2, ...
      wvbx, ...
      wvbm, ...
      wxt, ...
      wk1, ...
      wkt1, ...
      wkt1l, ...
      wkt2, ...
      wk2, ...
      wk3, ...
      wk3b, ...
      ww0, ...
      wnlx, ...
      wdvt0, ...
      wdvt1, ...
      wdvt2, ...
      wdvt0w, ...
      wdvt1w, ...
      wdvt2w, ...
      wdrout, ...
      wdsub, ...
      wvth0, ...
      wua, ...
      wua1, ...
      wub, ...
      wub1, ...
      wuc, ...
      wuc1, ...
      wu0, ...
      wute, ...
      wvoff, ...
      welm, ...
      wdelta, ...
      wrdsw, ...
      wprwg, ...
      wprwb, ...
      wprt, ...
      weta0, ...
      wetab, ...
      wpclm, ...
      wpdiblc1, ...
      wpdiblc2, ...
      wpdiblcb, ...
      wpscbe1, ...
      wpscbe2, ...
      wpvag, ...
      wwr, ...
      wdwg, ...
      wdwb, ...
      wb0, ...
      wb1, ...
      wcgsl, ...
      wcgdl, ...
      wckappa, ...
      wcf, ...
      wclc, ...
      wcle, ...
      walpha0, ...
      walpha1, ...
      wbeta0, ...
      wvfbcv, ...
      wvfb, ...
      wacde, ...
      wmoin, ...
      wnoff, ...
      wvoffcv, ...
      pcdsc, ...
      pcdscb, ...
      pcdscd, ...
      pcit, ...
      pnfactor, ...
      pxj, ...
      pvsat, ...
      pat, ...
      pa0, ...
      pags, ...
      pa1, ...
      pa2, ...
      pketa, ...
      pnsub, ...
      pnch, ...
      pngate, ...
      pgamma1, ...
      pgamma2, ...
      pvbx, ...
      pvbm, ...
      pxt, ...
      pk1, ...
      pkt1, ...
      pkt1l, ...
      pkt2, ...
      pk2, ...
      pk3, ...
      pk3b, ...
      pw0, ...
      pnlx, ...
      pdvt0, ...
      pdvt1, ...
      pdvt2, ...
      pdvt0w, ...
      pdvt1w, ...
      pdvt2w, ...
      pdrout, ...
      pdsub, ...
      pvth0, ...
      pua, ...
      pua1, ...
      pub, ...
      pub1, ...
      puc, ...
      puc1, ...
      pu0, ...
      pute, ...
      pvoff, ...
      pelm, ...
      pdelta, ...
      prdsw, ...
      pprwg, ...
      pprwb, ...
      pprt, ...
      peta0, ...
      petab, ...
      ppclm, ...
      ppdiblc1, ...
      ppdiblc2, ...
      ppdiblcb, ...
      ppscbe1, ...
      ppscbe2, ...
      ppvag, ...
      pwr, ...
      pdwg, ...
      pdwb, ...
      pb0, ...
      pb1, ...
      pcgsl, ...
      pcgdl, ...
      pckappa, ...
      pcf, ...
      pclc, ...
      pcle, ...
      palpha0, ...
      palpha1, ...
      pbeta0, ...
      pvfbcv, ...
      pvfb, ...
      pacde, ...
      pmoin, ...
      pnoff, ...
      pvoffcv, ...
      noia, ...
      noib, ...
      noic, ...
      em, ...
      ef, ...
      af, ...
      kf, ...
      Type] = deal(mparms{:});

   % similarly, get values from vecX, named exactly the same as otherIOnames
   % get otherIOs from vecX
   oios = feval(MOD.OtherIONames,MOD);
   for i = 1:length(oios)
      evalstr = sprintf('%s = vecX(i);', oios{i});
      eval(evalstr); % should be OK for vecvalder
   end
   % for this device, this should set up
   % vdb = vecX(1), vgb = vecX(2), vsb = vecX(3)

   % do the same for vecY from internalUnknowns
   % get internalUnknowns from vecY
   iunks = feval(MOD.InternalUnkNames,MOD);
   for i = 1:length(iunks)
      evalstr = sprintf('%s = vecY(i);', iunks{i});
      eval(evalstr); % should be OK for vecvalder
   end
   % for this device, this should set up
   % vdi_b = vecY(1), vsi_b = vecY(2)

   %{
   % do the same for u from uNames
   unms = uNames(MOD);
   for i = 1:length(unms)
      evalstr = sprintf('%s = u(i);', unms{i});
      eval(evalstr); % should be OK for vecvalder
   end
   % for this device, there are no us
   %}

   % end setting up scalar variables for the parms, vecX, vecY and u
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   vdb = vecX(1);
   vgb = vecX(2);
   vsb = vecX(3);
   vdbold = vecXold(1);
   vgbold = vecXold(2);
   vsbold = vecXold(3);
   % like spice3f5 code in mos6
   vgs = vgb - vsb;
   vgd = vgb - vdb;
   vbs = -vsb;
   vbd = -vdb;
   vdsold = vdbold - vsbold;
   vgsold = vgbold - vsbold;
   vgdold = vgbold - vdbold;
   vbsold = -vsbold;
   vbdold = -vdbold;
   %
   NOTGIVEN=-9999.9999;
   CONSTvt0=0.025864187;
   CONSTroot=sqrt(2.0);
   BSIM3type=Type;
   if (vth0 == NOTGIVEN) 
      BSIM3vth0Given=0;
      %BSIM3vth0 = (BSIM3type == 1) ? 0.7 : -0.7; % Default
      vth0 = 0.7*BSIM3type;
   else
      BSIM3vth0Given=1;
   end
   vcrit = CONSTvt0 * log10(CONSTvt0 / (CONSTroot * 1.0e-14));
   vt = CONSTvt0;
   %
   if vdsold >= 0
      vgs = fetlim(vgs, vgsold, vth0);
      vds = vgs - vgd;
      vds = limvds(vds, vdsold);
      vgd = vgs - vds;
   else
      vgd = fetlim(vgd, vgdold, vth0);
      vds = vgs - vgd;
      vds = -limvds(-vds, -vdsold);
      vgs = vgd + vds;
   end
   
   if vds >= 0
      vbs = pnjlim(vbsold, vbs, vt, vcrit);
      % TODO: no vt and vcrit for pnjlim
      vbd = vbs - vds;
   else
      vbd = pnjlim(vbdold, vbd, vt, vcrit);
      vbs = vbd + vds;
   end
   
   vecLim(1, 1) = vbs - vbd;   % vdisi
   vecLim(2, 1) = vgs;   % vgsi
end % limiting


%%%%%%%%%%%%%%%%% EQN and UNK SCALING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fe, qe, fi, qi] = fqei_all(vecX, vecY, vecLim, u, flag, MOD)
    if nargin < 6
		MOD = flag;
		flag = u;
		u = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end

   if ~isfield(flag,'fe')
      flag.fe =0;
   end
   if ~isfield(flag,'qe')
      flag.qe =0;
   end
   if ~isfield(flag,'fi')
      flag.fi =0;
   end
   if ~isfield(flag,'qi')
      flag.qi =0;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % set up scalar variables for the parms, vecX, vecY and u

   % create variables of the same names as the parameters and assign
   % them the values in MOD.parms
   % ideally, this should be a macro
   %    - could do this using a string and another eval()
   % the use of eval() is EXTREMELY SLOW; DEPRECATED
   %{
   pnames = feval(MOD.parmnames, MOD);
   for i = 1:length(pnames)
      evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
      eval(evalstr);
   end
   %}
   mparms = feval(MOD.getparms, MOD);
   [ ...
      l, ...
      w, ...
      ad, ...
      as, ...
      pd, ...
      ps, ...
      nrd, ...
      nrs, ...
      nqsmod, ...
      capmod, ...
      mobmod, ...
      noimod, ...
      binunit, ...
      version, ...
      tox, ...
      toxm, ...
      cdsc, ...
      cdscb, ...
      cdscd, ...
      cit, ...
      nfactor, ...
      xj, ...
      vsat, ...
      at, ...
      a0, ...
      ags, ...
      a1, ...
      a2, ...
      keta, ...
      nsub, ...
      nch, ...
      ngate, ...
      gamma1, ...
      gamma2, ...
      vbx, ...
      vbm, ...
      xt, ...
      k1, ...
      kt1, ...
      kt1l, ...
      kt2, ...
      k2, ...
      k3, ...
      k3b, ...
      w0, ...
      nlx, ...
      dvt0, ...
      dvt1, ...
      dvt2, ...
      dvt0w, ...
      dvt1w, ...
      dvt2w, ...
      drout, ...
      dsub, ...
      vth0, ...
      ua, ...
      ua1, ...
      ub, ...
      ub1, ...
      uc, ...
      uc1, ...
      u0, ...
      ute, ...
      voff, ...
      tnom, ...
      cgso, ...
      cgdo, ...
      cgbo, ...
      xpart, ...
      elm, ...
      delta, ...
      rsh, ...
      rdsw, ...
      prwg, ...
      prwb, ...
      prt, ...
      eta0, ...
      etab, ...
      pclm, ...
      pdiblc1, ...
      pdiblc2, ...
      pdiblcb, ...
      pscbe1, ...
      pscbe2, ...
      pvag, ...
      js, ...
      jsw, ...
      pb, ...
      nj, ...
      xti, ...
      mj, ...
      pbsw, ...
      mjsw, ...
      pbswg, ...
      mjswg, ...
      cj, ...
      vfbcv, ...
      vfb, ...
      cjsw, ...
      cjswg, ...
      tpb, ...
      tcj, ...
      tpbsw, ...
      tcjsw, ...
      tpbswg, ...
      tcjswg, ...
      Acde, ...
      moin, ...
      noff, ...
      voffcv, ...
      lint, ...
      ll, ...
      llc, ...
      lln, ...
      lw, ...
      lwc, ...
      lwn, ...
      lwl, ...
      lwlc, ...
      lmin, ...
      lmax, ...
      wr, ...
      wint, ...
      dwg, ...
      dwb, ...
      wl, ...
      wlc, ...
      wln, ...
      ww, ...
      wwc, ...
      wwn, ...
      wwl, ...
      wwlc, ...
      wmin, ...
      wmax, ...
      b0, ...
      b1, ...
      cgsl, ...
      cgdl, ...
      ckappa, ...
      cf, ...
      Clc, ...
      cle, ...
      dwc, ...
      dlc, ...
      alpha0, ...
      alpha1, ...
      beta0, ...
      ijth, ...
      lcdsc, ...
      lcdscb, ...
      lcdscd, ...
      lcit, ...
      lnfactor, ...
      lxj, ...
      lvsat, ...
      lat, ...
      la0, ...
      lags, ...
      la1, ...
      la2, ...
      lketa, ...
      lnsub, ...
      lnch, ...
      lngate, ...
      lgamma1, ...
      lgamma2, ...
      lvbx, ...
      lvbm, ...
      lxt, ...
      lk1, ...
      lkt1, ...
      lkt1l, ...
      lkt2, ...
      lk2, ...
      lk3, ...
      lk3b, ...
      lw0, ...
      lnlx, ...
      ldvt0, ...
      ldvt1, ...
      ldvt2, ...
      ldvt0w, ...
      ldvt1w, ...
      ldvt2w, ...
      ldrout, ...
      ldsub, ...
      lvth0, ...
      lua, ...
      lua1, ...
      lub, ...
      lub1, ...
      luc, ...
      luc1, ...
      lu0, ...
      lute, ...
      lvoff, ...
      lelm, ...
      ldelta, ...
      lrdsw, ...
      lprwg, ...
      lprwb, ...
      lprt, ...
      leta0, ...
      letab, ...
      lpclm, ...
      lpdiblc1, ...
      lpdiblc2, ...
      lpdiblcb, ...
      lpscbe1, ...
      lpscbe2, ...
      lpvag, ...
      lwr, ...
      ldwg, ...
      ldwb, ...
      lb0, ...
      lb1, ...
      lcgsl, ...
      lcgdl, ...
      lckappa, ...
      lcf, ...
      lclc, ...
      lcle, ...
      lalpha0, ...
      lalpha1, ...
      lbeta0, ...
      lvfbcv, ...
      lvfb, ...
      lacde, ...
      lmoin, ...
      lnoff, ...
      lvoffcv, ...
      wcdsc, ...
      wcdscb, ...
      wcdscd, ...
      wcit, ...
      wnfactor, ...
      wxj, ...
      wvsat, ...
      wat, ...
      wa0, ...
      wags, ...
      wa1, ...
      wa2, ...
      wketa, ...
      wnsub, ...
      wnch, ...
      wngate, ...
      wgamma1, ...
      wgamma2, ...
      wvbx, ...
      wvbm, ...
      wxt, ...
      wk1, ...
      wkt1, ...
      wkt1l, ...
      wkt2, ...
      wk2, ...
      wk3, ...
      wk3b, ...
      ww0, ...
      wnlx, ...
      wdvt0, ...
      wdvt1, ...
      wdvt2, ...
      wdvt0w, ...
      wdvt1w, ...
      wdvt2w, ...
      wdrout, ...
      wdsub, ...
      wvth0, ...
      wua, ...
      wua1, ...
      wub, ...
      wub1, ...
      wuc, ...
      wuc1, ...
      wu0, ...
      wute, ...
      wvoff, ...
      welm, ...
      wdelta, ...
      wrdsw, ...
      wprwg, ...
      wprwb, ...
      wprt, ...
      weta0, ...
      wetab, ...
      wpclm, ...
      wpdiblc1, ...
      wpdiblc2, ...
      wpdiblcb, ...
      wpscbe1, ...
      wpscbe2, ...
      wpvag, ...
      wwr, ...
      wdwg, ...
      wdwb, ...
      wb0, ...
      wb1, ...
      wcgsl, ...
      wcgdl, ...
      wckappa, ...
      wcf, ...
      wclc, ...
      wcle, ...
      walpha0, ...
      walpha1, ...
      wbeta0, ...
      wvfbcv, ...
      wvfb, ...
      wacde, ...
      wmoin, ...
      wnoff, ...
      wvoffcv, ...
      pcdsc, ...
      pcdscb, ...
      pcdscd, ...
      pcit, ...
      pnfactor, ...
      pxj, ...
      pvsat, ...
      pat, ...
      pa0, ...
      pags, ...
      pa1, ...
      pa2, ...
      pketa, ...
      pnsub, ...
      pnch, ...
      pngate, ...
      pgamma1, ...
      pgamma2, ...
      pvbx, ...
      pvbm, ...
      pxt, ...
      pk1, ...
      pkt1, ...
      pkt1l, ...
      pkt2, ...
      pk2, ...
      pk3, ...
      pk3b, ...
      pw0, ...
      pnlx, ...
      pdvt0, ...
      pdvt1, ...
      pdvt2, ...
      pdvt0w, ...
      pdvt1w, ...
      pdvt2w, ...
      pdrout, ...
      pdsub, ...
      pvth0, ...
      pua, ...
      pua1, ...
      pub, ...
      pub1, ...
      puc, ...
      puc1, ...
      pu0, ...
      pute, ...
      pvoff, ...
      pelm, ...
      pdelta, ...
      prdsw, ...
      pprwg, ...
      pprwb, ...
      pprt, ...
      peta0, ...
      petab, ...
      ppclm, ...
      ppdiblc1, ...
      ppdiblc2, ...
      ppdiblcb, ...
      ppscbe1, ...
      ppscbe2, ...
      ppvag, ...
      pwr, ...
      pdwg, ...
      pdwb, ...
      pb0, ...
      pb1, ...
      pcgsl, ...
      pcgdl, ...
      pckappa, ...
      pcf, ...
      pclc, ...
      pcle, ...
      palpha0, ...
      palpha1, ...
      pbeta0, ...
      pvfbcv, ...
      pvfb, ...
      pacde, ...
      pmoin, ...
      pnoff, ...
      pvoffcv, ...
      noia, ...
      noib, ...
      noic, ...
      em, ...
      ef, ...
      af, ...
      kf, ...
      Type] = deal(mparms{:});

   % flags
        BSIM3k1Given=0;
        BSIM3k2Given=0;
        BSIM3nsubGiven=0;
        BSIM3xtGiven=0;
        BSIM3vbxGiven=0;
        BSIM3gamma1Given=0;
        BSIM3gamma2Given=0;
        BSIM3vfbGiven=0;
        BSIM3vth0Given=0;
        BSIM3dlcGiven=0;

   BSIM3nqsMod = 0;


   % similarly, get values from vecX, named exactly the same as otherIOnames
   % get otherIOs from vecX
   oios = feval(MOD.OtherIONames, MOD);
   for i = 1:length(oios)
      evalstr = sprintf('%s = vecX(i);', oios{i});
      eval(evalstr); % should be OK for vecvalder
   end
   % for this device, this should set up vpn

   % do the same for vecY from internalUnknowns
   % get internalUnknowns from vecY
   iunks = feval(MOD.InternalUnkNames, MOD);
   for i = 1:length(iunks)
      evalstr = sprintf('%s = vecY(i);', iunks{i});
      eval(evalstr); % should be OK for vecvalder
   end
   % for this device, this should set up vin

   %{
   % do the same for u from uNames
   unms = uNames(MOD);
   for i = 1:length(unms)
      evalstr = sprintf('%s = u(i);', unms{i});
      eval(evalstr); % should be OK for vecvalder
   end
   % for this device, there are no us
   %}

   % end setting up scalar variables for the parms, vecX, vecY and u
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % BSIM3 was written originally using node voltages, not branch voltages
   % re-using that code, so defining node voltages
   vb = 0; % internal reference, arbitrary value
   vg = vgb + vb;
   vdp = vdi_b + vb;
   vsp = vsi_b + vb;
   vs = vsb + vb;
   vd = vdb + vb;

   %% constants
   % the following constants are from b3set.c
   MAX_EXP=5.834617425e+14;
   MIN_EXP=1.713908431e-15;
   EPSOX=3.453133e-11;
   EPSSI=1.03594e-10;
   PI=3.141592654;
   
   % the following constants are from b3temp.c
   KboQ=8.617087e-5;  % Kb / q  where q = 1.60219e-19 
   EXP_THRESHOLD=34.0;
   Charge_q=1.60219e-19;
   
   % the following constants are from b3ld.c
   DELTA_1=0.02;
   DELTA_3=0.02;
   DELTA_4=0.02;
   
   CONSTroot=sqrt(2.0);
   NOTGIVEN=-9999.9999;
   CKTgmin=1e-12;
   CKTtemp=(27+273.15); %% HACK: should read the temperature
   CONSTvt0=0.025864187;

   % Setup parameter: refer to b3set.c
   BSIM3drainArea = ad;
   BSIM3sourceArea = as;
   BSIM3drainSquares = nrd;
   BSIM3sourceSquares = nrs;
   BSIM3drainPerimeter = pd;
   BSIM3sourcePerimeter = ps;
   
   % The follow paragraph are generated by python scripts 
   % refer to: b3set.c b3mpar.c
   BSIM3mobMod = mobmod;
   BSIM3binUnit = binunit;
   BSIM3capMod = capmod;
   BSIM3noiMod = noimod;
   BSIM3version = version;
   BSIM3tox = tox;
   %toxm=tox;
   BSIM3toxm = toxm;
   BSIM3cdsc = cdsc;
   BSIM3cdscb = cdscb;
   BSIM3cdscd = cdscd;
   BSIM3cit = cit;
   BSIM3nfactor = nfactor;
   BSIM3xj = xj;
   BSIM3vsat = vsat;
   BSIM3a0 = a0;
   BSIM3ags = ags;
   BSIM3a1 = a1;
   BSIM3a2 = a2;
   BSIM3at = at;
   BSIM3keta = keta;
   BSIM3nsub = nsub;
   BSIM3npeak = nch;
   BSIM3ngate = ngate;
   BSIM3gamma1 = gamma1;
   BSIM3gamma2 = gamma2;
   BSIM3vbx = vbx;
   BSIM3vbm = vbm;
   BSIM3xt = xt;
   BSIM3k1 = k1;
   BSIM3kt1 = kt1;
   BSIM3kt1l = kt1l;
   BSIM3kt2 = kt2;
   BSIM3k2 = k2;
   BSIM3k3 = k3;
   BSIM3k3b = k3b;
   BSIM3nlx = nlx;
   BSIM3w0 = w0;
   BSIM3dvt0 = dvt0;
   BSIM3dvt1 = dvt1;
   BSIM3dvt2 = dvt2;
   BSIM3dvt0w = dvt0w;
   BSIM3dvt1w = dvt1w;
   BSIM3dvt2w = dvt2w;
   BSIM3drout = drout;
   BSIM3dsub = dsub;
   BSIM3vth0 = vth0;   %change from vtho to vth0
   BSIM3ua = ua;
   BSIM3ua1 = ua1;
   BSIM3ub = ub;
   BSIM3ub1 = ub1;
   BSIM3uc = uc;
   BSIM3uc1 = uc1;
   BSIM3u0 = u0;
   BSIM3ute = ute;
   BSIM3voff = voff;
   BSIM3delta = delta;
   BSIM3rdsw = rdsw;
   BSIM3prwg = prwg;
   BSIM3prwb = prwb;
   BSIM3prt = prt;
   BSIM3eta0 = eta0;
   BSIM3etab = etab;
   BSIM3pclm = pclm;
   BSIM3pdibl1 = pdiblc1;
   BSIM3pdibl2 = pdiblc2;
   BSIM3pdiblb = pdiblcb;
   BSIM3pscbe1 = pscbe1;
   BSIM3pscbe2 = pscbe2;
   BSIM3pvag = pvag;
   BSIM3wr = wr;
   BSIM3dwg = dwg;
   BSIM3dwb = dwb;
   BSIM3b0 = b0;
   BSIM3b1 = b1;
   BSIM3alpha0 = alpha0;
   BSIM3alpha1 = alpha1;
   BSIM3beta0 = beta0;
   BSIM3ijth = ijth;
   BSIM3vfb = vfb;
   BSIM3elm = elm;
   BSIM3cgsl = cgsl;
   BSIM3cgdl = cgdl;
   BSIM3ckappa = ckappa;
   BSIM3cf = cf;
   BSIM3clc = Clc;
   BSIM3cle = cle;
   BSIM3dwc = dwc;
   BSIM3dlc = dlc;
   BSIM3vfbcv = vfbcv;
   BSIM3acde = Acde;
   BSIM3moin = moin;
   BSIM3noff = noff;
   BSIM3voffcv = voffcv;
   BSIM3tcj = tcj;
   BSIM3tpb = tpb;
   BSIM3tcjsw = tcjsw;
   BSIM3tpbsw = tpbsw;
   BSIM3tcjswg = tcjswg;
   BSIM3tpbswg = tpbswg;
   BSIM3lcdsc = lcdsc;
   BSIM3lcdscb = lcdscb;
   BSIM3lcdscd = lcdscd;
   BSIM3lcit = lcit;
   BSIM3lnfactor = lnfactor;
   BSIM3lxj = lxj;
   BSIM3lvsat = lvsat;
   BSIM3la0 = la0;
   BSIM3lags = lags;
   BSIM3la1 = la1;
   BSIM3la2 = la2;
   BSIM3lat = lat;
   BSIM3lketa = lketa;
   BSIM3lnsub = lnsub;
   BSIM3lnpeak = lnch;
   BSIM3lngate = lngate;
   BSIM3lgamma1 = lgamma1;
   BSIM3lgamma2 = lgamma2;
   BSIM3lvbx = lvbx;
   BSIM3lvbm = lvbm;
   BSIM3lxt = lxt;
   BSIM3lk1 = lk1;
   BSIM3lkt1 = lkt1;
   BSIM3lkt1l = lkt1l;
   BSIM3lkt2 = lkt2;
   BSIM3lk2 = lk2;
   BSIM3lk3 = lk3;
   BSIM3lk3b = lk3b;
   BSIM3lnlx = lnlx;
   BSIM3lw0 = lw0;
   BSIM3ldvt0 = ldvt0;
   BSIM3ldvt1 = ldvt1;
   BSIM3ldvt2 = ldvt2;
   BSIM3ldvt0w = ldvt0w;
   BSIM3ldvt1w = ldvt1w;
   BSIM3ldvt2w = ldvt2w;
   BSIM3ldrout = ldrout;
   BSIM3ldsub = ldsub;
   BSIM3lvth0 = lvth0;   %change from lvtho to lvth0
   BSIM3lua = lua;
   BSIM3lua1 = lua1;
   BSIM3lub = lub;
   BSIM3lub1 = lub1;
   BSIM3luc = luc;
   BSIM3luc1 = luc1;
   BSIM3lu0 = lu0;
   BSIM3lute = lute;
   BSIM3lvoff = lvoff;
   BSIM3ldelta = ldelta;
   BSIM3lrdsw = lrdsw;
   BSIM3lprwb = lprwb;
   BSIM3lprwg = lprwg;
   BSIM3lprt = lprt;
   BSIM3leta0 = leta0;
   BSIM3letab = letab;
   BSIM3lpclm = lpclm;
   BSIM3lpdibl1 = lpdiblc1;
   BSIM3lpdibl2 = lpdiblc2;
   BSIM3lpdiblb = lpdiblcb;
   BSIM3lpscbe1 = lpscbe1;
   BSIM3lpscbe2 = lpscbe2;
   BSIM3lpvag = lpvag;
   BSIM3lwr = lwr;
   BSIM3ldwg = ldwg;
   BSIM3ldwb = ldwb;
   BSIM3lb0 = lb0;
   BSIM3lb1 = lb1;
   BSIM3lalpha0 = lalpha0;
   BSIM3lalpha1 = lalpha1;
   BSIM3lbeta0 = lbeta0;
   BSIM3lvfb = lvfb;
   BSIM3lelm = lelm;
   BSIM3lcgsl = lcgsl;
   BSIM3lcgdl = lcgdl;
   BSIM3lckappa = lckappa;
   BSIM3lcf = lcf;
   BSIM3lclc = lclc;
   BSIM3lcle = lcle;
   BSIM3lvfbcv = lvfbcv;
   BSIM3lacde = lacde;
   BSIM3lmoin = lmoin;
   BSIM3lnoff = lnoff;
   BSIM3lvoffcv = lvoffcv;
   BSIM3wcdsc = wcdsc;
   BSIM3wcdscb = wcdscb;
   BSIM3wcdscd = wcdscd;
   BSIM3wcit = wcit;
   BSIM3wnfactor = wnfactor;
   BSIM3wxj = wxj;
   BSIM3wvsat = wvsat;
   BSIM3wa0 = wa0;
   BSIM3wags = wags;
   BSIM3wa1 = wa1;
   BSIM3wa2 = wa2;
   BSIM3wat = wat;
   BSIM3wketa = wketa;
   BSIM3wnsub = wnsub;
   BSIM3wnpeak = wnch;
   BSIM3wngate = wngate;
   BSIM3wgamma1 = wgamma1;
   BSIM3wgamma2 = wgamma2;
   BSIM3wvbx = wvbx;
   BSIM3wvbm = wvbm;
   BSIM3wxt = wxt;
   BSIM3wk1 = wk1;
   BSIM3wkt1 = wkt1;
   BSIM3wkt1l = wkt1l;
   BSIM3wkt2 = wkt2;
   BSIM3wk2 = wk2;
   BSIM3wk3 = wk3;
   BSIM3wk3b = wk3b;
   BSIM3wnlx = wnlx;
   BSIM3ww0 = ww0;
   BSIM3wdvt0 = wdvt0;
   BSIM3wdvt1 = wdvt1;
   BSIM3wdvt2 = wdvt2;
   BSIM3wdvt0w = wdvt0w;
   BSIM3wdvt1w = wdvt1w;
   BSIM3wdvt2w = wdvt2w;
   BSIM3wdrout = wdrout;
   BSIM3wdsub = wdsub;
   BSIM3wvth0 = wvth0;   %change from wvtho to wvth0
   BSIM3wua = wua;
   BSIM3wua1 = wua1;
   BSIM3wub = wub;
   BSIM3wub1 = wub1;
   BSIM3wuc = wuc;
   BSIM3wuc1 = wuc1;
   BSIM3wu0 = wu0;
   BSIM3wute = wute;
   BSIM3wvoff = wvoff;
   BSIM3wdelta = wdelta;
   BSIM3wrdsw = wrdsw;
   BSIM3wprwb = wprwb;
   BSIM3wprwg = wprwg;
   BSIM3wprt = wprt;
   BSIM3weta0 = weta0;
   BSIM3wetab = wetab;
   BSIM3wpclm = wpclm;
   BSIM3wpdibl1 = wpdiblc1;
   BSIM3wpdibl2 = wpdiblc2;
   BSIM3wpdiblb = wpdiblcb;
   BSIM3wpscbe1 = wpscbe1;
   BSIM3wpscbe2 = wpscbe2;
   BSIM3wpvag = wpvag;
   BSIM3wwr = wwr;
   BSIM3wdwg = wdwg;
   BSIM3wdwb = wdwb;
   BSIM3wb0 = wb0;
   BSIM3wb1 = wb1;
   BSIM3walpha0 = walpha0;
   BSIM3walpha1 = walpha1;
   BSIM3wbeta0 = wbeta0;
   BSIM3wvfb = wvfb;
   BSIM3welm = welm;
   BSIM3wcgsl = wcgsl;
   BSIM3wcgdl = wcgdl;
   BSIM3wckappa = wckappa;
   BSIM3wcf = wcf;
   BSIM3wclc = wclc;
   BSIM3wcle = wcle;
   BSIM3wvfbcv = wvfbcv;
   BSIM3wacde = wacde;
   BSIM3wmoin = wmoin;
   BSIM3wnoff = wnoff;
   BSIM3wvoffcv = wvoffcv;
   BSIM3pcdsc = pcdsc;
   BSIM3pcdscb = pcdscb;
   BSIM3pcdscd = pcdscd;
   BSIM3pcit = pcit;
   BSIM3pnfactor = pnfactor;
   BSIM3pxj = pxj;
   BSIM3pvsat = pvsat;
   BSIM3pa0 = pa0;
   BSIM3pags = pags;
   BSIM3pa1 = pa1;
   BSIM3pa2 = pa2;
   BSIM3pat = pat;
   BSIM3pketa = pketa;
   BSIM3pnsub = pnsub;
   BSIM3pnpeak = pnch;
   BSIM3pngate = pngate;
   BSIM3pgamma1 = pgamma1;
   BSIM3pgamma2 = pgamma2;
   BSIM3pvbx = pvbx;
   BSIM3pvbm = pvbm;
   BSIM3pxt = pxt;
   BSIM3pk1 = pk1;
   BSIM3pkt1 = pkt1;
   BSIM3pkt1l = pkt1l;
   BSIM3pkt2 = pkt2;
   BSIM3pk2 = pk2;
   BSIM3pk3 = pk3;
   BSIM3pk3b = pk3b;
   BSIM3pnlx = pnlx;
   BSIM3pw0 = pw0;
   BSIM3pdvt0 = pdvt0;
   BSIM3pdvt1 = pdvt1;
   BSIM3pdvt2 = pdvt2;
   BSIM3pdvt0w = pdvt0w;
   BSIM3pdvt1w = pdvt1w;
   BSIM3pdvt2w = pdvt2w;
   BSIM3pdrout = pdrout;
   BSIM3pdsub = pdsub;
   BSIM3pvth0 = pvth0;   %change from pvtho->pvth0
   BSIM3pua = pua;
   BSIM3pua1 = pua1;
   BSIM3pub = pub;
   BSIM3pub1 = pub1;
   BSIM3puc = puc;
   BSIM3puc1 = puc1;
   BSIM3pu0 = pu0;
   BSIM3pute = pute;
   BSIM3pvoff = pvoff;
   BSIM3pdelta = pdelta;
   BSIM3prdsw = prdsw;
   BSIM3pprwb = pprwb;
   BSIM3pprwg = pprwg;
   BSIM3pprt = pprt;
   BSIM3peta0 = peta0;
   BSIM3petab = petab;
   BSIM3ppclm = ppclm;
   BSIM3ppdibl1 = ppdiblc1;
   BSIM3ppdibl2 = ppdiblc2;
   BSIM3ppdiblb = ppdiblcb;
   BSIM3ppscbe1 = ppscbe1;
   BSIM3ppscbe2 = ppscbe2;
   BSIM3ppvag = ppvag;
   BSIM3pwr = pwr;
   BSIM3pdwg = pdwg;
   BSIM3pdwb = pdwb;
   BSIM3pb0 = pb0;
   BSIM3pb1 = pb1;
   BSIM3palpha0 = palpha0;
   BSIM3palpha1 = palpha1;
   BSIM3pbeta0 = pbeta0;
   BSIM3pvfb = pvfb;
   BSIM3pelm = pelm;
   BSIM3pcgsl = pcgsl;
   BSIM3pcgdl = pcgdl;
   BSIM3pckappa = pckappa;
   BSIM3pcf = pcf;
   BSIM3pclc = pclc;
   BSIM3pcle = pcle;
   BSIM3pvfbcv = pvfbcv;
   BSIM3pacde = pacde;
   BSIM3pmoin = pmoin;
   BSIM3pnoff = pnoff;
   BSIM3pvoffcv = pvoffcv;
   %BSIM3tnom = tnom;
   BSIM3tnom=tnom+273.15;
   BSIM3cgso = cgso;
   BSIM3cgdo = cgdo;
   BSIM3cgbo = cgbo;
   BSIM3xpart = xpart;
   BSIM3sheetResistance = rsh;
   BSIM3jctSatCurDensity = js;
   BSIM3jctSidewallSatCurDensity = jsw;
   BSIM3bulkJctPotential = pb;
   BSIM3bulkJctBotGradingCoeff = mj;
   BSIM3sidewallJctPotential = pbsw;
   BSIM3bulkJctSideGradingCoeff = mjsw;
   BSIM3unitAreaJctCap = cj;
   BSIM3unitLengthSidewallJctCap = cjsw;
   BSIM3jctEmissionCoeff = nj;
   BSIM3GatesidewallJctPotential = pbswg;
   BSIM3bulkJctGateSideGradingCoeff = mjswg;
   BSIM3unitLengthGateSidewallJctCap = cjswg;
   BSIM3jctTempExponent = xti;
   BSIM3Lint = lint;
   BSIM3Ll = ll;
   BSIM3Llc = llc;
   BSIM3Lln = lln;
   BSIM3Lw = lw;
   BSIM3Lwc = lwc;
   BSIM3Lwn = lwn;
   BSIM3Lwl = lwl;
   BSIM3Lwlc = lwlc;
   BSIM3Lmin = lmin;
   BSIM3Lmax = lmax;
   BSIM3Wint = wint;
   BSIM3Wl = wl;
   BSIM3Wlc = wlc;
   BSIM3Wln = wln;
   BSIM3Ww = ww;
   BSIM3Wwc = wwc;
   BSIM3Wwn = wwn;
   BSIM3Wwl = wwl;
   BSIM3Wwlc = wwlc;
   BSIM3Wmin = wmin;
   BSIM3Wmax = wmax;
   BSIM3oxideTrapDensityA = noia;
   BSIM3oxideTrapDensityB = noib;
   BSIM3oxideTrapDensityC = noic;
   BSIM3em = em;
   BSIM3ef = ef;
   BSIM3af = af;
   BSIM3kf = kf;

   BSIM3l=l;
   BSIM3w=w;

   %The following paragraph is adopted from b3set.c
   BSIM3type=Type;

   if (vth0 == NOTGIVEN) 
      BSIM3vth0Given=0;
      %BSIM3vth0 = (BSIM3type == 1) ? 0.7 : -0.7; % Default
      BSIM3vth0 = 0.7*BSIM3type;
   else
      BSIM3vth0Given=1;
   end
   
   if (k1==NOTGIVEN) 
      BSIM3k1Given=0;
      BSIM3k1=0.53;%from b3temp.c
   else
      BSIM3k1Given=1;
   end

   if (k2==NOTGIVEN) 
      BSIM3k2Given=0;
      BSIM3k2=-0.0186;%from b3temp.c
   else
      BSIM3k2Given=1;
   end

   if (ijth  == NOTGIVEN)
      BSIM3ijth = 0.1;
   end
   
   if (uc == NOTGIVEN)
      %BSIM3uc = (BSIM3mobMod == 3) ? -0.0465 : -0.0465e-9; % from b3set.c
      if BSIM3mobMod == 3 
         BSIM3uc = -0.0465;
      else
          BSIM3uc = -0.0465e-9; 
      end
   end
  
   if (uc1 == NOTGIVEN)
      %BSIM3uc1 = (BSIM3mobMod == 3) ? -0.056 : -0.056e-9; % from b3set.c
      if BSIM3mobMod == 3 
         BSIM3uc1 = -0.056;
      else
          BSIM3uc1 = -0.056e-9; 
      end
   end
   
   if (u0 == NOTGIVEN) 
      %BSIM3u0 = (BSIM3type == 1 ) ? 0.067 : 0.025; % from b3set.c
      if BSIM3type == 1 
         BSIM3u0 = 0.067;
      else
          BSIM3u0 = 0.025; 
      end
   end

   if (cf==NOTGIVEN)
      BSIM3cf = 2.0 * EPSOX / PI * log10(1.0 + 0.4e-6 / BSIM3tox);
   end
      
   if (BSIM3dlc == NOTGIVEN) 
      BSIM3dlcGiven=0;
      BSIM3dlc = BSIM3Lint;
   else
      BSIM3dlcGiven=1;
   end

   BSIM3cox= 3.453133e-11 / BSIM3tox;
   Cox = BSIM3cox;

   if (cgdo == NOTGIVEN) 
      if (BSIM3dlc > 0.0)
         BSIM3cgdo = BSIM3dlc * BSIM3cox - BSIM3cgdl;
      else
         BSIM3cgdo = 0.6 * BSIM3xj * BSIM3cox;
      end
   end
      
   
   if (BSIM3cgso == NOTGIVEN) 
      if (BSIM3dlc > 0.0)
         BSIM3cgso = BSIM3dlc * BSIM3cox - BSIM3cgsl;
      else
         BSIM3cgso = 0.6 * BSIM3xj * BSIM3cox;
      end
   end
   
   if (BSIM3cgbo == NOTGIVEN)
      BSIM3cgbo = 2.0 * BSIM3dwc * BSIM3cox;
   end

   %TODO/FIXME: add model parameter check (from b3check.c)
   %
   %
   %///////////////////////////////////////////////////////
   %
   % The following section is adopted from b3temp.c
   %
   %///////////////////////////////////////////////////////
   Tnom = BSIM3tnom;
   Temp = Tnom;
   TRatio = Temp / Tnom;
    
   BSIM3vcrit = CONSTvt0 * log10(CONSTvt0 / (CONSTroot * 1.0e-14));
   BSIM3factor1 = sqrt(EPSSI / EPSOX * BSIM3tox);

   Vtm0 = KboQ * Tnom;
   Eg0 = 1.16 - 7.02e-4 * Tnom * Tnom / (Tnom + 1108.0);
   ni = 1.45e10 * (Tnom / 300.15) * sqrt(Tnom / 300.15) * exp(21.5565981 - Eg0 / (2.0 * Vtm0));

   BSIM3vtm = KboQ * Temp;
   Eg = 1.16 - 7.02e-4 * Temp * Temp / (Temp + 1108.0);
   if (Temp ~= Tnom)
      T0 = Eg0/Vtm0 -Eg/BSIM3vtm + BSIM3jctTempExponent* log10(Temp / Tnom);
      T1 = exp(T0 / BSIM3jctEmissionCoeff);
      BSIM3jctTempSatCurDensity = BSIM3jctSatCurDensity * T1;
      BSIM3jctSidewallTempSatCurDensity = BSIM3jctSidewallSatCurDensity * T1;
   else
      BSIM3jctTempSatCurDensity = BSIM3jctSatCurDensity;
      BSIM3jctSidewallTempSatCurDensity=BSIM3jctSidewallSatCurDensity;
   end

   if (BSIM3jctTempSatCurDensity < 0.0)
      BSIM3jctTempSatCurDensity = 0.0;
   end
   if (BSIM3jctSidewallTempSatCurDensity < 0.0)
      BSIM3jctSidewallTempSatCurDensity = 0.0;
   end

    %{/ Temperature dependence of D/B and S/B diode capacitance begins %}
   delTemp = CKTtemp - BSIM3tnom;
   T0 = BSIM3tcj * delTemp;
   if (T0 >= -1.0)
       BSIM3unitAreaTempJctCap = BSIM3unitAreaJctCap * (1.0 + T0);
   elseif (BSIM3unitAreaJctCap > 0.0)
       BSIM3unitAreaTempJctCap = 0.0;
       %fprintf(2, 'Temperature effect has caused cj to be negative. Cj is clamped to zero.\n');
       fprintf(2,'BSIM3: Temperature effect has caused cj to be negative. Cj is clamped to zero.\n');
   end
    
   T0 = BSIM3tcjsw * delTemp;
   if (T0 >= -1.0)
      BSIM3unitLengthSidewallTempJctCap = BSIM3unitLengthSidewallJctCap * (1.0 + T0);
   elseif (BSIM3unitLengthSidewallJctCap > 0.0)
      BSIM3unitLengthSidewallTempJctCap = 0.0;
      %fprintf(2, 'Temperature effect has caused cjsw to be negative. Cjsw is clamped to zero.\n');
      fprintf(2,'BSIM3: Temperature effect has caused cjsw to be negative. Cjsw is clamped to zero.\n');
   end
   
   T0 = BSIM3tcjswg * delTemp;
   if (T0 >= -1.0)
      BSIM3unitLengthGateSidewallTempJctCap=BSIM3unitLengthGateSidewallJctCap*(1.0+T0);
   elseif (BSIM3unitLengthGateSidewallJctCap > 0.0)
      BSIM3unitLengthGateSidewallTempJctCap = 0.0;
      %fprintf(2, 'Temperature effect has caused cjswg to be negative. Cjswg is clamped to zero.\n');
      fprintf(2,'BSIM3: Temperature effect has caused cjswg to be negative. Cjswg is clamped to zero.\n');
   end

   BSIM3PhiB = BSIM3bulkJctPotential - BSIM3tpb * delTemp;
   if (BSIM3PhiB < 0.01)
      BSIM3PhiB = 0.01;
      %fprintf(2, 'Temperature effect has caused pb to be less than 0.01. Pb is clamped to 0.01.\n');
      fprintf(2,'Temperature effect has caused pb to be less than 0.01. Pb is clamped to 0.01.\n');
   end
   
   BSIM3PhiBSW = BSIM3sidewallJctPotential - BSIM3tpbsw * delTemp;
   if (BSIM3PhiBSW <= 0.01)
      BSIM3PhiBSW = 0.01;
      %fprintf(2, 'Temperature effect has caused pbsw to be less than 0.01. Pbsw is clamped to 0.01.\n');
      fprintf(2,'Temperature effect has caused pbsw to be less than 0.01. Pbsw is clamped to 0.01.\n');
   end

   BSIM3PhiBSWG = BSIM3GatesidewallJctPotential- BSIM3tpbswg * delTemp;
   if (BSIM3PhiBSWG <= 0.01)
      BSIM3PhiBSWG = 0.01;
      %fprintf(2, 'Temperature effect has caused pbswg to be less than 0.01. Pbswg is clamped to 0.01.\n');
      fprintf(2,'Temperature effect has caused pbswg to be less than 0.01. Pbswg is clamped to 0.01.\n');
   end
   %{/ End of junction capacitance %}
   
   Ldrn = l;
   Wdrn = w;
   Length = Ldrn;
   Width = Wdrn;
        
   T0 = pow(Ldrn, BSIM3Lln);
   T1 = pow(Wdrn, BSIM3Lwn);
   tmp1=BSIM3Ll/T0+BSIM3Lw/T1+BSIM3Lwl/(T0*T1);
   BSIM3dl = BSIM3Lint + tmp1;
   tmp2 = BSIM3Llc / T0 + BSIM3Lwc / T1+ BSIM3Lwlc / (T0 * T1);
   BSIM3dlc = BSIM3dlc + tmp2;
   T2 = pow(Ldrn, BSIM3Wln);
   T3 = pow(Wdrn, BSIM3Wwn);
   tmp1 = BSIM3Wl / T2 + BSIM3Ww / T3 + BSIM3Wwl / (T2 * T3);
   BSIM3dw = BSIM3Wint + tmp1;
   tmp2 = BSIM3Wlc / T2 + BSIM3Wwc / T3+ BSIM3Wwlc / (T2 * T3);
   BSIM3dwc = BSIM3dwc + tmp2;

   BSIM3leff = BSIM3l - 2.0 *BSIM3dl;

   if (BSIM3leff <= 0.0)
      %fprintf(2, 'BSIM3: Effective channel length <= 0\n');
      fprintf(2,'BSIM3: ERROR: Effective channel length <= 0'\n');
      %$finish(-1);
      return;
   end

   BSIM3weff = BSIM3w - 2.0 * BSIM3dw;
   if (BSIM3weff <= 0.0)
      %fprintf(2, 'BSIM3: Effective channel width <= 0\n');
      fprintf(2,'BSIM3: ERROR: Effective channel width <= 0\n');
      %$finish(-1);
      return;
   end

   BSIM3leffCV = BSIM3l - 2.0 * BSIM3dlc;
   if (BSIM3leffCV <= 0.0)
      %fprintf(2, 'BSIM3: Effective channel length for C-V <= 0\n');
      fprintf(2,'BSIM3: ERROR: Effective channel length for C-V <= 0\n');
      %$finish(-1);
      return;
   end

   BSIM3weffCV = BSIM3w - 2.0 * BSIM3dwc;
   if (BSIM3weffCV <= 0.0)
      %fprintf(2, 'BSIM3: Effective channel width for C-V <= 0\n');
      fprintf(2,'BSIM3: ERROR: Effective channel width for C-V <= 0\n');
      %$finish(-1);
      return;
   end

   if (BSIM3binUnit == 1)
      Inv_L = 1.0e-6 / BSIM3leff;
      Inv_W = 1.0e-6 / BSIM3weff;
      Inv_LW = 1.0e-12 / (BSIM3leff * BSIM3weff);
   else
      Inv_L = 1.0 / BSIM3leff;
      Inv_W = 1.0 / BSIM3weff;
      Inv_LW = 1.0 / (BSIM3leff*BSIM3weff);
   end

   BSIM3cdsc = BSIM3cdsc + BSIM3lcdsc * Inv_L + BSIM3wcdsc * Inv_W + BSIM3pcdsc * Inv_LW;
   BSIM3cdscb = BSIM3cdscb + BSIM3lcdscb * Inv_L + BSIM3wcdscb * Inv_W + BSIM3pcdscb * Inv_LW; 
          
   BSIM3cdscd = BSIM3cdscd + BSIM3lcdscd * Inv_L + BSIM3wcdscd * Inv_W + BSIM3pcdscd * Inv_LW; 
          
   BSIM3cit = BSIM3cit + BSIM3lcit * Inv_L + BSIM3wcit * Inv_W + BSIM3pcit * Inv_LW;
   BSIM3nfactor = BSIM3nfactor + BSIM3lnfactor * Inv_L + BSIM3wnfactor * Inv_W + BSIM3pnfactor * Inv_LW;
   BSIM3xj = BSIM3xj + BSIM3lxj * Inv_L + BSIM3wxj * Inv_W + BSIM3pxj * Inv_LW;
   BSIM3vsat = BSIM3vsat + BSIM3lvsat * Inv_L + BSIM3wvsat * Inv_W + BSIM3pvsat * Inv_LW;
   BSIM3at = BSIM3at + BSIM3lat * Inv_L + BSIM3wat * Inv_W + BSIM3pat * Inv_LW;
   BSIM3a0 = BSIM3a0 + BSIM3la0 * Inv_L + BSIM3wa0 * Inv_W + BSIM3pa0 * Inv_LW; 
        
   BSIM3ags = BSIM3ags + BSIM3lags * Inv_L + BSIM3wags * Inv_W + BSIM3pags * Inv_LW; 
   BSIM3a1 = BSIM3a1 + BSIM3la1 * Inv_L + BSIM3wa1 * Inv_W + BSIM3pa1 * Inv_LW;
   BSIM3a2 = BSIM3a2 + BSIM3la2 * Inv_L + BSIM3wa2 * Inv_W + BSIM3pa2 * Inv_LW;
   BSIM3keta = BSIM3keta + BSIM3lketa * Inv_L + BSIM3wketa * Inv_W + BSIM3pketa * Inv_LW;
   BSIM3nsub = BSIM3nsub + BSIM3lnsub * Inv_L + BSIM3wnsub * Inv_W + BSIM3pnsub * Inv_LW;
   BSIM3npeak = BSIM3npeak + BSIM3lnpeak * Inv_L + BSIM3wnpeak * Inv_W + BSIM3pnpeak * Inv_LW;
   BSIM3ngate = BSIM3ngate + BSIM3lngate * Inv_L + BSIM3wngate * Inv_W + BSIM3pngate * Inv_LW;
   BSIM3gamma1 = BSIM3gamma1 + BSIM3lgamma1 * Inv_L + BSIM3wgamma1 * Inv_W + BSIM3pgamma1 * Inv_LW;
   BSIM3gamma2 = BSIM3gamma2 + BSIM3lgamma2 * Inv_L + BSIM3wgamma2 * Inv_W + BSIM3pgamma2 * Inv_LW;
   BSIM3vbx = BSIM3vbx + BSIM3lvbx * Inv_L + BSIM3wvbx * Inv_W + BSIM3pvbx * Inv_LW;
   BSIM3vbm = BSIM3vbm + BSIM3lvbm * Inv_L + BSIM3wvbm * Inv_W + BSIM3pvbm * Inv_LW;
   BSIM3xt = BSIM3xt + BSIM3lxt * Inv_L + BSIM3wxt * Inv_W + BSIM3pxt * Inv_LW;
   BSIM3vfb = BSIM3vfb + BSIM3lvfb * Inv_L + BSIM3wvfb * Inv_W + BSIM3pvfb * Inv_LW;
   BSIM3k1 = BSIM3k1 + BSIM3lk1 * Inv_L + BSIM3wk1 * Inv_W + BSIM3pk1 * Inv_LW;
   BSIM3kt1 = BSIM3kt1 + BSIM3lkt1 * Inv_L + BSIM3wkt1 * Inv_W + BSIM3pkt1 * Inv_LW;
   BSIM3kt1l = BSIM3kt1l + BSIM3lkt1l * Inv_L + BSIM3wkt1l * Inv_W + BSIM3pkt1l * Inv_LW;
   BSIM3k2 = BSIM3k2 + BSIM3lk2 * Inv_L + BSIM3wk2 * Inv_W + BSIM3pk2 * Inv_LW;
   BSIM3kt2 = BSIM3kt2 + BSIM3lkt2 * Inv_L + BSIM3wkt2 * Inv_W + BSIM3pkt2 * Inv_LW;
   BSIM3k3 = BSIM3k3 + BSIM3lk3 * Inv_L + BSIM3wk3 * Inv_W + BSIM3pk3 * Inv_LW;
   BSIM3k3b = BSIM3k3b + BSIM3lk3b * Inv_L + BSIM3wk3b * Inv_W + BSIM3pk3b * Inv_LW;
   BSIM3w0 = BSIM3w0 + BSIM3lw0 * Inv_L + BSIM3ww0 * Inv_W + BSIM3pw0 * Inv_LW;
   BSIM3nlx = BSIM3nlx + BSIM3lnlx * Inv_L + BSIM3wnlx * Inv_W + BSIM3pnlx * Inv_LW;
   BSIM3dvt0 = BSIM3dvt0 + BSIM3ldvt0 * Inv_L + BSIM3wdvt0 * Inv_W + BSIM3pdvt0 * Inv_LW;
   BSIM3dvt1 = BSIM3dvt1 + BSIM3ldvt1 * Inv_L + BSIM3wdvt1 * Inv_W + BSIM3pdvt1 * Inv_LW;
   BSIM3dvt2 = BSIM3dvt2 + BSIM3ldvt2 * Inv_L + BSIM3wdvt2 * Inv_W + BSIM3pdvt2 * Inv_LW;
   BSIM3dvt0w = BSIM3dvt0w + BSIM3ldvt0w * Inv_L + BSIM3wdvt0w * Inv_W + BSIM3pdvt0w * Inv_LW;
   BSIM3dvt1w = BSIM3dvt1w + BSIM3ldvt1w * Inv_L + BSIM3wdvt1w * Inv_W + BSIM3pdvt1w * Inv_LW;
   BSIM3dvt2w = BSIM3dvt2w + BSIM3ldvt2w * Inv_L + BSIM3wdvt2w * Inv_W + BSIM3pdvt2w * Inv_LW;
   BSIM3drout = BSIM3drout + BSIM3ldrout * Inv_L + BSIM3wdrout * Inv_W + BSIM3pdrout * Inv_LW;
   BSIM3dsub = BSIM3dsub + BSIM3ldsub * Inv_L + BSIM3wdsub * Inv_W + BSIM3pdsub * Inv_LW;
   BSIM3vth0 = BSIM3vth0 + BSIM3lvth0 * Inv_L + BSIM3wvth0 * Inv_W + BSIM3pvth0 * Inv_LW;
   BSIM3ua = BSIM3ua + BSIM3lua * Inv_L + BSIM3wua * Inv_W + BSIM3pua * Inv_LW;
   BSIM3ua1 = BSIM3ua1 + BSIM3lua1 * Inv_L + BSIM3wua1 * Inv_W + BSIM3pua1 * Inv_LW;
   BSIM3ub = BSIM3ub + BSIM3lub * Inv_L + BSIM3wub * Inv_W + BSIM3pub * Inv_LW;
   BSIM3ub1 = BSIM3ub1 + BSIM3lub1 * Inv_L + BSIM3wub1 * Inv_W + BSIM3pub1 * Inv_LW;
   BSIM3uc = BSIM3uc + BSIM3luc * Inv_L + BSIM3wuc * Inv_W + BSIM3puc * Inv_LW;
   BSIM3uc1 = BSIM3uc1 + BSIM3luc1 * Inv_L + BSIM3wuc1 * Inv_W + BSIM3puc1 * Inv_LW;
   BSIM3u0 = BSIM3u0 + BSIM3lu0 * Inv_L + BSIM3wu0 * Inv_W + BSIM3pu0 * Inv_LW;
   BSIM3ute = BSIM3ute + BSIM3lute * Inv_L + BSIM3wute * Inv_W + BSIM3pute * Inv_LW;
   BSIM3voff = BSIM3voff + BSIM3lvoff * Inv_L + BSIM3wvoff * Inv_W + BSIM3pvoff * Inv_LW;
   BSIM3delta = BSIM3delta + BSIM3ldelta * Inv_L + BSIM3wdelta * Inv_W + BSIM3pdelta * Inv_LW;
   BSIM3rdsw = BSIM3rdsw + BSIM3lrdsw * Inv_L + BSIM3wrdsw * Inv_W + BSIM3prdsw * Inv_LW;
   BSIM3prwg = BSIM3prwg + BSIM3lprwg * Inv_L + BSIM3wprwg * Inv_W + BSIM3pprwg * Inv_LW;
   BSIM3prwb = BSIM3prwb + BSIM3lprwb * Inv_L + BSIM3wprwb * Inv_W + BSIM3pprwb * Inv_LW;
   BSIM3prt = BSIM3prt + BSIM3lprt * Inv_L + BSIM3wprt * Inv_W + BSIM3pprt * Inv_LW;
   BSIM3eta0 = BSIM3eta0 + BSIM3leta0 * Inv_L + BSIM3weta0 * Inv_W + BSIM3peta0 * Inv_LW;
   BSIM3etab = BSIM3etab + BSIM3letab * Inv_L + BSIM3wetab * Inv_W + BSIM3petab * Inv_LW;
   BSIM3pclm = BSIM3pclm + BSIM3lpclm * Inv_L + BSIM3wpclm * Inv_W + BSIM3ppclm * Inv_LW;
   BSIM3pdibl1 = BSIM3pdibl1 + BSIM3lpdibl1 * Inv_L + BSIM3wpdibl1 * Inv_W + BSIM3ppdibl1 * Inv_LW;
   BSIM3pdibl2 = BSIM3pdibl2 + BSIM3lpdibl2 * Inv_L + BSIM3wpdibl2 * Inv_W + BSIM3ppdibl2 * Inv_LW;
   BSIM3pdiblb = BSIM3pdiblb + BSIM3lpdiblb * Inv_L + BSIM3wpdiblb * Inv_W + BSIM3ppdiblb * Inv_LW;
   BSIM3pscbe1 = BSIM3pscbe1 + BSIM3lpscbe1 * Inv_L + BSIM3wpscbe1 * Inv_W + BSIM3ppscbe1 * Inv_LW;
   BSIM3pscbe2 = BSIM3pscbe2 + BSIM3lpscbe2 * Inv_L + BSIM3wpscbe2 * Inv_W + BSIM3ppscbe2 * Inv_LW;
   BSIM3pvag = BSIM3pvag + BSIM3lpvag * Inv_L + BSIM3wpvag * Inv_W + BSIM3ppvag * Inv_LW;
   BSIM3wr = BSIM3wr + BSIM3lwr * Inv_L + BSIM3wwr * Inv_W + BSIM3pwr * Inv_LW;
   BSIM3dwg = BSIM3dwg + BSIM3ldwg * Inv_L + BSIM3wdwg * Inv_W + BSIM3pdwg * Inv_LW;
   BSIM3dwb = BSIM3dwb + BSIM3ldwb * Inv_L + BSIM3wdwb * Inv_W + BSIM3pdwb * Inv_LW;
   BSIM3b0 = BSIM3b0 + BSIM3lb0 * Inv_L + BSIM3wb0 * Inv_W + BSIM3pb0 * Inv_LW;
   BSIM3b1 = BSIM3b1 + BSIM3lb1 * Inv_L + BSIM3wb1 * Inv_W + BSIM3pb1 * Inv_LW;
   BSIM3alpha0 = BSIM3alpha0 + BSIM3lalpha0 * Inv_L + BSIM3walpha0 * Inv_W + BSIM3palpha0 * Inv_LW;
   BSIM3alpha1 = BSIM3alpha1 + BSIM3lalpha1 * Inv_L + BSIM3walpha1 * Inv_W + BSIM3palpha1 * Inv_LW;
   BSIM3beta0 = BSIM3beta0 + BSIM3lbeta0 * Inv_L + BSIM3wbeta0 * Inv_W + BSIM3pbeta0 * Inv_LW;
   %{/ CV model %}
   BSIM3elm = BSIM3elm + BSIM3lelm * Inv_L + BSIM3welm * Inv_W + BSIM3pelm * Inv_LW;
   BSIM3cgsl = BSIM3cgsl + BSIM3lcgsl * Inv_L + BSIM3wcgsl * Inv_W + BSIM3pcgsl * Inv_LW;
   BSIM3cgdl = BSIM3cgdl + BSIM3lcgdl * Inv_L + BSIM3wcgdl * Inv_W + BSIM3pcgdl * Inv_LW;
   BSIM3ckappa = BSIM3ckappa + BSIM3lckappa * Inv_L + BSIM3wckappa * Inv_W + BSIM3pckappa * Inv_LW;
   BSIM3cf = BSIM3cf + BSIM3lcf * Inv_L + BSIM3wcf * Inv_W + BSIM3pcf * Inv_LW;
   BSIM3clc = BSIM3clc + BSIM3lclc * Inv_L + BSIM3wclc * Inv_W + BSIM3pclc * Inv_LW;
   BSIM3cle = BSIM3cle + BSIM3lcle * Inv_L + BSIM3wcle * Inv_W + BSIM3pcle * Inv_LW;
   BSIM3vfbcv = BSIM3vfbcv + BSIM3lvfbcv * Inv_L + BSIM3wvfbcv * Inv_W + BSIM3pvfbcv * Inv_LW;
   BSIM3acde = BSIM3acde + BSIM3lacde * Inv_L + BSIM3wacde * Inv_W + BSIM3pacde * Inv_LW;
   BSIM3moin = BSIM3moin + BSIM3lmoin * Inv_L + BSIM3wmoin * Inv_W + BSIM3pmoin * Inv_LW;
   BSIM3noff = BSIM3noff + BSIM3lnoff * Inv_L + BSIM3wnoff * Inv_W + BSIM3pnoff * Inv_LW;
   BSIM3voffcv = BSIM3voffcv + BSIM3lvoffcv * Inv_L + BSIM3wvoffcv * Inv_W + BSIM3pvoffcv * Inv_LW;

   BSIM3abulkCVfactor = 1.0 + pow((BSIM3clc / BSIM3leffCV), BSIM3cle);

   T0 = (TRatio - 1.0);
   BSIM3ua = BSIM3ua + BSIM3ua1 * T0;
   BSIM3ub = BSIM3ub + BSIM3ub1 * T0;
   BSIM3uc = BSIM3uc + BSIM3uc1 * T0;
   
   if (BSIM3u0 > 1.0) 
      BSIM3u0 = BSIM3u0 / 1.0e4;
   end
   BSIM3u0temp = BSIM3u0* pow(TRatio, BSIM3ute); 

   BSIM3vsattemp = BSIM3vsat - BSIM3at * T0;
   BSIM3rds0 = (BSIM3rdsw + BSIM3prt * T0)/ pow(BSIM3weff * 1E6, BSIM3wr);

   %TODO/FIXME: check parameters
   %{
   if (BSIM3checkModel(model, here, ckt))
   {   IFuid namarray[2];
      namarray[0] = model->BSIM3modName;
      namarray[1] = here->BSIM3name;
      (*(SPfrontEnd->IFerror)) (ERR_FATAL, "Fatal error(s) detected during BSIM3V3.2 parameter checking for %s in model %s", namarray);
      return(E_BADPARM);   
      }
   %}
   BSIM3cgdo = (BSIM3cgdo + BSIM3cf) * BSIM3weffCV;
   BSIM3cgso = (BSIM3cgso + BSIM3cf) * BSIM3weffCV;
   BSIM3cgbo = BSIM3cgbo * BSIM3leffCV;
   T0 = BSIM3leffCV * BSIM3leffCV;
   BSIM3tconst = BSIM3u0temp * BSIM3elm / (BSIM3cox* BSIM3weffCV * BSIM3leffCV * T0);
   if (BSIM3npeak==NOTGIVEN && BSIM3gamma1~=NOTGIVEN)
      T0 = BSIM3gamma1 * BSIM3cox;
      BSIM3npeak = 3.021E22 * T0 * T0;
   end

   BSIM3phi = 2.0 * Vtm0 * log10(BSIM3npeak / ni);
   BSIM3sqrtPhi = sqrt(BSIM3phi);
   BSIM3phis3 = BSIM3sqrtPhi * BSIM3phi;
   BSIM3Xdep0 = sqrt(2.0 * EPSSI / (Charge_q * BSIM3npeak * 1.0e6))* BSIM3sqrtPhi; 
   BSIM3sqrtXdep0 = sqrt(BSIM3Xdep0);
   BSIM3litl = sqrt(3.0 * BSIM3xj * BSIM3tox);
   BSIM3vbi = Vtm0 * log10(1.0e20 * BSIM3npeak / (ni * ni));
   BSIM3cdep0 = sqrt(Charge_q * EPSSI * BSIM3npeak * 1.0e6 / 2.0/ BSIM3phi);
   BSIM3ldeb = sqrt(EPSSI * Vtm0 / (Charge_q* BSIM3npeak * 1.0e6)) / 3.0;
   BSIM3acde = BSIM3acde*pow((BSIM3npeak / 2.0e16), -0.25);

   if (BSIM3k1Given || BSIM3k2Given) 
      if (~BSIM3k1Given)
         fprintf(2,'Warning: k1 should be specified with k2.\n');
         BSIM3k1 = 0.53;
      end
      if (~BSIM3k2Given)
         fprintf(2,'Warning: k2 should be specified with k1.\n');
         BSIM3k2 = -0.0186;
      end
      if (BSIM3nsubGiven)
         fprintf(2, 'Warning: nsub is ignored because k1 or k2 is given.\n');
      end
      if (BSIM3xtGiven)
         fprintf(2, 'Warning: xt is ignored because k1 or k2 is given.\n');
      end
      if (BSIM3vbxGiven)
         fprintf(2, 'Warning: vbx is ignored because k1 or k2 is given.\n');
      end
      if (BSIM3gamma1Given)
         fprintf(2, 'Warning: gamma1 is ignored because k1 or k2 is given.\n');
      end
      if (BSIM3gamma2Given)
         fprintf(2, 'Warning: gamma2 is ignored because k1 or k2 is given.\n');
      end
   else
      if (~BSIM3vbxGiven)
         BSIM3vbx = BSIM3phi - 7.7348e-4 * BSIM3npeak * BSIM3xt * BSIM3xt;
      end
      if (BSIM3vbx > 0.0)
         BSIM3vbx = -BSIM3vbx;
      end
      if (BSIM3vbm > 0.0)
         BSIM3vbm = -BSIM3vbm;
      end
      if (BSIM3gamma1==NOTGIVEN)
         BSIM3gamma1 = 5.753e-12* sqrt(BSIM3npeak) / BSIM3cox;
      end
      if (BSIM3gamma2==NOTGIVEN)
         BSIM3gamma2 = 5.753e-12 * sqrt(BSIM3nsub)/ BSIM3cox;
      end
      T0 = BSIM3gamma1 - BSIM3gamma2;
      T1 = sqrt(BSIM3phi - BSIM3vbx) - BSIM3sqrtPhi;
      T2 = sqrt(BSIM3phi * (BSIM3phi - BSIM3vbm)) - BSIM3phi;
      BSIM3k2 = T0 * T1 / (2.0 * T2 + BSIM3vbm);
      BSIM3k1 = BSIM3gamma2 - 2.0* BSIM3k2 * sqrt(BSIM3phi- BSIM3vbm);
   end
   
   if (BSIM3k2 < 0.0)
      T0 = 0.5 * BSIM3k1 / BSIM3k2;
      BSIM3vbsc = 0.9 * (BSIM3phi - T0 * T0);
      if (BSIM3vbsc > -3.0)
         BSIM3vbsc = -3.0;
      elseif (BSIM3vbsc < -30.0)
         BSIM3vbsc = -30.0;
      end
   else
      BSIM3vbsc = -30.0;
   end
   
   if (BSIM3vbsc > BSIM3vbm)
      BSIM3vbsc = BSIM3vbm;
   end
   if (~BSIM3vfbGiven)
      if (BSIM3vth0Given)
         BSIM3vfb = BSIM3type * BSIM3vth0 - BSIM3phi - BSIM3k1* BSIM3sqrtPhi;
      else
         BSIM3vfb = -1.0;
      end
   end

   if (~BSIM3vth0Given)
      BSIM3vth0 = BSIM3type * (BSIM3vfb+ BSIM3phi + BSIM3k1* BSIM3sqrtPhi);
   end
   
   BSIM3k1ox = BSIM3k1 * BSIM3tox/ BSIM3toxm;
   BSIM3k2ox = BSIM3k2 * BSIM3tox/ BSIM3toxm;
   T1 = sqrt(EPSSI / EPSOX * BSIM3tox * BSIM3Xdep0);

   T0 = exp(-0.5 * BSIM3dsub * BSIM3leff / T1);
   BSIM3theta0vb0 = (T0 + 2.0 * T0 * T0);

   T0 = exp(-0.5 * BSIM3drout * BSIM3leff / T1);
   T2 = (T0 + 2.0 * T0 * T0);
   BSIM3thetaRout = BSIM3pdibl1 * T2 + BSIM3pdibl2;

   tmp = sqrt(BSIM3Xdep0);
   tmp1 = BSIM3vbi - BSIM3phi;
   tmp2 = BSIM3factor1 * tmp;

   T0 = -0.5 * BSIM3dvt1w * BSIM3weff * BSIM3leff / tmp2;
   if (T0 > -EXP_THRESHOLD)
      T1 = exp(T0);
      T2 = T1 * (1.0 + 2.0 * T1);
   else
      T1 = MIN_EXP;
      T2 = T1 * (1.0 + 2.0 * T1);
   end
   T0 = BSIM3dvt0w * T2;
   T2 = T0 * tmp1;

   T0 = -0.5 * BSIM3dvt1 * BSIM3leff / tmp2;
   if (T0 > -EXP_THRESHOLD)
      T1 = exp(T0);
      T3 = T1 * (1.0 + 2.0 * T1);
   else
      T1 = MIN_EXP;
      T3 = T1 * (1.0 + 2.0 * T1);
   end
   T3 = BSIM3dvt0 * T3 * tmp1;

   T4 = BSIM3tox * BSIM3phi/ (BSIM3weff + BSIM3w0);

   T0 = sqrt(1.0 + BSIM3nlx / BSIM3leff);
   T5 = BSIM3k1ox * (T0 - 1.0) * BSIM3sqrtPhi + (BSIM3kt1 + BSIM3kt1l / BSIM3leff) * (TRatio - 1.0);

   tmp3 = BSIM3type * BSIM3vth0 - T2 - T3 + BSIM3k3 * T4 + T5;
   BSIM3vfbzb = tmp3 - BSIM3phi - BSIM3k1 * BSIM3sqrtPhi;
   %{/ End of vfbzb %}
   
   %{/ process source/drain series resistance %}
   BSIM3drainConductance = BSIM3sheetResistance * BSIM3drainSquares;
   if (BSIM3drainConductance > 0.0)
      BSIM3drainConductance = 1.0 / BSIM3drainConductance;
   else
      BSIM3drainConductance = 0.0;
   end

   BSIM3sourceConductance = BSIM3sheetResistance * BSIM3sourceSquares;
   if (BSIM3sourceConductance > 0.0) 
      BSIM3sourceConductance = 1.0 / BSIM3sourceConductance;
   else
      BSIM3sourceConductance = 0.0;
   end
   %BSIM3cgso = BSIM3cgso;
   %BSIM3cgdo = BSIM3cgdo;

   Nvtm = BSIM3vtm * BSIM3jctEmissionCoeff;
   if ((BSIM3sourceArea <= 0.0) && (BSIM3sourcePerimeter <= 0.0))
      SourceSatCurrent = 1.0e-14;
   else
      SourceSatCurrent = BSIM3sourceArea* BSIM3jctTempSatCurDensity + BSIM3sourcePerimeter* BSIM3jctSidewallTempSatCurDensity;
   end
   if ((SourceSatCurrent > 0.0) && (BSIM3ijth > 0.0))
      BSIM3vjsm = Nvtm * log10(BSIM3ijth/ SourceSatCurrent + 1.0);
      BSIM3IsEvjsm = SourceSatCurrent * exp(BSIM3vjsm/ Nvtm);
   end
   if ((BSIM3drainArea <= 0.0) && (BSIM3drainPerimeter <= 0.0))
      DrainSatCurrent = 1.0e-14;
   else
      DrainSatCurrent = BSIM3drainArea * BSIM3jctTempSatCurDensity + BSIM3drainPerimeter* BSIM3jctSidewallTempSatCurDensity;
   end
           
   if ((DrainSatCurrent > 0.0) && (BSIM3ijth > 0.0))
      BSIM3vjdm = Nvtm * log10(BSIM3ijth/ DrainSatCurrent + 1.0);
      BSIM3IsEvjdm = DrainSatCurrent * exp(BSIM3vjdm/ Nvtm);
   end

   %//////////////////////////////////////////////////
   %
   % BSIM3 DC calculation begins (section 2)
   %
   %/////////////////////////////////////////////////
   
   %{/ determine DC current and derivatives %}
   %vds=BSIM3type*V(vdp,vsp);
   vds = BSIM3type*(vdp-vsp);
   %vbs=BSIM3type*V(vb, vsp);
   vbs=BSIM3type*(vb-vsp);
   %vgs=BSIM3type*V(vg, vsp);
   vgs=BSIM3type*(vg-vsp);

   vbd = vbs - vds;
   vgd = vgs - vds;
   vgb = vgs - vbs;

   %{/ Source/drain junction diode DC model begins %}
   Nvtm = BSIM3vtm * BSIM3jctEmissionCoeff;
   if ((BSIM3sourceArea <= 0.0) && (BSIM3sourcePerimeter <= 0.0))
      SourceSatCurrent = 1.0e-14;
   else
      SourceSatCurrent = BSIM3sourceArea*BSIM3jctTempSatCurDensity +BSIM3sourcePerimeter*BSIM3jctSidewallTempSatCurDensity;
   end

   if (SourceSatCurrent <= 0.0) 
      BSIM3cbs =CKTgmin * vbs;
   else 
      if (BSIM3ijth == 0.0) 
         evbs = exp(vbs / Nvtm);
         BSIM3cbs = SourceSatCurrent * (evbs - 1.0) + CKTgmin * vbs; 
      else 
         if (vbs < BSIM3vjsm) 
            evbs = exp(vbs / Nvtm);
            BSIM3cbs = SourceSatCurrent * (evbs - 1.0) + CKTgmin * vbs;
         else 
            T0 = BSIM3IsEvjsm / Nvtm;
            BSIM3cbs=BSIM3IsEvjsm-SourceSatCurrent+T0*(vbs-BSIM3vjsm)+CKTgmin*vbs;
         end
      end
   end

   if ((BSIM3drainArea <= 0.0) && (BSIM3drainPerimeter <= 0.0))
      DrainSatCurrent = 1.0e-14;
   else 
      DrainSatCurrent = BSIM3drainArea * BSIM3jctTempSatCurDensity + BSIM3drainPerimeter * BSIM3jctSidewallTempSatCurDensity;
   end

   if (DrainSatCurrent <= 0.0) 
      BSIM3gbd = CKTgmin;
      BSIM3cbd = BSIM3gbd * vbd;
   else 
      if (BSIM3ijth == 0.0) 
         evbd = exp(vbd / Nvtm);
         BSIM3cbd = DrainSatCurrent * (evbd - 1.0) + CKTgmin * vbd;
      else 
         if (vbd < BSIM3vjdm) 
            evbd = exp(vbd / Nvtm);
            BSIM3cbd = DrainSatCurrent * (evbd - 1.0) + CKTgmin * vbd;
         else 
            T0 = BSIM3IsEvjdm / Nvtm;
            BSIM3cbd = BSIM3IsEvjdm - DrainSatCurrent + T0 * (vbd - BSIM3vjdm) + CKTgmin * vbd;
         end
      end
   end 

   %{/ End of diode DC model %}

   if (vds >= 0.0)
      %{/ normal mode %}
      BSIM3mode = 1;
      Vds = vds;
      Vgs = vgs;
      Vbs = vbs;
   else
      %{/ inverse mode %}
      BSIM3mode = -1;
      Vds = -vds;
      Vgs = vgd;
      Vbs = vbd;
   end

   T0 = Vbs - BSIM3vbsc - 0.001;
   T1 = sqrt(T0 * T0 - 0.004 * BSIM3vbsc);
   Vbseff = BSIM3vbsc + 0.5 * (T0 + T1);
   if (Vbseff < Vbs)
      Vbseff = Vbs;
   end
   
   if (Vbseff > 0.0)
      T0 = BSIM3phi / (BSIM3phi + Vbseff);
      Phis = BSIM3phi * T0;
      sqrtPhis = BSIM3phis3 / (BSIM3phi + 0.5 * Vbseff);
   else
      Phis = BSIM3phi - Vbseff;
      sqrtPhis = sqrt(Phis);
   end

   Xdep = BSIM3Xdep0 * sqrtPhis / BSIM3sqrtPhi;

   Leff = BSIM3leff;
   Vtm = BSIM3vtm;

   %{/ Vth Calculation %}
   T3 = sqrt(Xdep);
   V0 = BSIM3vbi - BSIM3phi;

   T0 = BSIM3dvt2 * Vbseff;
   if (T0 >= - 0.5)
      T1 = 1.0 + T0;
      T2 = BSIM3dvt2;
   else %{/ Added to avoid any discontinuity problems caused by dvt2 %} 
      T4 = 1.0 / (3.0 + 8.0 * T0);
      T1 = (1.0 + 3.0 * T0) * T4; 
      T2 = BSIM3dvt2 * T4 * T4;
   end

   lt1 = BSIM3factor1 * T3 * T1;
   T0 = BSIM3dvt2w * Vbseff;
   if (T0 >= - 0.5)
      T1 = 1.0 + T0;
      T2 = BSIM3dvt2w;
   else %{/ Added to avoid any discontinuity problems caused by dvt2w %} 
      T4 = 1.0 / (3.0 + 8.0 * T0);
      T1 = (1.0 + 3.0 * T0) * T4; 
      T2 = BSIM3dvt2w * T4 * T4;
   end

   ltw = BSIM3factor1 * T3 * T1;

   T0 = -0.5 * BSIM3dvt1 * Leff / lt1;
   if (T0 > -EXP_THRESHOLD)
      T1 = exp(T0);
      Theta0 = T1 * (1.0 + 2.0 * T1);
   else 
      T1 = MIN_EXP;
      Theta0 = T1 * (1.0 + 2.0 * T1);
   end

   BSIM3thetavth = BSIM3dvt0 * Theta0;
   Delt_vth = BSIM3thetavth * V0;

   T0 = -0.5 * BSIM3dvt1w * BSIM3weff * Leff / ltw;
   if (T0 > -EXP_THRESHOLD)
      T1 = exp(T0);
      T2 = T1 * (1.0 + 2.0 * T1);
   else
      T1 = MIN_EXP;
      T2 = T1 * (1.0 + 2.0 * T1);
   end

   T0 = BSIM3dvt0w * T2;
   T2 = T0 * V0;

   %FIXME: CKTtemp should be obtained by $temperature in veriloga
   TempRatio =  CKTtemp / BSIM3tnom - 1.0;
   T0 = sqrt(1.0 + BSIM3nlx / Leff);
   T1 = BSIM3k1ox * (T0 - 1.0) * BSIM3sqrtPhi + (BSIM3kt1 + BSIM3kt1l / Leff + BSIM3kt2 * Vbseff) * TempRatio;
   tmp2 = BSIM3tox * BSIM3phi/ (BSIM3weff + BSIM3w0);

   T3 = BSIM3eta0 + BSIM3etab * Vbseff;
   if (T3 < 1.0e-4) %{/ avoid  discontinuity problems caused by etab %} 
      T9 = 1.0 / (3.0 - 2.0e4 * T3);
      T3 = (2.0e-4 - T3) * T9;
      T4 = T9 * T9;
   else
      T4 = 1.0;
   end

   dDIBL_Sft_dVd = T3 * BSIM3theta0vb0;
   DIBL_Sft = dDIBL_Sft_dVd * Vds;
   
   Vth = BSIM3type * BSIM3vth0 - BSIM3k1 * BSIM3sqrtPhi + BSIM3k1ox * sqrtPhis - BSIM3k2ox * Vbseff - Delt_vth - T2 + (BSIM3k3 + BSIM3k3b * Vbseff) * tmp2 + T1 - DIBL_Sft;

   BSIM3von = Vth; 

   %{/ Calculate n %}
   tmp2 = BSIM3nfactor * EPSSI / Xdep;
   tmp3 = BSIM3cdsc + BSIM3cdscb * Vbseff+ BSIM3cdscd * Vds;
   tmp4 = (tmp2 + tmp3 * Theta0 + BSIM3cit) / BSIM3cox;
   if (tmp4 >= -0.5)
      n = 1.0 + tmp4;
   else %{/ avoid  discontinuity problems caused by tmp4 %} 
      T0 = 1.0 / (3.0 + 8.0 * tmp4);
      n = (1.0 + 3.0 * tmp4) * T0;
   end

   %{/ Poly Gate Si Depletion Effect %}
   T0 = BSIM3vfb + BSIM3phi;
   if ((BSIM3ngate > 1.0e18) && (BSIM3ngate < 1.0e25) && (Vgs > T0))
      %{/ added to avoid the problem caused by ngate %}
      T1 = 1.0e6 * Charge_q * EPSSI * BSIM3ngate/(BSIM3cox * BSIM3cox);
      T4 = sqrt(1.0 + 2.0 * (Vgs - T0) / T1);
      T2 = T1 * (T4 - 1.0);
      T3 = 0.5 * T2 * T2 / T1; %{/ T3 = Vpoly %}
      T7 = 1.12 - T3 - 0.05;
      T6 = sqrt(T7 * T7 + 0.224);
      T5 = 1.12 - 0.5 * (T7 + T6);
      Vgs_eff = Vgs - T5;
   else
      Vgs_eff = Vgs;
   end
   
   Vgst = Vgs_eff - Vth;

   %{/ Effective Vgst (Vgsteff) Calculation %}
   T10 = 2.0 * n * Vtm;
   VgstNVt = Vgst / T10;
   ExpArg = (2.0 * BSIM3voff - Vgst) / T10;

   %{/ MCJ: Very small Vgst %}
   if (VgstNVt > EXP_THRESHOLD)
      Vgsteff = Vgst;
   elseif (ExpArg > EXP_THRESHOLD)
      T0 = (Vgst - BSIM3voff) / (n * Vtm);
      ExpVgst = exp(T0);
      Vgsteff = Vtm * BSIM3cdep0 / BSIM3cox * ExpVgst;
   else
      ExpVgst = exp(VgstNVt);
      T1 = T10 * log10(1.0 + ExpVgst);

      dT2_dVg = -BSIM3cox / (Vtm * BSIM3cdep0) * exp(ExpArg);
      T2 = 1.0 - T10 * dT2_dVg;

      Vgsteff = T1 / T2;
   end
      
   BSIM3Vgsteff = Vgsteff;     

   %{/ Calculate Effective Channel Geometry %}
   T9 = sqrtPhis - BSIM3sqrtPhi;
   Weff = BSIM3weff - 2.0 * (BSIM3dwg * Vgsteff  + BSIM3dwb * T9); 

   if (Weff < 2.0e-8) %{/ to avoid the discontinuity problem due to Weff%}
      T0 = 1.0 / (6.0e-8 - 2.0 * Weff);
      Weff = 2.0e-8 * (4.0e-8 - Weff) * T0;
   end
   
   T0 = BSIM3prwg * Vgsteff + BSIM3prwb * T9;
   if (T0 >= -0.9)
      Rds = BSIM3rds0 * (1.0 + T0);
   else
   %{/ to avoid the discontinuity problem due to prwg and prwb%}
      T1 = 1.0 / (17.0 + 20.0 * T0);
      Rds = BSIM3rds0 * (0.8 + T0) * T1;
   end
   BSIM3rds = Rds; %{/ Noise Bugfix %}

   %{/ Calculate Abulk %}
   T1 = 0.5 * BSIM3k1ox / sqrtPhis;
   % dT1_dVb = -T1 / sqrtPhis * dsqrtPhis_dVb; not used anywhere
   T9 = sqrt(BSIM3xj * Xdep);
   tmp1 = Leff + 2.0 * T9;
   T5 = Leff / tmp1; 
   tmp2 = BSIM3a0 * T5;
   tmp3 = BSIM3weff + BSIM3b1; 
   tmp4 = BSIM3b0 / tmp3;
   T2 = tmp2 + tmp4;
   T6 = T5 * T5;
   T7 = T5 * T6;

   Abulk0 = 1.0 + T1 * T2; 

   T8 = BSIM3ags * BSIM3a0 * T7;
   dAbulk_dVg = -T1 * T8;
   Abulk = Abulk0 + dAbulk_dVg * Vgsteff; 

   if (Abulk0 < 0.1) %{/ added to avoid the problems caused by Abulk0 %}
      T9 = 1.0 / (3.0 - 20.0 * Abulk0);
      Abulk0 = (0.2 - Abulk0) * T9;
   end

   if (Abulk < 0.1)
   % added to avoid the problems caused by Abulk 
      T9 = 1.0 / (3.0 - 20.0 * Abulk);
      Abulk = (0.2 - Abulk) * T9;
   end
   BSIM3Abulk = Abulk;

   T2 = BSIM3keta * Vbseff;
   if (T2 >= -0.9)
      T0 = 1.0 / (1.0 + T2);
   else
   % added to avoid the problems caused by Keta 
      T1 = 1.0 / (0.8 + T2);
      T0 = (17.0 + 20.0 * T2) * T1;
   end
   Abulk = Abulk*T0;
   Abulk0= Abulk0*T0;

   % Mobility calculation %}
   if (BSIM3mobMod == 1)
      T0 = Vgsteff + Vth + Vth;
      T2 = BSIM3ua + BSIM3uc * Vbseff;
      T3 = T0 / BSIM3tox;
      T5 = T3 * (T2 + BSIM3ub * T3);
   elseif (BSIM3mobMod == 2)
      T5=Vgsteff/BSIM3tox*(BSIM3ua+BSIM3uc*Vbseff+BSIM3ub*Vgsteff/BSIM3tox);
   else
      T0 = Vgsteff + Vth + Vth;
      T2 = 1.0 + BSIM3uc * Vbseff;
      T3 = T0 / BSIM3tox;
      T4 = T3 * (BSIM3ua + BSIM3ub * T3);
      T5 = T4 * T2;
   end

   if (T5 >= -0.8)
      Denomi = 1.0 + T5;
   else %{/ Added to avoid the discontinuity problem caused by ua and ub%} 
      T9 = 1.0 / (7.0 + 10.0 * T5);
      Denomi = (0.6 + T5) * T9;
   end
   
   BSIM3ueff=BSIM3u0temp / Denomi;
   ueff=BSIM3ueff;
   %{/ Saturation Drain Voltage  Vdsat %}
   WVCox = Weff * BSIM3vsattemp * BSIM3cox;
   WVCoxRds = WVCox * Rds; 

   Esat = 2.0 * BSIM3vsattemp / ueff;
   EsatL = Esat * Leff;
  
   %{/ Sqrt() %}
   %a1 = BSIM3a1;
   if (BSIM3a1 == 0.0)
      Lambda = BSIM3a2;
   elseif (BSIM3a1 > 0.0)
   %{/ Added to avoid the discontinuity problem caused by a1 and a2 (Lambda) %}
      T0 = 1.0 - BSIM3a2;
      T1 = T0 - BSIM3a1 * Vgsteff - 0.0001;
      T2 = sqrt(T1 * T1 + 0.0004 * T0);
      Lambda = BSIM3a2 + T0 - 0.5 * (T1 + T2);
   else
      T1 = BSIM3a2 + BSIM3a1 * Vgsteff - 0.0001;
      T2 = sqrt(T1 * T1 + 0.0004 * BSIM3a2);
      Lambda = 0.5 * (T1 + T2);
   end

   Vgst2Vtm = Vgsteff + 2.0 * Vtm;
   BSIM3AbovVgst2Vtm = Abulk / Vgst2Vtm;
   
   if ((Rds == 0.0) && (Lambda == 1.0))
      T0 = 1.0 / (Abulk * EsatL + Vgst2Vtm);
      T3 = EsatL * Vgst2Vtm;
      Vdsat = T3 * T0;
   else
      T9 = Abulk * WVCoxRds;
      T7 = Vgst2Vtm * T9;
      T6 = Vgst2Vtm * WVCoxRds;
      T0 = 2.0 * Abulk * (T9 - 1.0 + 1.0 / Lambda); 
      T1 = Vgst2Vtm * (2.0 / Lambda - 1.0) + Abulk * EsatL + 3.0 * T7;
      T2 = Vgst2Vtm * (EsatL + 2.0 * T6);
      T3 = sqrt(T1 * T1 - 2.0 * T0 * T2);
      Vdsat = (T1 - T3) / T0;
   end
   BSIM3vdsat = Vdsat;

   %{/ Effective Vds (Vdseff) Calculation %}
   T1 = Vdsat - Vds - BSIM3delta;
   T2 = sqrt(T1 * T1 + 4.0 * BSIM3delta * Vdsat);
   Vdseff = Vdsat - 0.5 * (T1 + T2);
   
   %{/ Added to eliminate non-zero Vdseff at Vds=0.0 %}
   if (Vds == 0.0)
      Vdseff = 0.0;
   end

   %{/ Calculate VAsat %}
   tmp4 = 1.0 - 0.5 * Abulk * Vdsat / Vgst2Vtm;
   T9 = WVCoxRds * Vgsteff;
   T0 = EsatL + Vdsat + 2.0 * T9 * tmp4;
   T9 = WVCoxRds * Abulk; 
   T1 = 2.0 / Lambda - 1.0 + T9; 
   Vasat = T0 / T1;
   
   if (Vdseff > Vds)
      Vdseff = Vds;
   end
   diffVds = Vds - Vdseff;
   BSIM3Vdseff = Vdseff;  

   %{/ Calculate VACLM %}
   if ((BSIM3pclm > 0.0) && (diffVds > 1.0e-10))
      T0 = 1.0 / (BSIM3pclm * Abulk * BSIM3litl);
      T2 = Vgsteff / EsatL;
      T1 = Leff * (Abulk + T2); 
      T9 = T0 * T1;
      VACLM = T9 * diffVds;
   else
      VACLM = MAX_EXP;
   end

   %{/ Calculate VADIBL %}
   if (BSIM3thetaRout > 0.0)
      T8 = Abulk * Vdsat;
      T0 = Vgst2Vtm * T8;
      T1 = Vgst2Vtm + T8;
      T2 = BSIM3thetaRout;
      VADIBL = (Vgst2Vtm - T0 / T1) / T2;
      T7 = BSIM3pdiblb * Vbseff;
      if (T7 >= -0.9)
         T3 = 1.0 / (1.0 + T7);
         VADIBL = VADIBL*T3;
      else
      %{/ Added to avoid the discontinuity problem caused by pdiblcb %}
         T4 = 1.0 / (0.8 + T7);
         T3 = (17.0 + 20.0 * T7) * T4;
         VADIBL = VADIBL * T3;
      end
   else
      VADIBL = MAX_EXP;
   end

   %{/ Calculate VA %}
   T8 = BSIM3pvag / EsatL;
   T9 = T8 * Vgsteff;
   if (T9 > -0.9)
      T0 = 1.0 + T9;
   else %{/ Added to avoid the discontinuity problems caused by pvag %}
      T1 = 1.0 / (17.0 + 20.0 * T9);
      T0 = (0.8 + T9) * T1;
   end
   tmp3 = VACLM + VADIBL;
   T1 = VACLM * VADIBL / tmp3;
   Va = Vasat + T0 * T1;

   %{/ Calculate VASCBE %}
   if (BSIM3pscbe2 > 0.0)
      if (diffVds > BSIM3pscbe1 * BSIM3litl/ EXP_THRESHOLD)
         T0 =  BSIM3pscbe1 * BSIM3litl / diffVds;
         VASCBE = Leff * exp(T0) / BSIM3pscbe2;
         T1 = T0 * VASCBE / diffVds;
      else
         VASCBE = MAX_EXP * Leff/BSIM3pscbe2;
      end
   else
      VASCBE = MAX_EXP;
   end

   %{/ Calculate Ids %}
   CoxWovL =BSIM3cox * Weff / Leff;
   beta = ueff * CoxWovL;

   T0 = 1.0 - 0.5 * Abulk * Vdseff / Vgst2Vtm;
   fgche1 = Vgsteff * T0;
   T9 = Vdseff / EsatL;
   fgche2 = 1.0 + T9;
 
   gche = beta * fgche1 / fgche2;
   T0 = 1.0 + gche * Rds;
   T9 = Vdseff / T0;
   Idl = gche * T9;

   T9 =  diffVds / Va;
   T0 =  1.0 + T9;
   Idsa = Idl * T0;

   T9 = diffVds / VASCBE;
   T0 = 1.0 + T9;
   Ids = Idsa * T0;

   %{/ Substrate current begins %}
   tmp = BSIM3alpha0 + BSIM3alpha1 * Leff;
   if ((tmp <= 0.0) || (BSIM3beta0 <= 0.0))
      Isub = 0.0;
   else
      T2 = tmp / Leff;
      if (diffVds > BSIM3beta0 / EXP_THRESHOLD)
         T0 = -BSIM3beta0 / diffVds;
         T1 = T2 * diffVds * exp(T0);
      else
         T3 = T2 * MIN_EXP;
         T1 = T3 * diffVds;
      end
      Isub = T1 * Idsa;
   end
 
   %cdrain=Ids;

   %//////////////////////////////////////////////////
   %
   % BSIM3 charge calculation begins (section 3)
   %
   %/////////////////////////////////////////////////

   % BSIM3 thermal noise Qinv calculated from all capMod 
   %  * 0, 1, 2 & 3 stored in here->BSIM3qinv 1/1998 %
   if (BSIM3xpart < 0) 
      qgate=0.0;
      qdrn =0.0;
      qsrc =0.0;
      qbulk=0.0;
   elseif (BSIM3capMod == 0)
      if (Vbseff < 0.0)
         Vbseff = Vbs;
      else
         Vbseff = BSIM3phi - Phis;
      end
      Vfb = BSIM3vfbcv;
      Vth = Vfb + BSIM3phi + BSIM3k1ox * sqrtPhis; 
      Vgst = Vgs_eff - Vth;
      CoxWL = BSIM3cox * BSIM3weffCV * BSIM3leffCV;
      Arg1 = Vgs_eff - Vbseff - Vfb;

      if (Arg1 <= 0.0)
         qgate = CoxWL * Arg1;
         qbulk = -qgate;
         qdrn = 0.0;
      elseif (Vgst <= 0.0)
         T1 = 0.5 * BSIM3k1ox;
         T2 = sqrt(T1 * T1 + Arg1);
         qgate = CoxWL * BSIM3k1ox * (T2 - T1);
         qbulk = -qgate;
         qdrn = 0.0;
         
      else
         One_Third_CoxWL = CoxWL / 3.0;
         Two_Third_CoxWL = 2.0 * One_Third_CoxWL;

         AbulkCV = Abulk0 * BSIM3abulkCVfactor;
         Vdsat = Vgst / AbulkCV;

         if (BSIM3xpart > 0.5)
            %{/ 0/100 Charge partition model %}
            if (Vdsat <= Vds)
               %{/ saturation region %}
               T1 = Vdsat / 3.0;
               qgate = CoxWL * (Vgs_eff - Vfb - BSIM3phi - T1);
               T2 = -Two_Third_CoxWL * Vgst;
               qbulk = -(qgate + T2);
               qdrn = 0.0;
            else
               %{/ linear region %}
               Alphaz = Vgst / Vdsat;
               T1 = 2.0 * Vdsat - Vds;
               T2 = Vds / (3.0 * T1);
               T3 = T2 * Vds;
               T9 = 0.25 * CoxWL;
               T4 = T9 * Alphaz;
               T7 = 2.0 * Vds - T1 - 3.0 * T3;
               T8 = T3 - T1 - 2.0 * Vds;
               qgate=CoxWL*(Vgs_eff-Vfb-BSIM3phi - 0.5 * (Vds - T3));
               T10 = T4 * T8;
               qdrn = T4 * T7;
               qbulk = -(qgate + qdrn + T10);
               
            end
         elseif (BSIM3xpart < 0.5)
            %{/ 40/60 Charge partition model %}
            if (Vds >= Vdsat)
               %{/ saturation region %}
               T1 = Vdsat / 3.0;
               qgate = CoxWL * (Vgs_eff - Vfb - BSIM3phi - T1);
               T2 = -Two_Third_CoxWL * Vgst;
               qbulk = -(qgate + T2);
               qdrn = 0.4 * T2;
            else
               %{/ linear region  %}
               Alphaz = Vgst / Vdsat;
               T1 = 2.0 * Vdsat - Vds;
               T2 = Vds / (3.0 * T1);
               T3 = T2 * Vds;
               T9 = 0.25 * CoxWL;
               T4 = T9 * Alphaz;
               qgate=CoxWL*(Vgs_eff - Vfb - BSIM3phi - 0.5 * (Vds - T3));
               T6=8.0*Vdsat * Vdsat - 6.0 * Vdsat * Vds + 1.2 * Vds * Vds;
               T8 = T2 / T1;
               T7 = Vds - T1 - T8 * T6;
               qdrn = T4 * T7;
           
               T7 = 2.0 * (T1 + T3);
               qbulk = -(qgate - T4 * T7);
           
            end
         else
            %{/ 50/50 partitioning %}
            if (Vds >= Vdsat)
               %{/ saturation region %}
               T1 = Vdsat / 3.0;
               qgate = CoxWL * (Vgs_eff - Vfb - BSIM3phi - T1);
               T2 = -Two_Third_CoxWL * Vgst;
               qbulk = -(qgate + T2);
               qdrn = 0.5 * T2;

            else
               %{/ linear region %}
               Alphaz = Vgst / Vdsat;
               T1 = 2.0 * Vdsat - Vds;
               T2 = Vds / (3.0 * T1);
               T3 = T2 * Vds;
               T9 = 0.25 * CoxWL;
               T4 = T9 * Alphaz;
               qgate =CoxWL*(Vgs_eff-Vfb - BSIM3phi - 0.5 * (Vds - T3));
               
               T7 = T1 + T3;
               qdrn = -T4 * T7;
               qbulk = - (qgate + qdrn + qdrn);
            end
         end
      end
   else   %BSIM3capMod ~=0
      if (Vbseff < 0.0)
         VbseffCV = Vbseff;
      else
         VbseffCV = BSIM3phi - Phis;
      end

      CoxWL = BSIM3cox * BSIM3weffCV * BSIM3leffCV;

      %{/ Seperate VgsteffCV with noff and voffcv %}
      LOCAL_noff = n * BSIM3noff;
      T0 = Vtm * LOCAL_noff;
      LOCAL_voffcv = BSIM3voffcv;
      VgstNVt = (Vgst - LOCAL_voffcv) / T0;

      if (VgstNVt > EXP_THRESHOLD)
         Vgsteff = Vgst - LOCAL_voffcv;
      elseif (VgstNVt < -EXP_THRESHOLD)
         Vgsteff = T0 * log10(1.0 + MIN_EXP);
      else
         ExpVgst = exp(VgstNVt);
         Vgsteff = T0 * log10(1.0 + ExpVgst);
      end %{/ End of VgsteffCV %}
      
      if (BSIM3capMod == 1)
         Vfb = BSIM3vfbzb;
         Arg1 = Vgs_eff - VbseffCV - Vfb - Vgsteff;

         if (Arg1 <= 0.0)
            qgate = CoxWL * Arg1;
         else
            T0 = 0.5 * BSIM3k1ox;
            T1 = sqrt(T0 * T0 + Arg1);
           
            qgate = CoxWL * BSIM3k1ox * (T1 - T0);
         end
         qbulk = -qgate;

         One_Third_CoxWL = CoxWL / 3.0;
         Two_Third_CoxWL = 2.0 * One_Third_CoxWL;
         AbulkCV = Abulk0 * BSIM3abulkCVfactor;
         VdsatCV = Vgsteff / AbulkCV;
         if (VdsatCV < Vds)
            T0 = Vgsteff - VdsatCV / 3.0;
            qgate = qgate+ CoxWL * T0;

            T0 = VdsatCV - Vgsteff;
            qbulk =qgate+ One_Third_CoxWL * T0;

            if (BSIM3xpart > 0.5)
               T0 = -Two_Third_CoxWL;
            elseif (BSIM3xpart < 0.5)
               T0 = -0.4 * CoxWL;
            else
               T0 = -One_Third_CoxWL;
            end
            qsrc = T0 * Vgsteff;
         else
            T0 = AbulkCV * Vds;
            T1 = 12.0 * (Vgsteff - 0.5 * T0 + 1.0e-20);
            T2 = Vds / T1;
            T3 = T0 * T2;
            qgate =qgate+ CoxWL * (Vgsteff - 0.5 * Vds + T3);
            qbulk = qgate +CoxWL * (1.0 - AbulkCV) * (0.5 * Vds - T3);
            if (BSIM3xpart > 0.5)
               %{/ 0/100 Charge petition model %}
               T1 = T1 + T1;
               qsrc = -CoxWL * (0.5 * Vgsteff + 0.25 * T0 - T0 * T0 / T1);
            elseif (BSIM3xpart < 0.5)
               %{/ 40/60 Charge petition model %}
               T1 = T1 / 12.0;
               T2 = 0.5 * CoxWL / (T1 * T1);
               T3 = Vgsteff * (2.0 * T0 * T0 / 3.0 + Vgsteff * (Vgsteff - 4.0 * T0 / 3.0)) - 2.0 * T0 * T0 * T0 / 15.0;
               qsrc = -T2 * T3;
            else %{/ 50/50 Charge petition model %}
               qsrc = -0.5 * (qgate + qbulk);
            end
         end
         qdrn = -(qgate + qbulk + qsrc);
      elseif (BSIM3capMod == 2)
         Vfb = BSIM3vfbzb;
         V3 = Vfb - Vgs_eff + VbseffCV - DELTA_3;
         if (Vfb <= 0.0)
            T0 = sqrt(V3 * V3 - 4.0 * DELTA_3 * Vfb);
         else
            T0 = sqrt(V3 * V3 + 4.0 * DELTA_3 * Vfb);
         end
         Vfbeff = Vfb - 0.5 * (V3 + T0);
         Qac0 = CoxWL * (Vfbeff - Vfb);

         T0 = 0.5 * BSIM3k1ox;
         T3 = Vgs_eff - Vfbeff - VbseffCV - Vgsteff;
         if (BSIM3k1ox == 0.0)
            T1 = 0.0;
         elseif (T3 < 0.0)
            T1 = T0 + T3 / BSIM3k1ox;
         else
            T1 = sqrt(T0 * T0 + T3);
         end
         Qsub0 = CoxWL * BSIM3k1ox * (T1 - T0);
         AbulkCV = Abulk0 * BSIM3abulkCVfactor;
         VdsatCV = Vgsteff / AbulkCV;

         V4 = VdsatCV - Vds - DELTA_4;
         T0 = sqrt(V4 * V4 + 4.0 * DELTA_4 * VdsatCV);
         VdseffCV = VdsatCV - 0.5 * (V4 + T0);
         
         %{/ Added to eliminate non-zero VdseffCV at Vds=0.0 %}
         if (Vds == 0.0)
            VdseffCV = 0.0;
         end

         T0 = AbulkCV * VdseffCV;
         T1 = 12.0 * (Vgsteff - 0.5 * T0 + 1e-20);
         T2 = VdseffCV / T1;
         T3 = T0 * T2;
         %ningd: what's qinoi, for noise model?
         qinoi = -CoxWL * (Vgsteff - 0.5 * T0 + AbulkCV * T3);
         qgate = CoxWL * (Vgsteff - 0.5 * VdseffCV + T3);
         T7 = 1.0 - AbulkCV;
         qbulk = CoxWL * T7 * (0.5 * VdseffCV - T3);
         
         if (BSIM3xpart > 0.5)
            %{/ 0/100 Charge petition model %}
            T1 = T1 + T1;
            qsrc = -CoxWL * (0.5 * Vgsteff + 0.25 * T0 - T0 * T0 / T1);
         elseif (BSIM3xpart < 0.5)
            %{/ 40/60 Charge petition model %}
            T1 = T1 / 12.0;
            T2 = 0.5 * CoxWL / (T1 * T1);
            T3 = Vgsteff * (2.0 * T0 * T0 / 3.0 + Vgsteff * (Vgsteff - 4.0 * T0 / 3.0)) - 2.0 * T0 * T0 * T0 / 15.0;
            qsrc = -T2 * T3;
         else %{/ 50/50 Charge petition model %}
            qsrc = -0.5 * (qgate + qbulk);
         end
         
         qgate =qgate+ Qac0 + Qsub0;
         qbulk =qbulk- (Qac0 + Qsub0);
         qdrn = -(qgate + qbulk + qsrc);
         
         
         %TODO: find out what is qinoi
         BSIM3qinv = qinoi;
      %{/ New Charge-Thickness capMod (CTM) begins %}
      elseif (BSIM3capMod == 3)
         V3 = BSIM3vfbzb - Vgs_eff + VbseffCV - DELTA_3;
         if (BSIM3vfbzb <= 0.0)
            T0 = sqrt(V3 * V3 - 4.0 * DELTA_3 * BSIM3vfbzb);
         else
            T0 = sqrt(V3 * V3 + 4.0 * DELTA_3 * BSIM3vfbzb);
         end
         Vfbeff = BSIM3vfbzb - 0.5 * (V3 + T0);

         Cox = BSIM3cox;
         Tox = 1.0e8 * BSIM3tox;
         T0 = (Vgs_eff - VbseffCV - BSIM3vfbzb) / Tox;

         tmp = T0 * BSIM3acde;
         if ((-EXP_THRESHOLD < tmp) && (tmp < EXP_THRESHOLD))
            Tcen = BSIM3ldeb * exp(tmp);
         elseif (tmp <= -EXP_THRESHOLD)
            Tcen = BSIM3ldeb * MIN_EXP;
         else
            Tcen = BSIM3ldeb * MAX_EXP;
         end
         
         LINK = 1.0e-3 * BSIM3tox;
         V3 = BSIM3ldeb - Tcen - LINK;
         V4 = sqrt(V3 * V3 + 4.0 * LINK * BSIM3ldeb);
         Tcen = BSIM3ldeb - 0.5 * (V3 + V4);
         Ccen = EPSSI / Tcen;
         T2 = Cox / (Cox + Ccen);
         Coxeff = T2 * Ccen;
         CoxWLcen = CoxWL * Coxeff / Cox;
         
         Qac0 = CoxWLcen * (Vfbeff - BSIM3vfbzb);
         T0 = 0.5 * BSIM3k1ox;
         T3 = Vgs_eff - Vfbeff - VbseffCV - Vgsteff;
         if (BSIM3k1ox == 0.0)
            T1 = 0.0;
         elseif (T3 < 0.0)
            T1 = T0 + T3 / BSIM3k1ox;
         else
            T1 = sqrt(T0 * T0 + T3);
         end

         Qsub0 = CoxWLcen * BSIM3k1ox * (T1 - T0);

         %{/ Gate-bias dependent delta Phis begins %}
         if (BSIM3k1ox <= 0.0)
            Denomi = 0.25 * BSIM3moin * Vtm;
            T0 = 0.5 * BSIM3sqrtPhi;
         else
            Denomi = BSIM3moin * Vtm * BSIM3k1ox * BSIM3k1ox;
            T0 = BSIM3k1ox * BSIM3sqrtPhi;
         end
         T1 = 2.0 * T0 + Vgsteff;
         DeltaPhi = Vtm * log10(1.0 + T1 * Vgsteff / Denomi);
         %{/ End of delta Phis %}

         T3 = 4.0 * (Vth - BSIM3vfbzb - BSIM3phi);
         Tox = Tox + Tox;
         
         if (T3 >= 0.0)
            T0 = (Vgsteff + T3) / Tox;
         else
            T0 = (Vgsteff + 1.0e-20) / Tox;
         end
         tmp = exp(0.7 * log10(T0));
         T1 = 1.0 + tmp;
         Tcen = 1.9e-9 / T1;
         Ccen = EPSSI / Tcen;
         T0 = Cox / (Cox + Ccen);
         Coxeff = T0 * Ccen;
         CoxWLcen = CoxWL * Coxeff / Cox;

         AbulkCV = Abulk0 * BSIM3abulkCVfactor;
         VdsatCV = (Vgsteff - DeltaPhi) / AbulkCV;
         V4 = VdsatCV - Vds - DELTA_4;
         T0 = sqrt(V4 * V4 + 4.0 * DELTA_4 * VdsatCV);
         VdseffCV = VdsatCV - 0.5 * (V4 + T0);
         T1 = 0.5 * (1.0 + V4 / T0);
         
         %{/ Added to eliminate non-zero VdseffCV at Vds=0.0 %}
         if (Vds == 0.0)
            VdseffCV = 0.0;
         end
         
         T0 = AbulkCV * VdseffCV;
         T1 = Vgsteff - DeltaPhi;
         T2 = 12.0 * (T1 - 0.5 * T0 + 1.0e-20);
         T3 = T0 / T2;
         T4 = 1.0 - 12.0 * T3 * T3;
         T5 = AbulkCV * (6.0 * T0 * (4.0 * T1 - T0) / (T2 * T2) - 0.5);
         T6 = T5 * VdseffCV / AbulkCV;

         qgate = CoxWLcen * (T1 - T0 * (0.5 - T3));
         qinoi = qgate;   
         T7 = 1.0 - AbulkCV;
         qbulk = CoxWLcen * T7 * (0.5 * VdseffCV - T0 * VdseffCV / T2);
         if (BSIM3xpart > 0.5)
            %{/ 0/100 partition %}
            qsrc = -CoxWLcen * (T1 / 2.0 + T0 / 4.0 - 0.5 * T0 * T0 / T2);
         elseif (BSIM3xpart < 0.5)
            %{/ 40/60 partition %}
            T2 = T2 / 12.0;
            T3 = 0.5 * CoxWLcen / (T2 * T2);
            T4 = T1 * (2.0 * T0 * T0 / 3.0 + T1 * (T1 - 4.0 * T0 / 3.0)) - 2.0 * T0 * T0 * T0 / 15.0;
            qsrc = -T3 * T4;
         else
            %{/ 50/50 partition %}
            qsrc = -0.5 * qgate;
         end

         qgate =qgate+ Qac0 + Qsub0 - qbulk;
         qbulk =qbulk- (Qac0 + Qsub0);
         qdrn = -(qgate + qbulk + qsrc);
         
         %TODO: what is qinoi
         BSIM3qinv = -qinoi;
      end  %{/ End of CTM %}
   end

   %{  
         charge storage elements
            *  bulk-drain and bulk-source depletion capacitances
            *  czbd : zero bias drain junction capacitance
            *  czbs : zero bias source junction capacitance
            *  czbdsw: zero bias drain junction sidewall capacitance
           along field oxide
            *  czbssw: zero bias source junction sidewall capacitance
           along field oxide
         *  czbdswg: zero bias drain junction sidewall capacitance
            along gate side
         *  czbsswg: zero bias source junction sidewall capacitance
            along gate side
   %}
   
   czbd = BSIM3unitAreaTempJctCap * BSIM3drainArea; %{/bug fix %}
   czbs = BSIM3unitAreaTempJctCap * BSIM3sourceArea;
   
   if (BSIM3drainPerimeter < BSIM3weff)
      czbdswg = BSIM3unitLengthGateSidewallTempJctCap * BSIM3drainPerimeter;
      czbdsw = 0.0;
   else
      czbdsw=BSIM3unitLengthSidewallTempJctCap*(BSIM3drainPerimeter - BSIM3weff);
      czbdswg = BSIM3unitLengthGateSidewallTempJctCap *  BSIM3weff;
   end

   if (BSIM3sourcePerimeter < BSIM3weff)
      czbssw = 0.0; 
      czbsswg = BSIM3unitLengthGateSidewallTempJctCap * BSIM3sourcePerimeter;
   else
      czbssw=BSIM3unitLengthSidewallTempJctCap*(BSIM3sourcePerimeter - BSIM3weff);
      czbsswg = BSIM3unitLengthGateSidewallTempJctCap *  BSIM3weff;
   end

   MJ = BSIM3bulkJctBotGradingCoeff;
   MJSW = BSIM3bulkJctSideGradingCoeff;
   MJSWG = BSIM3bulkJctGateSideGradingCoeff;

   %{/ Source Bulk Junction %}
   %TODO/FIXME: use a flag to turn on/off this part of code
   if (vbs == 0.0)
      %   *(ckt->CKTstate0 + BSIM3qbs) = 0.0;
      BSIM3qbs = 0.0;
   elseif (vbs < 0.0)
      if (czbs > 0.0)
         arg = 1.0 - vbs / BSIM3PhiB;
         if (MJ == 0.5)
            sarg = 1.0 / sqrt(arg);
         else
            sarg = exp(-MJ * log10(arg));
         end

         BSIM3qbs = BSIM3PhiB * czbs * (1.0 - arg * sarg) / (1.0 - MJ);
      else
         %*(ckt->CKTstate0 + BSIM3qbs) = 0.0;
         BSIM3qbs = 0.0;
      end

      if (czbssw > 0.0)
         arg = 1.0 - vbs / BSIM3PhiBSW;
         if (MJSW == 0.5)
            sarg = 1.0 / sqrt(arg);
         else
            sarg = exp(-MJSW * log10(arg));
         end
         BSIM3qbs=BSIM3qbs+BSIM3PhiBSW*czbssw*(1.0-arg*sarg)/(1.0-MJSW);
      end

      if (czbsswg > 0.0)
         arg = 1.0 - vbs / BSIM3PhiBSWG;
         if (MJSWG == 0.5)
            sarg = 1.0 / sqrt(arg);
         else
            sarg = exp(-MJSWG * log10(arg));
            BSIM3qbs=BSIM3qbs+BSIM3PhiBSWG*czbsswg*(1.0-arg*sarg)/(1.0-MJSWG);
         end
      end
   else
      T0 = czbs + czbssw + czbsswg;
      T1 = vbs * (czbs * MJ / BSIM3PhiB + czbssw * MJSW / BSIM3PhiBSW + czbsswg * MJSWG / BSIM3PhiBSWG);    
      BSIM3qbs = vbs * (T0 + 0.5 * T1);
   end

   %{/ Drain Bulk Junction %}
   %TODO/FIXME: use a flag to turn on/off this part code
   if (vbd == 0.0)
      BSIM3qbd = 0.0;
   elseif (vbd < 0.0)
      if (czbd > 0.0)
         arg = 1.0 - vbd / BSIM3PhiB;
         if (MJ == 0.5)
            sarg = 1.0 / sqrt(arg);
         else
            sarg = exp(-MJ * log10(arg));
         end
         BSIM3qbd = BSIM3PhiB * czbd * (1.0 - arg * sarg) / (1.0 - MJ);
      else
         BSIM3qbd = 0.0;
      end

      if (czbdsw > 0.0)
         arg = 1.0 - vbd / BSIM3PhiBSW;
         if (MJSW == 0.5)
            sarg = 1.0 / sqrt(arg);
         else
            sarg = exp(-MJSW * log10(arg));
         end
         BSIM3qbd=BSIM3qbd+BSIM3PhiBSW*czbdsw*(1.0-arg*sarg) / (1.0 - MJSW);
      end

      if (czbdswg > 0.0)
         arg = 1.0 - vbd / BSIM3PhiBSWG;
         if (MJSWG == 0.5)
            sarg = 1.0 / sqrt(arg);
         else
            sarg = exp(-MJSWG * log10(arg));
         end
         BSIM3qbd=BSIM3qbd+BSIM3PhiBSWG*czbdswg*(1.0-arg*sarg)/(1.0 - MJSWG);
      end
   else
      T0 = czbd + czbdsw + czbdswg;
      T1 =vbd*(czbd*MJ/BSIM3PhiB+czbdsw*MJSW /BSIM3PhiBSW+czbdswg*MJSWG/BSIM3PhiBSWG);
      BSIM3qbd = vbd * (T0 + 0.5 * T1);
   end
    
    %{ NQS begins %}
   %TODO/FIXME: take care nqs model later
   %{
   if (here->BSIM3nqsMod)
        begin   qcheq = -(qbulk + qgate);

           here->BSIM3cqgb = -(here->BSIM3cggb + here->BSIM3cbgb);
           here->BSIM3cqdb = -(here->BSIM3cgdb + here->BSIM3cbdb);
           here->BSIM3cqsb = -(here->BSIM3cgsb + here->BSIM3cbsb);
           here->BSIM3cqbb = -(here->BSIM3cqgb + here->BSIM3cqdb
                       + here->BSIM3cqsb);

           gtau_drift = fabs(pParam->BSIM3tconst * qcheq) * ScalingFactor;
           T0 = pParam->BSIM3leffCV * pParam->BSIM3leffCV;
           gtau_diff = 16.0 * pParam->BSIM3u0temp * model->BSIM3vtm / T0
         * ScalingFactor;
           here->BSIM3gtau =  gtau_drift + gtau_diff;
        end
   %}
   
   if (BSIM3capMod == 0) %{/ code merge -JX %}
      LOCAL_cgdo = BSIM3cgdo;
      qgdo = BSIM3cgdo * vgd;
      LOCAL_cgso = BSIM3cgso;
      qgso = BSIM3cgso * vgs;
   end
   if (BSIM3capMod == 1)
      if (vgd < 0.0)
         T1 = sqrt(1.0 - 4.0 * vgd / BSIM3ckappa);
         LOCAL_cgdo = BSIM3cgdo + BSIM3weffCV * BSIM3cgdl / T1;
         qgdo=BSIM3cgdo*vgd-BSIM3weffCV*0.5*BSIM3cgdl*BSIM3ckappa*(T1 - 1.0);
      else
         LOCAL_cgdo = BSIM3cgdo + BSIM3weffCV * BSIM3cgdl;
         qgdo = (BSIM3weffCV * BSIM3cgdl + BSIM3cgdo) * vgd;
      end
      if (vgs < 0.0)
         T1 = sqrt(1.0 - 4.0 * vgs / BSIM3ckappa);
         LOCAL_cgso = BSIM3cgso + BSIM3weffCV * BSIM3cgsl / T1;
         qgso=BSIM3cgso*vgs-BSIM3weffCV*0.5*BSIM3cgsl*BSIM3ckappa*(T1 - 1.0);
      else
         LOCAL_cgso = BSIM3cgso + BSIM3weffCV * BSIM3cgsl;
         qgso = (BSIM3weffCV * BSIM3cgsl + BSIM3cgso) * vgs;
      end
   else
      T0 = vgd + DELTA_1;
      T1 = sqrt(T0 * T0 + 4.0 * DELTA_1);
      T2 = 0.5 * (T0 - T1);

      T3 = BSIM3weffCV * BSIM3cgdl;
      T4 = sqrt(1.0 - 4.0 * T2 / BSIM3ckappa);
      LOCAL_cgdo = BSIM3cgdo + T3 - T3 * (1.0 - 1.0 / T4)*(0.5 - 0.5 * T0 / T1);
      qgdo=(BSIM3cgdo + T3) * vgd - T3 * (T2 + 0.5 * BSIM3ckappa * (T4 - 1.0));

      T0 = vgs + DELTA_1;
      T1 = sqrt(T0 * T0 + 4.0 * DELTA_1);
      T2 = 0.5 * (T0 - T1);
      T3 = BSIM3weffCV * BSIM3cgsl;
      T4 = sqrt(1.0 - 4.0 * T2 / BSIM3ckappa);
      LOCAL_cgso=BSIM3cgso+T3 - T3 * (1.0 - 1.0 / T4) * (0.5 - 0.5 * T0 / T1);
      qgso=(BSIM3cgso+T3)*vgs-T3*(T2+0.5*BSIM3ckappa*(T4 - 1.0));
   end

   BSIM3cgdo = LOCAL_cgdo;
   BSIM3cgso = LOCAL_cgso;

   if (BSIM3mode > 0)
      if (BSIM3nqsMod == 0)
         qgd = qgdo;
         qgs = qgso;
         qgb = BSIM3cgbo * vgb;
         qgate =qgate+ qgd + qgs + qgb;
         qbulk =qbulk- qgb;
         qdrn =qdrn- qgd;
         qsrc = -(qgate + qbulk + qdrn);

      else
      %TODO/FIXME: take care nqs mode later
         %{
         if (qcheq > 0.0)
                 T0 = BSIM3tconst * qdef * ScalingFactor;
              else
                 T0 = -BSIM3tconst * qdef * ScalingFactor;
              ggtg = BSIM3gtg = T0 * BSIM3cqgb;
              ggtd = BSIM3gtd = T0 * BSIM3cqdb;
              ggts = BSIM3gts = T0 * BSIM3cqsb;
              ggtb = BSIM3gtb = T0 * BSIM3cqbb;
        gqdef = ScalingFactor * ag0;

              gcqgb = BSIM3cqgb * ag0;
              gcqdb = BSIM3cqdb * ag0;
              gcqsb = BSIM3cqsb * ag0;
              gcqbb = BSIM3cqbb * ag0;

              gcggb = (cgdo + cgso + BSIM3cgbo ) * ag0;
              gcgdb = -cgdo * ag0;
              gcgsb = -cgso * ag0;

              gcdgb = -cgdo * ag0;
              gcddb = (BSIM3capbd + cgdo) * ag0;
              gcdsb = 0.0;

              gcsgb = -cgso * ag0;
              gcsdb = 0.0;
              gcssb = (BSIM3capbs + cgso) * ag0;

              gcbgb = -BSIM3cgbo * ag0;
              gcbdb = -BSIM3capbd * ag0;
              gcbsb = -BSIM3capbs * ag0;

        CoxWL = model->BSIM3cox * BSIM3weffCV
                  * BSIM3leffCV;
        if (fabs(qcheq) <= 1.0e-5 * CoxWL)
        begin   if (model->BSIM3xpart < 0.5)
           begin   dxpart = 0.4;
           end
           else if (model->BSIM3xpart > 0.5)
           begin   dxpart = 0.0;
           end
           else
           begin   dxpart = 0.5;
           end
           ddxpart_dVd = ddxpart_dVg = ddxpart_dVb
              = ddxpart_dVs = 0.0;
        end
        else
        begin   dxpart = qdrn / qcheq;
           Cdd = BSIM3cddb;
           Csd = -(BSIM3cgdb + BSIM3cddb
           + BSIM3cbdb);
           ddxpart_dVd = (Cdd - dxpart * (Cdd + Csd)) / qcheq;
           Cdg = BSIM3cdgb;
           Csg = -(BSIM3cggb + BSIM3cdgb
           + BSIM3cbgb);
           ddxpart_dVg = (Cdg - dxpart * (Cdg + Csg)) / qcheq;

           Cds = BSIM3cdsb;
           Css = -(BSIM3cgsb + BSIM3cdsb
           + BSIM3cbsb);
           ddxpart_dVs = (Cds - dxpart * (Cds + Css)) / qcheq;

           ddxpart_dVb = -(ddxpart_dVd + ddxpart_dVg + ddxpart_dVs);
        end
        sxpart = 1.0 - dxpart;
        dsxpart_dVd = -ddxpart_dVd;
        dsxpart_dVg = -ddxpart_dVg;
        dsxpart_dVs = -ddxpart_dVs;
        dsxpart_dVb = -(dsxpart_dVd + dsxpart_dVg + dsxpart_dVs);

              qgd = qgdo;
              qgs = qgso;
              qgb = BSIM3cgbo * vgb;
              qgate = qgd + qgs + qgb;
              qbulk = -qgb;
              qdrn = -qgd;
              qsrc = -(qgate + qbulk + qdrn);
        %}
      end
   else
      if (BSIM3nqsMod == 0)
         qgd = qgdo;
         qgs = qgso;
         qgb = BSIM3cgbo * vgb;
         qgate =qgate+ qgd + qgs + qgb;
         qbulk =qbulk- qgb;
         qsrc = qdrn - qgs;
         qdrn = -(qgate + qbulk + qsrc);

      else
         %TODO/FIXME: take care of nqs model later
         %{
         if (qcheq > 0.0)
                 T0 = pParam->BSIM3tconst * qdef * ScalingFactor;
              else
                 T0 = -pParam->BSIM3tconst * qdef * ScalingFactor;
              ggtg = here->BSIM3gtg = T0 * here->BSIM3cqgb;
              ggts = here->BSIM3gtd = T0 * here->BSIM3cqdb;
              ggtd = here->BSIM3gts = T0 * here->BSIM3cqsb;
              ggtb = here->BSIM3gtb = T0 * here->BSIM3cqbb;
        gqdef = ScalingFactor * ag0;

              gcqgb = here->BSIM3cqgb * ag0;
              gcqdb = here->BSIM3cqsb * ag0;
              gcqsb = here->BSIM3cqdb * ag0;
              gcqbb = here->BSIM3cqbb * ag0;

              gcggb = (cgdo + cgso + pParam->BSIM3cgbo) * ag0;
              gcgdb = -cgdo * ag0;
              gcgsb = -cgso * ag0;

              gcdgb = -cgdo * ag0;
              gcddb = (here->BSIM3capbd + cgdo) * ag0;
              gcdsb = 0.0;

              gcsgb = -cgso * ag0;
              gcsdb = 0.0;
              gcssb = (here->BSIM3capbs + cgso) * ag0;

              gcbgb = -pParam->BSIM3cgbo * ag0;
              gcbdb = -here->BSIM3capbd * ag0;
              gcbsb = -here->BSIM3capbs * ag0;

        CoxWL = model->BSIM3cox * pParam->BSIM3weffCV
                  * pParam->BSIM3leffCV;
        if (fabs(qcheq) <= 1.0e-5 * CoxWL)
        begin   if (model->BSIM3xpart < 0.5)
           begin   sxpart = 0.4;
           end
           else if (model->BSIM3xpart > 0.5)
           begin   sxpart = 0.0;
           end
           else
           begin   sxpart = 0.5;
           end
           dsxpart_dVd = dsxpart_dVg = dsxpart_dVb
              = dsxpart_dVs = 0.0;
        end
        else
        begin   sxpart = qdrn / qcheq;
           Css = here->BSIM3cddb;
           Cds = -(here->BSIM3cgdb + here->BSIM3cddb
           + here->BSIM3cbdb);
           dsxpart_dVs = (Css - sxpart * (Css + Cds)) / qcheq;
           Csg = here->BSIM3cdgb;
           Cdg = -(here->BSIM3cggb + here->BSIM3cdgb
           + here->BSIM3cbgb);
           dsxpart_dVg = (Csg - sxpart * (Csg + Cdg)) / qcheq;

           Csd = here->BSIM3cdsb;
           Cdd = -(here->BSIM3cgsb + here->BSIM3cdsb
           + here->BSIM3cbsb);
           dsxpart_dVd = (Csd - sxpart * (Csd + Cdd)) / qcheq;

           dsxpart_dVb = -(dsxpart_dVd + dsxpart_dVg + dsxpart_dVs);
        end
        dxpart = 1.0 - sxpart;
        ddxpart_dVd = -dsxpart_dVd;
        ddxpart_dVg = -dsxpart_dVg;
        ddxpart_dVs = -dsxpart_dVs;
        ddxpart_dVb = -(ddxpart_dVd + ddxpart_dVg + ddxpart_dVs);

              qgd = qgdo;
              qgs = qgso;
              qgb = pParam->BSIM3cgbo * vgb;
              qgate = qgd + qgs + qgb;
              qbulk = -qgb;
              qsrc = -qgs;
              qdrn = -(qgate + qbulk + qsrc);
      %}
      end
   end

   %//////////////////////////////////////////////////
   %
   % BSIM3 charge/current contribution begins (section 4)
   %
   %/////////////////////////////////////////////////
   

   %The following code are essentially adopted from concetual BSIM3 DC model 
   %ceqbd=I(b,dp)
   %ceqbs=I(b,sp)
   %cdreq=cdrain=Ids=I(dp,sp)
   
   if (BSIM3mode > 0)
      cdreq=BSIM3type*Ids;
      ceqbd=-BSIM3type*Isub;   %Isub=BSIM3csub
      ceqbs = 0.0;   %Ibs
   else
      cdreq=-BSIM3type*Ids;
      ceqbs=-BSIM3type*Isub;
      ceqbd = 0.0;
   end

   if (BSIM3type > 0)
      ceqbs =ceqbs+ BSIM3cbs; 
      ceqbd =ceqbd+ BSIM3cbd;
   else
      ceqbs =ceqbs- BSIM3cbs;
      ceqbd =ceqbd- BSIM3cbd;
   end


   if flag.fe == 1
      fe(1,1) = (vd - vdp)*BSIM3drainConductance;
      % igb
      fe(2,1) = 0;
      % isb (vs - vsi)/Rs
      fe(3,1) = (vs - vsp)*BSIM3sourceConductance;
   else
      fe = [];
   end

   if flag.qe == 1
      qe(2,1) = BSIM3type*qgate;
      % igb
      % I(vg, vsp) <+ BSIM3type * ddt(qgate);
      % a charge q between g and sp is the same thing
      % as a charge q between g and b, and a charge -q
      % between s and b. We handle the gb component here

      % idb 
      qe(1,1) = 0; % no d/dt term in idb contribution

      % isb
      qe(3,1) = 0;  % no d/dt term in isb contribution

   else
      qe = [];
   end

   if flag.fi == 1
      fi(1,1) = (vdp-vd)*BSIM3drainConductance + cdreq - ceqbd;
            
         % si_KCL: 
      fi(2,1) = (vsp-vs)*BSIM3sourceConductance - cdreq - ceqbs;

   else
      fi = [];
   end

   if flag.qi == 1
      qi(1,1) = BSIM3type*(-BSIM3qbd+qdrn);
      % si_KQL: d/dt terms
      qi(2,1) = BSIM3type*(-qgate-qbulk-BSIM3qbs-qdrn);
   else
      qi = [];
   end

end % fqei(...)


%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = pow(a,b)
   out = a^b;
end
