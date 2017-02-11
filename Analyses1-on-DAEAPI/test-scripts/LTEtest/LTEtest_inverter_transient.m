%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running transient analysis on an inverter 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Changelog:
%---------
%2014/02/07: Jian Yao <jianyao@berkeley.edu>: demo for MAPP meeting 2014/02/06 
%


function LTEtest_inverter_transient(tstep)




% set up DAE
DAE =  SH_CMOS_inverter_DAEAPIv6('somename');

% set transient input to the DAE
utargs.A = 0.5; utargs.offset = 0.5; utargs.f=2e2; utargs.phi=0; 
utfunc = @(t, args) args.offset + args.A*cos(2*pi*args.f*t + args.phi);
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, but it also defines
                     % TRAPparms, FEparms, GEAR2Parms
%TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
LMStranparms = TransObjBE.tranparms; % has tranparms.NRparms
LMStranparms.NRparms.limiting = 1;
LMStranparms.NRparms.dbglvl = 1;
LMStranparms.trandbglvl = 1;

TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);
TransObjGEAR2 = LMS(DAE,TransObjBE.GEAR2parms, LMStranparms);

% run transient and plot
xinit = [0]; %
%xinit = zeros(feval(DAE.nunks,DAE),1); breaks both BE and TRAP
tstart = 0;
%tstep = 10e-6; tstop = 5e-2;
%tstep = 10e-5;
tstop = 10e-2;

% Gear2
tic
TransObjGEAR2.tranparms.LTEstepControlParms.doStepControl=0;
TransObjGEAR2 = feval(TransObjGEAR2.solve, TransObjGEAR2, xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2,[], 'GEAR2\_NoLTE');
fprintf('GEAR2_NoLTE\n');
toc

tic
TransObjGEAR2.tranparms.LTEstepControlParms.doStepControl=1;
TransObjGEAR2 = feval(TransObjGEAR2.solve, TransObjGEAR2, xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2,[],...
    'GEAR2\_LTE','o-',thefig, legends,'r');
fprintf('GEAR2_LTE\n');
toc

% TRAP
%TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, xinit, tstart, tstep, tstop);
%[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);

% multiple overlaid plots:
tic
TransObjBE.tranparms.LTEstepControlParms.doStepControl=0;
TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjBE.plot, TransObjBE,[], 'BE\_NoLTE'); % BE plots
fprintf('BE_NoLTE\n');
toc

tic
TransObjBE.tranparms.LTEstepControlParms.doStepControl=1;
TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjBE.plot, TransObjBE,[], 'BE\_LTE','o-',thefig, legends, 'r');
fprintf('BE_LTE\n');
toc

%% FE plots, overlaid
% %[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], 'TRAP', 'o-', thefig, legends); 
% % TRAP plots, overlaid
% [thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2, [], 'GEAR2', 'o-', thefig, legends); 
% % GEAR2 plots, overlaid
% title(sprintf('TRAP, BE and GEAR2 on %s', feval(DAE.daename,DAE)));
