%author: J. Roychowdhury, 2012/05/01-08
% Test script to run DC and transient analysis on a voltage  source-divided circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
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






	MNAEqnEngine_resistive_divider; % sets up DAE (DAEAPI script)

	% set DC and transient inputs - now set above using element udata
	%{
	DAE = feval(DAE.set_uQSS, 'v1:::E', 1, DAE);
	utargs.A = 1; utargs.f=1e3; utargs.phi=0;
	utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
	DAE = feval(DAE.set_utransient, 'v1:::E', utfunc, utargs, DAE);
	%}

	% run DC
	qss = QSS(DAE);
	qss = feval(qss.solve, qss);
	feval(qss.print, qss);

	% run transient

	% set up LMS object
	TransObjBE = LMS(DAE); % default method is BE, 
	TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
	LMStranparms = TransObjBE.tranparms; % has, eg, tranparms.NRparms
	TRmethods = LMSmethods(); % defines FE, BE, TRAP, GEAR2 and 
	TransObjTRAP = LMS(DAE, TRmethods.TRAP, LMStranparms);

	% run transient and plot
	xinit = zeros(feval(DAE.nunks,DAE),1);
	tstart = 0;
	tstep = 10e-6;
	tstop = 5e-3;
	TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
	      xinit, tstart, tstep, tstop);
	[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);
	%feval(TransObjTRAP.plot, TransObjTRAP);
