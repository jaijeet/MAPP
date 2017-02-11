function out = safeexp(x,maxslope)
%function out = safeexp(x,maxslope)
%   hacked exponential: becomes a line after slope hits maxslope
%      (useful for controlling numerical overflow in N-R)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	breakpoint = log(maxslope);
	out = exp(x.*(x <= breakpoint)).*(x <= breakpoint) + ...
		(x>breakpoint).*(maxslope + maxslope*(x-breakpoint));
	% vectorized; ensures exp(large) is not computed at all
end
% end of safeexp
