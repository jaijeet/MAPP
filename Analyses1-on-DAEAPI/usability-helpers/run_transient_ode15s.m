function trans = run_transient_ode15s(DAE, xinit, tstart, tstep, tstop)
%function trans = run_transient_ode15s(DAE, xinit, tstart, tstep, tstop)
%This usability function uses ODEXY with ode15s to solve the DAE.
%
%INPUTS args:
%   DAE                 - A MATLAB DAE object
%   xinit               - initial conditions to run the transient analysis. Set
%                         this to [] if you want a DC operating point computed
%                         at tstart (with DC inputs = transient input at
%                         tstart) and used as initial condition. Recommended
%                         if ode15s aborts with an initial condition
%                         consistency error.

%   tstart              - start time for transient analysis
%   tstep               - time step for transient analysis
%   tstop               - stop time for transient analysis 
%
%OUTPUT:
%   trans               - Transient object with transient analysis solution
%
%
%Example use:
%
% DAE = BJTdiffpairSchmittTrigger();
% trans = run_transient_ode15s(DAE, [], 0, 1e-5, 10e-3);
% feval(trans.plot, trans);
%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






 	tranparms.MaxStep = tstep;
 	%tranparms.BDF = 'on';
	if isempty(xinit)
		DAE = feval(DAE.set_uQSS, feval(DAE.utransient, tstart, DAE), DAE);
		qss = QSS(DAE); qss = feval(qss.solve, qss); 
		xinit = feval(qss.getsolution, qss);
		fprintf(2, 'QSS analysis completed, starting transient...\n');
	end

	trans = ODEXY(DAE, [], tranparms);
	trans = feval(trans.solve, trans, xinit, tstart, tstep, tstop);
	fprintf(2, '...transient finished.\n');
end

