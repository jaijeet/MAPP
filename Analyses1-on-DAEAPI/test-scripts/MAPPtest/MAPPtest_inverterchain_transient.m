function test3 = MAPPtest_inverterchain_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 3: Inverter Chain  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    nstages = 10; VDD = 1.2; betaN = 1e-3; betaP = 1e-3; VTN = 0.25;
    VTP = 0.25; RDSN = 5000; RDSP = 5000; CL = 1e-7;

    % set up DAE
    test3.DAE = inverterchain('inverterchain', nstages, VDD, betaN, ...
                      betaP, VTN, VTP, RDSN, RDSP, CL); % API v6.2
    test3.name = 'inverterchain: transient';
    test3.analysis = 'transient'; % Type of analysis
    test3.refFile = 'inverterChainTransient.mat';
    % If the analysis is transient, then setup the u_transient of the
    % circuit DAEconst_func = @(t,args) 1.2;
    utargs.A = 0.5; utargs.offset = 0.5; utargs.f=2e2; utargs.phi=0; 
    utfunc = @(t, args) args.offset + args.A*cos(2*pi*args.f*t + args.phi);
    test3.DAE = feval(test3.DAE.set_utransient, utfunc, utargs, test3.DAE);

    % Simulation time-related parameters
    test3.args.xinit =  zeros(feval(test3.DAE.nunks,test3.DAE),1); % Initial Condition
    test3.args.tstart = 0;           % Start time
    test3.args.tstep = 10e-5;        % Time step
    test3.args.tstop = 5e-2;         % Stop time
    % Transient simulation parameters
    test3.args.tranparms = defaultTranParms; % Transient simulation
    % Need this to setup for inverter chain to work
    test3.args.tranparms.NRparms.limiting = 1; 
    % Any changes to default tranparms setting
    test3.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test3.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
   
    %Where to Save the Data field
    test3.name='inverterChain_transient'; 
    % Update or testing/comparison
    %test3.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end
