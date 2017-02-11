function test = MAPPtest_MVSdiffpair_DCsweep()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MVS_diffpair_DC_AC_tran.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

	DAE =  MNA_EqnEngine(MVS_diffpair());
	DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'IS:::I', 2e-3, DAE);
    test.DAE = DAE;
    test.name='MVSdiffpair_DCsweep';
    %MNAEqnEngine_vsrc_diode; test.DAE = DAE;
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'MVSdiffpair_DCSweep.mat';

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

    test.args.initGuess = [5; 3; 3; -0.7; 0.1; -2e-3; 0; 3.7; 0.1; 3.7; 0.1];

	N = 20;
	VinMAX = 1;
	Vins = VinMAX*((0:N)/N*2 - 1); Vins = Vins';
	VCC = 5*ones(length(Vins),1);
	IE = 2e-3*ones(length(Vins),1);



    test.args.QSSInputs = [VCC, Vins, IE]; 
end
