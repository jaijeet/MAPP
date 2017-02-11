function test = Tworeactionchain_transient()
	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from run_tworeactionchain_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Circuit DAE
	DAE =  TwoReactionChainDAEAPIv6_2('somename');
    test.DAE = DAE;
    test.name = 'tworeactionchain_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'tworeactionchain_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [0.9; 0.8; 0.7; 0.6; 0.5];


    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 0.05;        % Time step
    test.args.tstop = 6;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

