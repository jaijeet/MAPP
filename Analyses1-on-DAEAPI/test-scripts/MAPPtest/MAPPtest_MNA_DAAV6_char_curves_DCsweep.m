function test = MAPPtest_MNA_DAAV6_char_curves_DCsweep()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MNAEqnEngine_DAAV6_char_curves.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	MNAEqnEngine_DAAV6_P_N_devices; % DAEAPI script that sets up DAE
	% set DC inputs
    test.DAE = DAE;
    test.name='MNA_DAAV6_char_curves_DCsweep';
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'MNA_DAAV6_char_curves_DCsweep.mat';

	test.args.initGuess = [];

	VDSs = 0:0.05:1.2; VDSs = VDSs';
	VGSs = 0.5*ones(length(VDSs),1);
    test.args.QSSInputs = [VDSs, VDSs, VGSs, VGSs];


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
