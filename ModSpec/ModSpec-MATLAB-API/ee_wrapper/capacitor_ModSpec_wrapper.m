function MOD = capacitor_ModSpec_wrapper()
%function MOD = capacitor_ModSpec_wrapper()
% This function returns a ModSpec model for a linear capacitor.
% The function should be self-explanatory. To see the code:
% >> type capacitor_ModSpec_wrapper;
% or
% >> edit capacitor_ModSpec_wrapper;
%
	MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'external_nodes', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'parms', {'C', 1e-12});

    MOD = add_to_ee_model(MOD, 'q', @q);

	MOD = finish_ee_model(MOD);
end

function out = q(S)
    v2struct(S); % C = S.C; vpn = S.vpn;
    out = C*vpn;
end
