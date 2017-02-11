smoothing = 10^-12;
smoothing = 0.1^2;
xs = -0.5:0.005:0.5;

figure; 

m=3; n=6;

% abs
subplot(m,n,1); plotfuncWtwoArgs(@smoothabs, xs, smoothing);
subplot(m,n,2); plotfuncWtwoArgs(@dsmoothabs, xs, smoothing);

% clip
subplot(m,n,3); plotfuncWtwoArgs(@smoothclip, xs, smoothing);
subplot(m,n,4); plotfuncWtwoArgs(@dsmoothclip, xs, smoothing);

% step
subplot(m,n,5); plotfuncWtwoArgs(@smoothstep, xs, smoothing);
subplot(m,n,6); plotfuncWtwoArgs(@dsmoothstep, xs, smoothing);

% sign
subplot(m,n,7); plotfuncWtwoArgs(@smoothsign, xs, smoothing);
subplot(m,n,8); plotfuncWtwoArgs(@dsmoothsign, xs, smoothing);

% safesqrt
subplot(m,n,9); plotfuncWtwoArgs(@safesqrt, xs, smoothing);
subplot(m,n,10); plotfuncWtwoArgs(@dsafesqrt, xs, smoothing);

% safelog
subplot(m,n,11); plotfuncWtwoArgs(@safelog, xs, smoothing);
subplot(m,n,12); plotfuncWtwoArgs(@dsafelog, xs, smoothing);

ys=-5:0.01:5;
maxslope=exp(3);

% safeexp
subplot(m,n,13); plotfuncWtwoArgs(@safeexp, ys, maxslope);
subplot(m,n,14); plotfuncWtwoArgs(@dsafeexp, ys, maxslope);

ys = -0.6:0.005:0.6;

% smoothmax
subplot(m,n,15); plotfuncWthreeArgs(@smoothmax, xs, ys, smoothing);
subplot(m,n,16); plotfuncWthreeArgs(@dsmoothmax, xs, ys, smoothing);

% smoothmax
subplot(m,n,17); plotfuncWthreeArgs(@smoothmin, xs, ys, smoothing);
subplot(m,n,18); plotfuncWthreeArgs(@dsmoothmin, xs, ys, smoothing);

% should also plot smoothswitch/dsmoothswitch - need a plotfuncWfourArgs

axis tight;
