function test =  MAPPtest_RCline_wrapper_AC()
    test.DAE =  RCline_wrapper(); 
    test.name = 'RCLine_wrapper_AC'; % Type of analysis
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'RCLine_wrapper_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE
    Ufargs.string = 'no args used'; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    udcop = [0];
    test.DAE = feval(test.DAE.set_uQSS, udcop, test.DAE);
    test.DAE = feval(test.DAE.set_uLTISSS, Uffunc, Ufargs, test.DAE);

    % Simulation-related parameters
    test.args.initGuess=feval(test.DAE.NRinitGuess, udcop, test.DAE);
    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e5; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
