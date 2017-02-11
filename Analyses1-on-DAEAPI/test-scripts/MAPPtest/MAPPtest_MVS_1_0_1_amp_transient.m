function test = MAPPtest_MVS_1_0_1_amp_transient()

    % Moved from MVS_diffpair_transient
    % which was moved from test_MVS_diffpair_DC_AC_tran.m
    % original author: Bichen Wu
    % Date: 05/06/2014
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

%Changelog:
%---------
%2014-06-19: Tianshi Wang <tianshi@berkeley.edu>: changed from MVS_diffpair to
%                                                 MVSamp_ckt
%2014-05-06: Bichen Wu <bichen@berkeley.edu>: MVS_diffpair_transient
%

    % Circuit DAE
    DAE = MNA_EqnEngine(MVSamp_ckt);

    % set transient input to the DAE
    utargs.A = 0.1; utargs.f=1e9; utargs.phi=0;
    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    DAE = feval(DAE.set_utransient, 'Vin:::E', utfunc, utargs, DAE);
  
    test.DAE = DAE;
    test.name = 'MVSamp_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'MVSamp_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [1.0000
						0.5500
						0.5062
						0.5500
					   -0.0005
							 0
							 0
						0.4568
						0.0494];

    test.args.tstart = 0;           % Start time
    test.args.tstep = 5e-11;        % Time step
    test.args.tstop = 2e-9;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'GEAR2'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end
