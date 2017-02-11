%author: J. Roychowdhury, 2012/05/21
% Test script to run a transient on a 3 stage ring oscillator made with DAAv6 MOSFETs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	run a transient on a 3 stage ring oscillator made with DAAv6 MOSFETs
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






MNAEqnEngine_DAAV6_ringosc; % sets up DAE (a DAEAPI script)

% set DC and transient inputs for VDD - now done via element
% in circuitdata
%{ 
DAE = feval(DAE.set_uQSS, 'vdd:::E', 1.2, DAE);
const_func = @(t,args) 1.2;
DAE = feval(DAE.set_utransient, 'vdd:::E', const_func, [], DAE);
%}

% run DC
qss = QSS(DAE);
qss = feval(qss.solve, qss);
%feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);

% run transient

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, 
LMStranparms = TransObjBE.tranparms; % has, eg, tranparms.NRparms
TRmethods = LMSmethods(); % defines FE, BE, TRAP, GEAR2 and 
TransObjGEAR2 = LMS(DAE, TRmethods.GEAR2, LMStranparms);

% run transient and plot
xinit = 0*DCsol;
xinit = rand(size(DCsol));
%tstart = 0; tstep = 0.4e-14; tstop =  7e-12; % takes a very long time
%tstart = 0; tstep = 0.4e-14; tstop =  1e-13; % tstop too small to build up oscillations
%tstart = 0; tstep = 1e-13; tstop =  7e-12; % still takes long
tstart = 0; tstep = 1.5e-13; tstop =  3e-12; % crude, but enough to test
TransObjGEAR2 = feval(TransObjGEAR2.solve, TransObjGEAR2, ...
      xinit, tstart, tstep, tstop);

outs = StateOutputs(DAE);
outs = feval(outs.DeleteAll, outs);
outs = feval(outs.Add, {'e_inv1', 'e_inv2', 'e_inv3'}, outs);


[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2, outs);
drawnow;

