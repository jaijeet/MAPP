function test = STA_vsrcRC_DC()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_STAEqnEngine_vsrcRC_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	STAEqnEngine_vsrcRC; % sets up DAE (a DAEAPI script)

    test.DAE = DAE;
    test.name = 'STA_vsrc_RC_DC'; % Type of analysis
    test.analysis = 'DCsweep'; % Type of analysis
    test.refFile = 'STA_vsrcRC_DC.mat';

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

