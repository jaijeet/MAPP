function MOD = vsrcModSpecNew(uniqID)
%function MOD = vsrcModSpecNew(uniqID)
%This function returns a ModSpec model for an independent voltage source.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'V1'.
%
%Return values:
% - MOD:    a ModSpec object for the voltage source.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'}: the positive and negative nodes of the voltage source.
%
% - parameters and their default values:
%   - the voltage source has no parameters.
%
% - independent source(s) within the model:
%   - 'E': the voltage.
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO name(s):                      vpn, ipn
% - explicit output name(s):         vpn
% - other IO name(s) (vecX):         ipn
% - implicit unknown name(s) (vecY): {}
% - input name(s) (vecU):            E
%
% 2. equations:
% - basic voltage source equation:
%     unlike res/cap/ind devices, a voltage source has an input vecU = E whose
%     value can be set up from outside of the device.
%   vpn = E;
% - fe: E 
% - qe: 0
%
%Examples
%--------
% % adding an independent voltage source with DC, AC and transient values to an 
% % existing circuitdata structure
%
%   VinDC = 0; % DC input value of Vin
%   vinoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
%                                                     % input function for Vin
%   vinargs.A = 1; vinargs.f = 1e3; vinargs.phi = 0; % arguments for
%                                                       % transient function
%
% %                       voltage source model    name      nodes
% %                                    ^            ^         ^ 
%   cktdata = add_element(cktdata, vsrcModSpec(), 'Vin', {'Vin', 'gnd'}, ...
%              {},  {{'E', {'DC', VinDC}, {'AC' 1}, {'tr', vinoft, vinargs}}});
% %            ^       ^   ^^^^^^^^^^^^^  ^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^^^
% %        no parms  source   DC value     AC value   time-varying waveform
% %                   name                            for transient analysis
%
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

	MOD.model_name = 'vsrc';
	MOD.model_description = 'independent voltage source';

	MOD.parm_names = {};
	MOD.parm_defaultvals = {};
	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

	MOD.explicit_output_names = {'vpn'};
	MOD.internal_unk_names = {};
	MOD.implicit_equation_names = {};
	MOD.u_names = {'E'};

	MOD.NIL.node_names = {'p', 'n'};
	MOD.NIL.refnode_name = 'n';

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fqei = @fqei;

% Newton-Raphson initialization support

% Newton-Raphson limiting support

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % vsrc MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fe, qe, fi, qi] = fqei(vecX, vecY, vecU, flag, MOD)

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

	if length(vecU) > 0 % for q calls, u is not needed, so u=[] may be sent in
		unms = feval(MOD.uNames,MOD);
		for i = 1:length(unms)
			evalstr = sprintf('%s = vecU(i);', unms{i});
			eval(evalstr); % should be OK for vecvalder
		end
	end

	if flag.fe == 1
		fe(1,1) = E;
	else
		fe = [];
	end

	if flag.qe == 1
		qe(1,1) = 0;
	else
		qe = [];
    end

    fi = [];
	qi = [];
end % fqei(...)

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% ANALYSIS-SPECIFIC INPUT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% EQN and UNK SCALING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
