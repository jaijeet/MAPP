function MOD = basicSHMOS_ModSpec_wrapper()
%function MOD = basicSHMOS_ModSpec_wrapper()
% This function returns a ModSpec model for a basic Shichman Hodges NMOS model.
% The function should be self-explanatory. To see the code:
% >> type basicSHMOS_ModSpec_wrapper;
% or
% >> edit basicSHMOS_ModSpec_wrapper;
%
	MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'terminals', {'d', 'g', 's'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'igs', 'ids'});
    MOD = add_to_ee_model(MOD, 'parms', {'Beta', 1e-3, 'vth', 0.5});
    
    MOD = add_to_ee_model(MOD, 'f', @f);

    MOD = finish_ee_model(MOD);
end

function out = f(S)
    v2struct(S);

    igs = 0;
    
    if vgs < vth
        ids = 0; % cutoff region
    else
        if vds - vgs > -vth
            ids = 0.5 * Beta * (vgs - vth)^2; % active
        else
            ids = Beta * vds * (vgs - vth - 0.5*vds); % triode
        end
    end

    out = [igs; ids];
end
