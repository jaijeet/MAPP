function MOD = diodeC_Rd_implicit()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'diodeC_Rd_implicit');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {});

    MOD = add_to_ee_model(MOD, 'parms', {'Vt', 0.026});
    MOD = add_to_ee_model(MOD, 'parms', {'Is', 1e-12});
    MOD = add_to_ee_model(MOD, 'parms', {'C', 1e-12});
    MOD = add_to_ee_model(MOD, 'parms', {'Rd', 1});

    MOD = add_to_ee_model(MOD, 'fi', @fi);
    MOD = add_to_ee_model(MOD, 'qi', @qi);

    MOD = finish_ee_model(MOD);
end % diodeC_Rd_implicit

function out = mydiode(vpx, Vt, Is)
	out = Is*(safeexp(vpx/Vt, 1e15) - 1);
end

function out = fi(S)
    v2struct(S);
    Vd = vpn - ipn*Rd;
    out(1, 1) = mydiode(Vd, Vt, Is) - ipn;
end % fi

function out = qi(S)
    v2struct(S);
    Vd = vpn - ipn*Rd;
    out(1, 1) = C*Vd;
end % qi
