function dout = dsmoothabs(x,smoothing)
%function out = dsmoothabs(x,smoothing)
%This function computes derivative of smoothabs function.
%See smoothabs.m for more info.
%
%INPUT args:
%   x               - input vector
%   smoothing       - smoothing parameter
%
%OUTPUT
%    dout           - d/dx smoothabs(x,smoothing)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	%OLD: out = smoothing*log( exp(x/smoothing) + exp(-x/smoothing) );
	%OLD: dout = 1.0 ./( exp(x/smoothing) + exp(-x/smoothing) ) .* ...
	%OLD: 	(exp(x/smoothing) - exp(-x/smoothing));
	%out = sqrt(x.*x + smoothing);
	dout = x./sqrt(x.*x + smoothing); % = x./smoothabs(x,smoothing);
end
% end of dsmoothabs
