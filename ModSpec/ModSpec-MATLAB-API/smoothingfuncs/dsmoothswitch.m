function [da,db,dx] = dsmoothswitch(a,b,xs,smoothing)
%function [da, db, dx] = dsmoothswitch(a,b,x,smoothing)
% 	derivatives of smoothswitch wrt a, b and x
% 	example: [da,db,dx] = dsmoothswitch(-5,3,-0.5:0.01:0.5,0.1)
%
%CAVEAT EMPTOR: MAKE SURE you check monotonicity and slope properties wrt x 
%		if a or b is a function of x
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	oofs = smoothstep(xs,smoothing);
	doofs = dsmoothstep(xs,smoothing);
	%out = a*(1-oofs) + b*oofs;
	da = 1-oofs;
	db = oofs;
	dx = (-a+b)*doofs;
end
% end of dsmoothswitch
