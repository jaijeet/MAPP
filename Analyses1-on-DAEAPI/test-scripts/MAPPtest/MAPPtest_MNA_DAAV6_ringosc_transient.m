function test = MNA_DAAV6_ringosc_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MNAEqnEngine_DAAV6_ringosc_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	MNAEqnEngine_DAAV6_ringosc
    test.DAE = DAE;
    test.name = 'MNA_DAAV6_ringosc_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'MNA_DAAV6_ringosc_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [ 0.1493; 0.2575; 0.8407; 0.2543; 0.8143; 0.2435; 0.9293; ...
						0.3500; 0.1966; 0.2511; 0.6160; 0.4733; 0.3517; 0.8308; ...
						0.5853; 0.5497; 0.9172];



    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1.5e-13;        % Time step
    test.args.tstop = 8e-12;         % Stop time
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

