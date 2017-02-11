%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vbnewlim = pnjlim(vbold, vbnew, vt, vcrit)
% delta_v = vbnew - vbold
%this is the simple pnjlim function which recalculates vbnew
%vt = kT/q or .026 mv
%vcrit = kT/q * log ((kT/q) / (squareroot(2) * Is)) : .6145v for Is=1e-12
    if ((vbnew > vcrit) & (abs(vbnew - vbold) > 2*vt))
        if (vbold > 0)
            arg = 1 + (vbnew - vbold)/vt;
            if (arg > 0)
                outemp = vbold + vt * log(arg);
            else
                outemp  = vcrit;
            end	
        else
            outemp  = vt * log(vbnew/vt);
        end
    else % if ((vbnew > vcrit) & (abs(vbnew - vbold) > 2*vt))
        outemp = vbnew;
    end % if ((vbnew > vcrit) & (abs(vbnew - vbold) > 2*vt))

    vbnewlim = outemp;
end % pnjlim
