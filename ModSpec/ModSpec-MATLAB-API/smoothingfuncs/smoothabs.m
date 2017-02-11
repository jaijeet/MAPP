function out = smoothabs(x,smoothing)
%function out = smoothabs(x,smoothing)
%This function implements a smooth absolute function.
%smoothabs(x) = sqrt( x.*x + smoothing ) 
%       - smoothing is the offset from 0
%INPUT args:
%   x                - scalar/vector input
%   smoothing        - smoothing parameter
%
%OUTPUT
%   out              - smoothed absolute value of x [= sqrt(x.*x + smoothing)]

%   old: smoothabs(x) = smoothing*log( e^(x/smoothing) + e^(-x/smoothing) )
%   old: out = smoothing*log( exp(x/smoothing) + exp(-x/smoothing) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	out = sqrt(x.*x + smoothing);
end
% end of smoothabs
