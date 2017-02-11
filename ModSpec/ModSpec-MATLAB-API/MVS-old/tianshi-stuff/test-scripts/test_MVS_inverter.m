% set up DAE %
% DAE = MNA_EqnEngine(MVS_1_0_1_5_inverter_ckt);
% DAE = MNA_EqnEngine(MVS_1_0_1_6_inverter_ckt);
% DAE = MNA_EqnEngine(MVS_1_0_1_8_inverter_ckt);
% DAE = MNA_EqnEngine(MVS_1_0_1_9_inverter_ckt);
DAE = MNA_EqnEngine(MVS_1_0_1_11_inverter_ckt);


% OP %
DAE = feval(DAE.set_uQSS, 'Vin:::E', 0.0, DAE);

qss = dot_op(DAE);
% print DC operating point
feval(qss.print, qss);
qssSol = feval(qss.getsolution, qss);




% DC sweep %
swp = dot_dcsweep(DAE, [], 'Vin:::E', 0, 1, 20);
feval(swp.plot, swp);



% transient %
tic;
tstart = 0; tstep = 1e-12; tstop = 0.2e-9;                     
TransObj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
feval(TransObj.plot, TransObj);

dot_transient_time = toc;

[tpts, vals] = feval(TransObj.getsolution, TransObj);
n = length(tpts);

fprintf(1, 'dot_transient took %gs for %d timepoints = %gs/timepoint\n', ...
		dot_transient_time, n, dot_transient_time/n);


% run ode15s using the wrapper ODEXY. help ODEXY for details.
trans = ODEXY(DAE);
tic;
tstart = 0; tstep = 1e-12; tstop = 0.2e-9;                     
trans = feval(trans.solve, trans, qssSol, tstart, tstep, tstop);
feval(trans.plot, trans);
ode15s_tot_time = toc;

[tpts, vals] = feval(trans.getsolution, trans);
n = length(tpts);

fprintf(1, 'ODE15 took %gs for %d timepoints = %gs/timepoint\n', ...
		ode15s_tot_time, n, ode15s_tot_time/n);
