function test =  MAPPtest_RCline_wrapper_tran()
    DAE =  RCline_wrapper();
    test.DAE = DAE; 
    test.name='RCline_wrapper_transient';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'RCline_wrapper_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    utargs.A = 1; utargs.f=1e3; utargs.phi=0; 
    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    test.DAE = feval(test.DAE.set_utransient, utfunc, utargs, test.DAE); 

    % Simulation time-related parameters
    test.args.xinit = zeros(2,1); % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 10e-6;        % Time step
    test.args.tstop = 10e-3;         % Stop time

    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    test.args.tranparms.NRparms.limiting = 1; % Only errors 
end
