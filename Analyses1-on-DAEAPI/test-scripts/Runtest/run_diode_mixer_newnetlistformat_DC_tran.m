% set up DAE
more off;
DAE =  MNA_EqnEngine(diode_mixer_newnetlistformat());

dcop = dot_op(DAE);
feval(dcop.print, dcop);

xinit = feval(dcop.getsolution, dcop);

tstart = 0; tstep = 1e-10; tstop = 5e-9;
LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
feval(LMSobj.plot, LMSobj);

% Authot: Tianshi Wang, 2013/09/28
