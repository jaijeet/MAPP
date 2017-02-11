DAE = BJTschmittTrigger('BJTschmittTrigger');
DAE = set_uQSS(0, DAE);

outs = StateOutputs(DAE);

inputORparam = 1; % lambda is an input
contAnal = ArcContAnalysis(DAE, 'Vin', inputORparam);

if 0 == 1
	StartLambda = 0;
	StopLambda = 5;
	initDeltaLambda = 1e-1;
	initguess = [5; 3; 3.75; 3];
else 	% this breaks; there comes a point when delta_lambda remains
	% large in spite of smaller and smaller s-steps. Why this happens is
	% not clear; maybe there's a bug in LMS. Or maybe NR tolerances need
	% tightening (maybe related to scaling).
	% update: it now works, see comments below
	StartLambda = 5;
	StopLambda = 0;
	initDeltaLambda = 1e-2; % this is important in determining the
				% max step size
	initguess = [4.3656;4.3678;3.2742;5.0000]; % this initguess is very 
			% twitchy, it had to be found by continuation forward
	%contAnal.parms.NRparms.reltol = 1e-9;
	%contAnal.parms.NRparms.abstol = 1e-14;
	%contAnal.parms.tranparms.stepControlParms.increaseFactor = 1.01;
	contAnal.parms.maxDeltaLambda = 0.01; % this is what finally made it
					      % work
end

contAnal = feval(contAnal.solve, contAnal, initguess, ...
		 StartLambda, StopLambda, initDeltaLambda);
contAnal.ArcContObj.ArcContParms.dbglvl = 2;
sol = feval(contAnal.getsolution, contAnal);

% plots
feval(contAnal.plotVsArcLen, contAnal, outs); % vs arclength
feval(contAnal.plot, contAnal, outs); % vs lambda

spts = sol.spts;
yvals = sol.yvals;
finalSol = sol.finalSol
