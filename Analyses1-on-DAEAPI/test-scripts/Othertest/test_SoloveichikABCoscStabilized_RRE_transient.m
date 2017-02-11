%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/06/03
% Test script for running transient analysis (stabilized) on  Soloveichik ABC oscillator 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% run this a few times with random initial conditions.
% not only is its amplitude unstable, its frequency
% also depends dramatically on the initial conditions.
%
% just like an moon-earth orbital system.
%
% it's a genuine ODE, so TRAP should be safe, and much more
% accurate than GEAR2.
%
DAE = Soloveichik_ABC_oscillator_stabilized();

qss = QSS(DAE);
qss = feval(qss.solve, qss);
fprintf(1, 'failure of QSS is expected: this is an RRE\n');

concX = 1.2;
	      % [0.1,2) work
	      % - the "best" oscillations are in the range 1-2
	      % - 0.5 and below give really weird shapes
	      % 2 might be the threshold of instability
	      % 2.5, 3 are interesting: the oscillations keep growing
	      % 10 does not work!
xinit(4,1) = concX; %

golden = [0.91;0.86;0.882];
golden2 = [1.2; 1; 1];
golden3 = [1.6;0.5;0.4;concX];
xinit = golden3 + [0.1;-0.1;0.3;0];
%xinit = rand(3,1);
%xinit = [0.01;0.015;0.012];
%xinit = [1;0.9;0.8];
%xinit = [0.1;0.15;0.12];
%xinit = golden;


figh_t = figure;

if 0 == 1 % shooting
	% set up oscillator shooting with default parms
	isOsc = 1;
	xinit = [1.6;0.5;0.4;concX];
	shootparms = defaultShootingParms();
	shootparms.Nsteps = 400;
	shootparms.NRparms.maxiter = 50;
	TRmethods = LMSmethods();
	shootparms.TRmethod = TRmethods.TRAP; % oscillators: not a good idea to use
				% BE, leads to flat solution. Use TRAP, or GEAR2, and
				% increase Nsteps
	shoot = Shooting(DAE, shootparms, isOsc);

	% run shooting with initial guess
	T = 4.8; % something very weird about this oscillator: finds a periodic steady state
		 % for any period in the range T=[4.8 to 5.1], it seems!
		 % shooting Jacobian == monodromy matrix is rank-deficient by 3.
	shoot = feval(shoot.solve, shoot, xinit, T);

	outs = StateOutputs(DAE);
	outs = feval(outs.DeleteAll, outs);
	outs = feval(outs.Add, {'[A]', '[B]', '[C]'}, outs);


	% plot results
	set(0,'CurrentFigure',figh_t);
	[figh_t, legends] = feval(shoot.plot, shoot, outs, figh_t);
end

if 1 == 1 % transient
	tstart = 0;
	tstop = 80;
	tstep = 0.055; % OK with TRAP/GEAR2 for k=1
	%tstep = 0.01; % good with TRAP (not GEAR) for k=10

	%trans = run_transient_GEAR2(DAE, xinit, tstart, tstep, tstop);
	trans = run_transient_TRAP(DAE, xinit, tstart, tstep, tstop);


	outs = StateOutputs(DAE);
	outs = feval(outs.DeleteAll, outs);
	outs = feval(outs.Add, {'[A]', '[B]', '[C]', '[X]'}, outs);

	set(0,'CurrentFigure',figh_t);
	[figh_t, legends] = feval(trans.plot, trans, outs, [], [], figh_t);

	drawnow;
	hold on;
end


if 1 == 1
	[tpts, vals] = feval(trans.getsolution, trans); 

	% 3d phase plane plot

	figh_p=figure;
	hold on;
	xlabel('[A]');
	ylabel('[B]');
	zlabel('[C]');
	view(3);
	grid on;
	title(['3D phase plane plot of ', feval(DAE.daename,DAE)]);

	for i=1:5
		set(0,'CurrentFigure',figh_p);
		plot3(vals(1,:), vals(2,:), vals(3,:), '.-');
		%view(270,45); % or view(0,45) - shows them edge on - ie, makes it clear they lie on an [A]+[B]+[C]=const plane
		%view(135,35); % shows them head on: concentric "circles"
		drawnow;

		xinit(1:3,1) = rand(3,1); xinit(4,1) = concX;
		trans = run_transient_TRAP(DAE, xinit, tstart, tstep, tstop);
		set(0,'CurrentFigure',figh_t);
		[figh_t, legends] = feval(trans.plot, trans, outs, [], [], figh_t);
		[tpts, vals] = feval(trans.getsolution, trans); 
	end


	set(0,'CurrentFigure',figh_p);
	axis tight;
	view(270,45); % or view(0,45) - shows them edge on - ie, makes it clear they lie on an [A]+[B]+[C]=const plane
	pause(5);
	view(135,35); % shows them head on: concentric "circles"
end
