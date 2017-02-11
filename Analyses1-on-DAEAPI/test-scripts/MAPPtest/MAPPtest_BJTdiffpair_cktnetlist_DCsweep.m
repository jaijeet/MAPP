function test = MAPPtest_BJTdiffpair_cktnetlist_DCsweep()

    %Changelog:
    %- 2015/01/14: JR: updated QSSInputs to a sensible sweep. Previously,
    %              there was a -ve IEE, which led to millions of volts; even
    %              otherwise, IEE 100 and 200mA, instead of 2mA. Who did that?
	% Author: Bichen Wu 
	% Date: 05/06/2014
	% Moved from run_BJTdiffpair_newnetlistformat_DCop_AC_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	DAE =  MNA_EqnEngine(BJTdiffpair_ckt());
    test.DAE = DAE;
    test.name='BJTdiffpair_cktnetlist_DCsweep';
    %MNAEqnEngine_vsrc_diode; test.DAE = DAE;
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'BJTDiffPair_cktnetlist_DCSweep.mat';

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

    test.args.initGuess = [ -0.3345; 1.1445; 4.8941; 5.0000; 0.2000; -0.0020; -0.0000];

    %test.args.QSSInputs = [5 0 0.2; 5 0 0.1; 5 0 0; 5 0 -0.1]; 
    inputvals = feval(DAE.uQSS, DAE);
    Vins = ((0:25)/25)*0.4 - 0.2; % -0.2 to 0.2, 26 points.
    QSSInputs = inputvals * ones(1, length(Vins));
    VinIdx = feval(DAE.inputidx, 'Vin:::E', DAE);
    QSSInputs(VinIdx, :) = Vins;
    test.args.QSSInputs = QSSInputs';
end
