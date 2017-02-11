function dout = dsafesqrt(x,smoothing)
%function out = dsafesqrt(x,smoothing)
%   d/dx safesqrt(x,smoothing)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	%out = sqrt(smoothclip(x,smoothing)+1e-16);
	dout = 0.5 ./ sqrt(smoothclip(x,smoothing)+1e-16) ...
		.* dsmoothclip(x,smoothing);
end
% end of dsafesqrt
