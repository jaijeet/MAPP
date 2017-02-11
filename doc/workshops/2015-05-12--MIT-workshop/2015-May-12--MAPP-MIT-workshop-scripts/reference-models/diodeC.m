function MOD = diodeC()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'diodeC');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});

    MOD = add_to_ee_model(MOD, 'parms', {'VT', 0.026});
    MOD = add_to_ee_model(MOD, 'parms', {'IS', 1e-12});
    MOD = add_to_ee_model(MOD, 'parms', {'C',  1e-6});

    MOD = add_to_ee_model(MOD, 'fe', @fe);
    MOD = add_to_ee_model(MOD, 'qe', @qe);

    MOD = finish_ee_model(MOD);
end % diodeC

function out = fe(S)

    v2struct(S);

    ipn_fe = IS*(safeexp(vpn/VT, 1e15) - 1);

    out(1, 1) = ipn_fe;
end % fe

function out = qe(S)

    v2struct(S);

    ipn_qe = C*vpn; 

    out(1, 1) = ipn_qe;
end % qe
