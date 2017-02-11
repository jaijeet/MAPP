%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script to run transient on AtoB_RRE DAE (simple reaction model)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






DAE = AtoB_RRE();

qss = QSS(DAE);
qss = feval(qss.solve, qss);
fprintf(1, 'failure of QSS is expected: this is an RRE\n');

xinit = rand(2,1);
tstart = 0;
tstop = 10;
tstep = 0.05;


TransObjGEAR2 = run_transient_GEAR2(DAE, xinit, tstart, tstep, tstop);

%{
outs = StateOutputs(DAE);
outs = feval(outs.DeleteAll, outs);
outs = feval(outs.Add, {'e_inv1', 'e_inv2', 'e_inv3'}, outs);

[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2, outs);
%}

[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2);
