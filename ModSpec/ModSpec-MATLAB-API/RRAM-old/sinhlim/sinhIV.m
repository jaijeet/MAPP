function MOD = sinhIV()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'sinhIV');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});

    MOD = add_to_ee_model(MOD, 'parms', {'A', 1});
    MOD = add_to_ee_model(MOD, 'parms', {'k', 1});

    MOD = add_to_ee_model(MOD, 'fe', @fe);

    MOD = finish_ee_model(MOD);
end % diodeC

function out = fe(S)
    v2struct(S);
    ipn_fe = A*sinh(k*vpn);
    out(1, 1) = ipn_fe;
end % fe
