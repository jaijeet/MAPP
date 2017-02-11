function test = MAPPtest_tworeactionchain_wrapper_tran()

	DAE = TwoReactionChainDAEAPI_wrapper(); 
    test.DAE = DAE; 
    test.name='TwoReactionChain_wrapper_transient';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'TwoReactionChain_wrapper_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE

    % Simulation time-related parameters
	xinit = [0.9; 0.8; 0.7; 0.6; 0.5];
    test.args.xinit = xinit; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 0.05;        % Time step
    test.args.tstop = 6;         % Stop time

    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    test.args.tranparms.NRparms.limiting = 1; % Only errors
end
