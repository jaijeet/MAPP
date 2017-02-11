%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script to run DC sweep on a Schmitt Trigger based on BJT  differential pair
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






DAE = BJTdiffpairSchmittTrigger('BJTdiffpairSchmittTrigger');% v6.2

NRparms = defaultNRparms();
NRparms.maxiter = 100;
NRparms.reltol = 1e-5;
NRparms.abstol = 1e-10;
NRparms.residualtol = 1e-10;
NRparms.limiting = 0;
NRparms.dbglvl = 1; % minimal output


N = 100;
VinsUp = -0.5 + (0:N)/N*1; % sweeping Vin = -0.5:0.5 in N steps
VinsDown = 0.5 - (0:N)/N*1; % sweeping Vin = 0.5:-0.5 in N steps

figure;

initguess = [4;2;-0.7];
lntyp = 'b.-';
for oof = {VinsUp, VinsDown}
	Vins = oof{:};
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
		if success <= 0
			fprintf(1, 'QSS failed at Vin=%g\n', Vin);
			break;
		else
			Vouts(i) = feval(DAE.C, DAE)*sol;
			initguess = sol;
		end
	end

	% plot the sweep

	len = length(Vouts);
	plot(Vins(1:len), Vouts, lntyp);
	initguess = [2;4;-0.1];
	lntyp = 'r.-';
	hold on;
end
xlabel('Vin');
ylabel('Vout');
title('BJTdiffpairSchmittTrigger QSS sweep showing hysteresis');
grid on; axis tight;

display('QSS SWEEP FAILURE IS EXPECTED: this is a Schmitt trigger');
