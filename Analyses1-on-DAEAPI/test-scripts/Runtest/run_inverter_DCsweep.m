%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running SC sweep on an inverter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






DAE = SH_CMOS_inverter_DAEAPIv6('somename'); % v6.2

NRparms = defaultNRparms();
NRparms.maxiter = 100;
NRparms.reltol = 1e-5;
NRparms.abstol = 1e-10;
NRparms.residualtol = 1e-10;
NRparms.limiting = 0;
NRparms.dbglvl = 1; % minimal output

if 0 == 1
	% could change rDS - eg, make it very large
	DAE = feval(DAE.setparms, {'rDSN', 'rDSP'}, {10000, 10000}, DAE);
end


N = 100;
Vins = (0:N)/N*1.2; % sweeping Vin = 0:1.2 in N steps
Vouts = [];

prevVout = 1.2;
for i = 1:length(Vins)
	Vin = Vins(i);
	DAE = feval(DAE.set_uQSS, Vin, DAE);
	if NRparms.dbglvl > 1
		fprintf(2, 'QSS sweep: updating Vin to %g\n', Vin);
	end
	% set up or update QSS analysis object
	QSSobj = QSS(DAE, NRparms);
	QSSobj = feval(QSSobj.solve, prevVout, QSSobj);
	[Vout, iters, success] = feval(QSSobj.getSolution, QSSobj);
	if ((success <= 0) | (NaN == Vout))
		fprintf(1, 'QSS failed on inverter at Vin=%g and init guess %g\nre-running with NR progress enabled\n', Vin, prevVout);
		NRparms.dbglvl = 2;
		QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
		QSSobj = feval(QSSobj.solve, prevVout, QSSobj);
		fprintf(1, '\naborting QSS sweep\n');
		return;
	else
		Vouts(i) = Vout;
		prevVout = Vout;
	end
end

% plot the sweep

figure;
plot(Vins, Vouts, '.-');
xlabel('Vin');
ylabel('Vout');
title('DSinv SH CMOS inverter QSS sweep');
grid on; axis tight;
