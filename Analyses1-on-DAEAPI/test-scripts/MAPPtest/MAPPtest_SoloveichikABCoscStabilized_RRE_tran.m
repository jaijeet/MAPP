function test = SoloveichikABCoscStabilized_RRE_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_SoloveichikABCoscStabilized_RRE_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	DAE = Soloveichik_ABC_oscillator_stabilized();
    test.DAE = DAE;
    test.name = 'SoloveichikABcoscStabilized_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'SoloveichikABcoscStabilized_tran.mat';

    % Simulation time-related parameters
	concX = 1.2;
		      % [0.1,2) work
		      % - the "best" oscillations are in the range 1-2
		      % - 0.5 and below give really weird shapes
		      % 2 might be the threshold of instability
		      % 2.5, 3 are interesting: the oscillations keep growing
		      % 10 does not work!
	xinit(4,1) = concX; %
	
	golden = [0.91;0.86;0.882];
	golden2 = [1.2; 1; 1];
	golden3 = [1.6;0.5;0.4;concX];
	xinit = golden3 + [0.1;-0.1;0.3;0];

    test.args.xinit = xinit;



    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 0.055;        % Time step
    test.args.tstop = 80;         % Stop time
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

