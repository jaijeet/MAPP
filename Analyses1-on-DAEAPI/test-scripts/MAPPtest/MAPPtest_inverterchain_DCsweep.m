function test = MAPPtest_inverterchain_DCsweep()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from run_inverterchain_DCsweep.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	nstages = 10;
	VDD = 1.2;
	betaN = 1e-3;
	betaP = 1e-3;
	VTN = 0.25;
	VTP = 0.25;
	RDSN = 5000;
	RDSP = 5000;
	CL = 1e-6;
	
	DAE = inverterchain('somename', nstages, VDD, betaN, betaP, VTN, VTP, RDSN, RDSP, CL); % API v6.2
	


    test.DAE = DAE;
    test.name='inverterchain_DCsweep';
    %MNAEqnEngine_vsrc_diode; test.DAE = DAE;
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'inverterchain_DCSweep.mat';

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

	nunks = feval(DAE.nunks, DAE);
    test.args.initGuess = zeros(nunks,1);

	N = 200;
	Vins = (0:N)/N*1.2;
    test.args.QSSInputs = Vins'; 
end
