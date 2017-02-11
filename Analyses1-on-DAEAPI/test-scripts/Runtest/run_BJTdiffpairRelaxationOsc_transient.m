%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script to run transient analysis on a Relaxation Oscillator based  on BJT differential pair
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% set up DAE
DAE =  BJTdiffpairRelaxationOsc('BJTdiffpairRelaxationOsc');

% set up LMS object
TRmethods = LMSmethods();
TRparms = defaultTranParms();
TRparms.NRparms.limiting = 1;
TRparms.stepControlParms.doStepControl = 1;
TRparms.LTEstepControlParms.trreltol = 5e-3;  % relative error spec for LTE control
%TransObjTRAP = LMS(DAE, TRmethods.TRAP, TRparms); TRAP shows DAE oscillatory artifacts at eE 
	% and makes convergence/timestepping difficult - excellent example
TransObjTRAP = LMS(DAE, TRmethods.GEAR2, TRparms);

% run transient and plot
xinit = [3.05; 2.95; -0.5; -0.1]; %
%xinit = zeros(feval(DAE.nunks,DAE),1); breaks both BE and TRAP
tstart = 0;
%tstep = 10e-6; tstop = 5e-3;
%tstep = 10e-5; tstop = 5e-2;
tstep = 20e-4; tstop = 2e-1;
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
      xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);
souts = StateOutputs(DAE);

[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, souts);
