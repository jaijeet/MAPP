function test = MAPPtest_MVS_1_0_1_inverter_transient()

    % Moved from MVS_diffpair_transient
    % which was moved from test_MVS_diffpair_DC_AC_tran.m
    % original author: Bichen Wu
    % Date: 05/06/2014
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

%Changelog:
%---------
%2014-06-24: Tianshi Wang <tianshi@berkeley.edu>: changed from MVS_diffpair to
%                                                 MVSinverter_ckt
%2014-05-06: Bichen Wu <bichen@berkeley.edu>: MVS_diffpair_transient
%

    % Circuit DAE
    DAE = MNA_EqnEngine(MVSinverter_ckt);

    % set transient input to the DAE: already set up in cktnetlist/DAE
  
    test.DAE = DAE;
    test.name = 'MVSinverter_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'MVSinverter_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [ 1.0000
                             0
                        0.9989
                       -0.0000
                             0
                        0.9985
                        0.0004
                       -0.0004
                       -0.0008];

    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-12;        % Time step
    test.args.tstop = 0.1e-9;       % Stop time
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
