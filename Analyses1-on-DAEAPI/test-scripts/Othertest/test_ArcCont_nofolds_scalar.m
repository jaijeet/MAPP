% g(x, lambda) = x^3 - 1 - lambda
%

% flexOutputs enables nargout processing in NR to work
g_h = @(y, args) flexOutput(y(1,1)^3 - 1 - y(2,1),[]);
dg_dxLambda_h = @(y, args) flexOutput([3*y(1,1)^2, -1],[]);

contObj = ArcCont(g_h, dg_dxLambda_h, []);

initguess = 0.5; 
contObj = feval(contObj.solve, contObj, initguess);
[spts, yvals, finalSol] = feval(contObj.getsolution, contObj);

plot(yvals(2,:), yvals(1,:), 'b.-');
xlabel('\lambda(s)');
ylabel('x(s)');
title('ArcCont run on g(x,\lambda)=x^3-1-\lambda');
grid on; axis tight;
