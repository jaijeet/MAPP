function test = LTE_UltraSimplePLL_transient()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from LTEtest_UltraSimplePLL_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE


	epsilon = 1e-10; % stable lock, but only just about (with utfunc2)
	f0 = 1e9; f1 = 0.9e9; f2 = 1.1e9;
	VCOgain = (2*pi+epsilon)*1e8; 


	ncycles = 500;
	tstart = 0; tstop = 1/f0*ncycles; tstep = 1/f0/40; 
	xinit = 0; % zero initial condition

	utargs.f1 = f1; utargs.ncyc=100; utargs.T = 1/f0; utargs.f2 = f2;

	utfunc = @utfunc2; % defined below
	%utfunc = utfunc1;

	DAE =  UltraSimplePLL_DAEAPIv6('somename', f0, VCOgain);
	DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

    test.DAE = DAE;
    test.name = 'LTE_UltraSimplePLL_tran'; % Type of analysis
    test.analysis = 'transient'; % Type of analysis
    test.refFile = 'LTE_UltraSimplePLL_tran.mat';

    % Simulation time-related parameters
    test.args.xinit = [0];



    % [3; 3; -0.5]; % Initial condition
    test.args.tstart = tstart;           % Start time
    test.args.tstep = tstep;        % Time step
    test.args.tstop = tstop;         % Stop time
    % Transient simulation parameters
    test.args.tranparms = defaultTranParms; % Transient simulation
    test.args.tranparms.NRparms.limiting = 1; 
    test.args.tranparms.doStepControl = 1;
    test.args.tranparms.LTEstepControlParms.doStepControl = 1;
    % Any changes to default tranparms setting
    test.args.tranparms.trandbglvl = -1; % Only errors 
    % LMS method to be used
    test.args.LMSMethod = 'BE'; % {'BE','FE','TRAP','GEAR2'}
    % Update or testing/comparison
    % test.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end


function out = utfunc2(t, args)
	% vectorized version of
	% utfunc2 = @(t, args) 2*pi*ifthenelse(t<30*args.T, args.f1*t, ...
	%			args.f1*30*args.T + args.f2*(t-30*args.T));
	test = (t < args.ncyc*args.T); % vector of 0s and 1s
	yes = args.f1*t;
	no = args.f1*args.ncyc*args.T + args.f2*(t-args.ncyc*args.T);

	out = 2*pi*(test.*yes + (1-test).*no);
end
%end utfunc2
