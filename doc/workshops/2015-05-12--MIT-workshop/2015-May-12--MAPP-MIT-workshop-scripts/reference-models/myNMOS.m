function MOD = myNMOS()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'myNMOS');
    MOD = add_to_ee_model(MOD, 'terminals', {'d', 'g', 's'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ids', 'igs'});

    MOD = add_to_ee_model(MOD, 'parms', {'Beta', 1e-2});
    MOD = add_to_ee_model(MOD, 'parms', {'Vth', 0.5});
    MOD = add_to_ee_model(MOD, 'parms', {'Cgs', 1e-12});
    MOD = add_to_ee_model(MOD, 'parms', {'Cgd', 1e-12});

    MOD = add_to_ee_model(MOD, 'fe', @fe);
    MOD = add_to_ee_model(MOD, 'qe', @qe);

    MOD = finish_ee_model(MOD);
end % myNMOS

function out = fe(S)
    v2struct(S);

    if vgs < Vth
        ids_fe = 0;
    elseif vds < vgs - Vth
		ids_fe = Beta * vds * (vgs - Vth - 0.5*vds);
    else % vgs >= Vth && vds >= vgs - Vth
		ids_fe = 0.5 * Beta * (vgs - Vth)^2;
    end

    igs_fe = 0;

    out(1, 1) = ids_fe;
    out(2, 1) = igs_fe;
end % fe

function out = qe(S)
    v2struct(S);

    Vgd = vgs - vds;

    Qgd = Cgd * Vgd;
    Qgs = Cgs * vgs;

    ids_qe = -Qgd;
    igs_qe = Qgd + Qgs;

    out(1, 1) = ids_qe;
    out(2, 1) = igs_qe;
end % qe
