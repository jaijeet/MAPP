DAE = nestedFoldsDAE('nestedFoldsDAE');
DAE = set_uQSS(0, DAE);

inputORparam = 1; % lambda is an input
contAnal = ArcContAnalysis(DAE, 'lambda', inputORparam);
%contAnal.ArcContObj.ArcContParms

outs = StateOutputs(DAE);

StartLambda = -1;
StopLambda = 1;
initDeltaLambda = 1e-2;
initguess = [-1; -1]; 

contAnal = feval(contAnal.solve, contAnal, initguess, StartLambda, StopLambda, initDeltaLambda);
sol = feval(contAnal.getsolution, contAnal);

% plots
feval(contAnal.plotVsArcLen, contAnal); % vs arclength
feval(contAnal.plot, contAnal); % vs lambda

spts = sol.spts;
yvals = sol.yvals;
finalSol = sol.finalSol
