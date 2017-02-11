function MOD = sinhIV_initlimiting()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'sinhIV_initlimiting');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});

    MOD = add_to_ee_model(MOD, 'parms', {'A', 1});
    MOD = add_to_ee_model(MOD, 'parms', {'k', 1});

    MOD = add_to_ee_model(MOD, 'fe', @fe);

    MOD = add_to_ee_model(MOD, 'limited_var', {'vpnlim'});
    MOD = add_to_ee_model(MOD, 'limited_matrix', 1);
    MOD = add_to_ee_model(MOD, 'limiting', @limiting);
    MOD = add_to_ee_model(MOD, 'initGuess', @initGuess);

    MOD = finish_ee_model(MOD);
end % diodeC_initlimiting

function out = fe(S)
    v2struct(S);
    ipn_fe = A*sinh(k*vpnlim);
    out(1, 1) = ipn_fe;
end

function vpnlimInitout = initGuess(S)
    v2struct(S);
    vpnlimInitout = 0;
end

function vpnlimout = limiting(S)
    v2struct(S);
    vpnlimout = sinhlim(vpn, vpnlim, k);
end

function xlim = sinhlim(x, xold, k)
    % sinh(k*xlim) = sinh(k*xold) + k*cosh(k*xold) * (x - xold)
    % sinh^-1(x) = log(x + sqrt(1+x^2)); 
    ylim = sinh(k*xold) + k*cosh(k*xold) * (x - xold);
    xlim = log(ylim + sqrt(1+ylim^2)) / k; 
end
