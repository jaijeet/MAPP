function test = MAPPtest_fullWaveRectifier_DAEAPIv6_AC()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from run_fullWaveRectifier_AC.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
    test.DAE = fullWaveRectifier_DAEAPIv6('fullWaveRectifier');
	test.name = 'fullWaveRectifierAC';  
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'fullWaveRectifierAC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE
    Ufargs.string = 'no args used'; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    udcop = [0.1];
    test.DAE = feval(test.DAE.set_uQSS, udcop, test.DAE);
    test.DAE = feval(test.DAE.set_uLTISSS, Uffunc, Ufargs, test.DAE);

    % Simulation-related parameters
    test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e5; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
    test.name='fullWaveRectifier_AC'; 
end
