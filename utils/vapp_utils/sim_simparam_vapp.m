function parmVal = sim_simparam_vapp(parmName, parmDefVal)
% SIM_SIMPARAM_VAPP
    switch parmName
        case 'gmin'
            parmVal = 1e-12;
        case 'cmin'
            parmVal = 0;
        otherwise
            parmVal = NaN;
    end

    if nargin > 1 && isnan(parmVal) == true
        parmVal = parmDefVal;
    end

    if isnan(parmVal) == true
        error('The parameter %s is not known to the simulator!', parmName);
    end
end
