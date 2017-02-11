function test = MAPPtest_SHdiffpair_AC

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from run_SHdiffpair_ckt_DCop_AC_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	DAE =  MNA_EqnEngine(SHdiffpair_ckt());
    udcop = [0.2];
	DAE = feval(DAE.set_uQSS, 'Vin:::E', udcop, DAE);
    test.DAE = DAE;
    test.name='SHdiffpair_AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'SHdiffpair_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE

    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess=[ -1.7142; 3.0000; 3.0000; 5.0000; 0; -0.0020; 0];

    % Simulation-related parameters
    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e5; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
