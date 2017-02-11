function test = LTE_inverter_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from LTEtest_inverter_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	DAE =  SH_CMOS_inverter_DAEAPIv6('somename');
	utargs.A = 0.5; utargs.offset = 0.5; utargs.f=2e2; utargs.phi=0; 
	utfunc = @(t, args) args.offset + args.A*cos(2*pi*args.f*t + args.phi);
	DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);


    test.DAE = DAE;
    test.name = 'LTE_inverter_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'LTE_inverter_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [0];



    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-4;        % Time step
    test.args.tstop = 1e-1;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    test.args.tranparms.LTEstepControlParms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

