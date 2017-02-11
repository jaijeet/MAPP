function vbnewlim = pnjlim_tianshi(vbold,vbnew,vt,vcrit,smoothing)
%function vbnewlim = pnjlim(vbold,vbnew,vt,vcrit,smoothing)
%PNJLIM function designed by Tianshi for NR limiting for a PN junction which recalculates
%vbnew.
% it is a combination of pnjlim and smoothpnjlim
% it is smooth and ensures if (vbold==vbnew), vbnewlim=vbnew
%
%INPUT args:
%   vnew            - new voltage during an NR step
%   vbold           - voltage from previous NR step
%   vt              - threshold voltage of a PN junction
%   vcrit           - critical voltage of a PN junction
%   smoothing       - critical voltage of a PN junction
%
%OUTPUT:
%   vbnewlim        - recalculated (PNJlimited) new voltage

% delta_v = vbnew - vbold
%vt = kT/q or .026 mv
%vcrit = kT/q * log ((kT/q) / (squareroot(2) * Is)) : .6145v for Is=1e-12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vbnewlim1 = pnjlim(vbold,vbnew,vt,vcrit);
vbnewlim2 = smoothpnjlim(vbold,vbnew,vt,vcrit,smoothing);

beta = vbnew - vbold;
alpha = 1/(100*beta^2+1);

% when alpha == 1, vbnewlim is the non-smooth version
vbnewlim = alpha * vbnewlim1 + (1-alpha) * vbnewlim2;
