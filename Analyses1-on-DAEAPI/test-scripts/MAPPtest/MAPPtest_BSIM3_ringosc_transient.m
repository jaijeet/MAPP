function test2 = MAPPtest_BSIM3_ringosc_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 2: BSIM3 Ring Oscillator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    test2.DAE = BSIM3_ringosc('BSIM3_ringosc');
    test2.name='BSIM3_ringosc: transient';
    test2.analysis = 'transient'; % Type of analysis
    test2.refFile = 'BSIM3RingOscillatorTransient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAEconst_func = @(t,args) 1.2;
    const_func = @(t,args) 1.2;
    zero_func = @(t, args) 0;
    test2.DAE = feval(test2.DAE.set_utransient, 'vdd:::E', const_func, [], test2.DAE);
    test2.DAE = feval(test2.DAE.set_utransient, 'iInj1:::I', zero_func, [], test2.DAE);

    % Simulation time-related parameters
    test2.args.xinit = 0.2*ones(feval(test2.DAE.nunks,test2.DAE),1);
    test2.args.tstart = 0;           % Start time
    test2.args.tstep = 6e-9;        % Time step
    test2.args.tstop = 1e-7;         % Stop time
    % Transient simulation parameters
    test2.args.tranparms = defaultTranParms(); 
    % Any changes to default tranparms setting
    test2.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test2.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
end
