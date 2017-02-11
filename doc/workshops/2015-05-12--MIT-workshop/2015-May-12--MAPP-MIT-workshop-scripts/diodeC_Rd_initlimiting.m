function MOD = diodeC_initlimiting()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'diodeC_initlimiting');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});

    MOD = add_to_ee_model(MOD, 'parms', {'Is', 1e-12, 'Vt', 0.026});
    
    MOD = add_to_ee_model(MOD, 'fe', @fe);

    MOD = add_to_ee_model(MOD, 'limited_var', {'vpnlim'});
    MOD = add_to_ee_model(MOD, 'limited_matrix', 1);
    MOD = add_to_ee_model(MOD, 'limiting', @limiting);
    MOD = add_to_ee_model(MOD, 'initGuess', @initGuess);

    MOD = finish_ee_model(MOD);
end % diodeC_initlimiting

function out = fe(S)
    v2struct(S);

    out = Is*(exp(vpnlim/Vt)-1);
end

function vpnlimInitout = initGuess(S)
    v2struct(S);

    vcrit = Vt*log(Vt/(sqrt(2)*Is));
    vpnlimInitout = vcrit;
end

function vpnlimout = limiting(S)
    v2struct(S);

    vcrit = Vt*log(Vt/(sqrt(2)*Is));
    vpnlimout = pnjlim(vpnlim, vpn, Vt, vcrit);
end
