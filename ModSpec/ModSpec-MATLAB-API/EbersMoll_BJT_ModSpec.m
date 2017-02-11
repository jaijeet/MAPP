function MOD = EbersMoll_BJT_ModSpec(uniqID)
%function MOD = EbersMoll_BJT_ModSpec(uniqID)
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
%
%Examples
%--------
% % adding a BJT with default parameters to an existing circuitdata structure
% cktdata = add_element(cktdata, EbersMoll_BJT_ModSpec(), 'Q1', ...
%           {'nC', 'nB', 'nE'}, [], {});
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts
%

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
        'IsF', ... 
        'VtF', ... 
        'IsR', ... 
        'VtR', ... 
        'alphaF', ... 
        'alphaR',  ...
        'Rshunt' ...
    };

    MOD.parm_defaultvals = {...
	    'NPN', ...
        1e-12, ... % IsF
        0.025, ... % VtF
        1e-12, ... % IsR
        0.025, ... % VtR
        0.99, ... % alphaF
        0.5, ... % alphaR
        1e8 ... % Rshunt
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


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set up scalar variables for the parms, vecX, vecY and u

    % create variables of the same names as the parameters and assign
    % them the values in MOD.parms
    % ideally, this should be a macro
    %     - could do this using a string and another eval()
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
    % for this device, this should set up vce, vbe

    % do the same for vecY from internalUnknowns
    % get internalUnknowns from vecY
    iunks = feval(MOD.InternalUnkNames,MOD);
    for i = 1:length(iunks)
        evalstr = sprintf('%s = vecY(i);', iunks{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, this is no internal unks

    % do the same for vecLim from limitedVars
    % get limitedVars from vecLim
    lvars = feval(MOD.LimitedVarNames,MOD);
    for i = 1:length(lvars)
        evalstr = sprintf('%s = vecLim(i);', lvars{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, this should set up vcelim, vbelim


    if flag.fe == 1
		if strcmp(tipe,'NPN')
			% forward means C--B--E, reverse means E--B--C
			reverse_diode_i = diode(vbelim-vcelim, IsR, VtR);
			forward_diode_i = diode(vbelim, IsF, VtF);
			% ice
			fe(1,1) = forward_diode_i*alphaF - reverse_diode_i + vce/Rshunt; % ice
			% ibe
			fe(2,1) = forward_diode_i*(1-alphaF) + reverse_diode_i*(1-alphaR); % ibe
		elseif strcmp(tipe, 'PNP')
			% forward means E--B--C, reverse means C--B--E
			reverse_diode_i = diode(vcelim-vbelim, IsR, VtR);
			forward_diode_i = diode(-vbelim, IsF, VtF);
			% ice
			fe(1,1) = - forward_diode_i*alphaF + reverse_diode_i + vce/Rshunt;
			% ibe
			fe(2,1) = - forward_diode_i*(1-alphaF) - reverse_diode_i*(1-alphaR);
		else
		    error('EbersMoll_BJT_ModSpec: unsupported value for parameter ''tipe''. It should be either ''NPN'' or ''PNP''.\n');
		end
    else
        fe = [];
    end

    if flag.qe == 1
        qe(1,1) = 0;
        qe(2,1) = 0;
    else
        qe = [];
    end

    fi = [];

    qi = [];

end % fqei(...)

% Newton-Raphson initialization support
function vecLim = initGuess(u, MOD)
    tipe = getparms_ModSpec('tipe', MOD);
    vtf = getparms_ModSpec('VtF', MOD);
    isf = getparms_ModSpec('IsF', MOD);
    vtr = getparms_ModSpec('VtR', MOD);
    isr = getparms_ModSpec('IsR', MOD);
    vcritf = vtf*log(vtf/(sqrt(2)*isf));
    vcritr = vtr*log(vtr/(sqrt(2)*isr));
    % TODO: the spice3 code uses temperature adjusted Vcrit
    % temperature seems not supported in this diode model
    % because Is and Vt are constant
	if strcmp(tipe,'NPN')
		vbc = vcritr;
		vbe = vcritf;
	elseif strcmp(tipe, 'PNP')
		vbc = -vcritr;
		vbe = -vcritf;
	else
		error('EbersMoll_BJT_ModSpec: unsupported value for parameter ''tipe''. It should be either ''NPN'' or ''PNP''.\n');
	end
	vecLim(1,1) = vbe - vbc; % vce
	vecLim(2,1) = vbe; % vbe
end % initGuess

% Newton-Raphson limiting support
function vecLim = limiting(vecX,vecY, vecLimOld, u, MOD)
    % vecX = [vce, vbe]; % corresponds to OtherIOs
    tipe = getparms_ModSpec('tipe', MOD);
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
	if strcmp(tipe,'NPN')
		vbc = smoothpnjlim(vbcold, vbc, vtr, vcritr, smoothing);
		vbe = smoothpnjlim(vbeold, vbe, vtf, vcritf, smoothing);
	elseif strcmp(tipe, 'PNP')
		vbc = -smoothpnjlim(-vbcold, -vbc, vtr, vcritr, smoothing);
		vbe = -smoothpnjlim(-vbeold, -vbe, vtf, vcritf, smoothing);
	else
		error('EbersMoll_BJT_ModSpec: unsupported value for parameter ''tipe''. It should be either ''NPN'' or ''PNP''.\n');
	end

    vecLim(1,1) = vbe - vbc;  % vce
    vecLim(2,1) = vbe;  % vbe
end % limiting

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%
function [id, d_id] = diode(vd, Is, Vt)
%function [id, d_id] = diode(vd, Is, Vt)
%
%the function is vectorized wrt Vd
%
    id = Is*(exp(vd/Vt) - 1);
    if nargout > 1
        d_id = Is*exp(vd/Vt)/Vt;
    end
end
% end diode

%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
