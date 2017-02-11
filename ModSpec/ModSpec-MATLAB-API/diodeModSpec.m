function MOD = diodeModSpec(uniqID)
%function MOD = diodeModSpec(uniqID)
%This function returns a ModSpec model for an exponential diode with a series
%resistor. Diffusion and depletion charges are included in the model.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'd1'.
%
%Return values:
% - MOD:    a ModSpec object for the diode. help ModSpec for more
%           information about ModSpec.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'} positive and negative terminals of the diode.
%
% - parameters and their default values:
%   - 'R'  (internal series resistance): 1.
%   - 'Is' (saturation current): 1e-12.
%   - 'Vt' (thermal voltage = kT/q): 0.026.
%   - 'tt' (transit time for diffusion capacitance): 1e-12.
%   - 'fc' (depletion capacitance parameter): 0.5.
%   - 'd_area' (diode area): (1e-7)^2.
%   - 'cjo', (depletion capacitance parameter): 30.
%   - 'phi' (depletion capacitance parameter): 0.7.
%   - 'm' (depletion capacitance parameter):   0.5.
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vpn, ipn
% - explicit output name(s):         ipn
% - other IO name(s) (vecX):         vpn
% - implicit unknown name(s) (vecY): vin
% - input names (vecU):              {}
% - limited variable (vecLim):       vinlim
%   when there is no init/limiting: vinlim = vin
%       i.e. vecLim = [0, 1] * [vecX; vecY];
%
% 2. equations:
% - basic diode equation:
%   ipn = (vpn - vin) /R;
%   KCL_i:
%   - (vpn-vin)/R + diodeId(vinlim, Is, Vt)
%   + d/dt (qDepletion(vin, MOD) + qDiffusion(vin, Is, Vt, tt)) = 0
% - fe: (vpn - vin)/R
% - qe: 0
% - fi: - (vpn-vin)/R + diodeId(vinlim, Is, Vt)
% - qi: qDepletion(vin, MOD) + qDiffusion(vin, Is, Vt, tt);
%
%
%Examples
%--------
% % adding a diode with default parameters to an existing circuitdata structure
% cktdata = add_element(cktdata, diodeModSpec(), 'd1', ...
%           {'n1', 'n2'}, {});
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

	MOD.model_name = 'diode';
	MOD.model_description = 'p-res-i-idealdiode-n (with depl. and diff. caps)';

	MOD.parm_names = {...
		'R', ...
		'Is', ...
		'Vt', ...
		'tt', ...
		'fc', ...
		'd_area', ...
		'cjo', ...
		'phi', ...
		'm', ...
	};

	MOD.parm_defaultvals = {...
		1, ... 	   	% R
		1e-12, ... 	% Is 
		0.026, ...	% Vt % TODO derive via kT/q, take T as parm
		1e-12, ... 	% tt
		0.5, ...	% fc
		(1e-7)^2, ...	% d_area
		30, ...		% cjo
		0.7, ...	% phi
		0.5, ...	% m
	};

	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

	MOD.explicit_output_names = {'ipn'};
	MOD.internal_unk_names = {'vin'};
	MOD.implicit_equation_names = {'KCL_i'};
	MOD.u_names = {};

    MOD.support_initlimiting = 1;
	MOD.limited_var_names = {'vinlim'};
	MOD.vecXY_to_limitedvars_matrix = [0,1];   % vecLim = vecXY_to_limitedvars_matrix * [vecX;vecY]

	MOD.NIL.node_names = {'p', 'n'};
	MOD.NIL.refnode_name = 'n';

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fqei = @fqei;

% Newton-Raphson initialization support
	MOD.initGuess = @initGuess;

% Newton-Raphson limiting support
	MOD.limiting = @limiting;


% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % diode MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

	% do the same for vecLim from limitedVars
	% get limitedVars from vecLim
	lvars = feval(MOD.LimitedVarNames,MOD);
	for i = 1:length(lvars)
		evalstr = sprintf('%s = vecLim(i);', lvars{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, this should set up vinlim

	%{
	% do the same for u from uNames
	unms = uNames(MOD);
	for i = 1:length(unms)
		evalstr = sprintf('%s = u(i);', unms{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, there are no us
	%}

	% end setting up scalar variables for the parms, vecX, vecY and u
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if flag.fe == 1
		fe = (vpn - vin)/R;
	else
		fe = [];
	end 
	if flag.qe == 1
		qe(1,1) = 0;
	else
		qe = [];
	end 
	if flag.fi == 1
		fi = - (vpn-vin)/R + diodeId(vinlim, Is, Vt);
	else
		fi = [];
	end 
	if flag.qi == 1
   		qi = qDepletion(vin, MOD) + qDiffusion(vin, Is, Vt, tt);
	else
		qi = [];
	end 
end 

% Newton-Raphson initialization support
function vecLim = initGuess(u, MOD)
% vt = kT/q or .026 mv
% vcrit = kT/q * log ((kT/q) / (squareroot(2) * Is)) : .6145v for Is=1e-12
	vt = getparms_ModSpec('Vt', MOD);
	is = getparms_ModSpec('Is', MOD);
	R = getparms_ModSpec('R', MOD);
	vcrit = vt*log(vt/(sqrt(2)*is));
	vecLim = vcrit;
	% TODO: the spice3 code uses temperature adjusted Vcrit
end % initGuess

% Newton-Raphson limiting support
function vecLim = limiting(vecX, vecY, vecLimOld, u, MOD)
% vt = kT/q or .026 mv
% vcrit = kT/q * log ((kT/q) / (squareroot(2) * Is)) : .6145v for Is=1e-12
	vt = getparms_ModSpec('Vt', MOD);
	is = getparms_ModSpec('Is', MOD);
	vcrit = vt*log(vt/(sqrt(2)*is));
	%vecLim = smoothpnjlim(vecLimOld, vecY, vt, vcrit, 1e-8);
	vecLim = pnjlim(vecLimOld, vecY, vt, vcrit);
	%vecLim = pnjlim_tianshi(vecLimOld, vecY, vt, vcrit, 1e-2);
end % limiting

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function id = diodeId(vd, Is, Vt)
	% FIXME: un-hardcode these
	%kBoltz = 1.3806503e-23;
	%qElecCharge = 1.60217646e-19;
	%vt = kBoltz*T{1}/qElecCharge;

	id = Is*(exp(vd/Vt) - 1);
end %diodeID

function d_id = d_diodeId(vd, Is, Vt)
	% FIXME: un-hardcode these
	%kBoltz = 1.3806503e-23;
	%qElecCharge = 1.60217646e-19;
	%vt = kBoltz*T{1}/qElecCharge;

	d_id = Is/Vt*exp(vd/Vt);
end %d_diodeID

function Qdiff = qDiffusion(vd, Is, Vt, tt)
  	id = diodeId(vd, Is, Vt);
  	Qdiff = tt*id;
end %qDiffusion 

function d_Qdiff = d_qDiffusion(vd, Is, Vt, tt)
  	d_id = d_diodeId(vd, Is, Vt);
  	d_Qdiff = tt*d_id;
end %d_qDiffusion 

function Qdepl = qDepletion(vd, MOD)
	mparms = feval(MOD.getparms, MOD);
	[ ...
		R, ...
		Is, ...
		Vt, ...
		tt, ...
		fc, ...
		d_area, ...
		cjo, ...
		phi, ...
		m ...
	] = deal(mparms{:});

	% derived parms (TODO/FIXME: these should really be done ONCE at constructor/parm-update time for speed)
	fcp = fc*phi;
	f1 = (phi/(1 - m))*(1 - (1 - fc)^m);
	f2 = (1 - fc)^(1 + m);
	f3 = 1 - fc*(1 + m);

	%{ doing it using regular if conditions for speed
  	ifcond = (vd <= fcp);
  	Qdepl = ifcond*(d_area*cjo*phi*(1 - (1 - vd/phi)^(1 - m))/(1 - m));
  	Qdepl = Qdepl + (1-ifcond)*(d_area*cjo*(f1+(1/f2)*(f3*(vd-fcp) ...
    		+(0.5*m/phi)*(vd*vd-fcp*fcp))));
	%}

	if vd <= fcp
  		Qdepl = d_area*cjo*phi*(1 - (1 - vd/phi)^(1 - m))/(1 - m);
	else
  		Qdepl = d_area*cjo*(f1+(1/f2)*(f3*(vd-fcp) + (0.5*m/phi)*(vd*vd-fcp*fcp)));
	end
end %qDepletion

function d_Qdepl = d_qDepletion(vd, MOD)
	mparms = feval(MOD.getparms, MOD);
	[ ...
		R, ...
		Is, ...
		Vt, ...
		tt, ...
		fc, ...
		d_area, ...
		cjo, ...
		phi, ...
		m ...
	] = deal(mparms{:});

	% derived parms (TODO/FIXME: these should really be done ONCE at constructor/parm-update time for speed)
	fcp = fc*phi;
	f1 = (phi/(1 - m))*(1 - (1 - fc)^m);
	f2 = (1 - fc)^(1 + m);
	f3 = 1 - fc*(1 + m);

	%{ doing it using regular if conditions for speed
  	ifcond = (vd <= fcp);
  	Qdepl = ifcond*(d_area*cjo*phi*(1 - (1 - vd/phi)^(1 - m))/(1 - m));
  	Qdepl = Qdepl + (1-ifcond)*(d_area*cjo*(f1+(1/f2)*(f3*(vd-fcp) ...
    		+(0.5*m/phi)*(vd*vd-fcp*fcp))));
	%}

	if vd <= fcp
  		%Qdepl = d_area*cjo*phi*(1 - (1 - vd/phi)^(1 - m))/(1 - m);
  		d_Qdepl = d_area*cjo*(1-m)*(1 - vd/phi)^(1 - m - 1)/(1 - m);
	else
  		%Qdepl = d_area*cjo*( ...
		% 	f1+ ...
		%       (1/f2)*(f3*(vd-fcp) + (0.5*m/phi)*(vd*vd-fcp*fcp)) ...
		%                   );
  		d_Qdepl = d_area*cjo*( ...
			(1/f2)*(f3 + (m/phi)*vd) ...
			             );
	end
end %qDepletion

