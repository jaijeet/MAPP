function dout = dsafelog(x,smoothing)
%function dout = dsafelog(x,smoothing)
%   d/dx safelog(x,smoothing)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	%out = log(smoothclip(x,smoothing) + 1e-16);
	dout = 1 ./ (smoothclip(x,smoothing)+1e-16) .* dsmoothclip(x,smoothing);
end
% end of dsafelog
