function doit
% Test script running a transient analysis on a simple PLL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	%
	epsilon = -0.0001; % try this with utfunc2 to see continuous cycle
			  % slipping
	epsilon = +100; % stable lock, solid/robust
	epsilon = 1e-10; % stable lock, but only just about (with utfunc2)
	%epsilon = 2e-11; % cycle slipping (with utfunc2)
	%epsilon = +0.0000; % cycle slipping with utfunc2
	f0 = 1e9; f1 = 0.9e9; f2 = 1.1e9;
	VCOgain = (2*pi+epsilon)*1e8; 
	%
	DAE =  UltraSimplePLL_DAEAPIv6('somename', f0, VCOgain);


	%%%%%%%%%%%%%%%%%%%%%%%%% transient %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
	% set up transient simulation parameters
	ncycles = 500;
	tstart = 0; tstop = 1/f0*ncycles; tstep = 1/f0/40; 
	xinit = 0; % zero initial condition

	% set up transient input waveform
	utargs.f1 = f1; utargs.ncyc=100; utargs.T = 1/f0; utargs.f2 = f2;
	utfunc1 = @(t, args) 2*pi*args.f1*t;
	%utfunc2 = @(t, args) 2*pi*ifthenelse(t<30*args.T, args.f1*t, ...
	%			args.f1*30*args.T + args.f2*(t-30*args.T));

	utfunc = @utfunc2; % defined below
	%utfunc = utfunc1;

	DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

	% set up transient simulation object
	BEobj = LMS(DAE); % default method is BE, but it also defines
			  % TRAPparms, FEparms, GEAR2Parms
	TRmethod = BEobj.TRmethod; % contains order, alphas, betas of LMS method
	LMStranparms = BEobj.tranparms; % has tranparms.NRparms
	%TRAPobj = LMS(DAE,BEobj.TRAPparms, LMStranparms);

	% run the simulation
	BEobj = feval(BEobj.solve, BEobj, xinit, tstart, tstep, tstop);

	% produce plots
	tpts = BEobj.tpts;
	phi_os = BEobj.vals;
	phi_is = utfunc(tpts, utargs);

	delta_phis = phi_is - phi_os;

	PlotPhis = 0;
	if 1 == PlotPhis
		figure;
		plot(tpts, phi_os, 'r.-');
		hold on;
		plot(tpts, phi_is, 'b.-');
		xlabel('t');
		ylabel('\phi_o(t) and \phi_i(t)');
		legend({'\phi_o(t)', '\phi_i(t)'});
		grid on;
		axis tight;
		title('UltraSimplePLL: plots of \phi_o(t) and \phi_i(t)');
	end

	PlotDeltaPhis = 1;
	Overlay = 1;
	if 1 == PlotDeltaPhis
		if 0 == Overlay
			figure;
		else
			hold on;
		end
		plot(tpts, delta_phis, 'b.');
		%plot(tpts, delta_phis, 'ro');
		set(gca, 'FontSize', 14 );
		xlabel('t');
		ylabel('\Delta\phi(t)');
		grid on;
		axis tight;
		title('UltraSimplePLL: \Delta\phi(t) plot');
	end
% end of doit

function out = utfunc2(t, args)
	% vectorized version of
	% utfunc2 = @(t, args) 2*pi*ifthenelse(t<30*args.T, args.f1*t, ...
	%			args.f1*30*args.T + args.f2*(t-30*args.T));
	test = (t < args.ncyc*args.T); % vector of 0s and 1s
	yes = args.f1*t;
	no = args.f1*args.ncyc*args.T + args.f2*(t-args.ncyc*args.T);

	out = 2*pi*(test.*yes + (1-test).*no);
%end utfunc2
