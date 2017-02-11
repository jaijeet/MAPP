function MOD = SHMOSWithParasitics_ModSpec_wrapper()
%function MOD = SHMOSWithParasitics_ModSpec_wrapper()
% This function returns a ModSpec model for a Shichman Hodges MOSFET model
% with parasitic capacitors Cgs and Cgd, parasitic resistors Rd and Rs.
% The function should be self-explanatory. To see the code:
% >> type SHMOSWithParasitics_ModSpec_wrapper;
% or
% >> edit SHMOSWithParasitics_ModSpec_wrapper;
%
	MOD = ee_model();

    MOD = add_to_ee_model (MOD, 'terminals', {'d', 'g', 's'});
    MOD = add_to_ee_model (MOD, 'explicit_outs', {'igs', 'ids'});

    MOD = add_to_ee_model (MOD, 'internal_unks', {'vrs', 'vrd'});

    MOD = add_to_ee_model (MOD, 'parms', {'Beta', 1e-3, 'vth', 0.5});
    MOD = add_to_ee_model (MOD, 'parms', {'Cgs', 1e-14, 'Cgd', 1e-14});
    MOD = add_to_ee_model (MOD, 'parms', {'Rd', 1, 'Rs', 1});
    MOD = add_to_ee_model (MOD, 'parms', {'Type', 'N'});
    
    MOD = add_to_ee_model (MOD, 'fe', @fe);
    MOD = add_to_ee_model (MOD, 'qe', @qe);
    MOD = add_to_ee_model (MOD, 'fi', @fi);
    MOD = add_to_ee_model (MOD, 'qi', @qi);

    MOD = finish_ee_model(MOD);
end

function ids = SH (vgs, vds, Beta, vth, Type)
    m = Type2Int(Type);

    if m * vgs < vth
        ids = 0;
    else
        if m * (vds - vgs) > -vth
            ids = m * 0.5 * Beta * (m*vgs - vth)^2;
        else
            ids = Beta * vds * (m*vgs - vth - m*0.5*vds);
        end
    end
end

function out = fe (S)
    v2struct(S);
    m = Type2Int(Type);

    out = [0; m*vrd/Rd];
end

function out = qe (S)
    v2struct(S);
    m = Type2Int(Type);

    qgd = Cgd * (vgs - vds + m*vrd);
    qgs = Cgs * (vgs - m*vrs);

    out = [qgd+qgs; 0];
end

function out = fi (S)
    v2struct(S);
    m = Type2Int(Type);
    
    iSH = SH(vgs-m*vrs, vds-m*vrd-m*vrs, Beta, vth, Type);
    out = [-m*vrd/Rd + iSH; m*vrs/Rs - iSH];
    
end

function out = qi (S)
    v2struct(S);
    m = Type2Int(Type);

    qgd = Cgd * (vgs - vds + m*vrd);
    qgs = Cgs * (vgs - m*vrs);

    out = [-qgd; -qgs];

end

function m = Type2Int (Type)
    if strcmpi (Type, 'n')
        m = 1;
    elseif strcmpi (Type, 'p')
        m = -1;
    else
        disp ('ERROR: Unexpected MOSFET Type, should be ''N'' or ''P''');
        m = NaN;
    end
end
