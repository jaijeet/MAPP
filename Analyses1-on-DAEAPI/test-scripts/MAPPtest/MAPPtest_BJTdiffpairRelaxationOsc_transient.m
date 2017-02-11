function test5 = BJTDiffPairRelaxationOsc_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 5:BJT differential pair (Relaxation Oscillator) 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE
    test5.DAE = BJTdiffpairRelaxationOsc('BJTdiffpairRelaxationOsc');
    test5.name = 'BJTdiffpairRelaxationOsc: transient'; % Type of analysis
    test5.analysis = 'transient'; % Type of analysis
    test5.refFile = 'BJTDiffPairRelaxationOscTransient.mat';
    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    % Using default u_transient in the circuit DAE

    % Simulation time-related parameters
    test5.args.xinit = [3.05; 2.95; -0.5; -0.1];
    % [3; 3; -0.5]; % Initial condition
    test5.args.tstart = 0;           % Start time
    test5.args.tstep = 20e-5;        % Time step
    test5.args.tstop = 2e-1;         % Stop time
    % Transient simulation parameters
    test5.args.tranparms = defaultTranParms; % Transient simulation
    test5.args.tranparms.NRparms.limiting = 1; 
    test5.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test5.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test5.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test5.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end
