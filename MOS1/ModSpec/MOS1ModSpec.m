function MOD =MOS1ModSpec(uniqID)
OBSOLETE: see models in ../ee_wrapper
%function MOD =MOS1ModSpec(uniqID)
%This function creates a ModSpec object model for SPICE's MOSFET level 1 model
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'M1'
%
%Return values:
% - MOD:    a ModSpec object for MOS level 1 model
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'d', 'g', 's', 'b'} (drain, gate, source, bulk).
%
% - parameters and their default values:
%   based on The SPICE Book 
%     name    default unit   description
%   - 'VTO'    0.0    V      'Zero-bias threshold voltage'
%   - 'KP'     2e-5   A/V^2  'Transconductance coefficient'
%   - 'GAMMA'  0.0    V^0.5  'Bulk threshold parameter'
%   - 'PHI'    0.6    V      'Surface potential'
%   - 'LAMBDA' 0.0    V^-1   'Channel-length modulation'
%   - 'RD'     0.0    Ohm    'Drain ohmic resistance'
%   - 'RS'     0.0    Ohm    'Source ohmic resistance'
%   - 'RSH'    0.0    Ohm/sq 'Drain  source diffusion sheet resistance' %TODO: what's sq
%   - 'CBD'    0.0    F      'Zero-bias bulk-drain p-n capacitance'
%   - 'CBS'    0.0    F      'Zero-bias bulk-source p-n capacitance'
%   - 'CJ'     0.0    F/M^2  'Bulk p-n zero-bias bottom capacitance/area'
%   - 'MJ'     0.5    NONE   'Bulk p-n bottom grading coefficient'
%   - 'CJSW'   0.0    F/M^2  'Bulk p-n zero-bias sidewall capacitance/area' %TODO: CJSW is with unit F/m in The Spice Book
%   - 'MJSW'   0.5    NONE   'Bulk p-n sidewall grading coefficient'
%   - 'PB'     0.8    V      'Bulk p-n bottom potential'
%   - 'IS'     1e-14  A      'Bulk p-n saturation current'
%   - 'CGDO'   0.0    F/M    'Gate-drain overlap capacitance/channel width'
%   - 'CGSO'   0.0    F/M    'Gate-source overlap capacitance/channel width'
%   - 'CGBO'   0.0    F/M    'Gate-bulk overlap capacitance/channel length'
%   - 'TOX'    1e-7   m      'Gate oxide thickness'
%   - 'LD'     0.0    m      'Lateral diffusion length'
% extra parms in MOSFET1 in Xyce-6.0
%   - 'L'      1e-4   m      'Default channel length'
%   - 'W'      1e-4   m      'Default channel width'
%   - 'JS'     0.0    A/M^2  'Bulk p-n saturation current density'
%   - 'UO'     600.0  CMM2VM1SM1  'Surface mobility' %TODO: what's this
%   - 'U0'     600.0  CMM2VM1SM1  'Surface mobility' %TODO: what's this
%   - 'FC'     0.5    NONE   'Bulk p-n forward-bias capacitance coefficient'
%   - 'NSUB'   0.0    CMM3   'Substrate doping density'
%   - 'NSS'    0.0    CMM2   'Surface state density'
%   - 'TNOM'   27.0   NONE   ''
%   - 'KF'     0.0    NONE   'Flicker noise coefficient'
%   - 'AF'     1.0    NONE   'Flicker noise exponent'
%   - 'TPG'    0      NONE   'Gate material type (-1 = same as substrate
%                             0 = aluminum  1 = opposite of substrate)'
%
%Examples
%--------
% % adding an NMOS with default parameters to an existing circuitdata structure
% cktdata = add_element(cktdata, MOS1ModSpec(), 'M1', ...
%           {'nD', 'nG', 'nS', 'nB'}, [], {});
%
%See also
%--------
% 
% add_element, circuitdata, ModSpec, supported_ModSpec_devices, DAEAPI, DAE
%

%
% author: T. Wang. 2014-06-27

%change log:
%-----------
%2014/06/27: Tianshi Wang <tianshi@berkeley.edu> Created


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

    MOD.model_name = 'MOS1';
    MOD.model_description = 'SPICE MOSFET level 1 model';

    % external connections (nodes)
    MOD.NIL.node_names = {'d', 'g', 's','b'};
    MOD.NIL.refnode_name = 'b';

    % IOs will be: vdb, vgb, vsb, idb, igb, isb
    MOD.IO_names = {'vdb', 'vgb', 'vsb', 'idb', 'igb', 'isb'};
    MOD.explicit_output_names = {'vdb', 'vgb', 'vsb'};
    MOD.otherIO_names = {'idb', 'igb', 'isb'};

    MOD.internal_unk_names = {}; % vecY
    MOD.implicit_equation_names = {}; % vecW
    MOD.u_names = {}; % vecU

	MOD.support_initlimiting = 1;
    MOD.limited_var_names = {};
    MOD.vecXY_to_limitedvars_matrix = [];   % vecLim = vecXY_to_limitedvars_matrix * [vecX;vecY]

    % define model parameters
    MOD.parm_names = {...
        'VTO', ...    % Zero-bias threshold voltage
        'KP', ...     % Transconductance coefficient
        'GAMMA', ...  % Bulk threshold parameter
        'PHI', ...    % Surface potential
        'LAMBDA', ... % Channel-length modulation
        'RD', ...     % Drain ohmic resistance
        'RS', ...     % Source ohmic resistance
        'RSH', ...    % Drain  source diffusion sheet resistance
        'CBD', ...    % Zero-bias bulk-drain p-n capacitance
        'CBS', ...    % Zero-bias bulk-source p-n capacitance
        'CJ', ...     % Bulk p-n zero-bias bottom capacitance/area
        'MJ', ...     % Bulk p-n bottom grading coefficient
        'CJSW', ...   % Bulk p-n zero-bias sidewall capacitance/area
        'MJSW', ...   % Bulk p-n sidewall grading coefficient
        'PB', ...     % Bulk p-n bottom potential
        'IS', ...     % Bulk p-n saturation current
        'CGDO', ...   % Gate-drain overlap capacitance/channel width
        'CGSO', ...   % Gate-source overlap capacitance/channel width
        'CGBO', ...   % Gate-bulk overlap capacitance/channel length
        'TOX', ...    % Gate oxide thickness
        'LD'  ...     % Lateral diffusion length
    };

    MOD.parm_defaultvals = {...
        0.0, ...   % 'VTO'
        2e-5, ...  % 'KP'
        0.0, ...   % 'GAMMA'
        0.6, ...   % 'PHI'
        0.0, ...   % 'LAMBDA'
        0.0, ...   % 'RD'
        0.0, ...   % 'RS'
        0.0, ...   % 'RSH'
        0.0, ...   % 'CBD'
        0.0, ...   % 'CBS'
        0.0, ...   % 'CJ'
        0.5, ...   % 'MJ'
        0.0, ...   % 'CJSW'
        0.5, ...   % 'MJSW'
        0.8, ...   % 'PB'
        1e-14, ... % 'IS'
        0.0, ...   % 'CGDO'
        0.0, ...   % 'CGSO'
        0.0, ...   % 'CGBO'
        1e-7, ...  % 'TOX'
        0.0  ...   % 'LD'
    };

    MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

    % MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
    % MOD.NIL.io_nodenames are set up by this helper function
    MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
    MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
    MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
    MOD.qi = @qi; % qi(vecX, vecY, MOD)
    MOD.qe = @qe; % qe(vecX, vecY, MOD)
    MOD.fqeiJ = @fqeiJ;
    MOD.fqei = @fqei_all;

% Newton-Raphson initialization support
    % MOD.initGuess = @initGuess;

% Newton-Raphson limiting support
    % MOD.limiting = @limiting;

end % MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%

function feout = fe(vecX, vecY, vecLim, vecU, MOD)
    % parms

    % 2 explicit output ids, igs
    feout(1,1) = ids; % idb
    feout(2,1) = 0;   % igb
    feout(3,1) = 0;   % isb
end % fe(...)

function qeout = qe(vecX, vecY, vecLim, MOD)
    qeout(1, 1) = 0;
    qeout(2, 1) = 0;
    qeout(3, 1) = 0;
end % qe(...)

function fiout = fi(vecX, vecY, vecLim, vecU, MOD)
    fiout = [];
end % fi(...)

function qiout = qi(vecX, vecY, vecLim, MOD)
    qiout = [];
end % qi(...)


function [fqei, J] = fqeiJ(vecX, vecY, vecLim, vecU, flag, MOD)
    if flag.J == 0
        [fqei.fe, fqei.qe, fqei.fi, fqei.qi] = fqei_all(vecX, vecY, vecLim, vecU, flag, MOD);
        J = [];
    else
        [fqei J] = dfqei_dvecXYLimU_auto(vecX, vecY, vecLim, vecU, MOD);
    end
end


function [fe, qe, fi, qi] = fqei_all(vecX, vecY, vecLim, u, flag, MOD)
% A structure that returns all the Js
% J is calculated by either vecvalder or by hand
% Stack 

    % ne = length(feval(MOD.ExplicitOutputNames, MOD));    
    % ni = length(feval(MOD.ImplicitEquationNames, MOD));    

    if ~isfield(flag,'fe')
        flag.fe =0;
    end
    if ~isfield(flag,'qe')
        flag.qe =0;
    end
    if ~isfield(flag,'fi')
        flag.fi =0;
    end
    if ~isfield(flag,'qi')
        flag.qi =0;
    end

    % parms
    Type = MOD.parm_vals{1};
    Beta = MOD.parm_vals{2};
    VT = MOD.parm_vals{3};
    Cgs = MOD.parm_vals{4};
    Cgd = MOD.parm_vals{5};
    DSgmin = MOD.parm_vals{6};

    vds = vecX(1);
    vgs = vecX(2);

    vdslim = vecLim(1);
    vgslim = vecLim(2);



    if flag.fe == 1
        if strcmp(Type, 'N') || strcmp(Type, 'n')
            if vdslim >=0 
                ids = forward_ids(vdslim, vgslim, Beta, VT);
            else % vdslim < 0, drain-source inversion
                ids = -forward_ids(-vdslim, vgslim-vdslim, Beta, VT);
            end
        else % P-type
            if vdslim <=0 
                ids = -forward_ids(-vdslim, -vgslim, Beta, VT);
            else % vdslim < 0, drain-source inversion
                ids = forward_ids(vdslim, -vgslim+vdslim, Beta, VT);
            end
        end
        ids = ids + vds*DSgmin; % to prevent matrix singularity errors when the device is off
    
        % 2 explicit output ids, igs
        fe(1,1) = ids; % ids
        fe(2,1) = 0;   % igs
    else
        fe = [];
    end

    if flag.qe == 1
        qe(1,1) = Cgd*(vdslim - vgslim);          % ids
        qe(2,1) = Cgs*vgslim - Cgd*(vdslim - vgslim); % igs
    else
        qe = [];
    end

    fi = [];
    qi = [];


end % fi(...)



%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function vecLim = initGuess(u, MOD)
% vdb = vecX(1), vgb = vecX(2), vsb = vecX(3)
% vdi_b = vecY(1), vsi_b = vecY(2)

% order of mparms is specified in the API file daaV6.py
    mparms = feval(MOD.getparms, MOD);
    [     ...
         Type, ...
         Beta, ... % Beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
         VT,   ... % VT
         Cgs,  ... % Cgs
         Cgd,  ... % Cgd
         DSgmin ... % DSgmin
    ] = deal(mparms{:});
    if strcmp(Type, 'P') || strcmp(Type, 'p')
        VT = -VT;
    end
    vecLim(1, 1) = 0;    % vds
    vecLim(2, 1) = VT;    % vgs 
end % initGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function vecLim = limiting(vecX, vecY, vecLimOld, u, MOD)
% vds = vecX(1), vgs = vecX(2)

% order of mparms is specified in the API file daaV6.py
    mparms = feval(MOD.getparms, MOD);
    [     ...
         Type, ...
         Beta, ... % Beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
         VT,   ... % VT
         Cgs,  ... % Cgs
         Cgd,  ... % Cgd
         DSgmin ... % DSgmin
    ] = deal(mparms{:});
    
    vds = vecX(1);
    vgs = vecX(2);
    vdsold = vecLimOld(1);
    vgsold = vecLimOld(2);

    vsb = 0;
    vdb = vds;
    vgb = vgs;
    vsbold = 0;
    vdbold = vdsold;
    vgbold = vgsold;
    % adpated from spice3f5 code in mos6
    % Note: this SH model currently doesn't actually have terminal b 
    vgs = vgb - vsb;
    vgd = vgb - vdb;
    vbs = -vsb;
    vbd = -vdb;
    vdsold = vdbold - vsbold;
    vgsold = vgbold - vsbold;
    vgdold = vgbold - vdbold;
    vbsold = -vsbold;
    vbdold = -vdbold;
    % TODO: vcrit is hard-coded here should get them somehow from parms
    vcrit = 0.6145;

    if strcmp(Type, 'P') || strcmp(Type, 'p')
        VT = -VT;
    end
    
    if vdsold >= 0
        vgs = fetlim(vgs, vgsold, VT);
        vds = vgs - vgd;
        vds = limvds(vds, vdsold);
        vgd = vgs - vds;
    else
        vgd = fetlim(vgd, vgdold, VT);
        vds = vgs - vgd;
        vds = -limvds(-vds, -vdsold);
        vgs = vgd + vds;
    end
    
    if vds >= 0
        vbs = pnjlim(vbsold, vbs, VT, vcrit);
        vbd = vbs - vds;
    else
        vbd = pnjlim(vbdold, vbd, VT, vcrit);
        vbs = vbd + vds;
    end
    
    vecLim(1, 1) = -vbd;
    vecLim(2, 1) = vgs - vbs;
end % limiting

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MODSPEC API %%%%%%%%%%%%%%%%%%%%%%%%

% private functions

function VTH = MOS1_VTH(vbs, VTO, GAMMA, PHI)
%function VTH = MOS1_VTH(vbs, VTO, GAMMA, PHI)
% This function calculates threshold voltage VTH in MOS level 1 model
% The implementation is based on "The SPICE Book", Chapter 3
% "Semiconductor-Device Elements", Section 3.5.1 MOSFET DC Model, Page 103.
% VTH = VTO + GAMMA * (sqrt(2*PHI-vbs) - sqrt(2*PHI))
% is the threshold voltage in the presence of back-gate bias, vbs < 0
    VTH = VTO + GAMMA * (sqrt(2*PHI-vbs) - sqrt(2*PHI));
end % MOS1_VTH

function ids = forward_ids(vds, vgs, VTH, KP, W, L, LD, LAMBDA)
%function ids = forward_ids(vds, vgs, VTH, KP, W, L, LD, LAMBDA)
% This function calculates forward ids in MOS level 1 model. It is pretty much
% the same as ids in Shichman Hodges model.
% The implementation is based on "The SPICE Book", Chapter 3
% "Semiconductor-Device Elements", Section 3.5.1 MOSFET DC Model, Page 103.
%       0                                              for vgs <= VTH
% ids = KP/2 * W/Leff * (vgs-VTH)^2 * (1+LAMBDA*vds)   for 0< vgs - VTH <= vds
%       KP/2 * W/Leff * vds * (2*(vgs-VTH)-vds) * (1+LAMBDA*vds)
%                                                       for 0< vds < vgs - VTH
% where Leff = L - 2*LD is the effective channel length corrected for the
% lateral diffusion LD, of the drain and source
    Leff = L - 2*LD;
    if (vgs <= VTH)
          % off
          ids = 0;
    elseif (vgs <= vds + VT)
          % active
          ids = KP/2 * W/Leff * (vgs-VTH)^2 * (1+LAMBDA*vds);
    else % vgs > vds+VT
          % triode
          ids = KP/2 * W/Leff * vds * (2*(vgs-VTH)-vds) * (1+LAMBDA*vds);
    end
end % forward_ids
