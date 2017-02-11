function test = MAPPtest_BJTdiffpair_cktnetlist_AC

	% Author: Bichen Wu 
	% Date: 05/06/2014
	% Moved from run_BJTdiffpair_newnetlistformat_DCop_AC_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	DAE =  MNA_EqnEngine(BJTdiffpair_ckt());
    udcop = [0.2];
	DAE = feval(DAE.set_uQSS, 'Vin:::E', udcop, DAE);
    test.DAE = DAE;
    test.name='BJTdiffpair_cktetlist_AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'BJTDiffPair_cktnetslit_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE

    % Simulation-related parameters
    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess=[ -0.3345; 1.1445; 4.8941; 5.0000; 0.2000; -0.0020; -0.0000;];

    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e5; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
