function test = MAPPtest_coupledRCdiodeSpringMasses_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from run_coupledRCdiodeSpringsMasses_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	DAE = coupledRCdiodeSpringsMasses('the-system');
	DAE = feval(DAE.set_uQSS, 0, DAE);
	utargs.A = 0.5; utargs.f=2.5; utargs.phi=pi; 
	utfunc = @(t, args) (1+args.A*sin(2*pi*args.f*t + args.phi)).*((t > 0) & (t < 5));
	DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

    test.DAE = DAE;
    test.name = 'coupledRCdiodeSpringMasses_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'coupledRCdiodeSpringMasses_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [ 0; 0; 0; 0.1000; 0; 0.1500; 0];



    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 5e-3;        % Time step
    test.args.tstop = 20;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'BE'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

