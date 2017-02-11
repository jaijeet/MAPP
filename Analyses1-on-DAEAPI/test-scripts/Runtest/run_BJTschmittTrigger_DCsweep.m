%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
%  Test script for running DC sweep on a BJT Schmitt Trigger
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






DAE = BJTschmittTrigger('BJTschmittTrigger');% v6.2

NRparms = defaultNRparms();
NRparms.maxiter = 100;
NRparms.reltol = 1e-5;
NRparms.abstol = 1e-10;
NRparms.residualtol = 1e-10;
NRparms.limiting = 0;
NRparms.dbglvl = 1; % minimal output


N = 200;

for j = 1:2
	if 1 == j
		Vins = (N:-1:0)/N*5; % sweeping Vin = 5:0 in N steps
		initguess = feval(DAE.QSSinitGuess, Vins(1), DAE);
	else
		Vins = (0:N)/N*5; % sweeping Vin = 0:5 in N steps
		initguess = [5; 3; 3.75; 3];
	end
	Vouts = [];

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
		if (success <= 0)
			fprintf(1, 'QSS failed on BJTschmittTrigger at Vin=%g\n', Vin);
			break;
			fprintf(1, 'QSS failed on BJTschmittTrigger at Vin=%g\nre-running with NR progress enabled\n', Vin);
			NRparms.dbglvl = 2;
			QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
			QSSobj = feval(QSSobj.solve,initguess,QSSobj);
			fprintf(1, '\naborting QSS sweep\n');
			return;
		else
			%Vouts(i) = feval(DAE.C, DAE)*sol;
			Vouts(i) = sol(1);
			initguess = sol;
		end
	end

	% plot the sweep

	%figure;
	plot(Vins(1:(i-1)), Vouts(1:(i-1)), '.-');
	hold on;
end % for j

xlabel('Vin');
ylabel('Vout');
title('BJT Schmitt Trigger QSS sweep');
grid on; axis tight;
hold on;
display('QSS SWEEP FAILURE IS EXPECTED: this is a Schmitt trigger');
