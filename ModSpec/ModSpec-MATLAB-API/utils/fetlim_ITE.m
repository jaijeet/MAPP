function vnewlim = fetlim(vnew,vold,vto)
%function vnewlim = fetlim(vnew,vold,vto)
%This is the simple fetlim function which recalculates vnew

%Author: Tianshi Wang <tianshi@berkeley.edu>, 11/01/2012

%Changelog:
%---------
%
%2014/07/09: Aadithya V. Karthik <aadithya@berkeley.edu>: Replaced if/else 
%            conditions with ITE for vv4.
%

    vtsthi = abs(2*(vold-vto))+2;
    vtstlo = vtsthi/2 +2;
    vtox = vto + 3.5;
    delv = vnew-vold;
    vnewlim = ite(vold >= vto, ite(vold >= vtox, ite(delv <= 0, ite(vnew >= vtox, ite(-delv > vtstlo, vold-vtstlo, vnew), (vnew>vto+2) * vnew + (1-(vnew>vto+2)) * (vto+2)), ite(delv >= vtsthi, vold + vtsthi, vnew)), ite(delv <= 0, (vnew>vto-.5) * vnew + (1-(vnew>vto-.5)) * (vto-.5), (vnew>vto+4) * (vto+4) + (1-(vnew>vto+4)) * vnew)), ite(delv <= 0, ite(-delv > vtsthi, vold - vtsthi, vnew), ite(vnew <= (vto + .5), ite(delv > vtstlo, vold + vtstlo, vnew), (vto + .5))));

end
