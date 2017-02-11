function MOD = resistor_ModSpec_wrapper()
%function MOD = resistor_ModSpec_wrapper()
% This function returns a ModSpec model for a linear resistor.
% The function should be self-explanatory. To see the code:
% >> type resistor_ModSpec_wrapper;
% or
% >> edit resistor_ModSpec_wrapper;
%
    MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'parms', {'R', 1e3});
    
    MOD = add_to_ee_model(MOD, 'f', @f);

    MOD = finish_ee_model(MOD);
end

function out = f(S)
    v2struct(S); % vpn = S.vpn; R = S.R;
    out = vpn/R;
end
