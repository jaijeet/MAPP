function vnewlim = fetlim(vnew,vold,vto)
%function vnewlim = fetlim(vnew,vold,vto)
%This is the simple fetlim function which recalculates vnew

%Author: Tianshi Wang <tianshi@berkeley.edu>, 11/01/2012
    vtsthi = abs(2*(vold-vto))+2;
    vtstlo = vtsthi/2 +2;
    vtox = vto + 3.5;
    delv = vnew-vold;

    if (vold >= vto)
        if(vold >= vtox) 
            if(delv <= 0)
                % going off  
                if(vnew >= vtox) 
                    if(-delv >vtstlo) 
                        vnew =  vold - vtstlo;
                    end  % if (-delv >vtstlo)
                else 
                    vnew = (vnew>vto+2) * vnew + (1-(vnew>vto+2)) * (vto+2);
                end  % if(vnew >= vtox)
            else 
                % staying on  
                if(delv >= vtsthi) 
                    vnew = vold + vtsthi;
                end % if(delv >= vtsthi) 
            end % if(delv <= 0)
        else
            % middle region  
            if(delv <= 0)
                % decreasing  
                vnew = (vnew>vto-.5) * vnew + (1-(vnew>vto-.5)) * (vto-.5);
            else
                % increasing  
                vnew = (vnew>vto+4) * (vto+4) + (1-(vnew>vto+4)) * vnew;
            end % if(delv <= 0)
        end % if(vold >= vtox) 
    else
        % off  
        if(delv <= 0)
            if(-delv >vtsthi) 
                vnew = vold - vtsthi;
            end % if(-delv >vtsthi)
        else
            vtemp = vto + .5;
            if(vnew <= vtemp)
                if(delv >vtstlo)
                  vnew = vold + vtstlo;
                end % if(delv >vtstlo)
            else
                vnew = vtemp;
            end % if(vnew <= vtemp)
        end % if(delv <= 0)
    end % if (vold >= vto)
    vnewlim = vnew;
