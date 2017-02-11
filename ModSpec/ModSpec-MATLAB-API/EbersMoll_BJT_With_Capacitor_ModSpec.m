function MOD = EbersMoll_BJT_With_Capacitor_ModSpec(uniqID)
%function MOD = EbersMoll_BJT_With_Capacitor_ModSpec(uniqID)
%This function returns a ModSpec model for the Ebers Moll model of Bipolar
%Junction Transistors.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'Q1'
%
%Return values:
% - MOD:    a ModSpec object for an Ebers-Moll BJT. help ModSpec for more
%           information about ModSpec.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'C', 'B', 'E'} (collector, base and emitter).
%
% - parameters and their default values:
%   - 'tipe'(type of the BJT): 'NPN'
%   - 'IsF' (Is of forward diode): 1e-12
%   - 'IsR' (Is of reverse diode): 1e-12
%   - 'VtF' (Vt = kT/q of forward diode: 0.025
%   - 'VtR' (Vt = kT/q of reverse diode: 0.025
%   - 'alphaF' (forward alpha): 0.99
%   - 'alphaR' (reverse alpha): 0.5
%   - 'Rshunt' (shunt resistance): 1e8
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vce, ice, vbe, ibe
% - explicit output name(s):         ice, ibe
% - other IO name(s) (vecX):         vce, vbe 
% - implicit unknown name(s) (vecY): {}
% - input names (vecU):              {}
% - limited variable (vecLim):       vcelim, vbelim
%   when there is no init/limiting:
%   vcelim = vce
%   vbelim = vbe
%       i.e. vecLim = eye(2) * [vecX; vecY];
% 2. equations:
% - basic Ebers Moll BJT equation for NPN type:
%   ice = forward_diode_i*alphaF - reverse_diode_i + vce/Rshunt
%   ibe = forward_diode_i*(1-alphaF) + reverse_diode_i*(1-alphaR)
%   where
%       forward_diode_i = diode_Id(vbelim, IsF, VtF)
%       reverse_diode_i = diode_Id(vbelim-vcelim, IsR, VtR)
%
% - basic Ebers Moll BJT equation for PNP type:
%   ice = - forward_diode_i*alphaF + reverse_diode_i + vce/Rshunt
%   ibe = - forward_diode_i*(1-alphaF) - reverse_diode_i*(1-alphaR)
%   where
%       forward_diode_i = diode_Id(-vbelim, IsF, VtF)
%       reverse_diode_i = diode_Id(-vbelim+vcelim, IsR, VtR)
%
%
%Examples
%--------
% % adding a BJT with default parameters to an existing circuitdata structure
% cktdata = add_element(cktdata, EbersMoll_BJT_With_Capacitor_ModSpec(), ...
%                       'Q1', {'nC', 'nB', 'nE'}, [], {});
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts
%

%Author: Tianshi Wang, 2012/11/20
%

%change log:
%-----------
%2014/05/13: Bichen Wu <bichen@berkeley.edu> Added the function handle of fqei
%            and fqeiJ to reduce redundant calling of f/q functions and to
%            improve efficiency


% use the common ModSpec skeleton, sets up fields and defaults
	MOD = ModSpec_common_skeleton();

% set up data members defined in ModSpec_common_skeleton. These are
% used by the API functions defined there.

% version, help string:
	MOD.version = 'EbersMoll_BJT_With_Capacitor_ModSpec';
	%

% uniqID
	if nargin < 1
		MOD.uniqID = '';
	else
		MOD.uniqID = uniqID;
	end

	MOD.model_name = 'EbersMoll BJT';
	MOD.model_description = 'EbersMoll BJT';

	MOD.parm_names = {...
	    'tipe', ...
		'alphaR' ...
		'RR', ...
		'IsR', ...
		'VtR', ...
		'ttR', ...
		'fcR', ...
		'd_areaR', ...
		'cjoR', ...
		'phiR', ...
		'mR', ...
		'alphaF', ... 
		'RF', ...
		'IsF', ...
		'VtF', ...
		'ttF', ...
		'fcF', ...
		'd_areaF', ...
		'cjoF', ...
		'phiF', ...
		'mF', ...
		'Rshunt' ...
	};

	MOD.parm_defaultvals = {...
	    'NPN', ...
		0.5 ... 	% alphaR
		1, ... 	   	% RR
		1e-12, ... 	% IsR 
		0.025, ...	% VtR % TODO derive via kT/q, take T as parm
		1e-12, ... 	% ttR
		0.5, ...	% fcR
		(1e-7)^2, ...	% d_areaR
		30, ...		% cjoR
		0.7, ...	% phiR
		0.5, ...	% mR
		0.99 ... 	% alphaF
		1, ... 	   	% RF
		1e-12, ... 	% IsF 
		0.025, ...	% VtF % TODO derive via kT/q, take T as parm
		1e-12, ... 	% ttF
		0.5, ...	% fcF
		(1e-7)^2, ...	% d_areaF
		30, ...		% cjoF
		0.7, ...	% phiF
		0.5, ...	% mF
		1e8  ...    % Rshunt
	};

	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

	MOD.explicit_output_names = {'ice', 'ibe'};
	MOD.internal_unk_names = {};
	MOD.implicit_equation_names = {};
	MOD.u_names = {};

    MOD.support_initlimiting = 1;
	MOD.limited_var_names = {'vcelim', 'vbelim'};
	MOD.vecXY_to_limitedvars_matrix = eye(2);   % vecLim = vecXY_to_limitedvars_matrix * [vecX;vecY]

	MOD.NIL.node_names = {'c', 'b', 'e'};
	MOD.NIL.refnode_name = 'e';

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fqei = @fqei;

% Newtos-Raphson initialization support
	MOD.initGuess = @initGuess;

% Newton-Raphson limiting support
    MOD.limiting = @limiting;


% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % MOD constructor

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

	pnames = feval(MOD.parmnames,MOD);
	for i = 1:length(pnames)
		evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
		eval(evalstr);
	end

	oios = feval(MOD.OtherIONames,MOD);
	for i = 1:length(oios)
		evalstr = sprintf('%s = vecX(i);', oios{i});
		eval(evalstr); % should be OK for vecvalder
	end

	iunks = feval(MOD.InternalUnkNames,MOD);
	for i = 1:length(iunks)
		evalstr = sprintf('%s = vecY(i);', iunks{i});
		eval(evalstr); % should be OK for vecvalder
	end

	lvars = feval(MOD.LimitedVarNames,MOD);
	for i = 1:length(lvars)
		evalstr = sprintf('%s = vecLim(i);', lvars{i});
		eval(evalstr); % should be OK for vecvalder
	end

    if flag.fe == 1
		if strcmp(tipe,'NPN')
			% forward means C--B--E, reverse means E--B--C
			reverse_diode_i = diodeId(vbelim-vcelim, IsR, VtR);
			forward_diode_i = diodeId(vbelim, IsF, VtF);
			% ice
			fe(1,1) = forward_diode_i*alphaF - reverse_diode_i + vce/Rshunt; % ice
			% ibe
			fe(2,1) = forward_diode_i*(1-alphaF) + reverse_diode_i*(1-alphaR); % ibe
		elseif strcmp(tipe, 'PNP')
			% forward means E--B--C, reverse means C--B--E
			reverse_diode_i = diodeId(vcelim-vbelim, IsR, VtR);
			forward_diode_i = diodeId(-vbelim, IsF, VtF);
			% ice
			fe(1,1) = - forward_diode_i*alphaF + reverse_diode_i + vce/Rshunt;
			% ibe
			fe(2,1) = - forward_diode_i*(1-alphaF) - reverse_diode_i*(1-alphaR);
		else
		    error('EbersMoll_BJT_With_Capacitor_ModSpec: unsupported value for parameter ''tipe''. It should be either ''NPN'' or ''PNP''.\n');
		end
    else
        fe = [];
    end


	if flag.qe == 1
		forward_q = qDiffusion(vbelim, IsF, VtF, ttF) + qDepletion(vbelim, RF, IsF, VtF, ttF, fcF, d_areaF, cjoF, phiF, mF);
		reverse_q = qDiffusion(vbelim-vcelim,IsR,VtR,ttR)+qDepletion(vbelim-vcelim, RR, IsR, VtR, ttR, fcR, d_areaR, cjoR, phiR, mR);

		qe(1,1) = forward_q*alphaF - reverse_q*alphaR;
		qe(2,1) = forward_q*(1-alphaF) + reverse_q*(1-alphaR);
	else
		qe = [];
	end

	fi = [];
	qi = [];

end % fqei(...)


% Newton-Raphson initialization support
function vecLim = initGuess(u, MOD)
	vtf = getparms_ModSpec('VtF', MOD);
	isf = getparms_ModSpec('IsF', MOD);
	vtr = getparms_ModSpec('VtR', MOD);
	isr = getparms_ModSpec('IsR', MOD);
	vcritf = vtf*log(vtf/(sqrt(2)*isf));
	vcritr = vtr*log(vtr/(sqrt(2)*isr));
	vbc = vcritr;
	vbe = vcritf;
	vecLim(1,1) = vbe - vbc; % vce
	vecLim(2,1) = vbe; % vbe
	% TODO: the spice3 code uses temperature adjusted Vcrit
	% temperature seems not supported in this diode model
	% because Is and Vt are constant
end % initGuess

% Newton-Raphson limiting support
function vecLim = limiting(vecX,vecY, vecLimOld, u, MOD)
	% vecX = [vce, vbe]; % corresponds to OtherIOs
	vtf = getparms_ModSpec('VtF', MOD);
	isf = getparms_ModSpec('IsF', MOD);
	vtr = getparms_ModSpec('VtR', MOD);
	isr = getparms_ModSpec('IsR', MOD);
	vcritf = vtf*log(vtf/(sqrt(2)*isf));
	vcritr = vtr*log(vtr/(sqrt(2)*isr));
	%   
	vceold = vecLimOld(1,1);
	vce = vecX(1,1);
	vbeold = vecLimOld(2,1);
	vbe = vecX(2,1);
	vbcold = vbeold - vceold;
	vbc = vbe - vce;
	%   
	smoothing = 1e-5;
	vbc = smoothpnjlim(vbcold, vbc, vtr, vcritr, smoothing);
	vbe = smoothpnjlim(vbeold, vbe, vtf, vcritf, smoothing);

	vecLim(1,1) = vbe - vbc;  % vce
	vecLim(2,1) = vbe;  % vbe
end % limiting

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%
function Qdiff = qDiffusion(vd, Is, Vt, tt)

  	id = diodeId(vd, Is, Vt);
  	Qdiff = tt*id;
end %qDiffusion 

function d_Qdiff = d_qDiffusion(vd, Is, Vt, tt)

  	d_id = d_diodeId(vd, Is, Vt);
  	d_Qdiff = tt*d_id;
end %d_qDiffusion 

function Qdepl = qDepletion(vd, R, Is, Vt, tt, fc, d_area, cjo, phi, m)

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

function d_Qdepl = d_qDepletion(vd, R, Is, Vt, tt, fc, d_area, cjo, phi, m)

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
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
