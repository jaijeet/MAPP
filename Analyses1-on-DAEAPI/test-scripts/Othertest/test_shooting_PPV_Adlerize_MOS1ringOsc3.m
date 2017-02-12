%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/05/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Changelog
%---------
%2014/07/15: Tianshi Wang <tianshi@berkeley.edu>: changed to MOS1ringOsc3
%2011/05/sometime: Jaijeet Roychowdhury <jr@berkeley.edu>

DAE = MNA_EqnEngine(MOS1ringOsc3_w_input_ckt);

if 1 == 0
	% run QSS
	qss = QSS(DAE);
	qss = feval(qss.solve, qss);
	outputs = StateOutputs(DAE);
	feval(qss.print, outputs, qss)

	% run transient
	trans = LMS(DAE); trans = LMS(DAE,trans.TRAPparms);
	tstart = 0; tstep = 1e-6; tstop = 3e-4;
	initcond = zeros(feval(DAE.nunks, DAE),1);
	initcond(2) = 3;
	trans = feval(trans.solve, trans, initcond, tstart, tstep, tstop);
	feval(trans.plot, trans, outputs)
	[tpts, vals] = feval(trans.getsolution, trans);
	xinit = vals(:,end)
	return;
end


% set up oscillator shooting with default parms
isOsc = 1;
shootparms = defaultShootingParms();
TRmethods = LMSmethods();
shootparms.TRmethod = TRmethods.GEAR2; % oscillators: not a good idea to use
			% BE, leads to flat solution. Use TRAP, or GEAR2, and
			% increase Nsteps
shoot = Shooting(DAE, shootparms, isOsc);

% run shooting with initial guess
xinit = zeros(feval(DAE.nunks, DAE),1);
xinit(2) = 3;

T = 1.0e-4; % good guess, eyeballed from transient
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
b_FD_twoD = [0 0 0 0 0 0 0; 0 0 1 0 0 1 0];  adler = Adlerize(ppv, b_FD_twoD*50e-6, 9.5e3); 
[fig, titlestr, labels] = feval(adler.plot, adler);
figure(fig); hold on;
titlestr = sprintf('2nd-harmonic injection, amplitude 100uA\n%s', titlestr);
title(titlestr);

trans = run_transient_GEAR2(adler.AdlerDAE, 0.9, 0,  1e-6, 3e-4);
fig = feval(trans.plot, trans);
figure(fig);
title('Adlerized DAE for 2nd-harmonic IL, amplitude 1.2e-2: transient with IC=0.9');

trans = run_transient_GEAR2(adler.AdlerDAE, 0.4, 0,  1e-6, 3e-4);
fig = feval(trans.plot, trans);
figure(fig);
title('Adlerized DAE for 2nd-harmonic IL, amplitude 1.2e-2: transient with IC=0.4');

b_FD_twoD = [0 0 0 0 0 0 0; 0 0 1 0 0 1 0]; adler = Adlerize(ppv, b_FD_twoD*50e-6, 9.5e3); 
[fig, titlestr, labels] = feval(adler.plot, adler);
figure(fig); hold on;
titlestr = sprintf('2nd-harmonic injection, amplitude 1.0e-2\n%s', titlestr);
title(titlestr);

trans = run_transient_GEAR2(adler.AdlerDAE, 0.9, 0,  1e-6, 4*3e-4);
fig = feval(trans.plot, trans);
figure(fig);
title('Adlerized DAE for 2nd-harmonic IL, amplitude 1.0e-2: transient with IC=0.9');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
