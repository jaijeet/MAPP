function MOD = myR_vpn()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'myR_vpn');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'vpn'});
    
    MOD = add_to_ee_model(MOD, 'parms', {'R', 1000.0});

    MOD = add_to_ee_model(MOD, 'fe', @fe);
    MOD = add_to_ee_model(MOD, 'qe', @qe);

    MOD = finish_ee_model(MOD);
end % myR_vpn

function out = fe(S)
    v2struct(S);

    vpn_fe = ipn * R;

    out(1, 1) = vpn_fe;
end % fe

function out = qe(S)
    v2struct(S);

    vpn_qe = 0; 

    out(1, 1) = vpn_qe;
end % qe
