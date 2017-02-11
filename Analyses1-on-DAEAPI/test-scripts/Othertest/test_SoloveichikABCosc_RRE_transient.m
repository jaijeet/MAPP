%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/06/03
% Test script for running transient analysis on  Soloveichik ABC oscillator
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
DAE = Soloveichik_ABC_oscillator();

qss = QSS(DAE);
qss = feval(qss.solve, qss);
fprintf(1, 'failure of QSS is expected: this is an RRE\n');

xinit = rand(3,1);
tstart = 0;
tstop = 15;
tstep = 0.1; % OK with TRAP/GEAR2 for k=1
%tstep = 0.01; % good with TRAP (not GEAR) for k=10

%trans = run_transient_GEAR2(xinit, tstart, tstep, tstop, DAE);
trans = run_transient_TRAP(DAE, xinit, tstart, tstep, tstop);

%{
outs = StateOutputs(DAE);
outs = feval(outs.DeleteAll, outs);
outs = feval(outs.Add, {'e_inv1', 'e_inv2', 'e_inv3'}, outs);

[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2, outs);
%}

[thefig, legends] = feval(trans.plot, trans); % regular plot
drawnow;

[tpts, vals] = feval(trans.getsolution, trans); 

% 3d phase plane plot

figure;
hold on;
xlabel('[A]');
ylabel('[B]');
zlabel('[C]');
view(3);
grid on;
title(['3D phase plane plot of ', feval(DAE.daename,DAE)]);

for i=1:20
	plot3(vals(1,:), vals(2,:), vals(3,:), '.-');
	%view(270,45); % or view(0,45) - shows them edge on - ie, makes it clear they lie on an [A]+[B]+[C]=const plane
	%view(135,35); % shows them head on: concentric "circles"
	drawnow;

	xinit = rand(3,1);
	trans = run_transient_TRAP(DAE, xinit, tstart, tstep, tstop);
	[tpts, vals] = feval(trans.getsolution, trans); 
end


axis tight;
view(270,45); % or view(0,45) - shows them edge on - ie, makes it clear they lie on an [A]+[B]+[C]=const plane
pause(5);
view(135,35); % shows them head on: concentric "circles"
