function ddout = ddsmoothabs(x,smoothing)
%function out = ddsmoothabs(x,smoothing)
%This function computes derivative of dsmoothabs function.
%See dsmoothabs.m for more info.
%
%INPUT args:
%   x               - input vector
%   smoothing       - smoothing parameter
%OUTPUT
%   ddout           - d/dx dsmoothabs(x,smoothing)

%author: J. Roychowdhury, 10/2008.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	%OLD: denom = exp(x/smoothing) + exp(-x/smoothing);
	%OLD: num = exp(x/smoothing) - exp(-x/smoothing);
	%OLD: ddenom = num/smoothing;
	%OLD: dnum = denom/smoothing;
	%OLD: % dout = num ./ denom;
	%OLD: ddout = dnum ./ denom - num ./ denom ./ denom .* ddenom;
	% dout = x./sqrt(x.*x + smoothing) = x/smoothabs(x);
	ddout = -x./(smoothabs(x,smoothing).^2) .* dsmoothabs(x,smoothing) ...
		+ 1./smoothabs(x,smoothing);
end
% end of ddsmoothabs
