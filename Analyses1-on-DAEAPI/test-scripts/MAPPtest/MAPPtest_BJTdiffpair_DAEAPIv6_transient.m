function test1 = MAPPtest_BJTdiffpair_DAEAPIv6_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 1: BJT differential pair
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    test1.DAE =  BJTdiffpair_DAEAPIv6('BJTdiffpair_DAEAPIv6');
    test1.name='BJTdiffpair_DAEAPIv6: transient';
    test1.analysis = 'transient'; % Type of analysis
    test1.refFile = 'BJTDifferentialPairTransient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    utargs.A = 0.2; utargs.f=1e2; utargs.phi=0; 
    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    test1.DAE = feval(test1.DAE.set_utransient, utfunc, utargs, test1.DAE); 

    % Simulation time-related parameters
    test1.args.xinit = [3; 3; -0.5; 0]; % Initial condition
    test1.args.tstart = 0;           % Start time
    test1.args.tstep = 10e-5;        % Time step
    test1.args.tstop = 5e-2;         % Stop time

    % LMS method to be used
    test1.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test1.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test1.args.tranparms.trandbglvl = -1; % Only errors 
    % Update or testing/comparison
    %test1.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end
