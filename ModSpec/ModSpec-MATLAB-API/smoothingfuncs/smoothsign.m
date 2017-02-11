function out = smoothsign(x,smoothing)
%function out = smoothsign(x,smoothing)
%This function implements a smooth sign function.
%[original: sign(x) = 2*step(x) - 1]
%
%INPUT args:
%   a                   - scalar/vector input
%   b                   - scalar/vector input
%   smoothing           - smoothing parameter
%
%OUTPUT
%   out                 - 2*smoothstep(x,smoothing)-1 
%
%See function 'smoothstep' for more info.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	out = 2*smoothstep(x,smoothing)-1;
end
% end of smoothsign
