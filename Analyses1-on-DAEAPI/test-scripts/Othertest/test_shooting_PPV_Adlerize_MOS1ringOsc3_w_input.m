%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/05/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Changelog
%---------
%2014/07/15: Tianshi Wang <tianshi@berkeley.edu>: changed to
%                    MOS1ringOsc3_w_input
%2011/05/sometime: Jaijeet Roychowdhury <jr@berkeley.edu>

DAE = MNA_EqnEngine(MOS1ringOsc3_w_input_ckt);

% set DC and transient inputs for VDD
DAE = feval(DAE.set_uQSS, 'Vdd:::E', 3, DAE);
DAE = feval(DAE.set_uQSS, 'Isync:::I', 0, DAE);

% set up oscillator shooting with default parms
isOsc = 1;
shootparms = defaultShootingParms();
TRmethods = LMSmethods();
shootparms.TRmethod = TRmethods.GEAR2; % oscillators: not a good idea to use
            % BE, leads to flat solution. Use TRAP, or GEAR2, and
            % increase Nsteps
shoot = Shooting(DAE, shootparms, isOsc);

% run shooting with initial guess
% xinit = zeros(DAE.nunks(DAE), 1);
% xinit(2) = 3;
xinit = [3.000000000000000
         2.059147636086045
         2.359157958567013
         0.010412309459361
         -0.000330379190615];
T = 1.052194230758148e-04;

shoot = feval(shoot.solve, shoot, xinit, T);

souts = StateOutputs(DAE);

% plot results
[thefig, legends] = feval(shoot.plot, shoot, souts);

% compute the PPV
shootsol = feval(shoot.getsolution, shoot);
ppv = compute_PPV_TD(shootsol, DAE);

% plot the PPV
feval(ppv.plot, ppv);

% Adlerization
% >> DAE.inputnames(DAE)
%    'Vdd:::E'    'Iin:::I'
%f0: 1.247458016138281e+04
%SHIL:
% b_FD_twoD = [0 0 0 0 0 0 0; 0 0 1/2 0 0 1/2 0]*10e-6;
% b_FD_twoD = b_FD_twoD + [0 0 0 0 0 0 0; 0 1/2 0 0 1/2 0 0]*20e-6;
% adler = Adlerize(ppv, b_FD_twoD, 9.5e3); 
%IL:
% b_FD_twoD = [0 0 0 0 0 0 0; 0 1 0 0 1 0 0]*100e-6;
% adler = Adlerize(ppv, b_FD_twoD, 12e3); 

% [fig, titlestr, labels] = feval(adler.plot, adler);
% figure(fig); hold on;
% titlestr = sprintf('SHIL and IL when both SYNC and SIG are present: \n%s', titlestr);
% title(titlestr);

%SHIL:
SYNCs = [30e-6; 50e-6; 70e-6; 100e-6];
f1 = 9.6e3;
colors = {'--b', '--k', '-b', '-k'};

legends = {};
for c = 1:length(SYNCs)
	SYNC = SYNCs(c);

	b_FD_twoD = [0 0 0 0 0 0 0; 0 0 1/2 0 0 1/2 0]*SYNC;
	% b_FD_twoD = b_FD_twoD + [0 0 0 0 0 0 0; 0 1/2 0 0 1/2 0 0]*20e-6;
	adler = Adlerize(ppv, b_FD_twoD, f1); 

	Npts = 100;
	DeltaPhis = (0:Npts)/Npts;
	RHS = adler.g(DeltaPhis, adler);
	hold on;
	plot(DeltaPhis, real(RHS), colors{c}, 'LineWidth', 2);
	legends = {legends{:}, sprintf('g(\\Delta\\phi) with SYNC = %g uA', SYNC*1e6)};
	if c == length(SYNCs)
		plot(DeltaPhis, adler.detuning*ones(length(DeltaPhis),1), 'r-', ...
				'LineWidth', 2);
		xlabel('\Delta\phi');
		ylabel('Steady-state Adler locking equation RHS/LHS');
		legends = {legends{:}, '(f_1-f_0)/f_0'};
		legend(legends{:});
		titlestring = sprintf('%s\nSteady-state Adlerized locking analysis: f_0=%g, f_1=%g', ...
			adler.ppvname, adler.f0, adler.f1);
		title(titlestring);
		grid on;
		box on;
	end
end

%IL:
SIGs = [5e-6; 10e-6; 20e-6; 30e-6];
SYNC = 150e-6;
f1 = 9.6e3;
colors = {'--b', '--k', '-b', '-k'};

legends = {};
for c = 1:length(SIGs)
	SIG = SIGs(c);

	b_FD_twoD = [0 0 0 0 0 0 0; 0 0 1/2 0 0 1/2 0]*SYNC;
	b_FD_twoD = b_FD_twoD + [0 0 0 0 0 0 0; 0 1/2 0 0 1/2 0 0]*SIG;

	adler = Adlerize(ppv, b_FD_twoD, f1); 

	Npts = 100;
	DeltaPhis = (0:Npts)/Npts;
	RHS = adler.g(DeltaPhis, adler);
	hold on;
	plot(DeltaPhis, real(RHS), colors{c}, 'LineWidth', 2);
	legends = {legends{:}, sprintf('g(\\Delta\\phi) with SIG = %g uA', SIG*1e6)};
	if c == length(SYNCs)
		plot(DeltaPhis, adler.detuning*ones(length(DeltaPhis),1), 'r-', ...
				'LineWidth', 2);
		xlabel('\Delta\phi');
		ylabel('Steady-state Adler locking equation RHS/LHS');
		legends = {legends{:}, '(f_1-f_0)/f_0'};
		legend(legends{:});
		titlestring = sprintf('%s\nSteady-state Adlerized locking analysis: SYNC=%guA, f_0=%g, f_1=%g', ...
			adler.ppvname, SYNC*1e6, adler.f0, adler.f1);
		title(titlestring);
		grid on;
		box on;
	end
end


SYNC = 150e-6;
f1 = 9.6e3;

b_FD_twoD = [0 0 0 0 0 0 0; 0 0 1/2 0 0 1/2 0]*SYNC;
adler = Adlerize(ppv, b_FD_twoD, f1); 

initguesses = 0.3:0.1:1.2;
for c = 1:length(initguesses)
	initguess = initguesses(c);
	trans = run_transient_GEAR2(adler.AdlerDAE, initguess, 0,  5e-6, 60e-4);
	if 1 == c
		fig = feval(trans.plot, trans);
	else
		fig = feval(trans.plot, trans, 'figh', fig);
	end
	figure(fig);
	title(sprintf('Adlerized DAE for IL with 150uA SYNC: transient with IC=0.3:0.1:1.2'));
end
