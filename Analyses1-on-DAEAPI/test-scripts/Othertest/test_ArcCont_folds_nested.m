% a function with folds (wrt lambda):
% 0.5*x + tanh(-x) has a max and a min as a function of x, somewhere in the range [-1, 1]
% g(x, lambda) = 0.5*x + tanh(-x) - lambda = 0 should have folds
slope1 = 0.5;%0.9;
slope2 = 0.3;
g_h = @(y, args) [y(1,1)*slope1 + tanh(-y(1,1)) - y(3,1); y(2,1)*slope2 + tanh(-y(2,1)) - y(3,1)];
dg_dxLambda_h = @(y, args) [slope1-dtanh(-y(1,1)), 0, -1; 0, slope2-dtanh(-y(2,1)), -1];

contObj = ArcCont(g_h, dg_dxLambda_h, []);
parms = contObj.ArcContParms;
parms.StartLambda = -1;
parms.StopLambda = 1;
parms.initDeltaLambda = 1e-2;
%parms.NRparms.dbglvl=3;
contObj = ArcCont(g_h, dg_dxLambda_h, [], parms);

initguess = [-1; -1]; 
contObj = feval(contObj.solve, contObj, initguess);
[spts, yvals, finalSol] = feval(contObj.getsolution, contObj);

% Matlab figure positioning
set(0,'Units','pixels') 
scnsize = get(0,'ScreenSize');

%autoplace on; doesn't seem to work on Ubuntu w compiz

% plot xs vs lambda
figure;
plot(yvals(3,:), yvals(1,:), 'b.-'); 
hold on;
plot(yvals(3,:), yvals(2,:), 'r.-'); 
xlabel('\lambda(s)');
ylabel('x_1(s) and x_2(s)');
legend({'x_1', 'x_2'});
title('x_1(s) and x_2(s) vs \lambda(s)');
grid on; axis tight;

% plot xs and lambda vs s
figure; %
plot(spts, yvals(3,:), 'k.-'); 
hold on;
plot(spts, yvals(1,:), 'b.-'); 
plot(spts, yvals(2,:), 'r.-'); 
legend({'\lambda', 'x_1', 'x_2'});
xlabel('s (arc length)');
ylabel('\lambda, x_1 and x_2');
title('\lambda, x_1 and x_2 vs arc length');
grid on; axis tight;

% 3d plot of xs and lambda
figure; % 3d plot
plot3(yvals(3,:), yvals(1,:), yvals(2,:), 'b.-'); 
xlabel('\lambda(s)');
ylabel('x_1(s)');
zlabel('x_2(s)');
grid on; axis tight;
title('3d plot of \lambda, x_1 and x_2');
view([-17.5,18]); pause(2);
view(3); 

