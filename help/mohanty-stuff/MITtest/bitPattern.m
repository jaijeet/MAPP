function out = bitPattern(t,args)
    high = 1;
    low  = 0.3; % 0;
    smoothing = 1e-21;
    %out = [];
%    for count = 1 : 1: 
    %out = [out, smoothPulse(t(count),0,high-low,1,2,smoothing)];
    out = low + smoothPulse(t,0,high-low,1e-9,2e-9,smoothing) + smoothPulse(t,0,high-low,5e-9,7e-9,smoothing) + smoothPulse(t,0,high-low,8e-9,9e-9,smoothing) + smoothPulse(t,0,high-low,11e-9,15e-9,smoothing); 
