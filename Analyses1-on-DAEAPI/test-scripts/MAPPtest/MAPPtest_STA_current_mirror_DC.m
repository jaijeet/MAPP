function test = MAPPtest_current_mirror_DCsweep()

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
	%% for this software.                                                          %
	%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
	%% reserved.                                                                   %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	test.DAE =  STA_EqnEngine(current_mirror_ckt());
	test.name = 'STA_current_mirror_QSS';
	test.analysis = 'DCSweep';
	test.refFile = 'STA_current_mirror_DC.mat';
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
	
	n = feval(test.DAE.nunks, test.DAE);
	initguess = -ones(n,1);
	test.args.initGuess = initguess;
	
	test.args.QSSInputs = [];

end
