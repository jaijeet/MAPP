%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running DC sweep on an inverter chain 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






nstages = 10;
VDD = 1.2;
betaN = 1e-3;
betaP = 1e-3;
VTN = 0.25;
VTP = 0.25;
RDSN = 5000;
RDSP = 5000;
CL = 1e-6;

DAE = inverterchain('somename', nstages, VDD, betaN, betaP, VTN, VTP, RDSN, RDSP, CL); % API v6.2

NRparms = defaultNRparms();
NRparms.maxiter = 100;
NRparms.reltol = 1e-5;
NRparms.abstol = 1e-10;
NRparms.residualtol = 1e-10;
NRparms.limiting = 0;
NRparms.dbglvl = 1; % minimal output

N = 200;
Vins = (0:N)/N*1.2; % sweeping Vin = 0:1.2 in N steps
Vouts = [];

nunks = feval(DAE.nunks, DAE);
prevSol = zeros(nunks,1);
for i = 1:length(Vins)
	Vin = Vins(i);
	DAE = feval(DAE.set_uQSS, Vin, DAE);
	if NRparms.dbglvl > 1
		fprintf(2, 'QSS sweep: updating Vin to %g\n', Vin);
	end
	% set up or update QSS analysis object
	QSSobj = QSS(DAE, NRparms);
	QSSobj = feval(QSSobj.solve, prevSol, QSSobj);
	[sol, iters, success] = feval(QSSobj.getSolution, QSSobj);
	if ((success <= 0) | (NaN == sol))
		fprintf(1, 'QSS failed on inverter chain at Vin=%g and init guess %g\nre-running with NR progress enabled\n', Vin, prevSol);
		NRparms.dbglvl = 2;
		QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
		QSSobj = feval(QSSobj.solve, prevSol, QSSobj);
		fprintf(1, '\naborting QSS sweep\n');
		return;
	else
		Sols(:,i) = sol;
		prevSol = sol;
	end
end

% plot the sweep

figure;
hold on;
for j=2:(nstages+1)
	col = getcolorfromindex(gca,j-1);
	plot(Vins, Sols(j,:), '.-', 'color', col);
end
legends = feval(DAE.unknames, DAE);
legends = {legends{2:(nstages+1)}};
legend(legends);
xlabel('Vin');
ylabel('inverter chain outputs');
title('DSinv inverter chain QSS sweep');
grid on; axis tight;
