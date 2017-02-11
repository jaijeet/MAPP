function test = MAPPtest_STA_vsrcRCL_tran

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_STAEqnEngine_vsrcRCL_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	STAEqnEngine_vsrcRCL; % sets up DAE (a DAEAPI script)
	% set step transient input
	utargs.A = 1; utargs.delay = 0.5e-3;
	utfunc = @(t, args) args.A*(t>=args.delay);
	DAE = feval(DAE.set_utransient, 'v1:::E', utfunc, utargs, DAE);

    test.DAE = DAE;
	 test.name='STA_vsrcRCL_tran';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'STA_vsrcRCL_tran.mat';

    % Simulation time-related parameters
	xinit = zeros(DAE.nunks(DAE),1);
    test.args.xinit = xinit;


    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-5;        % Time step
    test.args.tstop = 2e-3;         % Stop time
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




