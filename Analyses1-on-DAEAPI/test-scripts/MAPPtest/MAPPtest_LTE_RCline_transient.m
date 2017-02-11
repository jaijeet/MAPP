function test = LTE_RCline_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from LTEtest_RCline_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	nsegs = 3; R = 1000; C = 1e-6;
	DAE =  RClineDAEAPIv6('somename',nsegs, R, C);

	utargs.A = 1; utargs.f=1e3; utargs.phi=0; 
	utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
	DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

    test.DAE = DAE;
    test.name = 'LTE_RCline_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'LTE_RCline_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = zeros(nsegs,1);



    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 2e-4;        % Time step
    test.args.tstop = 1e-2;         % Stop time
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

