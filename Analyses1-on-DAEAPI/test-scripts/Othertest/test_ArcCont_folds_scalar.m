% a function with folds (wrt lambda):
% 0.5*x + tanh(-x) has a max and a min as a function of x, somewhere in the range [-1, 1]
% g(x, lambda) = 0.5*x + tanh(-x) - lambda = 0 should have folds
slope = 0.5;
%slope = 0.99;
g_h = @(y, args) y(1,1)*slope + tanh(-y(1,1)) - y(2,1);
dg_dxLambda_h = @(y, args) [slope-dtanh(-y(1,1)), -1];

contObj = ArcCont(g_h, dg_dxLambda_h, []);
parms = contObj.ArcContParms;
parms.StartLambda = -1;
parms.StopLambda = 1;
contObj = ArcCont(g_h, dg_dxLambda_h, [], parms);

initguess = -1; 
contObj = feval(contObj.solve, contObj, initguess);
[spts, yvals, finalSol] = feval(contObj.getsolution, contObj);

plot(yvals(2,:), yvals(1,:), 'b.-');
xlabel('\lambda(s)');
ylabel('x(s)');
title('ArcCont run on g(x,\lambda)=x/2+tanh(-x)-\lambda');
grid on; axis tight;
