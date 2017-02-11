function vbnewlim = pnjlim(vbold,vbnew,vt,vcrit)
%function vbnewlim = pnjlim(vbold,vbnew,vt,vcrit)
%a simple PNJLIM function for NR limiting for a PN junction which recalculates
%vbnew.
%
%INPUT args:
%   vnew            - new voltage during an NR step
%   vbold           - voltage from previous NR step
%   vt              - threshold voltage of a PN junction
%   vcrit           - critical voltage of a PN junction
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

%Changelog:
%---------
%
%2014/07/09: Aadithya V. Karthik <aadithya@berkeley.edu>: Replaced if/else 
%            conditions with ITE for vv4.
%

    arg = 1 + (vbnew - vbold)/vt;
    vbnewlim = ite(and(vbnew > vcrit, abs(vbnew - vbold) > 2*vt), ite(vbold > 0, ite(arg > 0, vbold + vt * log(arg), vcrit), vt * log(vbnew/vt)), vbnew);

end

