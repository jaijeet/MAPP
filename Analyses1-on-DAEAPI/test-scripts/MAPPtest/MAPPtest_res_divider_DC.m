function test = MAPPtest_res_divider_DC()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MNAEqnEngine_resistive_divider_DC_tran.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

	MNAEqnEngine_resistive_divider; % sets up DAE (DAEAPI script)
    test.DAE = DAE;
    test.name='res_divider_DC';
    %MNAEqnEngine_vsrc_diode; test.DAE = DAE;
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'res_divider_DC.mat';

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

    test.args.initGuess = [];

    test.args.QSSInputs = [1]; 
end
