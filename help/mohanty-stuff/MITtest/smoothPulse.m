function out = smoothPulse(t,low,high,a,b,smoothing)
    out1 = low + (high - low) * smoothstep(t-a,smoothing);
    out2 =  - (high - low) * smoothstep(t-b,smoothing);
    out = out1 + out2;
