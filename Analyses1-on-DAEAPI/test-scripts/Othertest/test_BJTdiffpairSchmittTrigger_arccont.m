DAE = BJTdiffpairSchmittTrigger('BJTdiffpairSchmittTrigger');
DAE = set_uQSS(0, DAE);

allouts = StateOutputs(DAE);
outs = feval(allouts.Delete, {'eE'}, allouts);

inputORparam = 1; % lambda is an input
contAnal = ArcContAnalysis(DAE, 'Vin', inputORparam);
%contAnal.ArcContObj.ArcContParms

if 1 == 1
	StartLambda = -0.5;
	StopLambda = 0.5;
	initDeltaLambda = 1e-2;
	initguess = [4; 2; -0.7]; 
else
	% this fails with a timestep control error
	StartLambda = 0.5;
	StopLambda = -0.5;
	initDeltaLambda = 1e-2;
	initguess = [2; 4; -0.1]; 
end

contAnal = feval(contAnal.solve, contAnal, initguess, StartLambda, StopLambda, initDeltaLambda);
sol = feval(contAnal.getsolution, contAnal);

spts = sol.spts;
yvals = sol.yvals;
finalSol = sol.finalSol;

% plots of output
feval(contAnal.plotVsArcLen, contAnal); % vs arclength
feval(contAnal.plot, contAnal); % vs lambda

% plots of all stateputs
feval(contAnal.plotVsArcLen, contAnal, allouts); % vs arclength
feval(contAnal.plot, contAnal, allouts); % vs lambda

% plots of some stateoutputs
feval(contAnal.plot, contAnal, outs); % vs lambda
