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


    if(vold >= 3.5)
        if(vnew > vold) 
            vnew = (vnew>(3*vold+2)) * (3*vold+2) + (1-(vnew>(3*vold+2))) * vnew;
        else
            if (vnew < 3.5)
                vnew = (vnew>2) * vnew + (1-(vnew>2)) * 2;
            end % if (vnew < 3.5)
        end % if(vnew > vold)
    else
        if(vnew > vold)
            vnew = (vnew>4) * 4 + (1-(vnew>4)) * vnew;
        else
			vnew = (vnew>-.5) * vnew + (1-(vnew>-.5)) * -.5;
        end % if(vnew > vold)
    end % if(vold >= 3.5)
    vnewlim = vnew;
