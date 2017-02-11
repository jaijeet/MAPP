function test1 = MAPPtest_UltraSimplePLL_transient()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Transient Test Case 1: BJT differential pair
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    epsilon = -0.0001; % try this with utfunc2 to see continuous cycle
    		  % slipping
    epsilon = +100; % stable lock, solid/robust
    epsilon = 1e-10; % stable lock, but only just about (with utfunc2)
    %epsilon = 2e-11; % cycle slipping (with utfunc2)
    %epsilon = +0.0000; % cycle slipping with utfunc2
    f0 = 1e9; f1 = 0.9e9; f2 = 1.1e9;
    VCOgain = (2*pi+epsilon)*1e8; 
    %
    DAE =  UltraSimplePLL_DAEAPIv6('UltraSimplePLL', f0, VCOgain);

    test1.DAE =  DAE;
    test1.name='UltraSimplePLLtransient';
    test1.analysis = 'transient'; % Type of analysis
    test1.refFile = 'UltraSimplePLLtransient.mat';

    % If the analysis is transient, then setup the u_transient of the
    % circuit DAE
    utargs.T = 1/f0; utargs.f1=f1; utargs.ncyc=100; utargs.f2 = f2;
    utfunc = @utfunc2;
    test1.DAE = feval(test1.DAE.set_utransient, utfunc, utargs, test1.DAE); 

    % Simulation time-related parameters
    test1.args.xinit = [0]; % Initial condition
    ncycles = 500;
    test1.args.tstart = 0;           % Start time
    test1.args.tstep = 1/f0/40;        % Time step
    test1.args.tstop = 1/f0*ncycles;         % Stop time

    % LMS method to be used
    test1.args.LMSMethod = 'BE'; % {'BE','FE','TRAP','GEAR2'}
    % Transient simulation parameters
    test1.args.tranparms = defaultTranParms(); % Transient simulation
    % Any changes to default tranparms setting
    test1.args.tranparms.trandbglvl = -1; % Only errors 
    % Update or testing/comparison
    %test1.args.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
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
