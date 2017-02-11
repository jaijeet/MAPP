%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script to run transient analysis on a Schmitt Trigger based on BJT  differential pair
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% set up DAE
DAE =  BJTdiffpairSchmittTrigger('BJTdiffpairSchmittTrigger');

% set transient input to the DAE
utargs.A = 1; utargs.f=1e3; utargs.phi=0; 
utargs.A = 0.2; utargs.f=1e3; utargs.phi=0; 
utargs.A = 0.5; utargs.f=1e1; utargs.phi=0; 
%utargs.A = 0.1; utargs.f=1e2; utargs.phi=0; 
%utargs.A = 0.01; utargs.f=1e2; utargs.phi=0; 
utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, but it also defines
                     % TRAPparms, FEparms, GEAR2Parms
TRmethod = TransObjBE.TRmethod; % contains order, alphas, betas of LMS method
LMStranparms = TransObjBE.tranparms; % has tranparms.NRparms
LMStranparms.NRparms.limiting = 1;
LMStranparms.stepControlParms.doStepControl = 1;
TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);

% run transient and plot
xinit = [2; 2; -0.7]; % BE works, TRAP doesn't
xinit = [3; 3; -0.5]; % BE and TRAP both work
%xinit = zeros(feval(DAE.nunks,DAE),1); breaks both BE and TRAP
tstart = 0;
%tstep = 10e-6; tstop = 5e-3;
%tstep = 10e-5; tstop = 5e-2;
tstep = 20e-5; tstop = 2e-1;
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
      xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);

if 0 == 1
	% multiple overlaid plots:
	TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ...
				tstep, tstop);
	[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE'); % BE plots
	%[thefig, legends] = feval(TransObjFE.plot, TransObjFE,  [], 'FE', 'x-', ...
	%				thefig, legends); 
	%% FE plots, overlaid
	[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], ...
					'TRAP', 'o-', thefig, legends); 
	% TRAP plots, overlaid
	title(sprintf('BE and TRAP on %s', feval(DAE.daename,DAE)));
else
	title(sprintf('TRAP on %s', feval(DAE.daename,DAE)));
end

hold on;
[tpts, transsol] = feval(TransObjTRAP.getsolution, TransObjTRAP);
inputvals = feval(utfunc, tpts, utargs);
plot(tpts, inputvals, 'k.');
legends = {legends{:}, 'input'};
legend(legends);

figure;
plot(inputvals, transsol(1,:)-transsol(2,:), '.-');
xlabel('Vin');
ylabel('Vout');
title('BJTdiffpairSchmittTrigger: hysteresis in Vin vs Vout characteristic');
grid on; axis tight;
