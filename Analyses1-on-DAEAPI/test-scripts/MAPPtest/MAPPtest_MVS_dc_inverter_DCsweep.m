function test = MAPPtest_MVS_dc_inverter_DCsweep()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MVS_dc_inverter.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

	DAE =  MNA_EqnEngine(MVS_DC_inverter());
    test.DAE = DAE;
    test.name='MVS_dc_inverter_DCsweep';
    %MNAEqnEngine_vsrc_diode; test.DAE = DAE;
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'MVS_dc_interter_DCSweep.mat';

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
	Vin = 0:0.1:1; Vin = Vin';
	Vsup = ones(length(Vin),1);

    test.args.QSSInputs = [Vsup, Vin]; 
end
