%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script to run transient analysis on an RC line cricuit
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

function LTEtest_RCline_transient(tstep)


% set up DAE
nsegs = 3; R = 1000; C = 1e-6;
DAE =  RClineDAEAPIv6('somename',nsegs, R, C);

% set transient input to the DAE
utargs.A = 1; utargs.f=1e3; utargs.phi=0; 
utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, but it also defines
                     % TRAPparms, FEparms, GEAR2Parms
TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
LMStranparms = TransObjBE.tranparms; % has tranparms.NRparms
LMStranparms.NRparms.limiting = 1;
TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);

% run transient and plot
xinit = zeros(nsegs,1); 
tstart = 0;
%tstep = 2e-4;
tstop = 10e-3;
%tstep = 10e-5; tstop = 5e-2;

%%%%%%%%%%%%%%%%%modified by jian %%%%%%%%%%%
tic
TransObjTRAP.tranparms.LTEstepControlParms.doStepControl=0;
%TransObjTRAP.tranparms.stepControlParms.doStepControl=0;
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
      xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], 'TRAP\_NoLTE');
fprintf('TRAP_NoLTE\n');
toc

tic
TransObjTRAP.tranparms.LTEstepControlParms.doStepControl=1;
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
      xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [],...
    'TRAP\_LTE','o-',thefig, legends,'r');
fprintf('TRAP_LTE\n');
toc



% multiple overlaid plots:
tic
TransObjBE.tranparms.LTEstepControlParms.doStepControl=0;
TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ...
			tstep, tstop);
[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE\_NoLTE'); % BE plots
fprintf('BE_NoLTE\n');
toc

tic
TransObjBE.tranparms.LTEstepControlParms.doStepControl=1;
TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ...
			tstep, tstop);
[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE\_LTE','o-',thefig, legends, 'r'); % BE plots
fprintf('BE_LTE\n');
toc




% %[thefig, legends] = feval(TransObjFE.plot, TransObjFE,  [], 'FE', 'x-', ...
% %				thefig, legends); 
% 
% 
% 
% 
% %% FE plots, overlaid
% [thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], ...
% 				'TRAP', 'o-', thefig, legends); 
% % TRAP plots, overlaid
% title(sprintf('BE and TRAP on %s', feval(DAE.daename,DAE)));
