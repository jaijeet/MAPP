function MOD = rram(uniqID)

    MOD = ee_model();
    MOD = add_to_ee_model (MOD, 'modelname', 'rram');
    MOD = add_to_ee_model (MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model (MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model (MOD, 'internal_unks', {'vlnoden'});

    MOD = add_to_ee_model (MOD, 'parms', {'I0', 0.001,...
                                          'g0', 0.25,...
                                          'V0', 0.25,...
                                          'h', 5,...
                                          'Vset', 1.5,...
                                          'Vreset', -1.5,...
                                          'K', 1000,...
                                          'Kclip', 1000,...
                                          'GMIN', 1e-12});

    MOD = add_to_ee_model (MOD, 'fqei_all', @fqei_all);

    MOD = finish_ee_model(MOD);

end

function [fe, qe, fi, qi] = fqei_all(S)
    v2struct(S);
    l = 0;
    dl = 0;
    clip_ge_h = 0;
    clip_le_0 = 0;
    l = vlnoden;
    fe(1,1) = (((I0*limexp(((-(h-l))/g0)))*limsinh((vpn/V0)))+(GMIN*vpn));
    clip_ge_h = (-limexp((Kclip*(l-h))));
    clip_le_0 = limexp((Kclip*(-l)));
    dl = (((K*((vpn-((1-(l/h))*Vset))-((l/h)*Vreset)))+clip_ge_h)+clip_le_0);
    qi(1,1) = (-l);
    fi(1,1) = dl;
    qe(1,1) = 0;
end

function y = limsinh(x)
    y = (limexp(x) - limexp(-x))/2;
end % mysinh

function y = limexp(x)
    y = safeexp(x, 1e15);
end


