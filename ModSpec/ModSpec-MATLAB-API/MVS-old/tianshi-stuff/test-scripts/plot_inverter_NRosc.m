
DAE = MNA_EqnEngine(MVS_1_0_1_9_inverter_ckt); 
DAE = feval(DAE.set_uQSS, 'Vin:::E', 0.0, DAE);
uDC = feval(DAE.uQSS, DAE);

% from 000-notes, not a lot of digits, but sufficient
x1 = [1 0 0.728507 5.93341e-05 0 0.73444 -0.00593341 0.00593341 -0.277427].';
x2 = [1 0 1.88243 -8.224e-06 0 1.88161 0.0008224 -0.0008224 0.88325].';

ts = -1:0.01:2;
xs = interp1([0,1], [x1.';x2.'], ts, 'linear', 'extrap');
xs = xs.';

for c = 1:size(xs, 2)
    x = xs(:,c);
    fx(:,c) = feval(DAE.f, x, uDC, DAE);
end

plot(ts, fx);
line([0, 0],[-6e-3, 6e-3]);
line([1, 1],[-6e-3, 6e-3]);
axis([-1, 2, -6e-3, 6e-3]);

