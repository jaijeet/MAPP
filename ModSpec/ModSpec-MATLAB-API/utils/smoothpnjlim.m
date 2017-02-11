function vbnewlim = smoothpnjlim(vbold,vbnew,vt,vcrit, smoothing)
%function vbnewlim = smoothpnjlim(vbold,vbnew,vt,vcrit, smoothing)
%a smooth version of simple PNJLIM function for NR limiting for a PN junction
% which recalculates vbnew.
%
%INPUT args:
%   vnew            - new voltage during an NR step
%   vbold           - voltage from previous NR step
%   vt              - threshold voltage of a PN junction
%   vcrit           - critical voltage of a PN junction
%   smoothing       - smoothing factor, the smaller the number, the more
%                     accurate (less smooth) the function
%
%OUTPUT:
%   vbnewlim        - recalculated (PNJlimited) new voltage

%Author: Tianshi Wang <tianshi@berkeley.edu>, 2013/04/05
%
    arg = 1 + (vbnew - vbold)/vt;
    vblim = smoothswitch(vt * safelog(vbnew/vt, smoothing),...
        smoothswitch(vcrit, vbold + vt * safelog(arg, smoothing), arg,... 
           smoothing), vbold, smoothing);
    vbnewlim = vbnew + smoothstep(vbnew-vcrit, smoothing) ...
        * smoothstep(smoothabs(vbnew-vbold, smoothing) - 2*vt, smoothing) ...
        * (vblim - vbnew);
