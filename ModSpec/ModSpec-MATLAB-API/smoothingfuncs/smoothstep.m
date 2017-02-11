function out = smoothstep(x,smoothing)
%function out = smoothstep(x,smoothing)
%This function implements a smooth step function.
%[original: step(x) = d/dx clip(x)]
%
%INPUT args:
%   a                   - scalar/vector input
%   b                   - scalar/vector input
%   smoothing           - smoothing parameter
%
%OUTPUT
%   out                 - dsmoothclip(x,smoothing)
%
%See function 'dsmoothclip' for more info.
% 
%EXAMPLE: 
%out = smoothstep(-0.5:0.01:0.5,0.1)

%author: J. Roychowdhury, 10/2008.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	out = dsmoothclip(x,smoothing);
end
% end of smoothstep
