function test6 = MAPPtest_BJTdiffpairSchmittTrigger_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 6: BJT differential pair (Schmitt Trigger) 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    test6.DAE = BJTdiffpairSchmittTrigger('BJTdiffpairSchmittTrigger');
    test6.name = 'BJTdiffpairSchmittTrigger: transient';
    test6.analysis = 'transient'; % Type of analysis
    test6.refFile = 'BJTdiffpairSchmittTriggertransient.m';
    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    utargs.A = 0.5; utargs.f=1e1; utargs.phi=0; 
    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    test6.DAE = feval(test6.DAE.set_utransient,utfunc,utargs,test6.DAE);


    % Simulation time-related parameters
    test6.args.xinit =[3;3;-0.5];
   % [3; 3; -0.5]; % Initial condition
    test6.args.tstart = 0;           % Start time
    test6.args.tstep = 20e-5;        % Time step
    test6.args.tstop = 2e-1;         % Stop time
    % Transient simulation parameters
    test6.args.tranparms = defaultTranParms; % Transient simulation
    test6.args.tranparms.NRparms.limiting = 1; 
    test6.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test6.args.tranparms.trandbglvl = -1; % Only errors
    % LMS method to be used
    test6.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
end
