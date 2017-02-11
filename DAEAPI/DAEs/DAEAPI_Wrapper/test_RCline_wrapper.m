% setup DAE
DAE = RCline_wrapper();

%%%%%%%%%%%%%%%%%%%%%%% DC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute QSS (DC) solution
uDC = 1; 
DAE = feval(DAE.set_uQSS, uDC, DAE);
qss = dot_op(DAE);
qssSol = feval(qss.getSolution, qss);

%%%%%%%%%%%%%%%%%%%%%%% AC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set AC analysis input as a function of frequency
Ufargs.string = 'no args used';; % 
Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);

% run the AC analysis
sweeptype = 'DEC'; fstart=1; fstop=1e5; nsteps=20;
acobj = dot_ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);

% plot frequency sweeps of system outputs 
feval(acobj.plot, acobj);

%%%%%%%%%%%%%%%%%%%%%%% Transient %%%%%%%%%%%%%%%%%%%%%%%%%
% setup transient input to the DAE
utargs.A = 1; utargs.f = 1e3; utargs.phi = 0;
utfunc = @(t,args) args.A*sin(2*pi*args.f*t+args.phi);
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

% setup transient parm
xinit = zeros(feval(DAE.nunks, DAE),1); 
tstart = 0; tstep = 10e-6; tstop = 5e-3;

% set up and run the transient analysis
LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);

% plot transient results (only the defined DAE outputs)
feval(LMSobj.plot, LMSobj);


