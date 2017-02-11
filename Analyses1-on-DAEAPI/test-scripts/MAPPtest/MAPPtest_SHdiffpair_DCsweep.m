function test = SHdiffpair_DCsweep()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from run_SHdiffpair_ckt_DCop_AC_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	DAE =  MNA_EqnEngine(SHdiffpair_ckt());
    test.DAE = DAE;
    test.name = 'SHdiffpair_DCsweep'; % Type of analysis
    test.analysis = 'DCsweep'; % Type of analysis
    test.refFile = 'SHdiffpair_DCsweep.mat';

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
    test.args.initGuess = [ -1.7142; 3.0000; 3.0000; 5.0000; 0; -0.0020; 0];

    test.args.QSSInputs = [5 0.2 2e-3; 5 0.1 2e-3; 5 0 2e-3; 5 -0.1 2e-3]; 

end

