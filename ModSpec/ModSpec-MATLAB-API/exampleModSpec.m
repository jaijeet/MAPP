function MOD = exampleModSpec(uniqID)
%function MOD = exampleModSpec(uniqID)
%This function creates an example ModSpec object model
% - the example describes basic Shichman Hodges model
% - MOD.support_initlimiting = 0
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'M1'
%
%Return values:
% - MOD:    an example ModSpec object
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'d', 'g', 's'} (drain, gate, source).
%
% - parameters and their default values:
%   - 'Type' (type of MOSFET): 'N' or 'P'
%   - 'Beta' (Saturation factor): 1e-3 I/V^2
%   - 'VT'   (resistance): 0.3V
%        Note that Beta and VT have positive values regardless of N- or P-type
%   - 'Cgs'  (capacitance between g and s): 1e-13 F
%   - 'Cgd'  (capacitance between g and d): 1e-14 F
%   - 'DSgmin' (minimum conductance between d and s): 1e-8 S
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vds, vgs, ids, igs
% - explicit output name(s):         ids, igs
% - other IO name(s) (vecX):         vds, vgs
% - implicit unknown name(s) (vecY): {}
% - input names (vecU):              {}
%
% 2. equations:
% - basic MOSFET equation (considering type P/N and DS inversion):
%       if N-type
%           vds >=0 
%               ids_I = forward_ids(vds, vgs) + vds*DSgmin
%           else % vds < 0, drain-source inversion
%               ids_I = -forward_ids(-vds, vgs-vds) + vds*DSgmin
%           end
%       else % P-type
%           if vds <=0 
%               ids_I = -forward_ids(-vds, -vgs) + vds*DSgmin
%           else % vds < 0, drain-source inversion
%               ids_I = forward_ids(vds, -vgs+vds) + vds*DSgmin
%           end
%       end
%
%       ids = ids_I + d/dt (Cgd*(vds - vgs));
%       igs = d/dt (Cgs*vgs - Cgd*(vds - vgs));
%
%   Notes:
%     1. DSgmin is used to prevent matrix singularity errors when the device is
%        off
%     2. forward_ids function describes the Shichman Hodges MOSFET equation:
%
%                               0;                 if vgs < VT
%        forward_ids(vds,vgs) = Beta/2*(vgs-VT)^2; if vgs <= vds + VT, vgs >= VT
%                               Beta*vds*(vgs-VT-vds/2);  if vgs > vds+VT
%
% - fe: [ids_I; 0]
% - qe: [Cgd*(vds - vgs);
%        Cgs*vgs - Cgd*(vds - vgs)]
%
%
%Examples
%--------
% % adding an NMOS with default parameters to an existing circuitdata structure
% cktdata = add_element(cktdata, exampleModSpec(), 'M1', ...
%           {'nD', 'nG', 'nS'}, [], {});
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts
%

%
% author: T. Wang. 2014-06-25

%change log:
%-----------
%2014/06/25: Tianshi Wang <tianshi@berkeley.edu> created

% use the common ModSpec skeleton, sets up fields and defaults
    MOD = ModSpec_common_skeleton();

% set up data members defined in ModSpec_common_skeleton. These are
% used by the API functions defined there.

% uniqID
    if nargin < 1
        MOD.uniqID = '';
    else
        MOD.uniqID = uniqID;
    end

    MOD.model_name = 'example';
    MOD.model_description = 'example ModSpec model';

    % external connections (nodes)
    MOD.NIL.node_names = {'d', 'g', 's'};
    MOD.NIL.refnode_name = 's';

    % IOs will be: vds, vgs, ids, igs
    MOD.IO_names = {'vds', 'vgs', 'ids', 'igs'};
    MOD.explicit_output_names = {'ids', 'igs'}; % vecZ = [ids; igs];
    MOD.otherIO_names = {'vds', 'vgs'}; % vecX = [vds; vgs];

    MOD.internal_unk_names = {}; % vecY
    MOD.implicit_equation_names = {}; % vecW
    MOD.u_names = {}; % vecU

    % define model parameters
    MOD.parm_names = {...
         'Type', ... % 'N' or 'P'
         'Beta', ... % Beta: Saturation factor
         'VT',   ... % VT
         'Cgs',  ... % Cgs
         'Cgd',  ... % Cgd
         'DSgmin'... % Gmin between drain and source (to prevent matrix
                     %  singularities when the device is off)
    };

    MOD.parm_defaultvals = {...
        'N',   ... % 'N' or 'P'
        1e-3,  ... % Beta: Saturation factor
        0.3,   ... % VT
        1e-13, ... % Cgs
        1e-14, ... % Cgd
        1e-8,  ... % DSgmin (default value 100Mohms)
    };

    MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

    % MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
    % MOD.NIL.io_nodenames are set up by this helper function
    MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
    MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
    MOD.qe = @qe; % qe(vecX, vecY, MOD)
    MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
    MOD.qi = @qi; % qi(vecX, vecY, MOD)

% Newton-Raphson initialization support

% Newton-Raphson limiting support

end % MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%

function feout = fe(vecX, vecY, vecU, MOD)
    feout = fqei(vecX, vecY, vecU, MOD, 'f', 'e');
end % fe(...)

function qeout = qe(vecX, vecY, MOD)
    qeout = fqei(vecX, vecY, [], MOD, 'q', 'e');
end % qe(...)

function fiout = fi(vecX, vecY, vecU, MOD)
    fiout = fqei(vecX, vecY, vecU, MOD, 'f', 'i');
end % fi(...)

function qiout = qi(vecX, vecY, MOD)
    qiout = fqei(vecX, vecY, [], MOD, 'q', 'i');
end % qi(...)

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MODSPEC API %%%%%%%%%%%%%%%%%%%%%%%%

function fqout = fqei(vecX, vecY, vecU, MOD, forq, eori)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set up scalar variables for the parms, vecX, vecY and vecU

    % create variables of the same names as the parameters and assign
    % them the values in MOD.parms
    % ideally, this should be a macro
    %     - could do this using a string and another eval()
    pnames = feval(MOD.parmnames,MOD);
    for i = 1:length(pnames)
        evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
        eval(evalstr);
    end
    % for this device, this should set up Type, Beta, VT, Cgs, Cgd, DSgmin

    % similarly, get values from vecX, named exactly the same as otherIOnames
    % get otherIOs from vecX
    oios = feval(MOD.OtherIONames,MOD);
    for i = 1:length(oios)
        evalstr = sprintf('%s = vecX(i);', oios{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, this should set up vds, vgs

    % do the same for vecY from internalUnknowns
    % get internalUnknowns from vecY
    iunks = feval(MOD.InternalUnkNames,MOD);
    for i = 1:length(iunks)
        evalstr = sprintf('%s = vecY(i);', iunks{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, there is no vecY

    % do the same for vecU from uNames
    if length(vecU) > 0 % for q calls, vecU = [] may be sent in
        unms = uNames(MOD);
        for i = 1:length(unms)
            evalstr = sprintf('%s = vecU(i);', unms{i});
            eval(evalstr); % should be OK for vecvalder
        end
    end
    % for this device, there is no vecU

    % end setting up scalar variables for the parms, vecX, vecY and vecU
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if 1 == strcmp(eori,'e') % e
        if 1 == strcmp(forq, 'f') % f
            if strcmp(Type, 'N') || strcmp(Type, 'n')
                if vds >= 0 
                    ids = forward_ids(vds, vgs, Beta, VT);
                else % vds < 0, drain-source inversion
                    ids = -forward_ids(-vds, vgs-vds, Beta, VT);
                end
            else % P-type
                if vds <= 0 
                    ids = -forward_ids(-vds, -vgs, Beta, VT);
                else % vds < 0, drain-source inversion
                    ids = forward_ids(vds, -vgs+vds, Beta, VT);
                end
            end
            ids = ids + vds*DSgmin; % to prevent matrix singularity errors when
                                    % the device is off

            % 2 explicit output ids, igs
            fqout(1,1) = ids; % ids
            fqout(2,1) = 0;   % igs
        else % q
            % 2 explicit output qds, qgs
            fqout(1,1) = Cgd*(vds - vgs);              % qds
            fqout(2,1) = Cgs*vgs - Cgd*(vds - vgs); % qgs
        end
    else % i
        if 1 == strcmp(forq, 'f') % f
            fqout = [];
        else % q
            fqout = [];
        end
    end
end % fqei

function ids = forward_ids(vds, vgs, Beta, VT)
    if (vgs < VT)
        % off
        ids = 0;
    elseif (vgs <= vds + VT)
        % active
        ids =Beta/2*(vgs-VT)^2;
    else % vgs > vds+VT
        % triode
        ids = Beta*vds*(vgs-VT-vds/2);
    end
end
