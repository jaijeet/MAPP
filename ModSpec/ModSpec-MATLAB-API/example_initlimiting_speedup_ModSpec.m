function MOD = example_initlimiting_speedup_ModSpec(uniqID)
%function MOD = example_initlimiting_speedup_ModSpec(uniqID)
%This function creates an example ModSpec object model with init/limiting
% as well as speedup implementation
% - the example describes basic Shichman Hodges model
% - MOD.support_initlimiting = 1
% - SPICE's limiting function with fetlim/limvds/pnjlim are used
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
% - limited variable (vecLim):       vdslim, vgslim
%   when there is no init/limiting:
%   vdslim = vds
%   vgslim = vgs
%       i.e. vecLim = eye(2) * [vecX; vecY];
%
% 2. equations:
% - basic MOSFET equation (considering type P/N and DS inversion):
%       if N-type
%           vdslim >=0 
%               ids_I = forward_ids(vdslim, vgslim) + vds*DSgmin
%           else % vdslim < 0, drain-source inversion
%               ids_I = -forward_ids(-vdslim, vgslim-vdslim) + vds*DSgmin
%           end
%       else % P-type
%           if vdslim <=0 
%               ids_I = -forward_ids(-vdslim, -vgslim) + vds*DSgmin
%           else % vdslim < 0, drain-source inversion
%               ids_I = forward_ids(vdslim, -vgslim+vdslim) + vds*DSgmin
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

    MOD.model_name = 'example_initlimiting';
    MOD.model_description = 'example ModSpec model with init/limiting';

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

    MOD.support_initlimiting = 1;
    MOD.limited_var_names = {'vdslim', 'vgslim'};
    MOD.vecXY_to_limitedvars_matrix = eye(2);
        % vecLim = vecXY_to_limitedvars_matrix * [vecX;vecY]

% Core functions: qi, fi, qe, fe: 
    % MOD.fe = @fe; % fe(vecX, vecY, vecLim, vecU, MOD)
    % MOD.qe = @qe; % qe(vecX, vecY, vecLim, MOD)
    % MOD.fi = @fi; % fi(vecX, vecY, vecLim, vecU, MOD)
    % MOD.qi = @qi; % qi(vecX, vecY, vecLim, MOD)
    MOD.fqei = @fqei; % fqei(vecX, vecY, vecLim, vecU, flag, MOD)

% Newton-Raphson initialization support
    MOD.initGuess = @initGuess;

% Newton-Raphson limiting support
    MOD.limiting = @limiting;

end % MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%

function [fe, qe, fi, qi] = fqei(vecX, vecY, vecLim, vecU, flag, MOD)
    if nargin < 6
		MOD = flag;
		flag = vecU;
		vecU = vecLim;
		vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
	end

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

	% get limitedvars from vecLim
	lvars = feval(MOD.LimitedVarNames,MOD);
	for i = 1:length(lvars)
		evalstr = sprintf('%s = vecLim(i);', lvars{i});
		eval(evalstr); % should be OK for vecvalder
	end
    % for this device, this sets up vdslim, vgslim

	% end setting up scalar variables for the parms, vecX, vecY, vecLim and
	% vecU
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        qe(1,1) = Cgd*(vds - vgs);          % ids
        qe(2,1) = Cgs*vgs - Cgd*(vds - vgs); % igs
    else
        qe = [];
    end

    fi = [];
    qi = [];
end % fqei(...)

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function vecLim = initGuess(vecU, MOD)
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
	if strcmp(Type, 'P') || strcmp(Type, 'p')
		VT = -VT;
	end
	vecLim(1, 1) = 0;	% vds
	vecLim(2, 1) = VT;	% vgs 
end % initGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function vecLim = limiting(vecX, vecY, vecLimOld, vecU, MOD)
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
