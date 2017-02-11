%function out = smoothstep(x,smoothing)
% 	out = 0.5*(1+tanh(x/smoothing));
% 	example: out = smoothstep(-0.5:0.01:0.5,0.1)
function out = smoothstep(x,smoothing)
	out = 0.5*(1+tanh(x/smoothing));
% end of smoothstep
