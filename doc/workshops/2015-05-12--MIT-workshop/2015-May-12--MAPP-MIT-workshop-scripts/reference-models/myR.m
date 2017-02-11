function MOD = myR()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'myR');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    
    MOD = add_to_ee_model(MOD, 'parms', {'R', 1000.0});

    MOD = add_to_ee_model(MOD, 'fe', @fe);
    MOD = add_to_ee_model(MOD, 'qe', @qe);

    MOD = finish_ee_model(MOD);
end % myR

function out = fe(S)
    v2struct(S);

    ipn_fe = vpn/R;

    out(1, 1) = ipn_fe;
end % fe

function out = qe(S)
    v2struct(S);

    ipn_qe = 0; 

    out(1, 1) = ipn_qe;
end % qe
