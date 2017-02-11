function test = BJTDiffPair_cktnetlist_transient()

	% Author: Bichen Wu 
	% Date: 05/06/2014
	% Moved from run_BJTdiffpair_newnetlistformat_DCop_AC_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	DAE = MNA_EqnEngine(BJTdiffpair_ckt());
	DAE = feval(DAE.set_uQSS, 'Vin:::E', 0, DAE);
    test.DAE = DAE;
    test.name = 'BJTdiffpair_cktnetlist_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'BJTDiffPair_cktnetlist_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [ -0.5172; 3.0193; 3.0193; 5.0000; 0; -0.0020; -0.0000];


    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-5;        % Time step
    test.args.tstop = 5e-3;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    %test.args.comparisonAbstol = 1e-8;
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

