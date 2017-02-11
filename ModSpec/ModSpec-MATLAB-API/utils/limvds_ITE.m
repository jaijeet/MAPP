function vnewlim = limvds(vnew,vold)
%function vnewlim = limvds(vnew,vold)
%This function recalculates vnew by limiting vold.
%INPUT args:
%   vnew        - new value of v (scalar)
%   vold        - old value of v (scalar)
%
%OUTPUT:
%   vnewlim     - vnew after limiting

%Author: Tianshi Wang <tianshi@berkeley.edu>, 11/01/2012

%Changelog:
%---------
%
%2014/07/09: Aadithya V. Karthik <aadithya@berkeley.edu>: Replaced if/else 
%            conditions with ITE for vv4.
%

    vnewlim = ite(vold >= 3.5, ite(vnew > vold, (vnew>(3*vold+2)) * (3*vold+2) + (1-(vnew>(3*vold+2))) * vnew, ite(vnew < 3.5, (vnew>2) * vnew + (1-(vnew>2)) * 2, vnew)), ite(vnew > vold, (vnew>4) * 4 + (1-(vnew>4)) * vnew, (vnew>-.5) * vnew + (1-(vnew>-.5)) * -.5));
    
end

