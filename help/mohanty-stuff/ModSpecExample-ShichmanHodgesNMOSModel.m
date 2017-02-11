%This file shows you how to build a ModSpec model, using a Schichman Hodges NMOS
%device as example. For more on ModSpec models, type 'help ModSpec' or 'help
%MAPPdevicemodels'.
%
%In this example, we will define a Matlab function that returns an object (MOD)
%that conforms to the ModSpec API format and captures the dynamics of the
%Schichman-Hodges device:
%
%function MOD = SchichmanHodgesNMOSModel (uniqID)
%
%We now call the function ModSpec_common_skeleton(), which returns to us a ModSpec
%model that we can modify to suit our needs:
%
%    MOD = ModSpec_common_skeleton();
%
%    MOD.version = 'SchichmanHodgesNMOSModel';
%    MOD.Usage = help('SchichmanHodgesNMOSModel');
%    MOD.uniqID = uniqID;
%    MOD.model_name = 'NMOS transistor';
%    MOD.model_description = 'Schichman Hodges NMOS transistor';
%    MOD.spice_key = 'M';
%
%The Schichman-Hodges device has 3 terminals: the source (s), the drain (d), and
%the gate (g). We define an object NIL (short for Network Interface Layer) that
%carries information about these terminals, and how the model interfaces with
%the outside world. So we say:
%
%    MOD.NIL.node_names = {'d', 'g', 's'};
%
%All voltages in the model are relative to the source voltage:
%
%    MOD.NIL.refnode_name = 's';
%
%Given vds and vgs, ids and igs can be explicitly calculated (rather than
%specifying an implicit relationship between the device voltages and currents):
%
%    MOD.explicit_output_names = {'ids', 'igs'};
%    MOD.implicit_equation_names = {};
%
%There are no internal nodes in the device:
%
%    MOD.internal_unk_names = {};
%    
%The device has no internal voltage/current sources:
%
%    MOD.u_names = {};
%
%To automatically set up other fields of MOD, such as IOnames, OtherIOnames,
%etc.:
%
%    MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);
%
%For example, after calling the above function, MOD.IOnames will be 
%{'vds', 'vgs', 'ids', 'igs'}
%
%Now to specify the parameters of the model. The model has 2 parameters, (1)
%beta (from the geometry of the device), and (2) VT (the threshold voltage).
%
%    MOD.parm_names = {'beta', 'Vt'};
%    MOD.parm_defaultvals = {1e-3, 0.4};
%    MOD.parm_types = {'double', 'double'};
%    MOD.parm_vals = MOD.parm_defaultvals;
%
%Finally, the core functions qi, fi, qe, and fe that capture the dynamics of the
%device (the exact definitions of these functions are provided below):
%
%    MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
%    MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
%    MOD.qi = @qi; % qi(vecX, vecY, MOD)
%    MOD.qe = @qe; % qe(vecX, vecY, MOD)
%
%The arguments of the functions above are given by:
%    
%    vecX = [vds, vgs]; % corresponds to OtherIOs
%    vecY = [];         % corresponds to InternalUnks
%    vecU = [];         % corresponds to internal voltage/current sources
%
%And the MOD object can now be returned:
%
%end
%
%Putting everything together, we have the following:
%
%function MOD = SchichmanHodgesNMOSModel (uniqID)
%
%    MOD = ModSpec_common_skeleton();
%
%    MOD.version = 'SchichmanHodgesNMOSModel';
%    MOD.Usage = help('SchichmanHodgesNMOSModel');
%    MOD.uniqID = uniqID;
%    MOD.model_name = 'NMOS transistor';
%    MOD.model_description = 'Schichman Hodges NMOS transistor';
%    MOD.spice_key = 'M';
%
%    MOD.NIL.NodeNames = {'d', 'g', 's'};
%    MOD.NIL.RefNodeName = 's';
%    MOD.explicit_output_names = {'ids', 'igs'};
%    MOD.implicit_equation_names = {};
%    MOD.internal_unk_names = {};
%    MOD.u_names = {};
%
%    MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);
%
%    MOD.parm_names = {'beta', 'Vt'};
%    MOD.parm_defaultvals = {1e-3, 0.4};
%    MOD.parm_types = {'double', 'double'};
%    MOD.parm_vals = MOD.parm_defaultvals;
%
%    MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
%    MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
%    MOD.qi = @qi; % qi(vecX, vecY, MOD)
%    MOD.qe = @qe; % qe(vecX, vecY, MOD)
%
%end
%
%function out = fi(vecX, vecY, vecU, MOD)
%    out = [];
%end
%
%function out = fe(vecX, vecY, vecU, MOD)
%    
%    vds = vecX(1,1);
%    vgs = vecX(2,1);
%
%    beta = MOD.parm_vals{1};
%    vt = MOD.parm_vals{2};
%
%    igs = 0;
%
%    inversion = 0;
%    if vds < 0
%        % drain source inversion
%        inversion = 1;
%        vds = -vds;
%        vgs = vgs + vds;
%    end
%
%    if vgs < vt
%        ids = 0;
%    else
%        if vds - vgs > -vt
%            ids = 0.5 * beta * (vgs - vt)^2;
%        else
%            ids = beta * (vgs - vt - 0.5*vds) * vds;
%        end
%    end
%
%    if inversion > 0.5
%        ids = -ids;
%    end
%
%    out = [ids; igs];
%
%end
%
%function out = qi(vecX, vecY, MOD)
%    out = [];
%end
%
%function out = qe(vecX, vecY, MOD)
%    out = [0; 0];
%end
%
%
