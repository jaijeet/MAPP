function test = MAPPtest_MVSdiffpair_AC

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MVS_diffpair_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Circuit DAE. 
	DAE =  MNA_EqnEngine(MVS_diffpair());
	constfunc = @(f, args) 1;
	DAE = feval(DAE.set_uLTISSS, 'Vin:::E', constfunc, [], DAE);
	DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'IS:::I', 2e-3, DAE);

    test.DAE = DAE;
    test.name='MVSdiffpair_AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'MVSdiffpair_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE

    % Simulation-related parameters
    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess=[];


    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e12; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
