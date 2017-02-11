%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for doing a QSS and transient analysis on  vsrc-xgate-resistor circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





DAE = vsrc_xgate_resistor;

% inputs are: vinp, vgnd, EN, ENbar
DAE = feval(DAE.set_uQSS, [0.7; 0; 1.2; 0], DAE); % on
%DAE = set_uQSS([0.7; 0; 0; 1.2], DAE); % off

% run QSS
qss = QSS(DAE);
qss = feval(qss.solve, qss); 
outputs = StateOutputs(DAE);
feval(qss.print, outputs, qss)

return

% run transient
trans = LMS(DAE); trans = LMS(DAE,trans.TRAPparms);
tstart = 0; tstop = 20e-3; tstep = 10e-6;
initcond = [0.1;0.3;0.7];
trans = feval(trans.solve, trans, initcond, tstart, tstep, tstop);
feval(trans.plot, trans, outputs)
