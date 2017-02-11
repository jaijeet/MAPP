function MOD = capModSpec(uniqID)
%function MOD = capModSpec(uniqID)
%This function returns a ModSpec model for a linear capacitor.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'C1'.
%
%Return values:
% - MOD:    a ModSpec object for the capacitor.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'} (the two nodes of the capacitor).
%
% - parameters and their default values:
%   - 'C' (capacitance): 1uF.
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO name(s):                      vpn, ipn
% - explicit output name(s):         ipn
% - other IO name(s) (vecX):         vpn
% - implicit unknown name(s) (vecY): {}
% - input name(s) (vecU):            {}
%
% 2. equations:
% - basic capacitor equation:
%   ipn = d/dt (C * vpn);
% - fe: 0
% - qe: C * vpn
%
%Examples
%--------
% % adding a capacitor of value 10uF to an existing circuitdata structure
% cktdata = add_element(cktdata, capModSpec(), 'C1', {'n1', 'n2'}, 1e-5);
% %                                   ^         ^          ^        ^
% %                        capacitor model      name      nodes  capacitance
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%change log:
%-----------
%2014/05/13: Bichen Wu <bichen@berkeley.edu> Added the function handle of fqei
%            and fqeiJ to reduce redundant calling of f/q functions and to
%            improve efficiency
%2016/06/13: JR <jr@berkeley.edu> removed eval() in functions and flag checking (for efficiency); found no fqeiJ, added that; all for efficiency.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

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

	MOD.model_name = 'capacitor';
	MOD.model_description = 'basic linear capacitor';

	MOD.parm_names = {'C'};
	MOD.parm_defaultvals = {1e-6};
	MOD.parm_types = {'double'};
	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

	MOD.explicit_output_names = {'ipn'};
	MOD.internal_unk_names = {};
	MOD.implicit_equation_names = {};
	MOD.u_names = {};

	MOD.NIL.node_names = {'p', 'n'};
	MOD.NIL.refnode_name = 'n';

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fqei = @fqei;
	MOD.fqeiJ = @fqeiJ; % hardcoded derivatives, should be faster

% Newton-Raphson initialization support

% Newton-Raphson limiting support

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % cap MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%
function [fe, qe, fi, qi] = fqei(vecX, vecY, vecU, flag, MOD)

    %{
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
    %}

    %{
	pnames = feval(MOD.parmnames,MOD);
	for i = 1:length(pnames)
		evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
		eval(evalstr);
	end
    %}
    C = MOD.parm_vals{1};

	% similarly, get values from vecX, named exactly the same as otherIOnames
	% get otherIOs from vecX
    %{
	oios = feval(MOD.OtherIONames,MOD);
	for i = 1:length(oios)
		evalstr = sprintf('%s = vecX(i);', oios{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, this should set up vpn
    %}
    vpn = vecX(1);

	% do the same for vecY from internalUnknowns
	% get internalUnknowns from vecY
    %{
	iunks = feval(MOD.InternalUnkNames,MOD);
	for i = 1:length(iunks)
		evalstr = sprintf('%s = vecY(i);', iunks{i});
		eval(evalstr); % should be OK for vecvalder
	end
    %}

	fe(1,1) = 0;
	qe(1) = C*vpn;
	fi = [];
	qi = [];
end % fqei

function [fqei, J] = fqeiJ(varargin)
%function [fqei, J] = fqeiJ(vecX, vecY, vecLim, vecU, flag, MOD)
% input vecLim is optional
%OUTPUTS:
%
%	fqei.fe 
%	fqei.qe
%	fqei.fi
%	fqei.qi
%
%	J.Jfe			- struct that contains:
%						.dfe_dvecX
%						.dfe_dvecY
%						.dfe_dvecLim
%						.dfe_dvecU
%	J.Jqe			- struct that contains:
%						.dqe_dvecX
%						.dqe_dvecY
%						.dqe_dvecLim
%	J.Jfi			- struct that contains:
%						.dfi_dvecX
%						.dfi_dvecY
%						.dfi_dvecLim
%						.dfi_dvecU
%	J.Jqi			- struct that contains:
%						.dqi_dvecX
%						.dqi_dvecY
%						.dqi_dvecLim
%
    MOD = varargin{end};
    vecX = varargin{1};

    C = MOD.parm_vals{1};
    vpn = vecX(1);
    
	fqei.fe(1,1) = 0;
	fqei.qe(1) = C*vpn;
	fqei.fi = [];
	fqei.qi = [];

    J.Jfe.dfe_dvecX = 0;
    J.Jfe.dfe_dvecY = sparse(1,0);
    J.Jfe.dfe_dvecLim = sparse(1,0);
    J.Jfe.dfe_dvecU = sparse(1,0);

    J.Jqe.dqe_dvecX = C;
    J.Jqe.dqe_dvecY = sparse(1,0);
    J.Jqe.dqe_dvecLim = sparse(1,0);
    J.Jqe.dqe_dvecU = sparse(1,0);

    J.Jfi.dfi_dvecX = sparse(0,1);
    J.Jfi.dfi_dvecY = [];
    J.Jfi.dfi_dvecLim = [];
    J.Jfi.dfi_dvecU = [];

    J.Jqi.dqi_dvecX = sparse(0,1);
    J.Jqi.dqi_dvecY = [];
    J.Jqi.dqi_dvecLim = [];
    J.Jqi.dqi_dvecU = [];
end

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% ANALYSIS-SPECIFIC INPUT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% EQN and UNK SCALING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


