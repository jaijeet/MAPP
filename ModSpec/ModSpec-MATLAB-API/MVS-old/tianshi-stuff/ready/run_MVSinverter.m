% set up DAE %
DAE = MNA_EqnEngine(MVSinverter_ckt);

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
tstart = 0; tstep = 1e-12; tstop = 0.1e-9;                     
TransObj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
feval(TransObj.plot, TransObj);
