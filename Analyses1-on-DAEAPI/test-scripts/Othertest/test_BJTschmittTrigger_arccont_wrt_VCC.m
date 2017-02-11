DAE = BJTschmittTrigger('BJTschmittTrigger');
outs = StateOutputs(DAE);

if 1 == 1
	Vinval = 0.6; % Vinval in the range 0.6 to 1 show turning points wrt VCC
	DAE = feval(DAE.set_uQSS, 'Vin', Vinval, DAE); 
	StartLambda = 0; % start at VCC = 0
	StopLambda = 5; % stop at VCC = 5
	initDeltaLambda = 1e-1;
	diodedrop = 0.7;
	initguess = [Vinval-diodedrop; Vinval-diodedrop; ...
			0.75*(Vinval-diodedrop); ...
			0.75*(Vinval-diodedrop)-diodedrop];
else
	Vinval = 0;
	DAE = feval(DAE.set_uQSS, 'Vin', Vinval, DAE); 
	StartLambda = 0; % start at VCC = 0
	StopLambda = 5; % stop at VCC = 5
	initDeltaLambda = 1e-1;
	initguess = [0;0;0;0];
end

inputORparam = 0; % lambda is a parameter (VCC)
contAnal = ArcContAnalysis(DAE, 'VCC', inputORparam);

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
