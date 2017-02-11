function MOD = diodeCapacitor_ModSpec_wrapper ()
%function MOD = diodeCapacitor_ModSpec_wrapper()
% This function returns a ModSpec model for a simple diode with capacitor
% parallely connected with it.
% The function should be self-explanatory. To see the code:
% >> type diodeCapacitor_ModSpec_wrapper;
% or
% >> edit diodeCapacitor_ModSpec_wrapper;
%
	MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'external_nodes', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'parms', {'C', 2e-12, 'Is', 1e-12, 'VT', 0.025});
    
    MOD = add_to_ee_model(MOD, 'f', @f);
    MOD = add_to_ee_model(MOD, 'q', @q);

	MOD = finish_ee_model(MOD);
end

function out = f(S)
    v2struct(S);
    out = Is*(exp(vpn/VT)-1);
end

function out = q(S)
    v2struct(S);
    out = C*vpn;
end
