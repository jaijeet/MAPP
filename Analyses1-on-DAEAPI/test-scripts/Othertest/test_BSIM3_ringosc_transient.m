%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/05/sometime
% Test script for running transient analysis on a ring oscillator based on BSIM3 CMOS model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





DAE = BSIM3_ringosc;

% set DC and transient inputs for VDD
DAE = feval(DAE.set_uQSS, 'vdd:::E', 1.2, DAE);
DAE = feval(DAE.set_uQSS, 'iInj1:::I', 0, DAE);
const_func = @(t,args) 1.2;
zero_func = @(t, args) 0;
DAE = feval(DAE.set_utransient, 'vdd:::E', const_func, [], DAE);
DAE = feval(DAE.set_utransient, 'iInj1:::I', zero_func, [], DAE);
%DAE = feval(DAE.set_uHB, 'vdd:::E', const_func, [], DAE);
%DAE = feval(DAE.set_uHB, 'iInj1:::I', zero_func, [], DAE);

% run DC
qss = QSS(DAE);
qss = feval(qss.solve, qss);
feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);

outs = StateOutputs(DAE);
outs = feval(outs.DeleteAll, outs);
outs = feval(outs.Add, {'e_inv1', 'e_inv2', 'e_inv3'}, outs);


if 1 == 1
	% run transient and plot
	xinit = 0*DCsol;
	xinit = rand(size(DCsol));
	%tstart = 0; tstep = 0.4e-14; tstop =  7e-12; % takes a very long time
	%tstart = 0; tstep = 0.4e-14; tstop =  1e-13; % tstop too small to build up oscillations
	%tstart = 0; tstep = 1e-13; tstop =  7e-12; % still takes long
	%tstart = 0; tstep = 3e-9; tstop =  3e-7; % 4 or 5 cycles
	tstart = 0; tstep = 6e-9; tstop =  1e-7; % crude, but enough to test
	trans = run_transient_GEAR2(DAE, xinit, tstart, tstep, tstop);
	[thefig, legends] = feval(trans.plot, trans, outs);
	%
	% T from eyeballing the above is about 2e-12
	%
end %
