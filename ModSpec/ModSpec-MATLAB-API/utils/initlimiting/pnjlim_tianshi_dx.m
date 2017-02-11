function deltaVbnew = pnjlim_tianshi_dx(deltaVb,vbold,vt,vcrit,smoothing)
%function deltaVbnew = pnjlim_tianshi_dx(deltaVb,vbold,vt,vcrit,smoothing)
%This function implements PNJLIM function for NR limiting for a PN junction
%
%INPUT args:
%   deltaVb         - voltage increment during an NR step
%   vbold           - voltage from previous NR step
%   vt              - threshold voltage of a PN junction
%   vcrit           - critical voltage of a PN junction
%
%OUTPUT:
%   deltaVbnew      - new (limited) voltage increment

%Author: J. Roychowdhury <jr@berkeley.edu>, 2008/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	vbnew = vbold + deltaVb;
	vbnew = pnjlim_tianshi(vbold, vbnew, vt, vcrit, smoothing);
	deltaVbnew = vbnew-vbold;
