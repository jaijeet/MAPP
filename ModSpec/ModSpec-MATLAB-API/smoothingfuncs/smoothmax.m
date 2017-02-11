function out = smoothmax(a, b, smoothing)
%function out = smoothmax(a, b, smoothing)
%This function implements a smooth max function.
%[original: max(a, b) = 0.5*(a + b + abs(a-b))]
%
%INPUT args:
%   a                   - scalar/vector input
%   b                   - scalar/vector input
%   smoothing           - smoothing parameter
%
%Both a and b can be vectors
%    a will be reshaped into a col vector, b into a row vector
%    out = smoothmax( a*row_of_1s, col_of_1s*b ) % outer product matrix
%
%OUTPUT
%   out                 - +0.5*(a + b + smoothabs(a-b,smoothing))
%
%See function 'smoothabs' for more info.

%author: J. Roychowdhury, 10/2008.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	la = length(a);
	a = reshape(a, [], 1)*ones(1, length(b)); % col vector * row_of_1s
	b = ones(la,1)*reshape(b, 1, []); % col of 1s * row vector
	%
	out = 0.5*(a + b + smoothabs(a-b,smoothing));
end
% end of smoothmax
