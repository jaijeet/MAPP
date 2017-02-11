function MOD = isrcModSpecNew(uniqID)
%function MOD = isrcModSpecNew(uniqID)
%This function returns a ModSpec model for an independent current source.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'I1'.
%
%Return values:
% - MOD:    a ModSpec object for the current source.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'}: the positive and negative nodes of the current source.
%                 (a positive current flows in through p and out through n)
%
% - parameters and their default values:
%   - the current source has no parameters.
%
% - independent source(s) within the model:
%   - 'I': the current.
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO name(s):                      vpn, ipn
% - explicit output name(s):         ipn
% - other IO name(s) (vecX):         vpn
% - implicit unknown name(s) (vecY): {}
% - input name(s) (vecU):            I
%
% 2. equations:
% - basic current source equation:
%     unlike res/cap/ind devices, a current source has an input vecU = I whose
%     value can be set up from outside of the device.
%   ipn = I;
% - fe: I 
% - qe: 0
%
%Examples
%--------
% % adding an independent current source with DC, AC and transient values to an 
% % existing circuitdata structure
%
%   IinDC = 0; % DC input value of Iin
%   iinoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
%                                                     % input function for Iin
%   iinargs.A = 1; iinargs.f = 1e3; iinargs.phi = 0; % arguments for
%                                                       % transient function
%
% %                       current source model    name      nodes
% %                                    ^            ^         ^ 
%   cktdata = add_element(cktdata, isrcModSpec(), 'Iin', {'p', 'gnd'}, ...
%              {},  {{'I', {'DC', IinDC}, {'AC' 1}, {'tr', iinoft, iinargs}}});
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

	MOD.model_name = 'isrc';
	MOD.model_description = 'independent current source';

	MOD.parm_names = {};
	MOD.parm_defaultvals = {};
	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

	MOD.explicit_output_names = {'ipn'};
	MOD.internal_unk_names = {};
	MOD.implicit_equation_names = {};
	MOD.u_names = {'I'};

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

end % isrc MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%
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
		fe(1,1) = I;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% NETWORK INTERFACE LAYER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% ANALYSIS-SPECIFIC INPUT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% EQN and UNK SCALING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
