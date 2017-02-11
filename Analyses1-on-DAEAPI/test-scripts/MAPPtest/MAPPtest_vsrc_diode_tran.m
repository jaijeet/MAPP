function test = vsrc_diode_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MNAEqnEngine_vsrc_diode_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
	MNAEqnEngine_vsrc_diode; % sets up DAE (DAEAPI script)
	utargs.A = 1; utargs.delay = 0.5e-3;
	utfunc = @(t, args) args.A*(t>=args.delay);
	DAE = feval(DAE.set_utransient, 'v1:::E', utfunc, utargs, DAE);

    test.DAE = DAE;
    test.name = 'vsrc_diode_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'vsrc_diode_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = zeros(3,1);

    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = 0;           % Start time
    test.args.tstep = 1e-5;        % Time step
    test.args.tstop = 5e-3;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'TRAP'; % {'BE','FE','TRAP','GEAR2'}
end

