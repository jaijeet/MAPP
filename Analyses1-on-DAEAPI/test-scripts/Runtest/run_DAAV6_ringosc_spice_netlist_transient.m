%
% Test script for running transient simulation for a ring oscillator  using DAAV6   model
 global PARSERLIBPATH; % set up in setuppaths_DAEAPI
netlist = sprintf('%s/netlists/netlist_daav6_ringosc.sp', PARSERLIBPATH);
DAE = readSPICE(netlist);
tstart = 0;
tstep = 1e-13;
tstop = 2e-12;
tran = dot_transient(rand(feval(DAE.nunks,DAE),1), tstart, tstep, tstop, DAE);
feval(tran.plot, tran);
