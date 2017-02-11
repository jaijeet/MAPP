function test9 =  MAPPtest_RClineDAEAPIv6_AC()
    nsegs = 3; R = 1000; C = 1e-6;
    test9.DAE =  RClineDAEAPIv6('RCLineDAEAPIv6', nsegs, R, C); 
    test9.name = 'RCLineDAEAPIv6:AC'; % Type of analysis
    test9.analysis = 'AC'; % Type of analysis
    test9.refFile = 'RCLineAC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE
    Ufargs.string = 'no args used'; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    udcop = [0];
    test9.DAE = feval(test9.DAE.set_uQSS, udcop, test9.DAE);
    test9.DAE = feval(test9.DAE.set_uLTISSS, Uffunc, Ufargs, test9.DAE);

    % Simulation-related parameters
    test9.args.initGuess=feval(test9.DAE.NRinitGuess, udcop, test9.DAE);
    test9.args.sweeptype = 'DEC'; % Sweeptype 
    test9.args.fstart = 1; % Start frequency
    test9.args.fstop = 1e5; % Stop frequency 
    test9.args.nsteps = 10; % No. of steps
end
