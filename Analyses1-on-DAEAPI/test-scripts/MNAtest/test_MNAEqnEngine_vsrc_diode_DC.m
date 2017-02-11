%author: J. Roychowdhury, 2012/05/01-08
% Test script to run DC, AC and transient analysis on a Vsrc-diode circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	- vsrc-diode
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






	MNAEqnEngine_vsrc_diode; % sets up DAE (DAEAPI script)
	stateoutputs = StateOutputs(DAE); % all MNA unknowns
	% set DC input - now done using element udata
	%{
	DAE = feval(DAE.set_uQSS, 'v1:::E', 1, DAE);
	%}

	% run DC
	NRparms = defaultNRparms;
	NRparms.init = 1;
	NRparms.limiting = 1;
	%NRparms.method = 0;
	NRparms.dbglvl = 2;
	qss = QSS(DAE, NRparms);
	xguess = [1; 0; 0.6];
	qss = feval(qss.solve, xguess, qss);
	feval(qss.print, qss);

