function [douta, doutb] = dsmoothmax(a, b, smoothing)
%function [douta, doutb] = dsmoothmax(a, b, smoothing)
% d/d[a,b] smoothmax(a,b,smoothing)
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
	%out = 0.5*(a + b + smoothabs(a-b,smoothing));
	douta = 0.5*(1 + dsmoothabs(a-b,smoothing));
	doutb = 0.5*(1 - dsmoothabs(a-b,smoothing));
end
% end of dsmoothmax
