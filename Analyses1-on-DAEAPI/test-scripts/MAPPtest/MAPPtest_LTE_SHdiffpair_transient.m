function test = LTE_SHdiffpair_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from LTEtest_SHdiffpair_ckt_DCop_AC_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Circuit DAE
	DAE =  MNA_EqnEngine(SHdiffpair_ckt());
	DAE.doLTE=1;
	DAE = feval(DAE.set_uQSS, 'Vin:::E', 0, DAE);


    test.DAE = DAE;
    test.name = 'LTE_SHdiffpair_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'LTE_SHdiffpair_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [ -1.7142; 3.0000; 3.0000; 5.0000; 0; -0.0020; 0];




    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-4;        % Time step
    test.args.tstop = 2e-3;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    test.args.tranparms.LTEstepControlParms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

