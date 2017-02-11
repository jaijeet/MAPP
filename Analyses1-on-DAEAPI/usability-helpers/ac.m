function  acobj = ac(DAE, QSSsol, QSSu, fstart, fstop, nsteps, sweeptype)
%function  acobj = ac(DAE, QSSsol, QSSu, fstart, fstop, nsteps, sweeptype)
%Run an AC analysis on a DAE.
%
%AC analysis (better termed Linear Time Invariant Sinusoidal Steady State or
%LTISSS analysis) analyses a circuit/system by first linearizing it about a DC
%operating point, then solving the linearized circuit for its transfer
%function at a number of frequency points chosen by the user. The complex
%numbers computed by AC analysis represent phasors. AC analysis is equivalent
%to computing the steady-steady response of a linear time-invariant system to 
%sinusoidal inputs.
%
%Note: ac is just a wrapper function that calls LTISSS - help LTISSS for
%more information.
%
%
%Arguments:
%  - DAE:       A DAEAPI structure/object (see help DAEAPI). Note: the DAE
%               should already have LTISSS inputs set using set_uLTISSS.
%
%  - QSSsol:    state value around which to linearize the DAE. Should be a
%               vector with number of entries (rows) equal to feval(DAE.nunks,
%               DAE).  This should be the solution of a QSS (aka DC) analysis,
%               obtained via QSSsol = feval(QSSobj.getsolution, QSSobj); after
%               a successful QSS analysis (see help QSS, help op).
%
%  - QSSu:      (needed only if DAE.f_takes_inputs == 1) The QSS (DC) inputs
%               to the DAE that led to QSSsol. These can be obtained from the
%               DAE via: QSSu = feval(DAE.uQSS, DAE);
%
%  - fstart:    start frequency for the LTISSS/AC sweep.
%
%  - fstop:     stop frequency for the LTISSS/AC sweep.
%
%  - nsteps:    number of frequency steps to take (per decade if 
%               sweeptype=='DEC'; if sweeptype=='LIN', then the total number
%               of steps).
%
%  - sweeptype: a string: 'LIN' (for a linear frequency sweep)
%               or 'DEC' (for logarithmically spaced frequency points). 'DEC'
%	        is typically preferred for Bode plots.
%
%
%Output:
%  - acobj:     an LTISSS object (containing the AC analysis solution). Use 
%	     		feval(LTISSSobj.plot, LTISSSobj) 
%               to plot results, or 
%                      [freqs, vals] = feval(LTISSSobj.getsolution,
%                      LTISSSobj); to obtain the freq points and complex
%               values from LTISSS analysis.
%
%Examples
%--------
%
% %%%%% set up DAE and state outputs
% nsegs = 5; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
% stateoutputs = StateOutputs(DAE);
% 
% %%%%% compute QSS (DC) solution
% uDC = 1; DAE = feval(DAE.set_uQSS, uDC, DAE);
% qss = op(DAE);
% qssSol = feval(qss.getSolution, qss);
% % feval(qss.print, stateoutputs, qss);
%
% % set AC analysis input as a function of frequency
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
% DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);
%
% % run the AC analysis
% sweeptype = 'DEC'; fstart=1; fstop=1e3; nsteps=10;
% acobj = ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
%
% % plot frequency sweeps of system outputs (overlay all on 1 plot)
% feval(acobj.plot, acobj);
%
% % plot frequency sweeps of state variable outputs (overlay on 1 plot)
% feval(acobj.plot, acobj, stateoutputs);
%
% % print results for all stateouputs
% feval(acobj.print, acobj, StateOutputs(DAE));
%
% %get the solution
% [fpts, sol_at_all_fs] = feval(acobj.getsolution, ac); % n x #fpts matrix
%
%
%
%See also
%--------
%
%  LTISSS, LTISSS::LTISSSplot, LTISSS::LTISSSprint, op, QSS, uLTISSS,
%  set_uLTISSS.
%            




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%

	acobj = LTISSS(DAE, QSSsol, QSSu);
	acobj = feval(acobj.solve, fstart, fstop, nsteps, sweeptype, acobj);
end % ac
