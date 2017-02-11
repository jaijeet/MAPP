function test = MAPPtest_BJTdiffpair_DAEAPIv6_AC
    % Circuit DAE. 
    test.DAE =  BJTdiffpair_DAEAPIv6('BJTdiffpair_DAEAPIv6');
    test.name='BJTdiffpair_DAEAPIv6: AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'BJTDiffPairAC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE
    udcop = [0.2];
    test.DAE = feval(test.DAE.set_uQSS, udcop, test.DAE);
    Ufargs.string = 'no args used'; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    test.DAE = feval(test.DAE.set_uLTISSS, Uffunc, Ufargs, test.DAE);

    % Simulation-related parameters
    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess=[3;3;-0.7;0];
    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e5; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
