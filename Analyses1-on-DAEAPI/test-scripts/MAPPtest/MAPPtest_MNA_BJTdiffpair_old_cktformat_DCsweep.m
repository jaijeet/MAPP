function test = MAPPtest_MNAEqnEngine_BJTdiffpair_old_cktformat_DCsweep()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MNAEqnEngine_BJTdiffpair_DCsweep_dumb.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	MNAEqnEngine_BJTdiffpair;
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'ie:::I', 2e-3, DAE);
    test.DAE = DAE;
    test.name='MNAEqnEngine_BJTdiffpair_old_cktformat_DCsweep';
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'MNAEqnEngine_BJTDiffPair_old_cktformat_DCSweep.mat';

	test.args.initGuess = [5; 5; -0.7; -0.7; -0.2; 0; 0];
	N = 20;
	Vins = -0.2 + (0:N)/N*0.4; Vins = Vins';
	Vdd = 5*ones(N+1,1);
	Is = 2e-3*ones(N+1,1);
    test.args.QSSInputs = [Vdd, Vins, Is];


    % Simulation time-related parameters
    test.args.NRparms = defaultNRparms();
    test.args.NRparms.maxiter = 100;
    test.args.NRparms.reltol = 1e-5;
    test.args.NRparms.abstol = 1e-10;
    test.args.NRparms.residualtol = 1e-10;
    test.args.NRparms.limiting = 0;
    test.args.NRparms.dbglvl = 0; % minimal output

    test.args.comparisonAbstol = 1e-9;
    test.args.comparisonReltol = 1e-3;

end
