function MOD = ShichmanHodgesNMOSModel (uniqID)

    MOD = ModSpec_common_skeleton();

    MOD.version = 'ShichmanHodgesNMOSModel';
    MOD.Usage = help('ShichmanHodgesNMOSModel');
    MOD.uniqID = uniqID;
    MOD.model_name = 'NMOS transistor';
    MOD.model_description = 'Shichman Hodges NMOS transistor';
    MOD.spice_key = 'M';

    MOD.NIL.node_names = {'d', 'g', 's'};
    MOD.NIL.refnode_name = 's';
    MOD.explicit_output_names = {'ids', 'igs'};
    MOD.implicit_equation_names = {};
    MOD.internal_unk_names = {};
    MOD.u_names = {};

    MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

    MOD.parm_names = {'beta', 'Vt'};
    MOD.parm_defaultvals = {1e-6, 0.4};
    MOD.parm_types = {'double', 'double'};
    MOD.parm_vals = MOD.parm_defaultvals;

    MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
    MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
    MOD.qi = @qi; % qi(vecX, vecY, MOD)
    MOD.qe = @qe; % qe(vecX, vecY, MOD)

end

function out = fi(vecX, vecY, vecU, MOD)
    out = [];
end

function out = fe(vecX, vecY, vecU, MOD)
    
    vds = vecX(1,1);
    vgs = vecX(2,1);

    beta = MOD.parm_vals{1};
    vt = MOD.parm_vals{2};

    igs = 0;

    inversion = 0;
    if vds < 0
        % drain source inversion
        inversion = 1;
        vds = -vds;
        vgs = vgs + vds;
    end

    if vgs < vt
        ids = 0;
    else
        if vds - vgs > -vt
            ids = 0.5 * beta * (vgs - vt)^2;
        else
            ids = beta * (vgs - vt - 0.5*vds) * vds;
        end
    end

    if inversion > 0.5
        ids = -ids;
    end

    out = [ids; igs];

end

function out = qi(vecX, vecY, MOD)
    out = [];
end

function out = qe(vecX, vecY, MOD)
    out = [0; 0];
end



