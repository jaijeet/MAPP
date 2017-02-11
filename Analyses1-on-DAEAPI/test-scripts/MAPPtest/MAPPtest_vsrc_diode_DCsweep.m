function test = MAPPtest_vsrc_diode_DCsweep()

	% Test script to run DC sweep on a BJT differential pair
	%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
	%% for this software.                                                          %
	%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
	%% reserved.                                                                   %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	MNAEqnEngine_vsrc_diode; % sets up DAE (DAEAPI script)
	test.DAE = DAE;% v6.2
	test.name = 'vsrc_diode';
	test.analysis = 'DCSweep';
	test.refFile = 'vsrc_diode.mat';
	
	NRparms = defaultNRparms();
	NRparms.maxiter = 100;
	NRparms.reltol = 1e-5;
	NRparms.abstol = 1e-10;
	NRparms.residualtol = 1e-10;
	NRparms.limiting = 0;
	NRparms.dbglvl = 0; % minimal output
	test.args.NRparms = NRparms;
	
	test.args.comparisonAbstol = 1e-9;
	test.args.comparisonReltol = 1e-3;
	
	test.args.initGuess = [1; 0; 0.6];
	
	test.args.QSSInputs = (0:20).'/20;
end
