%author: Tianshi Wang, 2012/09/17
%
% TODO: help strings obsolete.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%
% An ideal-ish differential pair using MVS MOSFETs.
% The emitters of 2 N-type MOSFETs are connected at node nS.
% An ideal current source of DC value IS drains node S.
% The drain of the MOSFET on the left is connected
% to node nDL (node voltage eDL); that of the one on the right to node nDR (node
% voltage eDR). Resistors rL and rR connect from VDD to nodes nDL and nDR,
%
% The MOSFET on the left has its gate connected to Vin; that of the one on the right 
% connects to ground. The circuit is, therefore, not perfectly symmetric. This
% lack of symmetry shows up in different DC components at the two output nodes
% with large Vin, and exacerbated if you use an insufficient number of harmonics.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cktdata = MVS_1_0_1_5_diffpair_ckt;

% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine(cktdata);

doOP = 1;
doDCsweep = 0;
doAC = 0;
doTran = 0;

outputs = StateOutputs(DAE); %to plot all state vars
% outputs = feval(outputs.DeleteAll, outputs);
% outputs = feval(outputs.Add, {'e_DL', 'e_DR', 'e_S'}, outputs);

if 1 == doOP
	fprintf(2, 'Running an operating point analysis:\n');
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'VCC:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'IE:::I', 2e-3, DAE);
	%
	DAE = feval(DAE.set_uQSS, 'Vin:::E', 0.0, DAE);
	% run DC
	qss = QSS(DAE);
	qss.NRparms.dbglvl = 2;
	qss.NRparms.maxiter = 100;
	qss.NRparms.do_limiting = 1;
	qss.NRparms.do_initializing = 1;
	% x0 = [5; 3; 3; -0.7; 0.1; -2e-3; 0; 3.6; 0.8; 3.6; 0.8];
	% x0 = rand(feval(DAE.nunks, DAE),1);
	qss = feval(qss.solve, qss);
	feval(qss.print, qss);
	sol = feval(qss.getsolution, qss);

	fprintf(2, '\nOperating point analysis done, hit Return to continue:\n'); pause;
end

if 1 == doDCsweep
	fprintf(2, 'Running a DC sweep analysis:\n');

	% DC sweep
	DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'IS:::I', 2e-3, DAE);
	%
	%DAE = feval(DAE.set_uQSS, 'Vin:::E', 0.1, DAE);

	x0 = [5; 3; 3; -0.7; 0.1; -2e-3; 0; 3.7; 0.1; 3.7; 0.1];

	N = 100;
	VinMAX = 1;
	Vins = VinMAX*((0:N)/N*2 - 1); % -VinMAX to +VinMAX range of Vins

	DCsols = [];
	DCus = [];
	for Vin = Vins
		fprintf(1, 'doing Vin = %0.3g:\t', Vin);
		DAE = feval(DAE.set_uQSS, 'Vin:::E', Vin, DAE);
		qss = QSS(DAE);
		qss.NRparms.dbglvl = 1;
		qss.NRparms.maxiter = 100;
		qss.NRparms.do_limiting = 0;
		qss.NRparms.do_initializing = 0;
		qss = feval(qss.solve, x0, qss);
		x0 = feval(qss.getsolution, qss);
		DCsols = [DCsols, x0];
		DCus = [DCus, feval(DAE.uQSS, DAE)];
		fprintf(1, '\n', Vin);
	end

	idx_L = unkidx_DAEAPI('e_DL', DAE);
	idx_R = unkidx_DAEAPI('e_DR', DAE);
	idx_S = unkidx_DAEAPI('e_S', DAE);

	plot(Vins, DCsols(idx_L,:), 'b.-');
	hold on;
	plot(Vins, DCsols(idx_R,:), 'r.-');
	plot(Vins, DCsols(idx_S,:), 'k.-');
	legend({'e_{DL}', 'e_{DR}', 'e_S'});
	xlabel('Vin');
	ylabel('node voltages');
	title('SH diffpair: DC sweep vs Vin');
	grid on; axis tight;

	fprintf(2, '\nDC sweep analysis done, hit Return to continue:\n'); pause;
end

if 1 == doAC
	oppts = [DCsols(:,floor(N/2)+1), DCsols(:,1), DCsols(:,end)];
	opptus = [DCus(:,floor(N/2)+1), DCus(:,1), DCus(:,end)];
	nops = size(oppts,2);
	fprintf(2, 'Running AC analyses at %d different operating points:\n', nops);

	% set AC inputs
	constfunc = @(f, args) 1;
	DAE = feval(DAE.set_uLTISSS, 'Vin:::E', constfunc, [], DAE);

	for i = 1:nops
		op = oppts(:,i);
		us = opptus(:,i); % DC input vals

		AC = LTISSS(DAE, op, us);
		sweeptype = 'DEC'; % decade plot
		fstart=1; fstop=1e12; nsteps=5;% 5 pts/decade
		AC=feval(AC.solve, fstart, fstop, nsteps, sweeptype, AC);
		feval(AC.plot, AC, outputs); 
	end
	fprintf(2, '\nAC analyses done, hit Return to continue:\n'); pause;
end

if 1 == doTran
	fprintf(2, 'Running transient analysis\n');

	% set transient inputs
	args.f = 1000;
	args.A = 0.5;
	sinfunc = @(t, args) args.A*sin(args.f*2*pi*t);
	DAE = feval(DAE.set_utransient, 'Vin:::E', sinfunc, args, DAE);

	%{
	pulsefunc = @(t, args) args.A*pulse(args.f*t, 0, 0.1, 0.5, 0.6);
	DAE = feval(DAE.set_utransient, 'Vin:::E', pulsefunc, args, DAE);
	%}

	DAE = feval(DAE.set_utransient, 'vdd:::E', @(t,a) 5, [], DAE);
	DAE = feval(DAE.set_utransient, 'IS:::I', @(t,a) 2e-3, [], DAE);

	%{
	% change load resistances/caps and value of current source
	DAE = feval(DAE.setparms, 'R1:::R', 500, DAE);
	DAE = feval(DAE.setparms, 'R2:::R', 500, DAE);
	DAE = feval(DAE.setparms, 'C1:::C', 0.1e-6, DAE);
	DAE = feval(DAE.setparms, 'C2:::C', 0.1e-6, DAE);
	DAE = feval(DAE.set_utransient, 'IS:::I', @(t,a) 8e-3, [], DAE);
	%}

	% do a DC with uDC set to u(tstart)
	tstart=0;
	uDC = feval(DAE.utransient, tstart, DAE);
	DAE = feval(DAE.set_uQSS, uDC, DAE);
	qss = QSS(DAE); qss = feval(qss.solve, x0, qss);
	x0 = feval(qss.getsolution, qss);

	TRmethods = LMSmethods(); % defines FE, BE, TRAP, GEAR2
	GEAR2= LMS(DAE, TRmethods.GEAR2); %GEAR2
	Trans = GEAR2;
	%Trans.tranparms.stepControlParms.doStepControl=0;

	tstep=0.2e-4; tstop=10e-3;
	Trans = feval(Trans.solve, Trans, x0, tstart, tstep, tstop);
	outputs = feval(outputs.Add, {'e_{Vin}'}, outputs);
	[thefig,legends] = feval(Trans.plot, Trans, outputs);

	fprintf(2, '\nTransient analyses done.');
end
