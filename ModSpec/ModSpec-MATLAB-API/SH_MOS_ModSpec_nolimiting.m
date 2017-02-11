function MOD =SH_MOS_ModSpec(uniqID)
%function MOD =SH_MOS_ModSpec(uniqID)
%This function creates a ModSpec object model for basic Shichman Hodges
% NMOS model
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'M1'
%
%Return values:
% - MOD:    a ModSpec object for the Shichman Hodges NMOS.
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
%Examples
%--------
% % adding an NMOS with default parameters to an existing circuitdata structure
% cktdata = add_element(cktdata, SH_MOS_ModSpec(), 'M1', ...
%           {'nD', 'nG', 'nS'}, [], {});
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts
%

%
% author: T. Wang. 2013-02-25

%change log:
%-----------
%2014/05/13: Bichen Wu <bichen@berkeley.edu> Added the function handle of fqei
%            and fqeiJ to reduce redundant calling of f/q functions and to
%            improve efficiency

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

	MOD.model_name = 'SH_MOS';
	MOD.model_description = 'Schichman-Hodges MOSFET model';

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

	MOD.support_initlimiting = 1;
	MOD.limited_var_names = {'vdslim', 'vgslim'};
	MOD.vecXY_to_limitedvars_matrix = eye(2);   % vecLim = vecXY_to_limitedvars_matrix * [vecX;vecY]

	% define model parameters
	MOD.parm_names = {...
		 'Type', ... % 'N' or 'P'
		 'Beta', ... % Beta: Saturation factor
		 'VT',   ... % VT
		 'Cgs',  ... % Cgs
		 'Cgd',  ... % Cgd
		 'DSgmin' .... % Gmin between drain and source (to prevent matrix singularities when the device is off)
	};

	MOD.parm_defaultvals = {...
		'N',     ... % 'N' or 'P'
		1e-3,    ... % Beta: Saturation factor
		0.3,     ... % VT
		1e-13, 	 ... % Cgs
		1e-14, 	 ... % Cgd
		1e-8, 	 ... % DSgmin (default value 100Mohms)
	};

	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms


	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fqei = @fqei;

% Newton-Raphson initialization support
	MOD.initGuess = @initGuess;

% Newton-Raphson limiting support
	% MOD.limiting = @nolimiting;

end % MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%
function [fe, qe, fi, qi] = fqei(vecX, vecY, vecLim, u, flag, MOD)
% A structure that returns all the Js
% J is calculated by either vecvalder or by hand
% Stack 

	% ne = length(feval(MOD.ExplicitOutputNames, MOD));	
	% ni = length(feval(MOD.ImplicitEquationNames, MOD));	

    if nargin < 6
		MOD = flag;
		flag = u;
		u = vecLim;
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
		qe(1,1) = Cgd*(vdslim - vgslim);  		% ids
		qe(2,1) = Cgs*vgslim - Cgd*(vdslim - vgslim); % igs
	else
		qe = [];
	end

	fi = [];
	qi = [];

end % fqei(...)

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
	vecLim(1, 1) = 0;	% vds
	vecLim(2, 1) = VT;	% vgs 
end % initGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MODSPEC API %%%%%%%%%%%%%%%%%%%%%%%%

% private function

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

