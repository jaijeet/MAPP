function test = MAPPtest_vsrcRCL_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 1: BJT differential pair
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    MNAEqnEngine_vsrcRCL;
    test.DAE =  DAE;
    test.name='vsrcRCL_transient';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'vsrcRCL_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE

    % Simulation time-related parameters
    test.args.xinit = zeros(feval(DAE.nunks,DAE),1); % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 10e-6;        % Time step
    test.args.tstop = 5e-3;         % Stop time

    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % Update or testing/comparison
    %test1.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end
