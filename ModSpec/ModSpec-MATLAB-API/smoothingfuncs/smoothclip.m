function out = smoothclip(x,smoothing)
%function out = smoothclip(x,smoothing)
%This function implements a smooth clip function.
%[original: clip(x) = (abs(x) + x)/2].
%
%INPUT args:
%   x                   - scalar/vector input
%   smoothing           - smoothing parameter
%
%OUTPUT
%   out                 - (smoothabs(x) + x)/2
%
%See function 'smoothabs' for more info.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	out = 0.5*(smoothabs(x,smoothing) + x);
end
% end of smoothclip
