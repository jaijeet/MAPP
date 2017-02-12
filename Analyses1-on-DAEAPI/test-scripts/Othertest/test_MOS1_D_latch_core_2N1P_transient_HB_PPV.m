%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/05/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Changelog
%---------
%2015/01/07: Jaijeet Roychowdhury <jr@berkeley.edu>: added DCguess arg to
%            HB_initguess
%2014/09/12: Tianshi Wang <tianshi@berkeley.edu>: changed to MOS1 from DAAV6
%2011/05/sometime: Jaijeet Roychowdhury <jr@berkeley.edu>
 
DAE = MNA_EqnEngine(MOS1_D_latch_core_2N1P_ckt);                

% set DC and transient inputs for VDD
DAE = feval(DAE.set_uQSS, 'Vdd:::E', 3, DAE);
% DAE = feval(DAE.set_uQSS, 'Isync:::I', 0, DAE);
const_func = @(t,args) 3;
zero_func = @(t, args) 0;
DAE = feval(DAE.set_utransient, 'V1:::E', const_func, [], DAE);
DAE = feval(DAE.set_utransient, 'V2:::E', zero_func, [], DAE);
% DAE = feval(DAE.set_utransient, 'Isync:::I', zero_func, [], DAE);

% DAE = feval(DAE.set_uHB, 'Isync:::I', zero_func, [], DAE);
DAE = feval(DAE.set_uHB, 'Vdd:::E', const_func, [], DAE);
DAE = feval(DAE.set_uHB, 'V1:::E', const_func, [], DAE);
DAE = feval(DAE.set_uHB, 'V2:::E', zero_func, [], DAE);

% run DC
qss = QSS(DAE);
qss = feval(qss.solve, qss);
%feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);

outs = StateOutputs(DAE);
outs = feval(outs.DeleteAll, outs);
outs = feval(outs.Add, {'e_inv1out'}, outs);

% HB
isOsc = 1;
NRparms = defaultNRparms(); NRparms.maxiter = 50; NRparms.residualtol = 1e-12;
NRparms.abstol = 1e-10; NRparms.reltol = 1e-6;
hb = HB(DAE, isOsc, NRparms);

f0=12.5e3;
M=20;
transient_initcond = rand(size(DCsol));
DConly = 'transient';
cycles = 2;
tsteps_per_cycle = 20;
cycles_to_skip = 0;
harmonics_to_keep = M;
doplot = 1;
Xinitguess_Nn = HB_initguess(DAE, f0, M, ... % remaining args are optional
    DCsol, ...
	transient_initcond, DConly, cycles, tsteps_per_cycle, ...
    cycles_to_skip, harmonics_to_keep, doplot);
drawnow;

% run HB with DC initguess
fprintf(1,'\nrunning HB...\n');
hb = feval(hb.solve, hb, Xinitguess_Nn, M, f0);
fprintf(1,'\nHB run completed.\n');

sol = feval(hb.getsolution, hb);
ppv = compute_PPV_FD(sol, DAE);
feval(ppv.plot, ppv);
