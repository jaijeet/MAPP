function test = STA_vsrcRCL_DC()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_STAEqnEngine_vsrcRCL_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	STAEqnEngine_vsrcRCL; % sets up DAE (a DAEAPI script)
	DAE = feval(DAE.set_uQSS, 'v1:::E', 1, DAE);
    test.DAE = DAE;
    test.name = 'STA_vsrcRCL_DC'; % Type of analysis
    test.analysis = 'DCsweep'; % Type of analysis
    test.refFile = 'STA_vsrcRCL_DC.mat';

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

    test.args.QSSInputs = [];

end

