function test = AtoB_RRE_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_AtoB_RRE_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	DAE =  AtoB_RRE();

    test.DAE = DAE;
    test.name = 'AtoB_RRE_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'AtoB_RRE_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [0.2581;0.4087];

    test.args.tstart = 0;           % Start time
    test.args.tstep = 0.05;        % Time step
    test.args.tstop = 10;         % Stop time
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

