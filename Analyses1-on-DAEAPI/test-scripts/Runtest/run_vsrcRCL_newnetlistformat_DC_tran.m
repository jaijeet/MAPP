% set up DAE
more off;
clear; % clear cktdata, TODO: make MNAEqnEngine_vsrcRCL_newnetlistformat a function 
vsrcRCL_newnetlistformat;
DAE =  MNA_EqnEngine(cktdata);

dcop = dot_op(DAE);
feval(dcop.print, dcop);

xinit = feval(dcop.getsolution, dcop);

tstart = 0; tstep = 1e-5; tstop = 1e-3;
LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
feval(LMSobj.plot, LMSobj);
