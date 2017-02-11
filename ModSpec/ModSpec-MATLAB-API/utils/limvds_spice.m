function vnewlim = limvds_spice(vnew,vold)
%function vnewlim = limvds_spice(vnew,vold)
%This function recalculates vnew by limiting vold.
%INPUT args:
%   vnew        - new value of v (scalar)
%   vold        - old value of v (scalar)
%
%OUTPUT:
%   vnewlim     - vnew after limiting

%Author: Tianshi Wang <tianshi@berkeley.edu>, 11/08/2013



    if(vold >= 3.5) 
        if(vnew > vold) 
            vnew = min(vnew,(3 * vold) +2);
        else 
            if (vnew < 3.5)
                vnew = max(vnew,2);
			end
		end
            
    else
        if(vnew > vold)
            vnew = min(vnew,4);
        else
            vnew = max(vnew,-.5);
		end
	end
    vnewlim = vnew;
