%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running steady state and  transient analysis on a 3-stage ring oscillator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






DAE = threeStageRingOsc;

% run QSS
qss = QSS(DAE);
qss = feval(qss.solve, qss);
outputs = StateOutputs(DAE);
feval(qss.print, outputs, qss)


% run transient
trans = LMS(DAE); trans = LMS(DAE,trans.TRAPparms);
tstart = 0; tstop = 20e-3; tstep = 10e-6;
initcond = [0.1;0.3;0.7];
trans = feval(trans.solve, trans, initcond, tstart, tstep, tstop);
[a,b,c]= feval(trans.plot, trans, outputs)
