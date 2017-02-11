function test = MAPPtest_charge_pump_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_STAEqnEngine_charge_pump_DC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 

	DAE = STA_EqnEngine(charge_pump_ckt());

    test.name='STA_charge_pump_transient';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'STA_charge_pump_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE

    % Simulation time-related parameters
    test.args.xinit = zeros(feval(DAE.nunks,DAE),1); % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 5e-10;        % Time step
    test.args.tstop = 1e-7;         % Stop time

    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % Update or testing/comparison
    %test1.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose

	tstep = 1e-9;
	args.ts = [tstep * 20, tstep * 21, tstep * 30, tstep*31, tstep * 50, tstep*51, tstep * 90, tstep * 91];
	args.vup = [2, 0, 0, 2, 2, 0, 0, 2];
	args.vdn = [0, 2, 2, 0, 0, 2, 2, 0];

	PWL_UP_func = @(t, args) PWL(args.ts,args.vup,t);
	PWL_DN_func = @(t, args) PWL(args.ts,args.vdn,t);
	DAE = feval(DAE.set_utransient, 'Vup:::E', PWL_UP_func, args, DAE);
	DAE = feval(DAE.set_utransient, 'Vdown:::E', PWL_DN_func, args, DAE);
    test.DAE =  DAE;

end
