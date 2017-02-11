function test = LTE_MNA_vsrcRC_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from LTEtest_MNAEqnEngine_vsrcRC_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	MNAEqnEngine_vsrcRC; % sets up DAE (a DAEAPI script)
	utargs.A = 1; utargs.delay = 0.5e-3;
	utfunc = @(t, args) args.A*(t>=args.delay);
	DAE = feval(DAE.set_utransient, 'v1:::E', utfunc, utargs, DAE);


    test.DAE = DAE;
    test.name = 'LTE_MNA_vsrcRC_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'LTE_MNA_vsrcRC_tran.mat';

    % Simulation time-related parameters
	xinit = zeros(feval(DAE.nunks,DAE),1);
    test.args.xinit = xinit;


    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-5;        % Time step
    test.args.tstop = 5e-3;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    test.args.tranparms.LTEstepControlParms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

