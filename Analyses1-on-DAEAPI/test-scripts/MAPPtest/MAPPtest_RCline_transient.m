function test1 = MAPPtest_RCline_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 1: BJT differential pair
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    nsegs = 3; R = 1000; C = 1e-6;
    DAE =  RClineDAEAPIv6('RCline_transient',nsegs, R, C);
    test1.DAE = DAE; 
    test1.name='RCline_transient';
    test1.analysis = 'transient'; % Type of analysis
    test1.refFile = 'RCline_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    utargs.A = 1; utargs.f=1e3; utargs.phi=0; 
    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    test1.DAE = feval(test1.DAE.set_utransient, utfunc, utargs, test1.DAE); 

    % Simulation time-related parameters
    test1.args.xinit = zeros(nsegs,1); % Initial condition
    test1.args.tstart = 0;           % Start time
    test1.args.tstep = 10e-6;        % Time step
    test1.args.tstop = 10e-3;         % Stop time

    % LMS method to be used
    test1.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test1.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test1.args.tranparms.trandbglvl = -1; % Only errors 
    test1.args.tranparms.NRparms.limiting = 1; % Only errors 
    % Update or testing/comparison
    %test1.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end
