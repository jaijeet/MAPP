%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running transient simulation on a vsrc-R-C-diode system, bidirectionally coupled with  2 springs and 2 masses.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% set up DAE
DAE = coupledRCdiodeSpringsMasses('the-system');

% set DC input to 0
DAE = feval(DAE.set_uQSS, 0, DAE);

% run a DC analysis
qss = QSS(DAE);
qss = feval(qss.solve, qss);
sol = feval(qss.getsolution, qss);

% set up initial condition for transient
xinit = sol;

% set up transient input to the DAE
utargs.A = 0.5; utargs.f=2.5; utargs.phi=pi; 
%utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%utfunc = @(t, args) (t > 0) & (t < 5);
utfunc = @(t, args) (1+args.A*sin(2*pi*args.f*t + args.phi)).*((t > 0) & (t < 5));
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

% set up transient parameters: start time, (uniform) timestep, and stop time
tstart = 0; tstep = 5e-3; tstop = 20;

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, but it also defines
                     % TRAPparms, FEparms, GEAR2Parms
TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
LMStranparms = TransObjBE.tranparms; % has tranparms.NRparms and tranparms.stepControlParms
LMStranparms.NRparms.limiting = 0; % do not use NR limiting
LMStranparms.stepControlParms.doStepControl = 0; % use uniform timesteps.
TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);
TransObjBE = LMS(DAE,TransObjBE.BEparms, LMStranparms);

% run transient and plot

% multiple overlaid plots:
TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ...
			tstep, tstop);
[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE'); % BE plots
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], ...
				'TRAP', 'o-', thefig, legends);  % TRAP plots
% TRAP plots, overlaid
title(sprintf('BE and TRAP on %s', feval(DAE.daename,DAE)));
