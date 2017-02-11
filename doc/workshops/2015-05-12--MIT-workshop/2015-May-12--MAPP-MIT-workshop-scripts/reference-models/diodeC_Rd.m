function MOD = diodeC_Rd()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'diodeC_Rd');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});
    MOD = add_to_ee_model(MOD, 'internal_unks', {'vpx'});
    MOD = add_to_ee_model(MOD, 'implicit_eqn_names', {'KCL_x'});

    MOD = add_to_ee_model(MOD, 'parms', {'Vt', 0.026});
    MOD = add_to_ee_model(MOD, 'parms', {'Is', 1e-12});
    MOD = add_to_ee_model(MOD, 'parms', {'C', 1e-12});
    MOD = add_to_ee_model(MOD, 'parms', {'Rd', 1});

    MOD = add_to_ee_model(MOD, 'fe', @fe);
    MOD = add_to_ee_model(MOD, 'qe', @qe);
    MOD = add_to_ee_model(MOD, 'fi', @fi);
    MOD = add_to_ee_model(MOD, 'qi', @qi);

    MOD = finish_ee_model(MOD);
end % diodeC_Rd

function out = mydiode(vpx, Vt, Is)
	out = Is*(safeexp(vpx/Vt, 1e15) - 1);
end

function out = fe(S)
    v2struct(S);
    ipn_fe = mydiode(vpx, Vt, Is);
    out(1, 1) = ipn_fe;
end % fe

function out = qe(S)
    v2struct(S);
    out(1, 1) = C*vpx;
end % qe

function out = fi(S)
    v2struct(S);
    vRd = vpn-vpx;
    out(1, 1) = mydiode(vpx, Vt, Is) - vRd/Rd;
end % fi

function out = qi(S)
    v2struct(S);
    out(1, 1) = C*vpx;
end % qi
