function out = smoothswitch(a,b,xs,smoothing)
%function out = smoothswitch(a,b,x,smoothing)
%This function implements a smooth switch function.
%[original: 
%   if xs < 0
%       switch(xs) = a;
%   else
%       switch(xs) = b;
%   end
%
%INPUT args:
%   a               - scalar/vector input
%   b               - scalar/vector input
%   smoothing       - smoothing parameter
%
%OUTPUT
%   out             - a*(smoothstep(x,smoothing)-1) + b*smoothstep(x,smoothing)
%
%See function 'dsmoothclip' for more info.
% 
%EXAMPLE: 
%out = smoothswitch(-5,3,-0.5:0.01:0.5,0.1)
%
%CAVEAT EMPTOR: 
%    MAKE SURE you check monotonicity and slope properties wrt x if a or b is a
%    function of x

%author: J. Roychowdhury, 10/2008.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	oofs = smoothstep(xs,smoothing);
	out = a*(1-oofs) + b*oofs;
end
% end of smoothswitch
