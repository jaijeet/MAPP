function test = MAPPtest_parallelRLCdiode_transient()

    % Circuit DAE. 
    test.DAE =  parallelRLCdiode('||rlcdiode');
    test.name='parallelRLCdiode_transient';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'parallelRLCdiode_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    utargs.A = 0.2; utargs.f=1e2; utargs.phi=0; 
    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    test.DAE = feval(test.DAE.set_utransient, utfunc, utargs, test.DAE); 

    % Simulation time-related parameters
    test.args.xinit = [0.5 0]'; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1.5e-9;        % Time step
    test.args.tstop = 2e-6;         % Stop time

    % LMS method to be used
    test.args.LMSMethod = 'BE'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    LMStranparms.stepControlParms.doStepControl = 0; % uniform timesteps only.
    % Update or testing/comparison
end
