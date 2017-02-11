function MOD = tunnelDiode_ModSpec_wrapper()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'external_nodes', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'parms', {'Is', 1e-12, 'VT', 0.025});
    MOD = add_to_ee_model(MOD, 'parms', {'Ip', 1e-5, 'Vp', 0.1});
    MOD = add_to_ee_model(MOD, 'parms', {'Iv', 1e-6, 'Vv', 0.4, 'K', 5});
    MOD = add_to_ee_model(MOD, 'parms', {'C', 0});
    MOD = add_to_ee_model(MOD, 'f', @f);
    MOD = add_to_ee_model(MOD, 'q', @q);
    MOD = finish_ee_model(MOD);
end

function out = f(S)
    v2struct(S);
    I_diode = Is*(exp(vpn/VT)-1);
    I_excess = Iv * exp(K * (vpn - Vv));
    I_tunnel = (Ip/Vp) * vpn * exp(-1/Vp * (vpn - Vp));
    out = I_diode + I_tunnel + I_excess;
end

function out = q(S)
    v2struct(S);
    out = C*vpn;
end
