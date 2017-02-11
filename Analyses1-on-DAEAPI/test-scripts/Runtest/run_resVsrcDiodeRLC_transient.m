%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime or before
% Test script for running transient analysis on R-Vsrc-D-RLC cicrcuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DO NOT CHANGE THIS SECTION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "Read in" the DAE
DAE = res_vsrc_diode_RLC('res_vsrc_diode_RLC'); 

% Do a DC
qss = QSS(DAE);
qss = feval(qss.solve, qss);
DCsol = feval(qss.getsolution,qss)
%

% setting a transient input function for E(t)
tstart = 0; tstop = 2e-6;  tstep = 1.5e-9; 
%mypulse = @(t,args) pulse(t/5e-6, 0.008, 0.009, 0.02, 0.021);
mypulse = @(t,args) 5*pulse(t/5e-6, 0.001, 0.01, 0.15, 0.16);
args = [];
DAE = feval(DAE.set_utransient, mypulse, args, DAE);

% set initial conditions for transient
xinit = DCsol;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END: DO NOT CHANGE THIS SECTION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create transient analysis objects for BE, TRAP
% this is how JR's implementation is exercised. Yours could be similar.
TransObjBE = LMS(DAE); % default method is BE
tranparms = TransObjBE.tranparms;
tranparms.stepControlParms.doStepControl = 0; % uniform timesteps only.
%tranparms.trandbglvl = 2; 
%tranparms.NRparms.dbglvl = 2;
%tranparms.NRparms.limiting = 0;
TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, tranparms); 
TransObjBE = LMS(DAE,TransObjBE.BEparms, tranparms); %


% BE plots
TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE'); % BE plots
% TRAP plots, overlaid
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], ...
				'TRAP', 'ko-', thefig, legends); 
title('BE and TRAP on res_vsrc_diode_RLC');

if 0 == 1
	hold on;
	tpts = feval(TransObjTRAP.getsolution, TransObjTRAP);
	inputvals = mypulse(tpts,[]);
	plot(tpts,inputvals,'go-');
	axis tight;
end
