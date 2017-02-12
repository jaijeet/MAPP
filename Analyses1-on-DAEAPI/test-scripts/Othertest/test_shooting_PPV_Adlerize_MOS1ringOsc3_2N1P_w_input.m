%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/05/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Changelog
%---------
%2014/07/15: Tianshi Wang <tianshi@berkeley.edu>: changed to
%                MOS1_D_latch_core_2N1P
%2011/05/sometime: Jaijeet Roychowdhury <jr@berkeley.edu>

DAE = MNA_EqnEngine(MOS1ringOsc3_2N1P_w_input_ckt);

% set DC and transient inputs for VDD
DAE = feval(DAE.set_uQSS, 'Vdd:::E', 3, DAE);
DAE = feval(DAE.set_uQSS, 'Iin:::I', 0, DAE);

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
         2.555846594706911
         0.137946364514471
         0.519614847229519
         -0.000577805780587];
T = 8.016301847942510e-05;

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
b_FD_twoD = [0 0 0 0 0 0 0; 0 0 1/2 0 0 1/2 0]*50e-6;
b_FD_twoD = b_FD_twoD + [0 0 0 0 0 0 0; 0 1/2 0 0 1/2 0 0]*20e-6;
adler = Adlerize(ppv, b_FD_twoD, 12.5e3); 
%IL:
% b_FD_twoD = [0 0 0 0 0 0 0; 0 1 0 0 1 0 0]*100e-6;
% adler = Adlerize(ppv, b_FD_twoD, 12e3); 

[fig, titlestr, labels] = feval(adler.plot, adler);
figure(fig); hold on;
titlestr = sprintf('SHIL and IL when both SYNC and SIG are present: \n%s', titlestr);
title(titlestr);

initguesses = 0.1:0.1:1;
for c = 1:length(initguesses)
	initguess = initguesses(c);
	trans = run_transient_GEAR2(adler.AdlerDAE, initguess, 0,  5e-6, 60e-4);
	if 1 == c
		fig = feval(trans.plot, trans);
	else
		fig = feval(trans.plot, trans, 'figh', fig);
	end
	figure(fig);
	title(sprintf('Adlerized DAE for IL with 10uA SIG: transient with IC=0.1:0.1:1'));
end
