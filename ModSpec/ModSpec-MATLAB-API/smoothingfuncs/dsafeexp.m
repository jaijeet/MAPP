function dout = dsafeexp(x,maxslope)
%function out = dsafeexp(x,maxslope)
%   d/dx of safeexp(x, maxslope)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	breakpoint = log(maxslope);
	dout = exp(x.*(x <= breakpoint)).*(x <= breakpoint) + ...
		(x>breakpoint)*maxslope;
	% vectorized; ensures exp(large) is not computed at all
end
% end of dsafeexp
