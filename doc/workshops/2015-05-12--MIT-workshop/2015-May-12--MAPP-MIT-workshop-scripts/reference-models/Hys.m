function MOD = Hys()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'Hys');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'vpn'});

    MOD = add_to_ee_model(MOD, 'parms', {'A', 1});
    MOD = add_to_ee_model(MOD, 'parms', {'B', -1});
    MOD = add_to_ee_model(MOD, 'parms', {'C', 1});
    MOD = add_to_ee_model(MOD, 'parms', {'I', 1});
    MOD = add_to_ee_model(MOD, 'parms', {'tau', 1e-7});

    MOD = add_to_ee_model(MOD, 'fe', @fe);
    MOD = add_to_ee_model(MOD, 'qe', @qe);

    MOD = finish_ee_model(MOD);
end % Hys

function out = fe(S)
    v2struct(S);
    vpn_fe = A*(ipn-I)^3 + B*(ipn-I) + C;
    out(1, 1) = vpn_fe;
end % fe

function out = qe(S)
    v2struct(S);
    vpn_qe = tau*ipn;
    out(1, 1) = vpn_qe;
end % qe
