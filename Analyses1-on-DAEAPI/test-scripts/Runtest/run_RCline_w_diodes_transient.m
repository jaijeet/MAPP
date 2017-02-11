%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script to run transient analysis on an RC line cricuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% set up DAE
nsegs = 3; R = 1000; C = 1e-6; Is = 1e-12; Vt = 0.026;
DAE =  RCline_w_diodes('somename',nsegs, R, C, Is, Vt);

% set transient input to the DAE
utargs.A = 3; utargs.f=1e2; utargs.phi=0; 
utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, but it also defines
                     % TRAPparms, FEparms, GEAR2Parms
TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
LMStranparms = TransObjBE.tranparms; % has tranparms.NRparms
LMStranparms.NRparms.limiting = 1;

TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);
TransObjFE = LMS(DAE,TransObjBE.FEparms, LMStranparms);

% run transient and plot
xinit = zeros(nsegs,1); 
tstart = 0;
tstep = 10e-5; tstop = 5e-2;

TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
      xinit, tstart, tstep, tstop);
feval(TransObjTRAP.plot, TransObjTRAP, StateOutputs(DAE));
title(sprintf('TRAP on %s', feval(DAE.daename,DAE)));

tstep = 10e-6; tstop = 5e-2;
TransObjFE = feval(TransObjFE.solve, TransObjFE, ...
      xinit, tstart, tstep, tstop);
feval(TransObjFE.plot, TransObjFE,  StateOutputs(DAE));
title(sprintf('FE on %s', feval(DAE.daename,DAE)));

%{

% multiple overlaid plots:
TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ...
			tstep, tstop);
[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE'); % BE plots
%[thefig, legends] = feval(TransObjFE.plot, TransObjFE,  [], 'FE', 'x-', ...
%				thefig, legends); 
%% FE plots, overlaid
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], ...
				'TRAP', 'o-', thefig, legends); 
% TRAP plots, overlaid
title(sprintf('BE and TRAP on %s', feval(DAE.daename,DAE)));
%}
