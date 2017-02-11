function test = MAPPtest_SH_PMOS_curves_DCsweep()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

	DAE =  MNA_EqnEngine(SH_PMOS_char_curves_ckt());
    test.DAE = DAE;
    test.name='SH_PMOS_curves_DCsweep';
    %MNAEqnEngine_vsrc_diode; test.DAE = DAE;
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'SH_PMOS_curves_DCSweep.mat';

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

    test.args.QSSInputs = [-1.2 0.8; -0.8 0.8; -0.4 0.8; 0 0.8; 0.4 0.8; 0.8 0.8; 1.2 0.8;];
end
