MNAEqnEngine_BJTdiffpair;

% unks: 'e_Vdd'  'e_CL'  'e_CR'  'e_E'  'e_Vin'
%       'vdd:::ipn'  'vin:::ipn'
% eqns: 'KCL_Vdd'  'KCL_CL'  'KCL_CR'  'KCL_E'
%       'KCL_Vin'  'KVL_vdd_vpn'  'KVL_vin_vpn'
% inputs: 'vdd:::E'  'vin:::E'  'ie:::I'

if 1 == 0
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'ie:::I', 2e-3, DAE);
	%
	DAE = feval(DAE.set_uQSS, 'vin:::E', 0.1, DAE);
	% run DC
	qss = QSS(DAE);
	qss.NRparms.dbglvl = 2;
	qss.NRparms.maxiter = 100;
	qss.NRparms.do_limiting = 1;
	qss.NRparms.do_initializing = 1;
	x0 = [5; 3; 3; -0.7; 0.1; 0; 0];
	qss = feval(qss.solve, x0, qss);
	sol = feval(qss.getsolution, qss);
else
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'ie:::I', 2e-3, DAE);
	% run DC


	N = 20;
	Vins = -0.2 + (0:N)/N*0.4; % sweeping Vin = -0.2:0.2 in N steps
	Vouts = [];

	initguess = [5; 5; -0.7; -0.7; -0.2; 0; 0];
	for i = 1:length(Vins)
		Vin = Vins(i);
		DAE = feval(DAE.set_uQSS, 'vin:::E', Vin, DAE);
		% DAE updated => set up/update QSS analysis object
		QSSobj = QSS(DAE);
		QSSobj.NRparms.dbglvl = 1;
		QSSobj.NRparms.maxiter = 100;
		QSSobj = feval(QSSobj.solve, initguess, QSSobj);
		[sol, iters, success] = feval(QSSobj.getSolution, QSSobj);
		if ((success <= 0) | (NaN == sol))
			fprintf(1, 'QSS failed on diffpair at Vin=%g\nre-running with NR progress enabled\n', Vin);
			NRparms.dbglvl = 2;
			QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
			QSSobj = feval(QSSobj.solve,initguess,QSSobj);
			fprintf(1, '\naborting QSS sweep\n');
			return;
		else
			Vouts(i) = sol(2)-sol(3);
			initguess = sol;
		end
	end

	% plot the sweep

	figure;
	plot(Vins, Vouts, '.-');
	xlabel('Vin');
	ylabel('Vout');
	title('Ebers-Moll BJT diffpair QSS sweep');
	grid on; axis tight;
end

