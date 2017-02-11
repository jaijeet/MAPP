function test = resVsrcDiodeRLC_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from run_resVsrcDiodeRLC_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	DAE = res_vsrc_diode_RLC('res_vsrc_diode_RLC'); 
	mypulse = @(t,args) 5*pulse(t/5e-6, 0.001, 0.01, 0.15, 0.16);
	args = [];
	DAE = feval(DAE.set_utransient, mypulse, args, DAE);

    test.DAE = DAE;
    test.name = 'res_vsrc_diode_RLC_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'res_vsrc_diode_RLC_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [ 0;0;0;0;0];


    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1.5e-9;        % Time step
    test.args.tstop = 2e-6;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 0;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

