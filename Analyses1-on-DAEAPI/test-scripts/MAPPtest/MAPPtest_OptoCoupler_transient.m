function test = MAPPtest_OptoCoupler_transient()
% 
% Test script to run DC sweep on a BJT differential pair
%Author: Bichen Wu <bichen@berkeley.edu> 2014/01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	DAE = MNA_EqnEngine(optocoupler_ckt());
	DAE = feval(DAE.set_uQSS,'Vin:::E',0.4,DAE);
	test.DAE = DAE;

	test.name = 'OptoCoupler_transient';
	test.analysis = 'transient';
	test.refFile = 'OptoCoupler_transient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE

	DAE = feval(DAE.set_uQSS,'Vin:::E',0.4,DAE);
	DAE = feval(DAE.set_uQSS,'Vin:::E',0.4,DAE);
	qss = QSS(DAE);
	qss.NRparms.dbglvl = 0;
	qss = feval(qss.solve, qss); 
	sol = feval(qss.getSolution, qss);

    % Simulation time-related parameters
	test.args.xinit = sol;
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-6;        % Time step
    test.args.tstop = 5e-5;         % Stop time

    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % Update or testing/comparison
    %test1.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose



end
