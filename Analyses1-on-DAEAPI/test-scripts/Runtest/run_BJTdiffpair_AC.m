%
% Test script to run AC analysis on a BJT differential pair
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%% set up DAE and state outputs
DAE = BJTdiffpair_DAEAPIv6('diffpair');
stateoutputs = StateOutputs(DAE);

for Vin = [-0.1 0 0.2] % 3 different DC op pts
	%%%%% compute QSS (DC) solution
	DAE = feval(DAE.set_uQSS, Vin, DAE);
	qss = QSS(DAE);
	% initguess = feval(DAE.NRinitGuess, Vin, DAE);
	initguess = [3;3;-0.7;0];
	qss = feval(qss.solve, initguess, qss);
	% feval(qss.print, stateoutputs, qss);
	qssSol = feval(qss.getSolution, qss);

	%%%%% LTISSS analysis
	% set AC analysis input as a function of frequency
	Ufargs.string = 'no args used'; % 
	Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
	DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);

	% AC analysis @ DC operating point
	ltisss = LTISSS(DAE,qssSol,Vin);
	ltisss.DAEname = sprintf('%s with Vin=%g', ltisss.DAEname, Vin); % sets plot title string properly
	sweeptype = 'DEC'; fstart=1; fstop=1e5; nsteps=10;
	ltisss = feval(ltisss.solve, fstart, fstop, nsteps, sweeptype, ltisss);
	%feval(ltisss.print, outputs, ltisss);
	%
	% plot frequency sweeps of system outputs (overlay all on 1 plot)
	feval(ltisss.plot, ltisss);
	% plot frequency sweeps of state variable outputs (overlay on 1 plot)
	%feval(ltisss.plot, ltisss, stateoutputs);
end
