function MOD = DAAV6ModSpec(uniqID)
%function MOD = DAAV6ModSpec(uniqID)
%The DAAV6 version of Dimitri Antoniadis' Virtual Source (VS) model.
%
% There is a newer version of this model.
% Please use MVS_1_0_1_ModSpec instead.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'M1'
%
%Return values:
% - MOD:    a ModSpec object for the MVS model
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'d', 'g', 's', 'b'} (drain, gate, source, bulk).
%
% - parameters:
%        default: 'n'
% - 'tipe'       ('n' or 'p')
%        default: 1.0e-4
% - 'W'          (Width [cm])
%        default: 35e-7
% - 'Lg'         (Gate length [cm])
%        default: 0.3*35e-7
% - 'dLg'        (dLg=L_g-L_c (default 0.3xLg_nom))
%        default: 1.83e-6
% - 'Cg'         (Gate cap [F/cm^2])
%        default: 0.120
% - 'delta'      (DIBL [V/V])
%        default: 0.100
% - 'S'          (Subthreshold swing [V/decade] OBSOLETE?)
%        default: 100e-9
% - 'Ioff'       (Adjusted from Transfer Id-Vg OBSOLETE?)
%        default: 1.2
% - 'Vdd'        (Vd [V] corresponding to Ioff OBSOLETE?)
%        default: 0
% - 'Vgoff'      (Vg [V] corresponding to Ioff (typ. 0V) OBSOLETE?)
%        default: 80
% - 'Rs'         (Rs [ohm-micron] )
%        default: 80
% - 'Rd'         (Rd [ohm-micron] )
%        default: 1.4e7
% - 'vxo'        (Virtual source velocity [cm/s])
%        default: 250
% - 'mu'         (Mobility [cm^2/V.s])
%        default: 1.8
% - 'beta'       (Saturation factor. Typ. nFET=1.8, pFET=1.4)
%        default: 0.0256
% - 'phit'       (kT/q assuming T=27 C.                      )
%        default: 0.1
% - 'gamma'      (Body factor  [sqrt(V)])
%        default: 0.9
% - 'phib'       (=abs(2*phin)>0 [V])
%        default: 1e-20
% - 'smoothing'  (smoothing parameter for smoothing funcs)
%        default: 1e50
% - 'expMaxslope'( max slope for safeexp)
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vdb  vgb  vsb  idb  igb  isb
% - explicit output name(s):         idb  igb  isb
% - other IO name(s) (vecX):         vdb  vgb  vsb
%
% - implicit unknown name(s) (vecY): vdib, vsib
% - input names (vecU):              {}
% - limited variable (vecLim):       vdiblim  vgblim  vsiblim
%   when there is no init/limiting:
%   vdiblim = vdib
%   vgblim = vgb
%   vsiblim = vsib
%   i.e.
%       vecXY_to_limitedvars_matrix = [0 0 0 1 0
%                                      0 1 0 0 0
%                                      0 0 0 0 1];
%       vecLim = vecXY_to_limitedvars_matrix * [vecX; vecY];
%
% 2. equations:
% - equations of MVS model are ported from DAAV6 version of Dimitri Antoniadis'
% Virtual Source (VS) model.
%
%
%Examples
%--------
% % adding a DAAV6 NMOS with default parameters to a circuitdata structure
% cktdata = add_element(cktdata, DAAV6ModSpec(), 'M1', ...
%           {'nD', 'nG', 'nS', 'nB'}, [], {});
%
%See also
%--------
% 
% MVS_1_0_1_ModSpec_wrapper, add_element, circuitdata[TODO], ModSpec, DAEAPI,
% DAE_concepts
%


%Author: JR, 2012/05/25 (using code supplied by Dimitri Antoniadis in 2008).
%     - added hand-coded derivative support 2012/07/23

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

    MOD.model_name = 'DAAV6';
    MOD.spice_key = 'm';
    MOD.model_description = 'DAAV6 version of VS model';

    MOD.parm_names = {...
         'tipe',   ... % 'n' or 'p'
         'W',      ... % Width [cm]
         'Lg',       ... % Gate length [cm]
         'dLg',    ... % dLg=L_g-L_c (default 0.3xLg_nom)
         'Cg',     ... % Gate cap [F/cm^2]
         'delta',  ... % DIBL [V/V]
         'S',      ... % Subthreshold swing [V/decade] OBSOLETE?
         'Ioff',   ... % Adjusted from Transfer Id-Vg OBSOLETE?
         'Vdd',    ... % Vd [V] corresponding to Ioff OBSOLETE?
         'Vgoff',  ... % Vg [V] corresponding to Ioff (typ. 0V) OBSOLETE?
         'Rs',     ... % Rs [ohm-micron] 
         'Rd',     ... % Rd [ohm-micron] 
         'vxo',    ... % Virtual source velocity [cm/s]
         'mu',     ... % Mobility [cm^2/V.s]
         'beta',   ... % Saturation factor. Typ. nFET=1.8, pFET=1.4
         'phit',   ... % kT/q assuming T=27 C.                      
         'gamma',  ... % Body factor  [sqrt(V)]
         'phib',   ... % =abs(2*phin)>0 [V]
         'smoothing',  ... % smoothing parameter for smoothing funcs
         'expMaxslope'  ... % max slope for safeexp
    };

    MOD.parm_defaultvals = {...
        'n',        ... % NFET - can  also be 'p' for PFET
        1.0e-4,    ... % W: Width [cm]
        35e-7,     ... % Lg: Gate length [cm]
        0.3*35e-7, ... % dLg=L_g-L_c (default {0.3,0.25}xLg_nom) {n,p}
        1.83e-6,   ... % Cg: Gate cap [F/cm^2] (p: 1.70e-6)
        0.120,     ... % delta: DIBL [V/V] (p: 0.155)
        0.100,     ... % S: Subthreshold swing [V/decade]
        100e-9,    ... % Ioff: Adjusted from Transfer Id-Vg
        1.2,       ... % Vdd: Vd [V] corresponding to Ioff
        0,         ... % Vgoff: Vg [V] corresponding to Ioff (typ. 0V)
        80,        ... % Rs [ohm-micron] (p: 130)
        80,        ... % Rd [ohm-micron] (assume Rs=Rd) (p: 130)
        1.4e7,     ... % vxo: Virtual source velocity [cm/s] (p: 0.85e7)
        250,       ... % mu: Mobility [cm^2/V.s] (p: 140)
        1.8,       ... % beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
        0.0256,    ... % phit: kT/q assuming T=27 C.                     
        0.1,       ... % gamma
        0.9,       ... % phib
        1e-20,     ... % smoothing
        1e50       ... % expMaxslope
    };

    MOD.parm_types = {...
        'char',        ... % NFET - can  also be 'p' for PFET
        'double',    ... % W: Width [cm]
        'double',     ... % Lg: Gate length [cm]
        'double', ... % dLg=L_g-L_c (default {0.3,0.25}xLg_nom) {n,p}
        'double',   ... % Cg: Gate cap [F/cm^2] (p: 1.70e-6)
        'double',     ... % delta: DIBL [V/V] (p: 0.155)
        'double',     ... % S: Subthreshold swing [V/decade]
        'double',    ... % Ioff: Adjusted from Transfer Id-Vg
        'double',       ... % Vdd: Vd [V] corresponding to Ioff
        'double',         ... % Vgoff: Vg [V] corresponding to Ioff (typ. 0V)
        'double',        ... % Rs [ohm-micron] (p: 130)
        'double',        ... % Rd [ohm-micron] (assume Rs=Rd) (p: 130)
        'double',     ... % vxo: Virtual source velocity [cm/s] (p: 0.85e7)
        'double',       ... % mu: Mobility [cm^2/V.s] (p: 140)
        'double',       ... % beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
        'double',    ... % phit: kT/q assuming T=27 C.                     
        'double',       ... % gamma
        'double',       ... % phib
        'double',     ... % smoothing
        'double'       ... % expMaxslope
    };

    MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

    MOD.NIL.node_names = {'d', 'g', 's', 'b'};
    MOD.NIL.refnode_name = 'b';
        % IOs will be: vdb, vgb, vsb, idb, igb, isb
    MOD.explicit_output_names = {'idb', 'igb', 'isb'};
    MOD.internal_unk_names = {'vdi_b', 'vsi_b'};
    MOD.implicit_equation_names = {'di_KCL', 'si_KCL'};
    MOD.u_names = {};

    % MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
    % MOD.NIL.io_nodenames are set up by this helper function
    MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
    MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
    MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
    MOD.qi = @qi; % qi(vecX, vecY, MOD)
    MOD.qe = @qe; % qe(vecX, vecY, MOD)

% Derivative functions
    % use hand-coded derivatives
    % (comment out to use automatic diff)
    %{
    MOD.dfe_dvecX = @dfe_dvecX;
    MOD.dfe_dvecY = @dfe_dvecY;
    MOD.dfe_dvecU = @dfe_dvecU;
    MOD.dqe_dvecX = @dqe_dvecX;
    MOD.dqe_dvecY = @dqe_dvecY;
    MOD.dfi_dvecX = @dfi_dvecX;
    MOD.dfi_dvecY = @dfi_dvecY;
    MOD.dfi_dvecU = @dfi_dvecU;
    MOD.dqi_dvecX = @dqi_dvecX;
    MOD.dqi_dvecY = @dqi_dvecY;
    %}

% Newtos-Raphson initialization support

% Newton-Raphson limiting support

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % DAAV6 MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fiout = fi(vecX, vecY, vecU, MOD)
    fiout = fqei_dfqeidXYU(vecX, vecY, vecU, MOD, 'f', 'i');
end % fi(...)

function qiout = qi(vecX, vecY, MOD)
    qiout = fqei_dfqeidXYU(vecX, vecY, [], MOD, 'q', 'i');
end % qi(...)

function feout = fe(vecX, vecY, vecU, MOD)
    feout = fqei_dfqeidXYU(vecX, vecY, vecU, MOD, 'f', 'e');
end % fe(...)

function qeout = qe(vecX, vecY, MOD)
    qeout = fqei_dfqeidXYU(vecX, vecY, [], MOD, 'q', 'e');
end % qe(...)

function dZf_dvecX = dfe_dvecX(vecX, vecY, vecU, MOD)
    [Zf, dZf_dvecX] = fqei_dfqeidXYU(vecX, vecY, vecU, MOD, 'f', 'e', 'X');
end 
% end function dfe_dvecX

function dZf_dvecY = dfe_dvecY(vecX, vecY, vecU, MOD)
    [Zf, dZf_dvecY] = fqei_dfqeidXYU(vecX, vecY, vecU, MOD, 'f', 'e', 'Y');
end 
% end function dfe_dvecY

function dZf_dvecU = dfe_dvecU(vecX, vecY, vecU, MOD)
    dZf_dvecU = sparse(3,0);
end 
% end function dfe_dvecU

function dZq_dvecX = dqe_dvecX(vecX, vecY, MOD)
    [Zq, dZq_dvecX] = fqei_dfqeidXYU(vecX, vecY, [], MOD, 'q', 'e', 'X');
end 
% end function dqe_dvecX

function dZq_dvecY = dqe_dvecY(vecX, vecY, MOD)
    [Zq, dZq_dvecY] = fqei_dfqeidXYU(vecX, vecY, [], MOD, 'q', 'e', 'Y');
end 
% end function dqe_dvecY

%%%

function dWf_dvecX = dfi_dvecX(vecX, vecY, vecU, MOD)
    [Wf, dWf_dvecX] = fqei_dfqeidXYU(vecX, vecY, vecU, MOD, 'f', 'i', 'X');
end 
% end function dfe_dvecX

function dWf_dvecY = dfi_dvecY(vecX, vecY, vecU, MOD)
    [Wf, dWf_dvecY] = fqei_dfqeidXYU(vecX, vecY, vecU, MOD, 'f', 'i', 'Y');
end 
% end function dfe_dvecY

function dWf_dvecU = dfi_dvecU(vecX, vecY, vecU, MOD)
    dWf_dvecU = sparse(2,0);
end 
% end function dfe_dvecU

function dWq_dvecX = dqi_dvecX(vecX, vecY, MOD)
    [Wq, dWq_dvecX] = fqei_dfqeidXYU(vecX, vecY, [], MOD, 'q', 'i', 'X');
end 
% end function dqe_dvecX

function dWq_dvecY = dqi_dvecY(vecX, vecY, MOD)
    [Wq, dWq_dvecY] = fqei_dfqeidXYU(vecX, vecY, [], MOD, 'q', 'i', 'Y');
end 
% end function dqe_dvecY



%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% ANALYSIS-SPECIFIC INPUT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% EQN and UNK SCALING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MODSPEC API %%%%%%%%%%%%%%%%%%%%%%%%
function [fqout, dfqout] = fqei_dfqeidXYU(vecX, vecY, vecU, MOD, forq, eori, XYorU)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set up scalar variables for the parms, vecX, vecY and vecU 

    % create variables of the same names as the parameters and assign
    % them the values in MOD.parms
    % ideally, this should be a macro
    %     - could do this using a string and another eval()
    % BUT eval() IS EXTREMELY INEFFICIENT - IT DOMINATES EVAL TIME. HENCE
    % DEPRECATED, EVEN THOUGH QUITE CONVENIENT.
    %{
    pnames = feval(MOD.parmnames, MOD);
    for i = 1:length(pnames)
        evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
        eval(evalstr);
    end
    %}
    mparms = feval(MOD.getparms, MOD);
    [     ...
    tipe, ...
        W,    ...
        Lg,   ...
        dLg,  ...
        Cg,   ...
        delta,...
        S,    ...
        Ioff, ...
        Vdd,  ...
        Vgoff,...
        Rs,   ...
        Rd,   ...
        vxo,  ...
        mu,   ...
        beta, ...
        phit, ...
    gamma,...
    phib, ...
    smoothing, ...
    expMaxslope ...
    ] = deal(mparms{:});

    % similarly, get values from vecX, named exactly the same as otherIOnames
    % get otherIOs from vecX
    oios = feval(MOD.OtherIONames, MOD);
    for i = 1:length(oios)
        evalstr = sprintf('%s = vecX(i);', oios{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, this should set up: vdb = vecX(1), vgb = vecX(2), vsb = vecX(3)

    % do the same for vecY from internalUnknowns
    % get internalUnknowns from vecY
    iunks = feval(MOD.InternalUnkNames, MOD);
    for i = 1:length(iunks)
        evalstr = sprintf('%s = vecY(i);', iunks{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, this should set up: vdi_b = vecY(1), vsi_b = vecY(2)

    %{
    % do the same for u from uNames
    unms = uNames(MOD);
    for i = 1:length(unms)
        evalstr = sprintf('%s = vecU(i);', unms{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, there are no us
    %}

    if nargout > 1
        derivs_wanted = 1;
        if nargin < 7
            fprintf(2, 'fqei_dfqeidXYU: error: derivatives wanted, but XYorU argument not specified!\n');
            fqout = []; dfqout = [];
            return;
        else
            if ~('X' == XYorU || 'Y' == XYorU || 'U' == XYorU)
                fprintf(2, 'fqei_dfqeidXYU: error: XYorU argument not one of ''X'', ''Y'' or ''U''.\n');
                fqout = []; dfqout = [];
                return;
            end
        end
    else
        derivs_wanted = 0;
    end

    % end setting up scalar variables for the parms, vecX, vecY and u
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    typemult = (tipe == 'n')*2 - 1;  % 1 if n-type device, -1 if p-type

    % DAAV6 was written originally using node voltages, not branch voltages
    % re-using that code, so defining node voltages
    vb = 0; % internal reference, arbitrary value
    vd = vdb + vb;
    vg = vgb + vb;
    vs = vsb + vb;
    vdi = vdi_b + vb;
    vsi = vsi_b + vb;

    corevd = typemult*vdi;
    corevg = typemult*vg;
    corevs = typemult*vsi;
    corevb = typemult*vb;

    mparms = feval(MOD.getparms, MOD);

    if 1 == strcmp(eori,'e') % e
        if 1 == strcmp(forq, 'f') % f
            ig = 0; 
            % idb (vd - vdi)/Rd
            fqout(1,1) = (vd - vdi)/Rd;
            % igb
            fqout(2,1) = typemult*ig;
            % isb (vs - vsi)/Rs
            fqout(3,1) = (vs - vsi)/Rs;
            if 1 == derivs_wanted
                if 'X' == XYorU
                    dfqout = sparse(3,3);
                    %fqout(1,1) = (vd - vdi)/Rd;
                    % vd: index 1 in X: vdb+vb
                    % vdi: index 1 in vecY
                    dfqout(1,1) = 1/Rd;

                    %fqout(2,1) = typemult*ig = 0;
                    % vg: index 2 in X: vgb+vb

                    %fqout(3,1) = (vs - vsi)/Rs;
                    % vs: index 3 in X: vsb+vb
                    % vsi: index 2 in Y: vsb+vb
                    dfqout(3,3) = 1/Rs;
                elseif 'Y' == XYorU
                    dfqout = sparse(3,2);
                    %fqout(1,1) = (vd - vdi)/Rd;
                    % vd: index 1 in X: vdb+vb
                    % vdi: index 1 in vecY
                    dfqout(1,1) = -1/Rd;

                    %fqout(2,1) = typemult*ig = 0;
                    % vg: index 2: vgb+vb

                    %fqout(3,1) = (vs - vsi)/Rs;
                    % vs: index 3: vsb+vb
                    % vsi: index 2 in Y: vsb+vb
                    dfqout(3,2) = -1/Rs;
                elseif 'U' == XYorU
                    dfqout = sparse(3,0);
                end
            end % derivs_wanted
        else % q
            [qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
            % qb not used because it is redundant: qb = (-qdi-qg-qsi)
            % idb 
            fqout(1,1) = 0*qg; % no d/dt term in idb contribution
            % igb
            fqout(2,1) = typemult*qg;
            % isb
            fqout(3,1) = 0*qg;  % no d/dt term in isb contribution
            if 1 == derivs_wanted
                %[qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
                [dqdi, dqg, dqsi, dqb] = d_daaV6_core_model_Qs(corevd,corevg,corevs,corevb,mparms);
                % ^^ each of these is a _column_ vector of size 4
                if 'X' == XYorU
                    dfqout = sparse(3,3);
                    % idb: fqout(1,1) = 0*qg; % no d/dt term in idb contribution

                    %corevd = typemult*vdi = typemult*vecY(1)
                    %corevg = typemult*vg = typemult*(vecX(2)+vb)
                    %corevs = typemult*vs = typemult*vecY(2)
                    % igb: fqout(2,1) = typemult*qg;
                    dfqout(2,2) = typemult*dqg(2)*typemult;

                    % isb: fqout(3,1) = 0*qg;  % no d/dt term in isb contribution
                elseif 'Y' == XYorU
                    dfqout = sparse(3,2);
                    % idb: fqout(1,1) = 0*qg; % no d/dt term in idb contribution

                    %corevd = typemult*vdi = typemult*vecY(1)
                    %corevg = typemult*vg = typemult*(vecX(2)+vb)
                    %corevs = typemult*vs = typemult*vecY(2)
                    % igb: fqout(2,1) = typemult*qg;
                    dfqout(2,1) = typemult*dqg(1)*typemult;
                    dfqout(2,2) = typemult*dqg(3)*typemult;

                    % isb: fqout(3,1) = 0*qg;  % no d/dt term in isb contribution
                elseif 'U' == XYorU
                    dfqout = sparse(3,0);
                end
            end % derivs_wanted
        end % forq
    else % i
        if 1 == strcmp(forq, 'f') % f
            ig = 0;
            ib = 0; 
            idsi = daaV6_core_model_Iy(corevd, corevg, corevs, corevb, mparms);
            % di_KCL: (vdi - vd)/Rd + idsi
            fqout(1,1) = (vdi-vd)/Rd + typemult*idsi;
            % si_KCL: (vsi - vs)/Rs - idsi - ig - ib
            fqout(2,1) = (vsi-vs)/Rs - typemult*(idsi+ig+ib);

            if 1 == derivs_wanted
                %idsi = daaV6_core_model_Iy(corevd, corevg, corevs, corevb, mparms);
                didsi = d_daaV6_core_model_Iy(corevd,corevg,corevs,corevb,mparms);
                % ^ this is a column vector of length 4

                % vdi = vecY(1)
                % vd ~= vecX(1)
                % vsi = vecY(2)
                % vs ~= vecX(3)
                % corevd = typemult*vdi = typemult*vecY(1)
                % corevg = typemult*vg = typemult*(vecX(2)+vb)
                % corevs = typemult*vsi = typemult*vecY(2)
                if 'X' == XYorU
                    dfqout = sparse(2,3);

                    % fqout(1,1) = (vdi-vd)/Rd + typemult*idsi;
                    dfqout(1, 1) = -1/Rd;
                    dfqout(1, 2) = typemult*didsi(2)*typemult;

                    % fqout(2,1) = (vsi-vs)/Rs - typemult*(idsi+ig+ib);
                    dfqout(2, 3) = -1/Rs;
                    dfqout(2, 2) = -typemult*didsi(2)*typemult;
                elseif 'Y' == XYorU
                    dfqout = sparse(2,2);

                    % fqout(1,1) = (vdi-vd)/Rd + typemult*idsi;
                    dfqout(1,1) = 1/Rd + typemult*didsi(1)*typemult;
                    dfqout(1,2) = typemult*didsi(3)*typemult;

                    % fqout(2,1) = (vsi-vs)/Rs - typemult*(idsi+ig+ib);
                    dfqout(2,1) = - typemult*didsi(1)*typemult;
                    dfqout(2,2) = 1/Rs - typemult*didsi(3)*typemult;
                elseif 'U' == XYorU
                    dfqout = sparse(2,0);
                end
            end % derivs_wanted
        else % q
            [qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
            % qb not used because it is redundant: qb = (-qdi-qg-qsi)
            % di_KCL: d/dt terms
            fqout(1,1) = typemult*qdi;
            % si_KQL: d/dt terms
            fqout(2,1) = typemult*qsi;

            if 1 == derivs_wanted
                %[qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
                [dqdi, dqg, dqsi, dqb] = d_daaV6_core_model_Qs(corevd,corevg,corevs,corevb,mparms);
                % ^^ each of these is a _column_ vector of size 4

                % corevd = typemult*vdi = typemult*vecY(1)
                % corevg = typemult*vg = typemult*(vecX(2)+vb)
                % corevs = typemult*vsi = typemult*vecY(2)
                if 'X' == XYorU
                    dfqout = sparse(2,3);

                    % fqout(1,1) = typemult*qdi;
                    dfqout(1,2) = typemult*dqdi(2)*typemult;

                    % fqout(2,1) = typemult*qsi;
                    dfqout(2,2) = typemult*dqsi(2)*typemult;

                elseif 'Y' == XYorU
                    dfqout = sparse(2,2);

                    % fqout(1,1) = typemult*qdi;
                    dfqout(1,1) = typemult*dqdi(1)*typemult;
                    dfqout(1,2) = typemult*dqdi(3)*typemult;

                    % fqout(2,1) = typemult*qsi;
                    dfqout(2,1) = typemult*dqsi(1)*typemult;
                    dfqout(2,2) = typemult*dqsi(3)*typemult;

                elseif 'U' == XYorU
                    dfqout = sparse(2,0);
                end
            end % derivs_wanted
        end
    end
end % fqei(...)

function [Vt, Vt0] = VT(W,Ioff,Vgoff,Vdd,S,delta,vxo,Qref,phit)
% this function is copied exactly from Dimitri's file VT.m
% Author: Dimitri Antoniadis <daa@mtl.mit.edu> - circa December 2008
% Calculate Vt(Vd=Vdd)from Ioff at Vg=Vgoff and Vd=Vdd.
% Then calculate Vt0=Vt(Vd=0) by accounting for DIBL.
% The Vdd value must be larger than ~3*phit.
% It is assumed that Vgoff is in the weak inversion
    Vt = Vgoff + S./2.3.*log((W*vxo .* Qref)./Ioff);
    dVt=1;
    alpha=3.5;
    % note: involves a loop, below
    while abs(dVt./Vt)>1e-3
        FF=1./(1+exp((Vgoff-(Vt-alpha/2*phit))/(alpha*phit)));
        Vtx=Vgoff+FF*alpha*phit-S/2.3.*log(exp(Ioff./(W*vxo*Qref))-1);
        dVt=Vtx-Vt;
        Vt=Vtx;
    end 
    Vt0=Vt+Vdd.*delta;
end
% end of VT

function idsi = daaV6_core_model_Iy(Vy, Vg, Vx, Vb, mparms)
    docharges = 0;
    docurrents = 1;
    [idsi,dummy1,dummy2,dummy3,dummy4] = daaV6_core_model(Vy,Vg,Vx,Vb,...
        mparms, docurrents, docharges);
end
% end of daaV6_core_model_Iy

function [qdi, qg, qsi, qb] = daaV6_core_model_Qs(Vy, Vg, Vx, Vb, mparms)
    docharges = 1;
    docurrents = 0;
    [dummy, qdi, qg, qsi, qb] = daaV6_core_model(Vy,Vg,Vx,Vb,mparms,...
        docurrents, docharges);
end
% end of daaV6_core_model_Qs

function [Iy, Qy, Qg, Qx, Qb] = daaV6_core_model(Vy, Vg, Vx, Vb, mparms, docurrents, docharges)
    % order of mparms is specified in the API file daaV6.py
    [     ...
    type, ...
        W,    ...
        Lg,   ...
        dLg,  ...
        Cg,   ...
        delta,...
        S,    ...
        Ioff, ...
        Vdd,  ...
        Vgoff,...
        Rs,   ...
        Rd,   ...
        vxo,  ...
        mu,   ...
        beta, ...
        phit, ...
    gamma,...
    phib, ...
    smoothing, ...
    expMaxslope ...
    ] = deal(mparms{:});

    % tipe is not used here, but applied in ./daaV6_{f,q,df,dq}func.m

    % from Dimitri's NFET_I_V_Q_2
    n = S/(2.3*phit);
    Qref=Cg*n*phit;
    [Vt, Vt0] = VT(W,Ioff,Vgoff,Vdd,S,delta,vxo,Qref,phit);

    % from Dimitri's IDC2n_smoothed.m
    alpha = 3.5;

    % charges are O(fF) = 10^-15, so need to scale smoothing for those
    % smoothabs(0) for charge quantities = sqrt(smoothing*qsmoothingfactor)
    % qsmoothingfactor = 10^-16;
    % but all smoothing seems to be applied to voltage quantities, so
    % there should be no need for this.

        Vgg=smoothmax((Vg-Vx),(Vg-Vy),smoothing); 
        Vbb=smoothmax((Vb-Vx),(Vb-Vy),smoothing);
        Vd=smoothabs(Vy-Vx,smoothing);          
        dir=smoothsign(Vy-Vx,smoothing);        
        Vt0b=Vt0+gamma*(safesqrt(phib-Vbb,smoothing)-sqrt(phib));

        FF=1./(1+safeexp((Vgg-(Vt0b-Vd.*delta-alpha/2*phit))/(alpha*phit),expMaxslope));
        eta=(Vgg-(Vt0b-Vd.*delta-FF*alpha*phit))./(n*phit);
        Qinv = Qref.*safelog(1+safeexp(eta,expMaxslope),smoothing);
        Vdsats=vxo.*(Lg-dLg)./mu;
        Vdsat=Vdsats.*(1-FF)+phit*FF;
        Fsat=(Vd./Vdsat)./((1+(Vd./Vdsat).^beta).^(1/beta));

    if (1 == docurrents)
            Iy =dir.*W.*Qinv.*vxo.*Fsat;
    else
        Iy = [];
    end % docurrents
 
    if (1 == docharges)
            Qx=-W*(Lg-dLg)*Qinv.*((1+dir)+(1-dir).*(1-Fsat))/4;
            Qy=-W*(Lg-dLg)*Qinv.*((1-dir)+(1+dir).*(1-Fsat))/4;

            psis=phib+alpha*phit+phit*safelog(safelog(1+exp(eta),smoothing),smoothing); 
            %psis=phib;  %Alternative approximation if above is troublesome!
            Qb=-W*Cg*Lg*gamma*(safesqrt(psis-Vbb,smoothing) + ...
                safesqrt(psis-(Vbb-(Vd.*(1-Fsat)+Vdsat.*Fsat)),smoothing))/2;
            Qg=-(Qx+Qy+Qb);
    else
        Qx = []; Qy = []; Qb = []; Qg = [];
    end % docharges
end
% end of daaV6_core_model

function didsi = d_daaV6_core_model_Iy(Vy,Vg,Vx,Vb,mparms)
    docharges = 0;
    docurrents = 1;
    [didsi, dummy1, dummy2, dummy3, dummy4] = d_daaV6_core_model(Vy,Vg,Vx,Vb,mparms, docurrents, docharges);
end
% end of d_daaV6_core_model_Iy
    
function [dqdi, dqg, dqsi, dqb] = d_daaV6_core_model_Qs(Vy,Vg,Vx,Vb,mparms)
    docharges = 1;
    docurrents = 0;
    [dummy, dqdi, dqg, dqsi, dqb] = d_daaV6_core_model(Vy,Vg,Vx,Vb,...
        mparms, docurrents, docharges);
end
% end of d_daaV6_core_model_Qs
    
function [dIy, dQy, dQg, dQx, dQb] = d_daaV6_core_model(Vy,Vg,Vx,Vb,mparms, docurrents, docharges)
    % order of mparms is specified in the API file daaV6.py
    [     ...
    type, ...
        W,    ...
        Lg,   ...
        dLg,  ...
        Cg,   ...
        delta,...
        S,    ...
        Ioff, ...
        Vdd,  ...
        Vgoff,...
        Rs,   ...
        Rd,   ...
        vxo,  ...
        mu,   ...
        beta, ...
        phit, ...
    gamma,...
    phib, ...
    smoothing, ...
    expMaxslope ...
    ] = deal(mparms{:});


    % type is not used here, but applied upstairs in
    %       ./daaV6_{f,q,df,dq}func.m

    % from Dimitri's NFET_I_V_Q_2
    n = S/(2.3*phit);
    Qref=Cg*n*phit;
    [Vt, Vt0] = VT(W,Ioff,Vgoff,Vdd,S,delta,vxo,Qref,phit);

    % from dIDC2n_smoothed.m
    alpha = 3.5;

    % charges are O(fF) = 10^-15, so need to scale smoothing for those
    % smoothabs(0) for charge quantities = sqrt(smoothing*qsmoothingfactor)
    qsmoothingfactor = 10^-28;

        %inputs are Vy=Vd, Vg, Vx=Vs, Vb

        Vg = reshape(Vg, 1, []); % convert to a row vector
        Vx = reshape(Vx, 1, []);
        Vy = reshape(Vy, 1, []);
        Vb = reshape(Vb, 1, []);
        
        Vgg=smoothmax((Vg-Vx),(Vg-Vy),smoothing); % Vgs
        % begin derivatives of Vgg
        [a, b] = dsmoothmax((Vg-Vx),(Vg-Vy),smoothing);
        dVgg_dy = -b;
        dVgg_dg = a+b;
        dVgg_dx = -a;
        %dVgg_db = 0;
        % end derivatives of Vgg
        
        Vbb=smoothmax((Vb-Vx),(Vb-Vy),smoothing); % Vbs
        % begin derivatives of Vbb
        [a, b] = dsmoothmax((Vb-Vx),(Vb-Vy),smoothing);
        dVbb_dy = -b;
        %dVbb_dg = 0;
        dVbb_dx = -a;
        dVbb_db = a+b;
        % end derivatives of Vbb
        
        Vd=smoothabs(Vy-Vx,smoothing);           % Vds
        % begin derivatives of Vd
        dVd_dy = dsmoothabs(Vy-Vx,smoothing);
        %dVd_dg = 0;
        dVd_dx = -dVd_dy; %-dsmoothabs(Vx-Vy,smoothing);
        %dVd_db = 0;
        % end derivatives of Vd
        
        dir=smoothsign(Vy-Vx,smoothing);          % whether Vd > Vs
        % begin derivatives of dir
        ddir_dy = dsmoothsign(Vy-Vx,smoothing);
        %ddir_dg = 0;
        ddir_dx = -ddir_dy; %dsmoothsign(Vy-Vx,smoothing);
        %ddir_db = 0;
        % end derivatives of dir
        
        
        Vt0b=Vt0+gamma*(safesqrt(phib-Vbb,smoothing)-sqrt(phib)); %
        % begin derivatives of Vt0b
        dVt0b_dVbb = -gamma*dsafesqrt(phib-Vbb,smoothing);
        dVt0b_dy = dVt0b_dVbb .* dVbb_dy;
        %dVt0b_dg = 0;
        dVt0b_dx = dVt0b_dVbb .* dVbb_dx;
        dVt0b_db = dVt0b_dVbb .* dVbb_db;
        % end derivatives of Vt0b
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % input variables now moving to: Vgg, Vd, Vt0b and dir
            
        %FF=1./(1+safeexp((Vgg-(Vt0b-Vd.*delta-alpha/2*phit))/(alpha*phit),...
        %    expMaxslope));
        FFdenom = 1+safeexp((Vgg-(Vt0b-Vd.*delta-alpha/2*phit))/(alpha*phit),...
            expMaxslope);
        % begin derivatives of FFdenom and FF wrt Vgg, Vt0b, Vd
        a = dsafeexp((Vgg-(Vt0b-Vd.*delta-alpha/2*phit))/(alpha*phit), expMaxslope);
        dFFdenom_dVgg = a/(alpha*phit);
        dFFdenom_dVt0b = -a/(alpha*phit);
        dFFdenom_dVd = a*delta/(alpha*phit);
        %
        FF=1./FFdenom;
        a = -1./(FFdenom.^2);
        dFF_dVgg = a.*dFFdenom_dVgg;
        dFF_dVt0b = a.*dFFdenom_dVt0b;
        dFF_dVd = a.*dFFdenom_dVd;
        % end derivatives of FFdenom and FF wrt Vgg, Vt0b, Vd

        eta=(Vgg-(Vt0b-Vd.*delta-FF*alpha*phit))./(n*phit);
        % begin derivatives of eta
        deta_dVgg = 1./(n*phit)  + dFF_dVgg*alpha/n;
        deta_dVd = delta./(n*phit) + dFF_dVd*alpha/n;
        deta_dVt0b = -1./(n*phit) + dFF_dVt0b*alpha/n;
        % end derivatives of eta

        Qinv = Qref.*safelog(1+safeexp(eta,expMaxslope),smoothing);
        % begin derivatives of Qinv
        a = dsafelog(1+safeexp(eta,expMaxslope),smoothing);
        b = dsafeexp(eta,expMaxslope);
        dQinv_dVgg = Qref.*a.*b.*deta_dVgg;
        dQinv_dVd = Qref.*a.*b.*deta_dVd;
        dQinv_dVt0b = Qref.*a.*b.*deta_dVt0b;
        % end derivatives of Qinv

        Vdsats=vxo.*(Lg-dLg)./mu;
        % note: Vdsats is a constant, no dependence on Vgg, Vd, or Vt0b

        Vdsat=Vdsats.*(1-FF)+phit*FF;
        % begin derivatives of Vdsat
        dVdsat_dVgg = (-Vdsats + phit).*dFF_dVgg;
        dVdsat_dVd = (-Vdsats + phit).*dFF_dVd;
        dVdsat_dVt0b = (-Vdsats + phit).*dFF_dVt0b;
        % end derivatives of Vdsat
        
        %Fsat=(Vd./Vdsat)./((1+(Vd./Vdsat).^beta).^(1/beta));
        % begin derivatives of Fsat
        FsatNum = Vd./Vdsat;
        a = -1./(Vdsat.^2);
        dFsatNum_dVgg = Vd.*a.*dVdsat_dVgg;
        dFsatNum_dVt0b = Vd.*a.*dVdsat_dVt0b;
        dFsatNum_dVd = Vd.*a.*dVdsat_dVd + 1./Vdsat;

        %FsatDenom = ((1+(Vd./Vdsat).^beta).^(1/beta));
        FsatDenom = ((1+FsatNum.^beta).^(1/beta));
        a = ((1+(FsatNum).^beta).^(1/beta-1)).*(FsatNum.^(beta-1)); % d/dFsatNum
        dFsatDenom_dVgg = a.*dFsatNum_dVgg;
        dFsatDenom_dVd = a.*dFsatNum_dVd;
        dFsatDenom_dVt0b = a.*dFsatNum_dVt0b;

        Fsat = FsatNum ./FsatDenom;
        a = -1./(FsatDenom.^2);
        dFsat_dVgg = dFsatNum_dVgg./FsatDenom + FsatNum.*a.*dFsatDenom_dVgg;
        dFsat_dVd = dFsatNum_dVd./FsatDenom + FsatNum.*a.*dFsatDenom_dVd;
        dFsat_dVt0b = dFsatNum_dVt0b./FsatDenom + FsatNum.*a.*dFsatDenom_dVt0b;
        % end derivatives of Fsat

    if (1 == docurrents)
            Iy =dir.*W.*Qinv.*vxo.*Fsat;
            % begin derivatives of Iy
            dIy_dVgg = W.*vxo.*dir.*(dQinv_dVgg.*Fsat + Qinv.*dFsat_dVgg);
            dIy_dVd = W.*vxo.*dir.*(dQinv_dVd.*Fsat + Qinv.*dFsat_dVd);
            dIy_dVt0b = W.*vxo.*dir.*(dQinv_dVt0b.*Fsat + Qinv.*dFsat_dVt0b);
            dIy_ddir = W.*vxo.*Qinv.*Fsat;
            % end derivatives of Iy
    end % docurrents

    if (1 == docharges)
            Qx=-W*(Lg-dLg)*Qinv.*((1+dir)+(1-dir).*(1-Fsat))/4;
            % begin derivatives of Qx
            a = -W*(Lg-dLg)/4;
            b = ((1+dir)+(1-dir).*(1-Fsat));
            % Qx = a*Qinv*b;
            dQx_dVgg = a*dQinv_dVgg.*b + a*Qinv.*((1-dir).*(-dFsat_dVgg));
            dQx_dVd =  a*dQinv_dVd.*b + a*Qinv.*((1-dir).*(-dFsat_dVd));
            dQx_dVt0b = a*dQinv_dVt0b.*b + a*Qinv.*((1-dir).*(-dFsat_dVt0b));
            dQx_ddir= a*Qinv.*Fsat;%a*Qinv.*(1-(1-Fsat));
            % end derivatives of Qx

            Qy=-W*(Lg-dLg)*Qinv.*((1-dir)+(1+dir).*(1-Fsat))/4;
            b = ((1-dir)+(1+dir).*(1-Fsat));
            %Qy = a*Qinv*b
            % begin derivatives of Qy
            dQy_dVgg=a*dQinv_dVgg.*b +a*Qinv.*((1+dir).*(-dFsat_dVgg));
            dQy_dVd=a*dQinv_dVd.*b +a*Qinv.*((1+dir).*(-dFsat_dVd));
            dQy_dVt0b=a*dQinv_dVt0b.*b +a*Qinv.*((1+dir).*(-dFsat_dVt0b));
            dQy_ddir=-a*Qinv.*Fsat;%a*Qinv.*(-1+1.*(1-Fsat));
            % end derivatives of Qy

            psis=phib+alpha*phit+phit*safelog(safelog(1+exp(eta),smoothing),smoothing); 
            %                                           ^^^^^^^^
            %          JR: forgot to make this safeexp, maybe should
            % begin derivatives of psis
            a = dsafelog(safelog(1+exp(eta),smoothing),smoothing); 
            b = dsafelog(1+exp(eta),smoothing);
            c = exp(eta);
            dpsis_dVgg = phit*a.*b.*c.*deta_dVgg;
            dpsis_dVd = phit*a.*b.*c.*deta_dVd;
            dpsis_dVt0b = phit*a.*b.*c.*deta_dVt0b;
            % end derivatives of psis
            %psis=phib;  %Alternative approximation if above is troublesome!

            Qb=-W*Cg*Lg*gamma*(safesqrt(psis-Vbb,smoothing) + ...
                safesqrt(psis-(Vbb-(Vd.*(1-Fsat)+Vdsat.*Fsat)),smoothing))/2;
            % begin derivatives of Qb
            % Note: Qb is now also a direct function of Vbb, shouldn't forget to
            %        deal with it later. Treat as an independent variable here. Note that
            %        Fsat, Vdsat, psi are not directly functions of Vbb; they are
            %        functions of Vgg, Vd, Vt0b (which are functions of Vbb)
            a = -W*Cg*Lg*gamma/2;
            b = dsafesqrt(psis-Vbb,smoothing);
            d = psis-(Vbb-(Vd.*(1-Fsat)+Vdsat.*Fsat));
            c = dsafesqrt(d,smoothing);
            % Qb = a*(safesqrt(psis-Vbb) + safesqrt(d));
            dQb_dVgg = a*(b.*dpsis_dVgg + c.*(dpsis_dVgg - (-(Vd.*(-dFsat_dVgg) + ...
                    dVdsat_dVgg.*Fsat + Vdsat.*dFsat_dVgg))));
            dQb_dVd = a*(b.*dpsis_dVd + c.*(dpsis_dVd - (-(Vd.*(-dFsat_dVd) ...
                    +(1-Fsat) + dVdsat_dVd.*Fsat + Vdsat.*dFsat_dVd))));
            dQb_dVt0b = a*(b.*dpsis_dVt0b + c.*(dpsis_dVt0b - (-(Vd.*(-dFsat_dVt0b) ...
                    + dVdsat_dVt0b.*Fsat + Vdsat.*dFsat_dVt0b))));
            dQb_dVbb = a*(-b + c.*(- 1));
            % end derivatives of Qb

            Qg=-(Qx+Qy+Qb);
            % begin derivatives of Qg
            dQg_dVgg = -(dQx_dVgg +dQy_dVgg + dQb_dVgg);
            dQg_dVd = -(dQx_dVd +dQy_dVd + dQb_dVd);
            dQg_dVt0b = -(dQx_dVt0b +dQy_dVt0b + dQb_dVt0b);
            dQg_ddir = -(dQx_ddir +dQy_ddir);
            dQg_dVbb = -(dQb_dVbb);
            % end derivatives of Qg
    end % docharges

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % for outputs: Iy, Qinv, Qx, Qy, Qb, Qb
        % moving to derivatives wrt final independent variables: Vy, Vg, Vx, Vb
        % intermediate indep vars wrt which we have derivatives of the outputs: 
        %    Vgg, Vd, Vt0b, dir, Vbb

    if (1 == docurrents)
            % Iy
            dIy_dy = dIy_dVgg.*dVgg_dy + dIy_dVd.*dVd_dy ...
                     + dIy_dVt0b.*dVt0b_dy + dIy_ddir .* ddir_dy;
            dIy_dg = dIy_dVgg.*dVgg_dg; 
                %+dIy_dVd.*dVd_dg+dIy_dVt0b.*dVt0b_dg+dIy_ddir .* ddir_dg;
            dIy_dx = dIy_dVgg.*dVgg_dx + dIy_dVd.*dVd_dx ...
                     + dIy_dVt0b.*dVt0b_dx + dIy_ddir .* ddir_dx;
            dIy_db = dIy_dVt0b.*dVt0b_db; % + dIy_ddir .* ddir_db
                     %+ dIy_dVgg.*dVgg_db + dIy_dVd.*dVd_db ...
    end % docurrents

    if (1 == docharges)
            % Qinv
            dQinv_dy = dQinv_dVgg .* dVgg_dy + dQinv_dVd .* dVd_dy ...
                     + dQinv_dVt0b .* dVt0b_dy;
            dQinv_dg = dQinv_dVgg .* dVgg_dg;
            dQinv_dx = dQinv_dVgg .* dVgg_dx + dQinv_dVd .* dVd_dx ...
                       + dQinv_dVt0b .* dVt0b_dx;
            dQinv_db = dQinv_dVt0b .* dVt0b_db;

            % Qx
            dQx_dy = dQx_dVgg .* dVgg_dy + dQx_dVd .* dVd_dy ...
                     + dQx_dVt0b .* dVt0b_dy + dQx_ddir .* ddir_dy;
            dQx_dg = dQx_dVgg .* dVgg_dg;
            dQx_dx = dQx_dVgg .* dVgg_dx + dQx_dVd .* dVd_dx ...
                     + dQx_dVt0b .* dVt0b_dx + dQx_ddir .* ddir_dx;
            dQx_db = dQx_dVt0b .* dVt0b_db;

            % Qy
            dQy_dy = dQy_dVgg .* dVgg_dy + dQy_dVd .* dVd_dy ...
                     + dQy_dVt0b .* dVt0b_dy + dQy_ddir .* ddir_dy;
            dQy_dg = dQy_dVgg .* dVgg_dg;
            dQy_dx = dQy_dVgg .* dVgg_dx + dQy_dVd .* dVd_dx ...
                     + dQy_dVt0b .* dVt0b_dx + dQy_ddir .* ddir_dx;
            dQy_db = dQy_dVt0b .* dVt0b_db;

            % Qb
            dQb_dy = dQb_dVgg .* dVgg_dy + dQb_dVd .* dVd_dy ...
                     + dQb_dVt0b .* dVt0b_dy + dQb_dVbb .* dVbb_dy;
            dQb_dg = dQb_dVgg .* dVgg_dg;
            dQb_dx = dQb_dVgg .* dVgg_dx + dQb_dVd .* dVd_dx ...
                     + dQb_dVt0b .* dVt0b_dx + dQb_dVbb .* dVbb_dx;
            dQb_db = dQb_dVt0b .* dVt0b_db + dQb_dVbb .* dVbb_db;

            % Qg
            dQg_dy = dQg_dVgg .* dVgg_dy + dQg_dVd .* dVd_dy ...
                     + dQg_dVt0b .* dVt0b_dy + dQg_dVbb .* dVbb_dy ...
                     + dQg_ddir .* ddir_dy;
            dQg_dg = dQg_dVgg .* dVgg_dg;
            dQg_dx = dQg_dVgg .* dVgg_dx + dQg_dVd .* dVd_dx ...
                     + dQg_dVt0b .* dVt0b_dx + dQg_dVbb .* dVbb_dx ...
                     + dQg_ddir .* ddir_dx;
            dQg_db = dQg_dVt0b .* dVt0b_db + dQg_dVbb .* dVbb_db;
    end % docharges

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set up the output vectors
    if (1 == docurrents)
            dIy = [dIy_dy; dIy_dg; dIy_dx; dIy_db]; % 4 rows, potentially many columns
    else
        dIy = [];
    end

    if (1 == docharges)
            %dQinv = [dQinv_dy; dQinv_dg; dQinv_dx; dQinv_db];
            dQy = [dQy_dy; dQy_dg; dQy_dx; dQy_db];
            dQx = [dQx_dy; dQx_dg; dQx_dx; dQx_db];
            dQb = [dQb_dy; dQb_dg; dQb_dx; dQb_db];
            dQg = [dQg_dy; dQg_dg; dQg_dx; dQg_db];
    else
        dQy = []; dQx = []; dQg = []; dQb = [];
    end % docharges
end
% end of d_daaV6_core_model

%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
