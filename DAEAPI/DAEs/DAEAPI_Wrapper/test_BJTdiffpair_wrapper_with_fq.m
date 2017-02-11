function test_BJTdiffpair_wrapper_with_fq(arg)

% set up DAE
DAE =  BJTdiffpair_wrapper_with_fq();

% set transient input to the DAE
utargs.A = 1; utargs.f=1e3; utargs.phi=0; 
utargs.A = 0.2; utargs.f=1e3; utargs.phi=0; 
utargs.A = 0.2; utargs.f=1e2; utargs.phi=0; 
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
TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms);

% run transient and plot
xinit = [2; 2; -0.7; 0]; % BE works, TRAP doesn't
xinit = [3; 3; -0.5; 0]; % BE and TRAP both work
%xinit = zeros(feval(DAE.nunks,DAE),1); breaks both BE and TRAP
tstart = 0;
%tstep = 10e-6; tstop = 5e-3;
tstep = 10e-5; tstop = 5e-2;
TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
      xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);

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



