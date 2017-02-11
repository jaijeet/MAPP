function test4 = MAPPtest_fullWaveRectifier_DAEAPIv6_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 4: FullWave Rectifier
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    test4.DAE = fullWaveRectifier_DAEAPIv6('fullWaveRectifier_DAEAPIv6'); 
    test4.name = 'fullWaveRectifier_DAEAPIv6: transient';
    test4.analysis = 'transient'; % Type of analysis
    test4.refFile = 'fullWaveRectifierTransient.mat';
    % If the analysis is transient, then setup the u_transient of the
    % circuit DAEconst_func = @(t,args) 1.2;% set transient input to the DAE
    utargs.A = 10; utargs.f=1e3; utargs.phi=0; 
    utfunc = @(t, args) args.A*cos(2*pi*args.f*t + args.phi);
    test4.DAE = feval(test4.DAE.set_utransient, utfunc, utargs, test4.DAE);

    % Simulation time-related parameters
    test4.args.xinit = feval(test4.DAE.QSSinitGuess,utargs.A,test4.DAE);
    % [3; 3; -0.5]; % Initial condition
    test4.args.tstart = 0;           % Start time
    test4.args.tstep = 10e-7;        % Time step
    test4.args.tstop = 5e-2;         % Stop time
    % Transient simulation parameters
    test4.args.tranparms = defaultTranParms; % Transient simulation
    test4.args.tranparms.NRparms.limiting = 1; 
    % Any changes to default tranparms setting
    test4.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test4.args.LMSMethod = 'BE'; % {'BE','FE','TRAP','GEAR2'}

    % Update or testing/comparison
    %test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end
