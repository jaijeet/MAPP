%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running transient analysis on a BJT Schmitt Trigger
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% set up DAE
DAE =  BJTschmittTrigger('BJTschmittTrigger');

% set transient input to the DAE
utargs = [];
utfunc = @(t, args) 0.5 + (2.5-0.5)*pulse(t/1e-4, 0.1, 0.4, 0.5, 0.9);
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

% Do a DC at input 0.0
Vin = feval(utfunc, 0.5, utargs);
DAE = feval(DAE.set_uQSS, Vin, DAE);
qss = QSS(DAE);
%initguess = feval(DAE.QSSinitGuess, Vin, DAE);
initguess = [5; 3; 3.75; 3];
qss = feval(qss.solve, initguess, qss);
% feval(qss.print, stateoutputs, qss);
xinit = feval(qss.getSolution, qss)


% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, but it also defines
                     % TRAPparms, FEparms, GEAR2Parms
TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
LMStranparms = TransObjBE.tranparms; % has tranparms.NRparms
LMStranparms.NRparms.limiting = 1;
LMStranparms.stepControlParms.MaxStepFactor = 1;
LMStranparms.stepControlParms.increaseFactor = 1.05;
TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);

% run transient and plot
tstart = 0; tstep = 0.1e-6; tstop = 2.1e-4;
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
      xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);

hold on;
[tpts, transsol] = feval(TransObjTRAP.getsolution, TransObjTRAP);
inputvals = feval(utfunc, tpts, utargs);
plot(tpts, inputvals, 'k.');
legends = {legends{:}, 'input'};
legend(legends);

figure;
plot(inputvals, transsol(4,:), '.-');
xlabel('Vin');
ylabel('Vout');
title('BJTschmittTrigger: hysteresis in Vin vs Vout characteristic');
grid on; axis tight;
