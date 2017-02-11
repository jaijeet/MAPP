%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running transient analysis on an inverter chain 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






nstages = 10;
VDD = 1.2;
betaN = 1e-3;
betaP = 1e-3;
VTN = 0.25;
VTP = 0.25;
RDSN = 5000;
RDSP = 5000;
CL = 1e-7;

% set up DAE
DAE = inverterchain('somename',nstages, VDD, betaN, betaP, VTN, VTP, RDSN, RDSP, CL); % API v6.2

% set transient input to the DAE
utargs.A = 0.5; utargs.offset = 0.5; utargs.f=2e2; utargs.phi=0; 
utfunc = @(t, args) args.offset + args.A*cos(2*pi*args.f*t + args.phi);
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, but it also defines
                     % TRAPparms, FEparms, GEAR2Parms
%TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
LMStranparms = TransObjBE.tranparms; % has tranparms.NRparms
LMStranparms.NRparms.limiting = 1;
LMStranparms.NRparms.dbglvl = 1;
LMStranparms.trandbglvl = 1;

TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);
TransObjGEAR2 = LMS(DAE,TransObjBE.GEAR2parms, LMStranparms);

% run transient and plot
xinit = zeros(feval(DAE.nunks,DAE),1);
tstart = 0;
%tstep = 10e-6; tstop = 5e-2;
tstep = 10e-5; tstop = 5e-2;

% Gear2
%TransObjGEAR2 = feval(TransObjGEAR2.solve, TransObjGEAR2, xinit, tstart, tstep, tstop);
%[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2);
%title(sprintf('GEAR2 on %s', feval(DAE.daename,DAE)));

% TRAP
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, xinit, tstart, tstep, tstop);
%[thefig, legends, colindex] = feval(TransObjTRAP.plot, TransObjTRAP);
%title(sprintf('TRAP on %s', feval(DAE.daename,DAE)));

% plot a few selected nodes
outputs = StateOutputs(DAE);
outputs = feval(outputs.DeleteAll, outputs); % clears all variables to print/plot
%outputs = feval(outputs.Reset, outputs; % restores all outputs to dae outputs
outputs = feval(outputs.Add, {'e1', 'e2', 'e5', 'e10'}, outputs);
[thefig, legends, colindex] = feval(TransObjTRAP.plot, TransObjTRAP, outputs);


% multiple overlaid plots:
%TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, tstep, tstop);
%[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE'); % BE plots
%
%[thefig, legends] = feval(TransObjFE.plot, TransObjFE,  [], 'FE', 'x-', ...
%				thefig, legends); 
%% FE plots, overlaid
%[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], 'TRAP', 'o-', thefig, legends); 
%
% TRAP plots, overlaid
%[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2, [], 'GEAR2', 'o-', thefig, legends); 
% GEAR2 plots, overlaid
%title(sprintf('TRAP, BE and GEAR2 on %s', feval(DAE.daename,DAE)));
