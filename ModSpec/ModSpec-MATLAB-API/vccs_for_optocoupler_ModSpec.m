function MOD = vccs_for_optocoupler_ModSpec(uniqID)
%function MOD = vccs_for_optocoupler_ModSpec(uniqID)
%This function returns a ModSpec model for ideal voltage-controlled
%current sources
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'G1'
%
%Return values:
% - MOD:    a ModSpec object for a voltage-controlled current source.
%           help ModSpec for more information about ModSpec.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'P', 'N', 'PC', 'NC'} (p, n, p-control, n-control).
%
% - parameters and their default values:
%   - 'gain' (gain of vccs): 1
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vpnc, vnnc, vpcnc, ipnc, innc, ipcnc
% - explicit output name(s) (vecZ):  ipcnc, ipnc, innc
% - other IO name(s) (vecX):         vpnc, vnnc, vpcnc
% - implicit unknown name(s) (vecY): {}
% - input names (vecU):              {}
%
% 2. equations:
% - equations derivation:
%    ipcnc = 0
%    gain*vpcnc-ipn = 0  -->  ipnc = gain*vpcnc
%    ipnc = -innc             
% - fe = [0;
%         gain*ipcnc;
%         -gain*ipcnc];
% - qe = [0;0;0];
%
%
%Examples
%--------
% % adding a vccs with gain equal to 0.5
% cktdata = add_element(cktdata, vccs_for_optocoupler_ModSpec(), 'G1', ...
%           {'np', 'nn', 'npc', 'nnc'}, {'gain', 0.5}, {});
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts
%


% NIL.NodeNames: {'p', 'n', 'pc', 'nc'}
% NIL.RefNodeName: 'nc' (you specify)
% => IOnames = {'vpnc', 'vnnc', 'vpcnc', 'ipnc', 'innc', 'ipcnc'}
% ExplicitOutputNames = {'ipcnc', 'vnnc', 'innc'} vecZ
% => OtherIONames = {'vpcnc', 'vpnc', 'ipnc'} vecX
% InternalUnkNames = {} vecY
% 
% ImplicitEquationNames {}
%
% NIL.IOtypes: {'v', 'v', 'v', 'i', 'i', 'i'}
% NIL.IOnodeNames: {'p', 'n', 'pc', 'p', 'n', 'pc'}
%
% Unames = {}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% vecX = [vpcnc, vpnc, ipnc]; % corresponds to OtherIOs
% vecZ = [ipcnc, vnnc, innc]; % corresponds to ExplicitOutputs
% vecY = []; % corvccsponds to InternalUnks
% vecW = []; % corvccsponds to ImplicitEquations
% u = []
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% equations derivation:
%	ipcnc = 0
%	gain*vpcnc-ipn = 0  -->  ipnc = gain*vpcnc
%	ipnc = -innc			 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% explicit eqn 3:
%	qe(vecX, vecY) = [0;0;0];
%	fe(vecX, vecY, u) = [0;
%						polyfunc(vpcnc);
%						-polyfunc(vpcnc)]
% out = polyfunc(vt)
%	if vt<=3e-3 
%		out = (-80e9*vt^5 + 800e6*vt^4 - 3e6*vt^3 + 5177.2*vt^2 + 0.2453*vt - 5e-5)*1.04/700; 
%	else 
%		out = (9e6*vt^5 - 998113*vt^4 + 42174*vt^3 - 861.32*vt^2 + 9.0836*vt - 0.0078)*0.945/700; 
%	end
%
%	if out > 1e-3
%		out = 1e-3;
%	elseif out < 0
%		out = 0;
%	end
%	
%
% implicit eqns: none
%	qi(vecX, vecY) = []
%	fi(vecX, vecY, u) = []
%
% Author: Bichen Wu   2013/11/21

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

	MOD.model_name = 'vccs';
	MOD.spice_key = 'g';
	MOD.model_description = 'ideal voltage controlled current source';

	MOD.parm_names = {'gain'};
	MOD.parm_defaultvals = {1};
	MOD.parm_types = {'double'};
	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

	MOD.explicit_output_names = {'ipcnc', 'ipnc', 'innc'};
	MOD.internal_unk_names = {};
	MOD.implicit_equation_names = {};
	MOD.u_names = {};

	MOD.NIL.node_names = {'p', 'n', 'pc', 'nc'};
	MOD.NIL.refnode_name = 'nc';

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);


% Core functions: qi, fi, qe, fe: 
	MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
	MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
	MOD.qi = @qi; % qi(vecX, vecY, MOD)
	MOD.qe = @qe; % qe(vecX, vecY, MOD)

% Newton-Raphson initialization support

% Newton-Raphson limiting support

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % vccs MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function fiout = fi(vecX, vecY, u, MOD)
	fiout = fqei(vecX, vecY, u, MOD, 'f', 'i');
end % fi(...)

function qiout = qi(vecX, vecY, MOD)
	qiout = fqei(vecX, vecY, [], MOD, 'q', 'i');
end % qi(...)

function feout = fe(vecX, vecY, u, MOD)
	feout = fqei(vecX, vecY, u, MOD, 'f', 'e');
end % fe(...)

function qeout = qe(vecX, vecY, MOD)
	qeout = fqei(vecX, vecY, [], MOD, 'q', 'e');
end % qe(...)

%%%%%%%%%%%%%%%%%%%%%%% NETWORK INTERFACE LAYER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% ANALYSIS-SPECIFIC INPUT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% EQN and UNK SCALING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%
function fqout = fqei(vecX, vecY, u, MOD, forq, eori)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set up scalar variables for the parms, vecX, vecY and u

	% create variables of the same names as the parameters and assign
	% them the values in MOD.parms
	% ideally, this should be a macro
	% 	- could do this using a string and another eval()
	pnames = feval(MOD.parmnames,MOD);
	for i = 1:length(pnames)
		evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
		eval(evalstr);
	end
	% for this device, this should set up a MATLAB variable R

	% similarly, get values from vecX, named exactly the same as otherIOnames
	% get otherIOs from vecX
	oios = feval(MOD.OtherIONames,MOD);
	for i = 1:length(oios)
		evalstr = sprintf('%s = vecX(i);', oios{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, this should set up vpn

	% do the same for vecY from internalUnknowns
	% get internalUnknowns from vecY
	iunks = feval(MOD.InternalUnkNames,MOD);
	for i = 1:length(iunks)
		evalstr = sprintf('%s = vecY(i);', iunks{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, this should set up vin

	%{
	% do the same for u from uNames
	if length(u) > 0 % for q calls, u is not needed, so u=[] may be sent in
		unms = uNames(MOD);
		for i = 1:length(unms)
			evalstr = sprintf('%s = u(i);', unms{i});
			eval(evalstr); % should be OK for vecvalder
		end
	end
	% for this device, there is 1 u: E
	%}

	% end setting up scalar variables for the parms, vecX, vecY and u
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if 1 == strcmp(eori,'e') % e
		if 1 == strcmp(forq, 'f') % f
			% only 1 explicit output ipn
			fqout = [0
					polyfunc(vpcnc) 
					-polyfunc(vpcnc)];
		else % q
			% fqout(1,1) = 0;
			% fqout(2,1) = 0;
			% fqout(3,1) = 0;
			fqout = [0;0;0];
		end
	else % i
		if 1 == strcmp(forq, 'f') % f
			% only 1 implicit equation (KCL_i)
			fqout = [];
		else % q
			% only 1 implicit equation:
   			fqout = [];
		end
	end

end % fqei(...)
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = polyfunc(v)
    vt = v; 
    out1 = (-80e9*vt^5 + 800e6*vt^4 - 3e6*vt^3 + 5177.2*vt^2 + 0.2453*vt - 5e-5)*1.04/700; 
    out2 = (9e6*vt^5 - 998113*vt^4 + 42174*vt^3 - 861.32*vt^2 + 9.0836*vt - 0.0078)*0.945/700; 
    out = smoothswitch(out1,out2,vt-3e-3,1e-12);
    out = smoothswitch(out,1e-3,out-1e-3,1e-9);
    out = smoothswitch(0,out,out,1e-9);
end % polyfunc
   % if vt<=3e-3 
   % 	out = (-80e9*vt^5 + 800e6*vt^4 - 3e6*vt^3 + 5177.2*vt^2 + 0.2453*vt - 5e-5)*1.04/700; 
   % else 
   % 	out = (9e6*vt^5 - 998113*vt^4 + 42174*vt^3 - 861.32*vt^2 + 9.0836*vt - 0.0078)*0.945/700; 
   % end
