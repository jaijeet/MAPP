function test = MAPPtest_inverter_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 1: BJT differential pair
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    test.DAE =  SH_CMOS_inverter_DAEAPIv6('SH_CMOS_inverter');
    test.name='SH_CMOS_inverter_transient';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'SH_CMOS_inverter.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    utargs.A = 0.5; utargs.offset = 0.5; utargs.f=2e2; utargs.phi=0; 
    utfunc = @(t, args) args.offset + args.A*cos(2*pi*args.f*t + args.phi);
    test.DAE = feval(test.DAE.set_utransient, utfunc, utargs, test.DAE); 

    % Simulation time-related parameters
    test.args.xinit = [0]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 10e-5;        % Time step
    test.args.tstop = 10e-2;         % Stop time

    % LMS method to be used
    test.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.NRparms.dbglvl = -1; % Only errors 
    % Update or testing/comparison
    %test1.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end
