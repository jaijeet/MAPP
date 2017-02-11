%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running transient analysis on a two reaction chain 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% set up DAE
DAE =  TwoReactionChainDAEAPI_wrapper();

% no input - just initial conditions

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, but it also defines
                     % TRAPparms, FEparms, GEAR2Parms
TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
LMStranparms = TransObjBE.tranparms; % has tranparms.NRparms
LMStranparms.NRparms.limiting = 1;
TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);

% run transient and plot
xinit = [0.9; 0.8; 0.7; 0.6; 0.5];
tstart = 0;
tstep = 0.05; tstop = 6;
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
      xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);

[tpts, vals] = feval(TransObjTRAP.getsolution, TransObjTRAP);
fprintf(2, 'last timepoint:\n');
vals(:,end)

% multiple overlaid plots:
%TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ...
%			tstep, tstop);
%[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE'); % BE plots
%[thefig, legends] = feval(TransObjFE.plot, TransObjFE,  [], 'FE', 'x-', ...
%				thefig, legends); 
%% FE plots, overlaid
%[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], ...
%				'TRAP', 'o-', thefig, legends); 
% TRAP plots, overlaid
%title(sprintf('BE and TRAP on %s', feval(DAE.daename,DAE)));
