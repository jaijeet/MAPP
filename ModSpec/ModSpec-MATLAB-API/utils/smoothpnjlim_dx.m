function deltaVbnew = smoothpnjlim_dx(deltaVb,vbold,vt,vcrit,smoothing)
%function deltaVbnew = smoothpnjlim_dx(deltaVb,vbold,vt,vcrit,smoothing)
%
%INPUT args: (TODO: update)
%   deltaVb         - voltage increment during an NR step
%   vbold           - voltage from previous NR step
%   vt              - threshold voltage of a PN junction
%   vcrit           - critical voltage of a PN junction
%
%OUTPUT:
%   deltaVbnew      - new (limited) voltage increment

%Author: Tianshi Wang <tianshi@berkeley.edu>, 2014/04/04

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	vbnew = vbold + deltaVb;
	vbnew = smoothpnjlim(vbold, vbnew, vt, vcrit,smoothing);
	deltaVbnew = vbnew-vbold;

