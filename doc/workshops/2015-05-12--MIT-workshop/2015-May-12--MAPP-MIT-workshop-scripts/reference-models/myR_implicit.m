function MOD = myR_implicit()
    MOD = ee_model();
    MOD = add_to_ee_model(MOD, 'name', 'myR_implicit');
    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {});
    MOD = add_to_ee_model(MOD, 'implicit_eqn_names', {'Ohm_law'});

    MOD = add_to_ee_model(MOD, 'parms', {'R', 1000.0});

    MOD = add_to_ee_model(MOD, 'fi', @fi);
    MOD = add_to_ee_model(MOD, 'qi', @qi);

    MOD = finish_ee_model(MOD);
end % myR_implicit

function out = fi(S)
    v2struct(S);

    % algebraic part of Ohm_law
    out(1, 1) = vpn - R*ipn;
end % fi

function out = qi(S)
    v2struct(S);

    % d/dt part of Ohm_law
    out(1, 1) = 0;
end % qi
