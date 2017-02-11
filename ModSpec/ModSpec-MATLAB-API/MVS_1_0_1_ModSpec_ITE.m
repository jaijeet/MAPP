function MOD = MVS_1_0_1_ModSpec(uniqID)
%function MOD = MVS_1_0_1_ModSpec(uniqID)
%This function creates a ModSpec model for MIT Virtual Source Nanotransistor
%Model (Silicon) v1.0.1 .
%
% The model is implemented based on Verilog-A model released on nanoHUB.org:
% https://nanohub.org/resources/19684
%
% The model is hand-translated from the Verilog-A file into ModSpec Matlab API.
% Also, gmin and init/limiting have been added in it.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'M1'.
%
%Return values:
% - MOD:    a ModSpec object for the MVS model.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'d', 'g', 's', 'b'} (drain, gate, source, bulk).
%
% - parameters:
% - 'version' (MVS model version)
%           default: 1.01
% - 'Type'    (type of transistor. nFET Type=1; pFET Type=-1)
%           default: 1
% - 'W'       (Transistor width [cm])
%           default: 1e-4
% - 'Lgdr'    (Physical gate length [cm])
%           default: 80e-7
% - 'dLg'     (Overlap length including both source and drain sides [cm])  
%           default: 10.5e-7
% - 'Cg'      (Gate-to-channel areal capacitance at the virtual source [F/cm^2])
%           default: 2.2e-6
% - 'etov'    (Equivalent thickness of dielectric at S/D-G overlap [cm])
%           default: 1.3e-3
% - 'delta'   (Drain-induced-barrier-lowering (DIBL) [V/V])
%           default: 0.10
% - 'n0'      (Subthreshold swing factor [unit-less])
%           default: 1.5
% - 'Rs0'     (Access resistance on s-terminal [Ohms-micron])
%           default: 100
% - 'Rd0'     (Access resistance on d-terminal [Ohms-micron])
%           default: 100
% - 'Cif'     (Inner fringing S or D capacitance [F/cm])
%           default: 1e-12
% - 'Cof'     (Outer fringing S or D capacitance [F/cm]) 
%           default: 2e-13
% - 'vxo'     (Virtual source injection velocity [cm/s])
%           default: 0.765e7
% - 'Mu'      (Low-field mobility [cm^2/V.s])
%           default: 200
% - 'Beta'    (Saturation factor. Typ. nFET=1.8, pFET=1.6)
%           default: 1.7
% - 'Tjun'    (Junction temperature [K])
%           default: 298
% - 'phib'    (~abs(2*phif)>0 [V])
%           default: 1.2
% - 'Gamma'   (Body factor  [sqrt(V)])
%           default: 0.0
% - 'Vt0'     (Strong inversion threshold voltage [V])
%           default: 0.486
% - 'Alpha'   (Empirical parameter for threshold voltage shift between strong
%              and weak inversion.)
%           default: 3.5
% - 'mc'      (Choose an appropriate value between 0.01 to 10)
%           default: 0.2
% - 'CTM_select' (If CTM_select = 1, then classic DD-NVSAT model is used)
%           default: 1
% - 'CC'   (Fitting parameter to adjust Vg-dependent inner fringe capacitances)
%           default: 0
% - 'nd'      (Punch-through factor [1/V])
%           default: 0
% - 'gmin'    (minimum conductance between drain and source, convergence aid)
%           default: 1e-12
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
% - equations of MVS model are ported from the MVS Verilog-A model released on
%   nanoHUB.org: https://nanohub.org/resources/19684
%
%
%Examples
%--------
% % adding an MVS NMOS with default parameters to a circuitdata structure
% cktdata = add_element(cktdata, MVS_1_0_1_ModSpec(), 'M1', ...
%           {'nD', 'nG', 'nS', 'nB'}, [], {});
%
%See also
%--------
% 
% MVS_1_0_1_ModSpec_wrapper, add_element, circuitdata[TODO], ModSpec, DAEAPI,
% DAE_concepts
%

%
% author: T. Wang. 2014-01-25

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%change log:
%-----------
%2014-01-25: Tianshi Wang <tianshi@berkeley.edu> Created
 
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

	MOD.model_name = 'mvs_si_1_0_1';
	MOD.model_description = '';

% real     version = 1.01;                             // MVS model version = 1.0.1
% integer  Type    = 1       from [-1 : 1] exclude 0;  // type of transistor. nFET Type=1; pFET Type=-1
% real     W       = 1e-4    from (0:inf);             // Transistor width [cm]
% real     Lgdr    = 80e-7   from (0:inf);             // Physical gate length [cm]. //    This is the designed gate length for litho printing.
% real     dLg     = 10.5e-7 from (0:inf);             // Overlap length including both source and drain sides [cm]  
% real     Cg      = 2.2e-6  from (0:inf);             // Gate-to-channel areal capacitance at the virtual source [F/cm^2]
% real     etov    = 1.3e-3  from (0:inf);             // Equivalent thickness of dielectric at S/D-G overlap [cm]
% real     delta   = 0.10    from [0:inf);             // Drain-induced-barrier-lowering (DIBL) [V/V]
% real     n0      = 1.5     from [0:inf);             // Subthreshold swing factor [unit-less] {typically between 1.0 and 2.0}
% real     Rs0     = 100     from (0:inf);             // Access resistance on s-terminal [Ohms-micron]
% real     Rd0     = 100     from (0:inf);             // Access resistance on d-terminal [Ohms-micron] 
%                                                      // Generally, Rs0 = Rd0 for symmetric source and drain
% real     Cif     = 1e-12   from [0:inf);             // Inner fringing S or D capacitance [F/cm] 
% real     Cof     = 2e-13   from [0:inf);             // Outer fringing S or D capacitance [F/cm] 
% real     vxo     = 0.765e7 from (0:inf);             // Virtual source injection velocity [cm/s]
% real     Mu      = 200     from (0:inf);             // Low-field mobility [cm^2/V.s]
% real     Beta    = 1.7     from (0:inf);             // Saturation factor. Typ. nFET=1.8, pFET=1.6
% real     Tjun    = 298     from [173:inf);           // Junction temperature [K]
% real     phib    = 1.2;                              // ~abs(2*phif)>0 [V]
% real     Gamma   = 0.0     from [0:inf);             // Body factor  [sqrt(V)]
% real     Vt0     = 0.486;                            // Strong inversion threshold voltage [V] 
% real     Alpha   = 3.5;                              // Empirical parameter for threshold voltage shift between strong and weak inversion.
% real     mc      = 0.2     from [0.01 : 10];         // Choose an appropriate value between 0.01 to 10 
%                                                      // For, values outside of this range,convergence or accuracy of results is not guaranteed
% integer CTM_select = 1     from [1 : inf);           // If CTM_select = 1, then classic DD-NVSAT model is used
%                                                      // For CTM_select other than 1,blended DD-NVSAT and ballistic charge transport model is used 
% real     CC      = 0       from [0:inf);             // Fitting parameter to adjust Vg-dependent inner fringe capacitances(Not used in this version)
% real     nd      = 0       from [0:inf);             // Punch-through factor [1/V]
%

	MOD.parm_names = {'version', 'Type', 'W', 'Lgdr', 'dLg', 'Cg', 'etov',...
	'delta', 'n0', 'Rs0', 'Rd0', 'Cif', 'Cof', 'vxo', 'Mu', 'Beta', 'Tjun',...
	'phib', 'Gamma', 'Vt0', 'Alpha', 'mc', 'CTM_select', 'CC', 'nd', 'gmin'};

	MOD.parm_defaultvals = {1.01, 1, 1e-4, 80e-7, 10.5e-7, 2.2e-6, 1.3e-3,...
	0.10, 1.5, 100, 100, 1e-12, 2e-13, 0.765e7, 200, 1.7, 298, 1.2, 0.0,...
	0.486, 3.5, 0.2, 1, 0, 0, 1e-12};

	MOD.parm_vals = MOD.parm_defaultvals; 
	MOD.explicit_output_names = {'idb', 'igb', 'isb'}; % vecZ
	MOD.internal_unk_names = {'vdib', 'vsib'}; % vecY
	MOD.implicit_equation_names = {...
		'KCL-di', ...
		'KCL-si', ...
	};
    MOD.support_initlimiting = 1;
	MOD.limited_var_names = {'vdiblim', 'vgblim', 'vsiblim'}; % vecLim
	MOD.vecXY_to_limitedvars_matrix = [0 0 0 1 0
	                                   0 1 0 0 0
									   0 0 0 0 1];

	MOD.u_names = {};

	MOD.NIL.node_names = {'d', 'g', 's', 'b' };
	MOD.NIL.refnode_name = 'b';

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

end % MOD constructor

%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%
%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%
function [fe, qe, fi, qi] = fqei(vecX, vecY, vecLim, vecU, flag, MOD)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	% set up scalar variables for the parms, vecX, vecY and u
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

	% create variables of the same names as the parameters and assign
	% them the values in MOD.parms
	% ideally, this should be a macro
	%	- could do this using a string and another eval()
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

	% do the same for vecY from internalUnknowns
	% get internalUnknowns from vecY
	iunks = feval(MOD.InternalUnkNames,MOD);
	for i = 1:length(iunks)
		evalstr = sprintf('%s = vecY(i);', iunks{i});
		eval(evalstr); % should be OK for vecvalder
	end

	% similarly, get values from vecLim, named exactly the same as limitedvarnames
	% get limitedvars from vecLim
	lvars = feval(MOD.LimitedVarNames,MOD);
	for i = 1:length(lvars)
		evalstr = sprintf('%s = vecLim(i);', lvars{i});
		eval(evalstr); % should be OK for vecvalder
	end

	% do the same for u from uNames
	unms = feval(MOD.uNames, MOD);
	for i = 1:length(unms)
		evalstr = sprintf('%s = vecU(i);', unms{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, there are no us

	% end setting up scalar variables for the parms, vecX, vecY and u
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% vdb = vecX(1); vgb = vecX(2); vsb = vecX(3);
	% vdib = vecY(1); vsib = vecY(2);
	% vdiblim = vecLim(1); vgblim = vecLim(2); vsiblim = vecLim(3);

	vb  = 0;
	vd  = vdb + vb;
	vg  = vgblim + vb;
	vs  = vsb + vb;
	vdi = vdiblim + vb;
	vsi = vsiblim + vb;

	if 1 == flag.qe || 1 == flag.qi 
		% do charges
		[iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, MOD, 1);
	else
		[iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, MOD, 0);
	end

	if 1 == flag.fe
		% KCL at d
		fe(1,1) = iddi;
		% KCL at g
		fe(2,1) = 0;
		% KCL at s
		fe(3,1) = -isis;
	else
		fe = [];
	end

	if 1 == flag.qe
		% KCL at g
		qe(2,1) = qgb; % TODO: vecvalder trick...
		% KCL at d
		qe(1,1) = 0;
		% KCL at s
		qe(3,1) = 0;
	else
		qe = [];
	end

	if 1 == flag.fi
		idisi = idisi + (vdi - vsi) * gmin;
		% KCL at di
		fi(1,1) = idisi - iddi;
		% KCL at si
		fi(2,1) = isis - idisi;
	else
		fi = [];
	end

	if 1 == flag.qi
		% KCL at di
		qi(1,1) = qdib;
		% KCL at si
		qi(2,1) = qsib;
	else
		qi = [];
	end
end % fqei(...)

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function vecLim = initGuess(u, MOD)

	pnames = feval(MOD.parmnames, MOD);
	pvals  = feval(MOD.getparms, MOD);
	evalstr = '[';
	for i = 1:length(pnames)
		if i ~= length(pnames)
			evalstr = [evalstr, sprintf('%s, ', pnames{i})];
		else
			evalstr = [evalstr, sprintf('%s', pnames{i})];
		end
	end
	evalstr = [evalstr, '] = deal(pvals{:});'];
	eval(evalstr);

	% MOD.limited_var_names = {'vdblim', 'vgblim', 'vsblim'}; % vecLim

    vecLim(2, 1) = Type * Vt0;  % vgblim 
    vecLim(1, 1) = 0;   % vdiblim
    vecLim(3, 1) = -1;  % vsiblim 
end % initGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function vecLim = limiting(vecX, vecY, vecLimOld, u, MOD)

	pnames = feval(MOD.parmnames, MOD);
	pvals  = feval(MOD.getparms, MOD);
	evalstr = '[';
	for i = 1:length(pnames)
		if i ~= length(pnames)
			evalstr = [evalstr, sprintf('%s, ', pnames{i})];
		else
			evalstr = [evalstr, sprintf('%s', pnames{i})];
		end
	end
	evalstr = [evalstr, '] = deal(pvals{:});'];
	eval(evalstr);

    vdb = vecY(1);
    vgb = vecX(2);
    vsb = vecY(2);
    vdbold = vecLimOld(1);
    vgbold = vecLimOld(2);
    vsbold = vecLimOld(3);

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
    vt = 0.026; % thermal voltage, different from VT
                % TODO: derive via kT/q, take T as parm
	vcrit = 0.6145; % TODO: vcrit is hard-coded here should get them somehow
                    % from parms

    vgs_before = vgs;
    vgd_before = vgd;

    vgs_if = fetlim_ITE(vgs_before, vgsold, Type*Vt0);
    vds_if = limvds_ITE(vgs_if-vgd_before, vdsold);
    vgd_if = vgs_if - vds_if;

    vgd_else = fetlim_ITE(vgd_before, vgdold, Type*Vt0);
    vds_else = -limvds_ITE(vgd_else-vgs_before, -vdsold);
    vgs_else = vgd_else + vds_else;

    ifcond = (vdsold >= 0);
    vgs = ite(ifcond, vgs_if, vgs_else);
    vds = ite(ifcond, vds_if, vds_else);
    vgd = ite(ifcond, vgd_if, vgd_else);

    %{
    if vdsold >= 0
		%TODO: problem with Type*Vt0
        vgs = fetlim(vgs, vgsold, Type*Vt0);
        vds = vgs - vgd;
        vds = limvds(vds, vdsold);
        vgd = vgs - vds;
    else
        vgd = fetlim(vgd, vgdold, Type*Vt0);
        vds = vgs - vgd;
        vds = -limvds(-vds, -vdsold);
        vgs = vgd + vds;
    end
    %}

    vbs_before = vbs;
    vbd_before = vbd;
    
    vbs_if = pnjlim_ITE(vbsold, vbs_before, vt, vcrit);
    vbd_if = vbs_if - vds;

    vbd_else = pnjlim_ITE(vbdold, vbd_before, vt, vcrit);
    vbs_else = vbd_else + vds;

    ifcond = (vds >= 0);
    vbd = ite(ifcond, vbd_if, vbd_else);
    vbs = ite(ifcond, vbs_if, vbs_else);

    %{
    if vds >= 0
        vbs = pnjlim(vbsold, vbs, vt, vcrit);
        vbd = vbs - vds;
    else
        vbd = pnjlim(vbdold, vbd, vt, vcrit);
        vbs = vbd + vds;
    end
    %}

    vecLim(2, 1) = vgs - vbs; % vgb %vecvader trick...
    vecLim(1, 1) = -vbd; % vdb
    vecLim(3, 1) = -vbs; % vsb

end % limiting

%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%
%===================================================================================
%			this part is derived from Verilog-A model
%===================================================================================

function [iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, MOD, do_Charge)

	pnames = feval(MOD.parmnames, MOD);
	pvals  = feval(MOD.getparms, MOD);
	evalstr = '[';
	for i = 1:length(pnames)
		if i ~= length(pnames)
			evalstr = [evalstr, sprintf('%s, ', pnames{i})];
		else
			evalstr = [evalstr, sprintf('%s', pnames{i})];
		end
	end
	evalstr = [evalstr, '] = deal(pvals{:});'];
	eval(evalstr);

	SMALL_VALUE = 1e-10;
	LARGE_VALUE = 40;
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams

	vgsi  = vg - vsi; 	% branch: (g, si)	br_gsi; %TODO: riscky naming convention, may cause conflictions, has to be checked
	vgdi  = vg - vdi; 	% branch: (g, di) 	br_gdi;
	vgs   = vg - vs;  	% branch: (g, s) 	br_gs;
	vgd   = vg - vd;  	% branch: (g, d) 	br_gd;
	vgb   = vg - vb;  	% branch: (g, b) 	br_gb;
	vdisi = vdi - vsi;	% branch: (di, si) 	br_disi;
	vds   = vd - vs;  	% branch: (d, s)	br_ds;
	vddi  = vd - vdi; 	% branch: (d, di) 	br_ddi;
	vdib  = vdi - vb; 	% branch: (di, b) 	br_dib;
	vbs   = vb - vs;  	% branch: (b, s) 	br_bs;
	vbsi  = vb - vsi; 	% branch: (b, si) 	br_bsi;
	vbd   = vb - vd;  	% branch: (b, d) 	br_bd;
	vbdi  = vb - vdi; 	% branch: (b, di) 	br_bdi;
	vsd   = vs - vd;  	% branch: (s, d) 	br_sd;
	vsidi = vsi - vdi;	% branch: (si, di) 	br_sidi;
	vsis  = vsi - vs; 	% branch: (si, s) 	br_sis;
	vsib  = vsi - vb; 	% branch: (si, b) 	br_sib;

	Vgsraw  = Type*(vgsi);
	Vgdraw  = Type*(vgdi);

	ifcond = (Vgsraw >= Vgdraw);
	Vds = ite(ifcond, Type*(vds), Type*(vsd));
    Vgs = ite(ifcond, Type*(vgs), Type*(vgd));
    Vbs = ite(ifcond, Type*(vbs), Type*(vbd));
    Vdsi = ite(ifcond, Type*(vdisi), Type*(vsidi));
    Vgsi = ite(ifcond, Vgsraw, Vgdraw);
    Vbsi = ite(ifcond, Type*(vbsi), Type*(vbdi));
    dir = ite(ifcond, 1, -1);

    %{
	if (Vgsraw >= Vgdraw)
		Vds = Type*(vds); 
		Vgs = Type*(vgs);
		Vbs = Type*(vbs);
		Vdsi = Type*(vdisi);
		Vgsi = Vgsraw;
		Vbsi = Type*(vbsi);
		dir = 1;
	else
		Vds = Type*(vsd);
		Vgs = Type*(vgd);
		Vbs = Type*(vbd);
		Vdsi = Type*(vsidi);
		Vgsi = Vgdraw;
		Vbsi = Type*(vbdi);
		dir = -1;
	end
    %}

    % Parasitic element definition
    Rs = 1e-4/ W * Rs0;                           % s-terminal resistance [ohms]
    Rd = Rs;                                      % d-terminal resistance [ohms] For symmetric source and drain Rd = Rs. 
    % Rd = 1e-4/ W * Rd0;                         % d-terminal resistance [ohms] {Uncomment for asymmetric source and drain resistance.}
    Cofs = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof;  % s-terminal outer fringing cap [F/cm]
    Cofd = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof;  % d-terminal outer fringing cap [F/cm]
    Leff = Lgdr - dLg;                            % Effective channel length [cm]. After subtracting overlap lengths on s and d side 
    
    phit = dollar_vt(Tjun);                             % Thermal voltage, kT/q [V]
    me = (9.1e-31) * mc;                          % Carrier mass [Kg]
    n = n0 + nd * Vds;                            % Total subthreshold swing factor taking punchthrough into account [unit-less]
    nphit = n * phit;                             % Product of n and phit [used as one variable]
    aphit = Alpha * phit;                         % Product of Alpha and phit [used as one variable]
    
    % Correct Vgsi and Vbsi
    % Vcorr is computed using external Vbs and Vgs but internal Vdsi, Qinv and Qinv_corr are computed with uncorrected Vgs, Vbs and corrected Vgs, Vbs respectively.    
    Vtpcorr = Vt0 + Gamma * (sqrt(abs(phib - Vbs))- sqrt(phib))- Vdsi * delta; % Calculated from extrinsic Vbs
    eVgpre  = exp(( Vgs - Vtpcorr ) / ( aphit * 1.5 ));                         % Calculated from extrinsic Vgs
    FFpre   = 1.0/ ( 1.0 + eVgpre );                                           % Only used to compute the correction factor
    ab      = 2 * ( 1 - 0.99 * FFpre ) * phit;  
    Vcorr   = ( 1.0 + 2.0 * delta ) * ( ab/ 2.0 ) * ( exp( -Vdsi/ ab ));       % Correction to intrinsic Vgs
    Vgscorr = Vgsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vbscorr = Vbsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vt0bs   = Vt0 + Gamma * (sqrt( abs( phib - Vbscorr)) - sqrt( phib ));      % Computed from corrected intrinsic Vbs
    Vt0bs0  = Vt0 + Gamma * (sqrt( abs( phib - Vbsi)) - sqrt( phib ));         % Computed from uncorrected intrinsic Vbs
    Vtp     = Vt0bs - Vdsi * delta - 0.5 * aphit;                              % Computed from corrected intrinsic Vbs and intrinsic Vds
    Vtp0    = Vt0bs0 - Vdsi * delta - 0.5 * aphit;                             % Computed from uncorrected intrinsic Vbs and intrinsic Vds
    eVg     = exp(( Vgscorr - Vtp )/ ( aphit ));                               % Compute eVg factor from corrected intrinsic Vgs
    FF      = 1.0/ ( 1.0 + eVg );
    eVg0    = exp(( Vgsi - Vtp0 )/ ( aphit ));                                 % Compute eVg factor from uncorrected intrinsic Vgs
    FF0     = 1.0/ ( 1.0 + eVg0 );
    Qref    = Cg * nphit;    
    eta     = ( Vgscorr - ( Vt0bs - Vdsi * delta - FF * aphit ))/ ( nphit );   % Compute eta factor from corrected intrinsic Vgs and intrinsic Vds
    eta0    = ( Vgsi - ( Vt0bs0 - Vdsi * delta - FFpre * aphit ))/ ( nphit );  % Compute eta0 factor from uncorrected intrinsic Vgs and internal Vds. 
                                                                               % Using FF instead of FF0 in eta0 gives smoother capacitances.

    % Charge at VS in saturation (Qinv)
    Qinv_corr = ite(eta  <= LARGE_VALUE, Qref * log( 1.0 + exp(eta) ), Qref * eta);

    %{
	if (eta  <= LARGE_VALUE)
        Qinv_corr = Qref * log( 1.0 + exp(eta) );
    else
        Qinv_corr = Qref * eta;
    end
    %}

    Qinv = ite(eta0 <= LARGE_VALUE, Qref * log( 1.0 + exp(eta0) ), Qref * eta0);

    %{
    if (eta0 <= LARGE_VALUE) 
        Qinv = Qref * log( 1.0 + exp(eta0) ); % Compute charge w/ uncorrected intrinsic Vgs for use later on in charge partitioning
	else
        Qinv = Qref * eta0;
    end
    %}

    %Transport equations
    vx0        = vxo;    
    Vdsats     = vx0 * Leff/ Mu;                            
    Vdsat      = Vdsats * ( 1.0 - FF ) + phit * FF; % Saturation drain voltage for current
    Vdratio    = abs( Vdsi/ Vdsat);
    Vdbeta     = pow( Vdratio, Beta);
    Vdbetabeta = pow( 1.0 + Vdbeta, 1.0/ Beta);
    Fsat       = Vdratio / Vdbetabeta; % Transition function from linear to saturation. 
                                       % Fsat = 1 when Vds>>Vdsat; Fsat= Vds when Vds<<Vdsat

    % Total drain current                                         
    Id = Qinv_corr * vx0 * Fsat * W;        

	if do_Charge
		% Calculation of intrinsic charge partitioning factors (qs and qd)
		Vgt = Qinv/ Cg; % Use charge computed from uncorrected intrinsic Vgs

		% Approximate solution for psis is weak inversion
        ifcond = (Gamma == 0);
        psis = ite(ifcond, ite(eta0 <= LARGE_VALUE, phib + phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 )))), phib + phit * ( 1.0 + log( eta0 ))), ite(eta0 <= LARGE_VALUE, phib + ( 1.0 - Gamma )/ ( 1.0 + Gamma ) * phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 )))), phib + ( 1.0 - Gamma )/ ( 1.0 + Gamma ) * phit * ( 1.0 + log( eta0 ))));
        a = ite(ifcond, 1.0, 1.0 + Gamma/ ( 2.0 * sqrt( abs( psis - ( Vbsi )))));
        
        %{
		if (Gamma == 0)
			a  = 1.0;
			if (eta0 <= LARGE_VALUE)
				psis = phib + phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
			else 
				psis = phib + phit * ( 1.0 + log( eta0 ));
			end
		else
			if (eta0 <= LARGE_VALUE)
			   psis = phib + ( 1.0 - Gamma )/ ( 1.0 + Gamma ) * phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
			else
			   psis = phib + ( 1.0 - Gamma )/ ( 1.0 + Gamma ) * phit * ( 1.0 + log( eta0 ));
			end
			a = 1.0 + Gamma/ ( 2.0 * sqrt( abs( psis - ( Vbsi ))));
		end
        %}

		Vgta   = Vgt / a; % Vdsat in strong inversion
		Vdsatq = sqrt( FF0 * aphit * aphit + Vgta * Vgta); % Vdsat approx. to extend to weak inversion; 
														   % The Multiplier of phit has strong effect on Cgd discontinuity at Vd=0.

		% Modified Fsat for calculation of charge partitioning
		% DD-NVSAT charge
		Fsatq = abs( Vdsi/ Vdsatq )/ ( pow( 1.0 + pow( abs( Vdsi/ Vdsatq ), Beta ), 1.0/ Beta ));
		x     = 1.0 - Fsatq;
		den   = 15 * ( 1 + x ) * ( 1 + x );
		qsc   = Qinv *(6 + 12 * x + 8 * x * x + 4 * x * x * x)/ den;
		qdc   = Qinv *(4 + 8 * x + 12 * x * x + 6 * x * x * x)/ den;
		qi    = qsc + qdc; % Charge in the channel 
		

		% QB charge    
		kq  = 0.0;
		tol = ( SMALL_VALUE * vxo/ 100.0 ) * ( SMALL_VALUE * vxo/ 100.0 ) * me/ ( 2 * P_Q );
        ifcond = (Vdsi <= tol);
        kq = ite(ifcond, 0.0, sqrt( 2.0 * P_Q/ me * Vdsi )/ vx0 * 100.0);
        kq2 = ite(ifcond, ( 2.0 * P_Q/ me * Vdsi )/ ( vx0 * vx0 ) * 10000.0, kq * kq);
        qsb = ite(ifcond, Qinv * ( 0.5 - kq2/ 24.0 + (kq2*kq2)/ 80.0 ), Qinv * ( asinh( kq )/ kq - ( sqrt( kq2 + 1.0 ) - 1.0 )/ kq2));
        qdb = ite(ifcond, Qinv * ( 0.5 - 0.125 * kq2 + (kq2*kq2)/ 16.0 ), Qinv * (( sqrt( kq2 + 1.0 )- 1.0 )/ kq2));
        
        %{
		if (Vdsi <= tol)
			kq2 = ( 2.0 * P_Q/ me * Vdsi )/ ( vx0 * vx0 ) * 10000.0;
			kq4 = kq2 * kq2;
			qsb = Qinv * ( 0.5 - kq2/ 24.0 + kq4/ 80.0 );
			qdb = Qinv * ( 0.5 - 0.125 * kq2 + kq4/ 16.0 );
		else
			kq  = sqrt( 2.0 * P_Q/ me * Vdsi )/ vx0 * 100.0;
			kq2 = kq * kq;
			qsb = Qinv * ( asinh( kq )/ kq - ( sqrt( kq2 + 1.0 ) - 1.0 )/ kq2);
			qdb = Qinv * (( sqrt( kq2 + 1.0 )- 1.0 )/ kq2);
		end
        %}

		% Flag for classic or ballistic charge partitioning:

		ifcond = (CTM_select == 1);
		qs = ite(ifcond, qsc, qsc * ( 1 - Fsatq * Fsatq ) + qsb * Fsatq * Fsatq);
        qd = ite(ifcond, qdc, qdc * ( 1 - Fsatq * Fsatq ) + qdb * Fsatq * Fsatq);
        
        %{
		if (CTM_select == 1) % Ballistic blended with classic DD-NVSAT
			qs = qsc; % Calculation of "ballistic" channel charge partitioning factors, qsb and qdb.
			qd = qdc; % Here it is assumed that the potential increases parabolically from the
					  % virtual source point, where Qinv_corr is known to Vds-dvd at the drain.
		else % Hence carrier velocity increases linearly by kq (below) depending on the
			qs = qsc * ( 1 - Fsatq * Fsatq ) + qsb * Fsatq * Fsatq; % efecive ballistic mass of the carriers.
			qd = qdc * ( 1 - Fsatq * Fsatq ) + qdb * Fsatq * Fsatq;                
		end
        %}
									
		% Body charge based on approximate surface potential (psis) calculation with delta=0 using psis=phib in Qb gives continuous Cgs, Cgd, Cdd in SI, while Cdd is smooth anyway.
		Qb = -Type * W * Leff * ( Cg * Gamma * sqrt( abs( psis - Vbsi )) + ( a - 1.0 )/ ( 1.0 * a ) * Qinv * ( 1.0 - qi ));

		% DIBL effect on drain charge calculation.
		% Calculate dQinv at virtual source due to DIBL only. Then:Correct the qd factor to reflect this channel charge change due to Vd
		% Vt0bs0 and FF=FF0 causes least discontinuity in Cgs and Cgd but produces a spike in Cdd at Vds=0 (in weak inversion.  But bad in strong inversion)
		etai = ( Vgsi - ( Vt0bs0 - FF * aphit ))/ ( nphit );

		Qinvi = ite(etai <= LARGE_VALUE, Qref * log( 1.0 + exp( etai )), Qref * etai);

        %{
		if (etai <= LARGE_VALUE)
			Qinvi = Qref * log( 1.0 + exp( etai ));
		else
			Qinvi = Qref * etai;
		end
        %}

		dQinv     = Qinv - Qinvi;
		dibl_corr = ( 1.0 - FF0 ) * ( 1.0 - Fsatq ) * qi * dQinv;
		qd        = qd - dibl_corr;
			 
		% Inversion charge partitioning to terminals s and d
		Qinvs = Type * Leff * (( 1 + dir ) * qs + ( 1 - dir ) * qd)/ 2.0;
		Qinvd = Type * Leff * (( 1 - dir ) * qs + ( 1 + dir ) * qd)/ 2.0;

		% Outer fringing capacitance
		Qsov = Cofs * ( vgsi );
		Qdov = Cofd * ( vgdi );

		% Inner fringing capacitance
		Vt0x = Vt0 + Gamma * ( sqrt( abs( phib - Type * ( vbsi ))) - sqrt(phib));
		Vt0y = Vt0 + Gamma * ( sqrt( abs( phib - Type * ( vbdi ))) - sqrt(phib));
		Fs_arg = ( Vgsraw - ( Vt0x - Vdsi * delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );

        ifcond = (Fs_arg <= LARGE_VALUE);
        Fs = ite(ifcond, 1.0 + exp( Fs_arg ), 0.0);
        FFx = ite(ifcond, Vgsraw - nphit * log( Fs ), Vgsraw - nphit * Fs_arg);

        %{
		if (Fs_arg <= LARGE_VALUE)
			Fs  = 1.0 + exp( Fs_arg );
			FFx = Vgsraw - nphit * log( Fs );
		else
			Fs  = 0.0; %    Not used
			FFx = Vgsraw - nphit * Fs_arg;
		end
        %}

		Fd_arg = ( Vgdraw - ( Vt0y - Vdsi * delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
		ifcond = (Fd_arg <= LARGE_VALUE);
        Fd  = ite(ifcond, 1.0 + exp( Fd_arg ), 0.0);
        FFy = ite(ifcond, Vgdraw - nphit * log( Fd ), Vgdraw - nphit * Fd_arg);
        
        %{
		if (Fd_arg <= LARGE_VALUE)
			Fd  = 1.0 + exp( Fd_arg );
			FFy = Vgdraw - nphit * log( Fd );
		else
			Fd  = 0.0; %    Not used
			FFy = Vgdraw - nphit * Fd_arg;
		end
        %}

		Qsif = Type * ( Cif + CC * Vgsraw ) * FFx;
		Qdif = Type * ( Cif + CC * Vgdraw ) * FFy;
		
		% Partitioned charge
		Qs = -W * ( Qinvs + Qsov + Qsif ); %     s-terminal charge
		Qd = -W * ( Qinvd + Qdov + Qdif ); %     d-terminal charge
		Qg = -( Qs + Qd + Qb );            %     g-terminal charge
	else
		Qs = 0;
		Qd = 0;
		Qg = 0;
	end

	% Contributions
	idisi =  Type*dir*Id;
	iddi =  (vddi)/Rd;
	isis =  (vsis)/Rs;
	qsib = Qs;  
	qdib = Qd;
	qgb = Qg; 
end % mvs_si_1_0_1

function out =  pow(a,b)
    out = a^b;
end % pow

function out = limexp(x)
breakpoint = 40;
maxslope = exp(breakpoint);
out = exp(x.*(x <= breakpoint)).*(x <= breakpoint) + ...
    (x>breakpoint).*(maxslope + maxslope*(x-breakpoint));
end % limexp

function vt = dollar_vt(T)
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams
	vt = T * P_K / P_Q;
end % dollar_vt
