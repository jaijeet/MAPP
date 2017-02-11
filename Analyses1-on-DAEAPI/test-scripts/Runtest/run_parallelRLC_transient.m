%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2009/sometime
% Test script for running transient analysis for a parallel RLC circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% "Read in" the DAE
DAE = parallelRLC('||RLC'); 
% resonant freq	is f0 = 1/(1/(2*pi*sqrt(L*C))) = 5.032921210448704e+06
% R is 10000

% set input
utfunc = @(t,args) args.A*sin(2*pi*args.f*t);
utargs.A = 1e-4; % small
utargs.f = 5e6; % very close to resonant freq
DAE = set_utransient(utfunc, utargs, DAE);

% set initial conditions for transient
xinit = [0;0];

% create transient analysis object for TRAP
TRmethods = LMSmethods();
tranparms = defaultTranParms();
tranparms.stepControlParms.doStepControl = 0; % uniform timesteps only.
tranparms.trandbglvl = 1; 
TransObjTRAP = LMS(DAE, TRmethods.TRAP, tranparms); 


% run timestepping using transient objects
tstart = 0; tstop = 100e-6;  tstep = 1.5e-9; 

TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, xinit, ...
			tstart, tstep, tstop);

% plot waveforms
% TRAP plots, overlaid
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], ...
			'TRAP', 'ko-'); 
title('TRAP on parallelRLC');
