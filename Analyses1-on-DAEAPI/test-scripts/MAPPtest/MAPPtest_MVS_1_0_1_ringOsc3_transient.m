function test = MAPPtest_MVS_1_0_1_ringOsc3_transient()

    % Moved from MVS_diffpair_transient
    % which was moved from test_MVS_diffpair_DC_AC_tran.m
    % original author: Bichen Wu
    % Date: 05/06/2014
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

%Changelog:
%---------
%2014-06-24: Tianshi Wang <tianshi@berkeley.edu>: changed from MVS_diffpair to
%                                                 MVSringOsc3_ckt
%2014-05-06: Bichen Wu <bichen@berkeley.edu>: MVS_diffpair_transient
%

    % Circuit DAE
    DAE = MNA_EqnEngine(MVSringosc3_ckt);

    % set transient input to the DAE: already set up in cktnetlist/DAE
  
    test.DAE = DAE;
    test.name = 'MVSringOsc3_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'MVSringOsc3_tran.mat';

    % Simulation time-related parameters
    xinit = zeros(feval(DAE.nunks, DAE),1);
    xinit(2) = 1;
    test.args.xinit = xinit;

    test.args.tstart = 0;           % Start time
    test.args.tstep = 0.5e-12;      % Time step
    test.args.tstop = 20e-12;       % Stop time
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
