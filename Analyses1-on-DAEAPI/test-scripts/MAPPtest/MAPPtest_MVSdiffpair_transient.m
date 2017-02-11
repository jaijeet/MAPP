function test = MVS_diffpair_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MVS_diffpair_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	DAE = MNA_EqnEngine(MVS_diffpair());
	args.f = 1000;
	args.A = 0.5;
	sinfunc = @(t, args) args.A*sin(args.f*2*pi*t);
	DAE = feval(DAE.set_utransient, 'Vin:::E', sinfunc, args, DAE);
	DAE = feval(DAE.set_utransient, 'vdd:::E', @(t,a) 5, [], DAE);
	DAE = feval(DAE.set_utransient, 'IS:::I', @(t,a) 2e-3, [], DAE);

	DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'IS:::I', 2e-3, DAE);
	DAE = feval(DAE.set_uQSS, 'Vin:::E', 0, DAE);

    test.DAE = DAE;
    test.name = 'MVSdiffpair_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'MVSdiffpair_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [ 5.0000; 3.0000; 3.0000; -0.8220; 0; -0.0020; 0; ... 
						3.7220; 0.1000; 3.7220; 0.1000;];


    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 2e-5;        % Time step
    test.args.tstop = 5e-3;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

