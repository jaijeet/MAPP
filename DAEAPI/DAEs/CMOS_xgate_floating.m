function DAE = CMOS_xgate_floating(uniqIDstr, betaN, betaP, VtN, VtP, RdsN, RdsP, CgsN, CgsP, CgdN, CgdP)  
%function DAE = CMOS_xgate_floating(uniqIDstr, betaN, betaP, VtN, VtP, RdsN, RdsP, CgsN, CgsP, CgdN, CgdP)  
% CMOS transmission gate using Shichmann-Hodges model with drain-source inversion
%author: J. Roychowdhury, 2011/10/25
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% CMOS transmission gate using DSinvSH.  Floating (both connections are hanging).
% 
%        EN
%        |
%      -----
%      | N |
% n1 --     -- n2
%      | P |
%      --o--
%        |
%      ENbar
%	
%
% There are 4 nodes: n1, n2, EN, ENbar.
% Rds is modelled for both MOS transistors.
% Capacitances between the nodes are modelled: Cgs_N, Cgd_N, Cgs_P, Cgd_P
% Noise is not supported yet.
%
% There are no inputs and no outputs.
% 
% Denoting n1 to be the drain of the N FET and the source of the P FET.
%
% n1 KCL: IDS_N - IDS_P + (e1-e2)/RdsN + (e1-e2)/RdsP + d/dt (CgdN*(e1-eEN)) + d/dt (CgsP*(e1-eENbar))
% n2 KCL: IDS_P - IDS_N + (e2-e1)/RdsN + (e2-e1)/RdsP + d/dt (CgsN*(e2-eEN)) + d/dt (CgdP*(e2-eENbar))
% EN KCL: d/dt (CgdN*(eEN-e1)) + d/dt (CgsN*(eEN-e2))
% ENbar KCL: d/dt (CgsP*(eENbar-e1)) + d/dt (CgdP*(eENbar-e2))
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('CMOS_xgate_floating');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff

	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	% data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE);


	%
	DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
	DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
	DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
	DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
	DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. should become a structure
	%
% sizes: 
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.ninputs = @ninputs;
	DAE.noutputs = @noutputs;
	%
% f, q: 
	DAE.f_takes_inputs = 1;
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx;
	DAE.dq_dx = @dq_dx;
	DAE.df_du = @df_du;
	%
% input-related functions
	% discontinued: DAE.b = @btransient; DAE.bQSS; DAE.bLTISSS; 
	%
	%DAE.B = @B;
	%DAE.dB_dx = @dB_dx; no support yet
	%DAE.dB_dp = @dB_dp; no support yet
	%
% output-related functions
	% what makes sense here for transient, LTISSS, etc.?
	DAE.C = @C;
	DAE.D = @D;
	%
% names
	DAE.uniqID   = @uniqID;
	DAE.daename   = @daename;
	DAE.unknames  = @unknames_DAEAPI;
	DAE.eqnnames  = @eqnnames_DAEAPI;
	DAE.inputnames  = @inputnames;
	DAE.outputnames  = @outputnames;
	DAE.renameUnks = @renameUnks_DAEAPI;
	DAE.renameEqns = @renameEqns_DAEAPI;
	DAE.renameParms = @renameParms_DAEAPI;
	%
% QSS initial guess support
	DAE.QSSinitGuess = @QSSinitGuess;
	%
% NR limiting support
	DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp;
	%DAE.dq_dp  = @dq_dp;
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
% functions for supporting noise
	% 
	DAE.nNoiseSources = @nNoiseSources;
	DAE.NoiseSourceNames = @NoiseSourceNames;
	DAE.NoiseStationaryComponentPSDmatrix = 'undefined'; % @NoiseStationaryComponentPSDmatrix;
	DAE.m = @m;
	DAE.dm_dx = @dm_dx;
	DAE.dm_dn = @dm_dn;
%
%
% % process arguments
	% betaN
	if nargin >= 2
		DAE = feval(DAE.setparms,'betaN', betaN, DAE);
	end

	% betaPs
	if nargin >= 3
		DAE = feval(DAE.setparms,'betaP', betaP, DAE);
	end

	% VtN
	if nargin >= 4
		DAE = feval(DAE.setparms,'VTN', VtN, DAE);
	end

	% VtP
	if nargin >= 5
		DAE = feval(DAE.setparms,'VTP', VtP, DAE);
	end

	% RdsN
	if nargin >= 6
		DAE = feval(DAE.setparms,'rDSN', RdsN, DAE);
	end

	% RdsP
	if nargin >= 7
		DAE = feval(DAE.setparms,'rDSP', RdsP, DAE);
	end

	% CgsN
	if nargin >= 8
		DAE = feval(DAE.setparms,'CgsN', CgsN, DAE);
	end

	% CgsP
	if nargin >= 9
		DAE = feval(DAE.setparms,'CgsP', CgsP, DAE);
	end

	% CgdN
	if nargin >= 10
		DAE = feval(DAE.setparms,'CgdN', CgdN, DAE);
	end

	% CgdP
	if nargin == 11
		DAE = feval(DAE.setparms,'CgdP', CgdP, DAE);
	end
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = 4;
% end nunks(...)

function out = neqns(DAE)
	out = 4;
% end neqns(...)

function out = ninputs(DAE)
	out = 0; 
% end ninputs(...)

function out = noutputs(DAE)
	out = 0;
% end noutputs(...)

function out = nparms(DAE)
	out = 10; % betaN, VTN, betaP, VTP, rDSN, rDSP, CgsN, CgsP, CgdN, CgdP
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('CMOS transmission gate (using SH models with D/S inversion)');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out = {'e1', 'e2', 'eEN', 'eENbar'};
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out = {'KCL1', 'KCL2', 'KCL_EN', 'KCL_ENbar'};
% end eqnnames()

function out = inputnames(DAE)
	out = {};
% end inputnames()

function out = outputnames(DAE)
	out = {};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'betaN', 'VTN', 'betaP', 'VTP', 'rDSN', 'rDSP', 'CgsN', 'CgsP', 'CgdN', 'CgdP'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {2e-3, 0.25, 2e-3, 0.25, 1e5, 1e5, 1e-8, 1e-8, 1e-8, 1e-8};
	%order: 'betaN', 'VTN', 'betap', 'VTP', 'rDSN', 'rDSP', 'CgsN', 'CgsP', 'CgdN', 'CgdP'
% end parmdefaults(...)



%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	e1 = x(1); e2 = x(2); eEN = x(3); eENbar = x(4);
	[betaN, VTN, betaP, VTP, rDSN, rDSP, CgsN, CgsP, CgdN, CgdP] = deal(DAE.parms{:});

	NMOS = DSintSH_Ntype;
	PMOS = DSintSH_Ptype;

	%VgsN = eEN-e2
	%VdsN = e1-e2
	%VgsP = eENbar - e1
	%VdsP = e2 - e1
	IDN = feval(NMOS.f, eEN-e2 , e1-e2 , betaN, VTN);
	IDP = feval(PMOS.f, eENbar - e1, e2-e1 , betaP, VTP);

	% n1 KCL: IDS_N - IDS_P + (e1-e2)/RdsN + (e1-e2)/RdsP + d/dt (CgdN*(e1-eEN)) + d/dt (CgsP*(e1-eENbar))
	fout(1,1) = IDN - IDP + (e1-e2)/rDSN + (e1-e2)/rDSP;

	% n2 KCL: IDS_P - IDS_N + (e2-e1)/RdsN + (e2-e1)/RdsP + d/dt (CgsN*(e2-eEN)) + d/dt (CgdP*(e2-eENbar))
	fout(2,1) = IDP - IDN + (e2-e1)/rDSN + (e2-e1)/rDSP;

	% EN KCL: d/dt (CgdN*(eEN-e1)) + d/dt (CgsN*(eEN-e2))
	fout(3,1) = 0;

	% ENbar KCL: d/dt (CgsP*(eENbar-e1)) + d/dt (CgdP*(eENbar-e2))
	fout(4,1) = 0;
% end f(...)

function qout = q(x, DAE)
	e1 = x(1); e2 = x(2); eEN = x(3); eENbar = x(4);
	[betaN, VTN, betaP, VTP, rDSN, rDSP, CgsN, CgsP, CgdN, CgdP] = deal(DAE.parms{:});

	% n1 KCL: IDS_N - IDS_P + (e1-e2)/RdsN + (e1-e2)/RdsP + d/dt (CgdN*(e1-eEN)) + d/dt (CgsP*(e1-eENbar))
	qout(1,1) = CgdN*(e1-eEN) + CgsP*(e1-eENbar);

	% n2 KCL: IDS_P - IDS_N + (e2-e1)/RdsN + (e2-e1)/RdsP + d/dt (CgsN*(e2-eEN)) + d/dt (CgdP*(e2-eENbar))
	qout(2,1) = CgsN*(e2-eEN) + CgdP*(e2-eENbar);

	% EN KCL: d/dt (CgdN*(eEN-e1)) + d/dt (CgsN*(eEN-e2))
	qout(3,1) = CgdN*(eEN-e1) + CgsN*(eEN-e2);

	% ENbar KCL: d/dt (CgsP*(eENbar-e1)) + d/dt (CgdP*(eENbar-e2))
	qout(4,1) = CgsP*(eENbar-e1) + CgdP*(eENbar-e2);
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)
	e1 = x(1); e2 = x(2); eEN = x(3); eENbar = x(4);
	[betaN, VTN, betaP, VTP, rDSN, rDSP, CgsN, CgsP, CgdN, CgdP] = deal(DAE.parms{:});

	NMOS = DSintSH_Ntype;
	PMOS = DSintSH_Ptype;

	[IDN, dIDN_dVGS, dIDN_dVDS] = feval(NMOS.f, eEN-e2 , e1-e2 , betaN, VTN);
	%                                            VGS      VDS
	[IDP, dIDP_dVGS, dIDP_dVDS] = feval(PMOS.f, eENbar-e1, e2-e1 , betaP, VTP);
	%                                            VGS       VDS

	% e1  e2   eEN  eENbar
	% 1   2    3    4

	Jf = sparse(4,4);

	%fout(1,1) = IDN - IDP + (e1-e2)/rDSN + (e1-e2)/rDSP;
	Jf(1,1) = dIDN_dVDS*1 - dIDP_dVGS*(-1) - dIDP_dVDS*(-1) + 1/rDSN + 1/rDSP;
	Jf(1,2) = dIDN_dVGS*(-1) + dIDN_dVDS*(-1) - dIDP_dVDS*1 - 1/rDSN - 1/rDSP;
	Jf(1,3) = dIDN_dVGS*1;
	Jf(1,4) = - dIDP_dVGS*1;

	%fout(2,1) = IDP - IDN + (e2-e1)/rDSN + (e2-e1)/rDSP;
	Jf(2,1) = dIDP_dVGS*(-1) + dIDP_dVDS*(-1) - dIDN_dVDS*1 -1/rDSN -1/rDSP;
	Jf(2,2) = dIDP_dVDS*1 - dIDN_dVGS*(-1) - dIDN_dVDS*(-1) + 1/rDSN + 1/rDSP;
	Jf(2,3) = - dIDN_dVGS*1;
	Jf(2,4) = dIDP_dVGS*1;

	% EN KCL: d/dt (CgdN*(eEN-e1)) + d/dt (CgsN*(eEN-e2))
	% ENbar KCL: d/dt (CgsP*(eENbar-e1)) + d/dt (CgdP*(eENbar-e2))
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	e1 = x(1); e2 = x(2); eEN = x(3); eENbar = x(4);
	[betaN, VTN, betaP, VTP, rDSN, rDSP, CgsN, CgsP, CgdN, CgdP] = deal(DAE.parms{:});

	Jq = sparse(4,4);

	% e1  e2   eEN  eENbar
	% 1   2    3    4

	%qout(1,1) = CgdN*(e1-eEN) + CgsP*(e1-eENbar);
	Jq(1,1) = CgdN + CgsP;
	Jq(1,3) = -CgdN;
	Jq(1,4) = -CgsP;

	%qout(2,1) = CgsN*(e2-eEN) + CgdP*(e2-eENbar);
	Jq(2,2) = CgsN + CgdP;
	Jq(2,3) = -CgsN;
	Jq(2,4) = -CgdP;

	%qout(3,1) = CgdN*(eEN-e1) + CgsN*(eEN-e2);
	Jq(3,1) = -CgdN;
	Jq(3,2) = -CgsN;
	Jq(3,3) = CgdN + CgsN;

	%qout(4,1) = CgsP*(eENbar-e1) + CgdP*(eENbar-e2);
	Jq(4,1) = -CgsP;
	Jq(4,2) = -CgdP;
	Jq(4,4) = CgsP + CgdP;
% end dq_dx(...)

function dfdu = df_du(x, u, DAE)
	dfdu = [];
% end df_du(...)
%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = [];
% end C(...)

function out = D(DAE)
	out = [];
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = [0.5;0.5;1.0;0.0];
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx;
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	error('NoiseStationaryComponentPSDmatrix undefined for xgate');
	m = nNoiseSources(DAE);
	out = speye(m);
	% unit PSDs; all the action is moved to m(x,n)
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% NOTE: m should be for one-sided PSDs
	% M is of size neqns. n is of size nNoiseSources
	%
	out = zeros(4,1);
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	error('hand-coded dm_dx undefined for xgate');
	Jm = [];
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
	error('hand-coded dm_dn undefined for xgate');
	% M is of size neqns. n is of size nNoiseSources
	% NOTE: M should be for one-sided PSDs
	%
	k = 1.3806503e-23; % Boltzmann's const
	q = 1.60217646e-19; % electronic charge
	T = 300; % Kelvin; absolute temperature FIXME: this should be a parameter

	n = nunks(DAE);
	nn = nNoiseSources(DAE);
	M = sparse([]); M(nsegs,nsegs) = 0;
	M = M*sqrt(4*k*T/R);
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs = 'No internal functions exposed by this DAE system.';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

