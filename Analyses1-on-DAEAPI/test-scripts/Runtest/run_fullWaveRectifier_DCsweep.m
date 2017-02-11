%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running DC sweep on a full Wave rectifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






DAE = fullWaveRectifier_DAEAPIv6('somename');% v6.2

NRparms = defaultNRparms();
NRparms.maxiter = 100;
NRparms.reltol = 1e-5;
NRparms.abstol = 1e-10;
NRparms.residualtol = 1e-10;
NRparms.limiting = 1;
NRparms.dbglvl = 1; % minimal output


N = 50; % note: 
	% N = 300 works without limiting.
	% N = 100 does not work without limiting; works fine with limiting.
	% N = 50 does not work without limiting; works fine with limiting.
	% N = 20 works with limiting, but there are singular matrix warnings; however, NR recovers.
Vins = -10 + (0:N)/N*20; % sweeping Vin = -10:10 in N steps
Vouts = [];

%initguess = feval(DAE.QSSinitGuess, DAE);
initguess = [-0.7; -9.3];
for i = 1:length(Vins)
	Vin = Vins(i);
	DAE = feval(DAE.set_uQSS, Vin, DAE);
	if NRparms.dbglvl > 1
		fprintf(2, 'QSS sweep: updating Vin to %g\n', Vin);
	end
	% DAE updated => set up/update QSS analysis object
	QSSobj = QSS(DAE, NRparms);
	QSSobj = feval(QSSobj.solve, initguess, QSSobj);
	[sol, iters, success] = feval(QSSobj.getSolution, QSSobj);
	if (success ~= 1)
		fprintf(1, 'QSS failed on diffpair at Vin=%g\nre-running with NR progress enabled\n', Vin);
		NRparms.dbglvl = 2;
		QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
		QSSobj = feval(QSSobj.solve,initguess,QSSobj);
		fprintf(1, '\naborting QSS sweep\n');
		return;
	else
		Vouts(i) = feval(DAE.C, DAE)*sol;
		initguess = sol;
	end
end

% plot the sweep

figure;
plot(Vins, Vouts, '.-');
xlabel('Vin');
ylabel('Vout');
title('fullWaveRectifier diffpair QSS sweep');
grid on; axis tight;
