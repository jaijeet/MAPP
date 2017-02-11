function deltaVbnew = pnjlim_dx(deltaVb,vbold,vt,vcrit)
%function deltaVbnew = pnjlim_dx(deltaVb,vbold,vt,vcrit)

%Author: J. Roychowdhury <jr@berkeley.edu>, 2008/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	vbnew = vbold + deltaVb;
	vbnew = pnjlim(vbold, vbnew, vt, vcrit);
	deltaVbnew = vbnew-vbold;
