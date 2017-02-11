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
%2014/07/15: Tianshi Wang <tianshi@berkeley.edu>: changed to MOS1 from DAAV6
%2011/05/sometime: Jaijeet Roychowdhury <jr@berkeley.edu>
 

DAE = MNA_EqnEngine(MOS1ringOsc3_w_input_ckt);

% set DC and transient inputs for VDD
DAE = feval(DAE.set_uQSS, 'Vdd:::E', 3, DAE);
DAE = feval(DAE.set_uQSS, 'Isync:::I', 0, DAE);
const_func = @(t,args) 3;
zero_func = @(t, args) 0;
DAE = feval(DAE.set_utransient, 'Vdd:::E', const_func, [], DAE);
DAE = feval(DAE.set_utransient, 'Isync:::I', zero_func, [], DAE);
DAE = feval(DAE.set_uHB, 'Vdd:::E', const_func, [], DAE);
DAE = feval(DAE.set_uHB, 'Isync:::I', zero_func, [], DAE);

% run DC
qss = QSS(DAE);
qss = feval(qss.solve, qss);
%feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);


outs = StateOutputs(DAE);
outs = feval(outs.DeleteAll, outs);
outs = feval(outs.Add, {'e_inv1', 'e_inv2', 'e_inv3'}, outs);


if 1 == 0
	% run transient and plot
	xinit = 0*DCsol;
	xinit = rand(size(DCsol));
    tstart = 0; tstep = 1e-6; tstop = 3e-4;
	trans = run_transient_GEAR2(xinit, tstart, tstep, tstop, DAE);
	[thefig, legends] = feval(trans.plot, trans, outs);
	%
	% T from eyeballing the above is about 1.05e-04
	%
end %

% HB
isOsc = 1;
NRparms = defaultNRparms(); NRparms.maxiter = 50; NRparms.residualtol = 1e-12;
NRparms.abstol = 1e-10; NRparms.reltol = 1e-6;
hb = HB(DAE, isOsc, NRparms);

T=1.05e-04; % eyeballed from transient
f0=1/T; % this is a good guess for the oscillator's period based on eyeballing the transient
M=20;
transient_initguess = rand(size(DCsol));
DConly = 'transient';
cycles = 2;
tsteps_per_cycle = 20;
cycles_to_skip = 0;
harmonics_to_keep = M;
doplot = 1;
Xinitguess_Nn = HB_initguess(DAE, f0, M, ... % remaining args are optional
	DCsol, ...
    transient_initguess, DConly, cycles, tsteps_per_cycle, cycles_to_skip, harmonics_to_keep, doplot);
drawnow;

% run HB with DC initguess
fprintf(1,'\nrunning HB...\n');
hb = feval(hb.solve, hb, Xinitguess_Nn, M, f0);
fprintf(1,'\nHB run completed.\n');

sol = feval(hb.getsolution, hb);
ppv = compute_PPV_FD(sol, DAE);
feval(ppv.plot, ppv);
