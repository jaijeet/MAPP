function test = MAPPtest_resistive_divider_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 1: BJT differential pair
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    MNAEqnEngine_resistive_divider; % sets up DAE (DAEAPI script)
    test.DAE = DAE;
    test.name='resistive_divider_transient';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'resistive_divider_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    %utargs.A = 0.5; utargs.offset = 0.5; utargs.f=2e2; utargs.phi=0; 
    %utfunc = @(t, args) args.offset + args.A*cos(2*pi*args.f*t + args.phi);
    %test.DAE = feval(test.DAE.set_utransient, utfunc, utargs, test.DAE); 

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
