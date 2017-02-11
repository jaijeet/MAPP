function out = dtanh(x)
%function out = dtanh(x)
%This functon computes the derivative of the tanh() function.
%INPUT arg:
%   x           - a scalar
%
%OUTPUT
%	out         - dtanh_dx(x)

%author: J. Roychowdhury, 2011/05/31
	out = 1 - (tanh(x))^2;
% end of dtanh
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





