function test = MAPPtest_STA_delay_line_transient()
%Author: Bichen <bichen@berkeley.edu> 2013/11/07
% Test script for running transient analysis on a ring oscillator based on BSIM3 CMOS model
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	DAE = STA_EqnEngine(delay_line_ckt());

    test.name='STA_delay_line_transient';
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'STA_delay_line_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE

    % Simulation time-related parameters
    test.args.xinit = zeros(feval(DAE.nunks,DAE),1); % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 5e-11;        % Time step
    test.args.tstop = 10e-9;         % Stop time

    % LMS method to be used
    %test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % Update or testing/comparison
    %test1.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose

	args.td = 0;
	args.thi = 0.01;
	args.tfs = 0.5;
	args.tfe = 0.51;
	args.T = 10e-9;
	args.A = 2.5;

	DAE = feval(DAE.set_uQSS, 'Vin:::E', 0, DAE);

	PUL_func = @(t, args) args.A * pulse(t/args.T, args.td, args.thi,args.tfs, args.tfe);
	DAE = feval(DAE.set_utransient, 'Vin:::E', PUL_func, args, DAE);

	args1.A = 0.7;
	ctrl_func = @(t, args) args.A;

	DAE = feval(DAE.set_utransient, 'Vctrl:::E', ctrl_func, args1, DAE);
    test.DAE =  DAE;

end



