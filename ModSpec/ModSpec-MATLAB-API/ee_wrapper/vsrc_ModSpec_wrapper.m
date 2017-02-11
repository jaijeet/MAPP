function MOD = vsrc_ModSpec_wrapper()
%function MOD = vsrc_ModSpec_wrapper()
% This function returns a ModSpec model for an ideal independent voltage source.
% The function should be self-explanatory. To see the code:
% >> type vsrc_ModSpec_wrapper;
% or
% >> edit vsrc_ModSpec_wrapper;
%
    MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'external_nodes', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'vpn'});
    
    MOD = add_to_ee_model(MOD, 'internal_srcs', {'E'});

    MOD = add_to_ee_model(MOD, 'f', @f);

    MOD = finish_ee_model(MOD);
end

function out = f(S)
    v2struct(S);
    out = E;
end
