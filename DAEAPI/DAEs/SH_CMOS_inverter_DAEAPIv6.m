function DAE = SH_CMOS_inverter_DAEAPIv6(uniqIDstr)  % DAEAPIv6.2
%function DAE = SH_CMOS_inverter_DAEAPIv6(uniqIDstr)  % DAEAPIv6.2
% CMOS inverter using Shichmann-Hodges model
%author: J. Roychowdhury, 2008/03/06; updates for 219A, 2011/09/18-29
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% CMOS inverter using SH. This is not strict MNA, because the VDD and Vin
% node voltage unknowns have been eliminated, leading to a scalar eqn at n1 (= Vout)
% 
% n1 KCL: d/dt(CL*e1) + SH_ID_N(VGS=Vin,VDS=e1) + SH_ID_P(VGS=-(VDD-Vin), VDS=-(VDD-e1)) + e1/RDSn - (VDD-e1)/RDSp = 0.
%
% The input is Vin. A DC/QSS input of 0.2V has been put in. You can change
% it by calling DAE.set_uQSS(...).
%
% Note that since we cannot represent the effect of Vin as
% an additive input, we set the flag DAE.f_takes_inputs to 1. This means
% that f() becomes a function of 2 arguments: f(x,u). Similarly with df_dx.
% DAE.B(...) is not used when DAE.f_takes_inputs == 1.
%
% the DAE is: qdot(x) + f(x, u(t))  = 0.
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

%Changelog:
%---------
%2014/01/31: Tianshi Wang <tianshi@berkeley.edu>: nargin checks for backward
%            compatibility
%2013/09/28: Tianshi Wang <tianshi@berkeley.edu>: init/limiting related updates
%2008/03/06: Jaijeet Roychowdhury <jr@berkeley.edu>






%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('SH_CMOS_inverter_DAEAPIv6');
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
	DAE.uQSSvec = 1.0; % 1V DC input
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
	DAE.B = @B;
	%DAE.dB_dx = @dB_dx; no support yet
	%DAE.dB_dp = @dB_dp; no support yet
	%
% output-related functions
	% what makes sense here for transient, LTISSS, etc.?
	DAE.C = @C;
	%DAE.dC_dx = @dC_dx; no support yet
	%DAE.dC_dp = @dC_dp; no support yet
	DAE.D = @D;
	%DAE.dD_dx = @dD_dx; no support yet
	%DAE.dD_dp = @dD_dp; no support yet
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
	% DAE.QSSinitGuess = @QSSinitGuess;
	%
% NR limiting support
	% DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames_DAEAPI;
	DAE.getparms  = @default_getparms_DAE;
	DAE.setparms  = @default_setparms_DAE;
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
	DAE.m = 'undefined'; % @m;
	DAE.dm_dx = 'undefined'; % @dm_dx;
	DAE.dm_dn = 'undefined'; % @dm_dn;
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = 1;
% end nunks(...)

function out = neqns(DAE)
	out = 1;
% end neqns(...)

function out = ninputs(DAE)
	out = 1; % Vin
% end ninputs(...)

function out = noutputs(DAE)
	out = 1; % Vout = e1
% end noutputs(...)

function out = nparms(DAE)
	out = 8; % betaN, VTN, betaP, VTP, rDSN, rDSP, VDD, CL
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('CMOS inverter (using SH models with D/S inversion)');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out{1} = sprintf('e%d', 1);
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out{1} = sprintf('KCL%d', 1);
% end eqnnames()

function out = inputnames(DAE)
	out = {'Vin'};
% end inputnames()

function out = outputnames(DAE)
	out = {'Vout'};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'betaN', 'VTN', 'betap', 'VTP', 'rDSN', 'rDSP', 'VDD', 'CL'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {2e-3, 0.25, 2e-3, 0.25, 1e5, 1e5, 1.2, 1e-7};
	%order:{'betaN', 'VTN', 'betap', 'VTP', 'rDSN', 'rDSP', 'VDD', 'CL'};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	% b = B*u(t) = 1*Vin(t)
	% n1 KCL: d/dt(CL*e1) + SH_ID_N(VGS=Vin,VDS=e1) + SH_ID_P(VGS=-(VDD-Vin), VDS=-(VDD-e1)) + e1/RDSn - (VDD-e1)/RDSp = 0.
	e1 = x(1);
	Vin = u;
	[betaN, VTN, betaP, VTP, rDSN, rDSP, VDD, CL] = deal(DAE.parms{:});
	NMOS = DSintSH_Ntype;
	PMOS = DSintSH_Ptype;
	IDN = feval(NMOS.f, Vin, e1, betaN, VTN);
	IDP = feval(PMOS.f, -(VDD-Vin), -(VDD-e1), betaP, VTP);
	fout = IDN + IDP + e1/rDSN - (VDD-e1)/rDSP;
% end f(...)

function qout = q(x, DAE)
	e1 = x(1);
	[betaN, VTN, betaP, VTP, rDSN, rDSP, VDD, CL] = deal(DAE.parms{:});
	% n1 KCL: d/dt(CL*e1) + SH_ID_N(VGS=Vin,VDS=e1) + SH_ID_P(VGS=-(VDD-Vin), VDS=-(VDD-e1)) + e1/RDSn - (VDD-e1)/RDSp = 0.
	qout = CL*e1;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)
	e1 = x(1);
	Vin = u;
	[betaN, VTN, betaP, VTP, rDSN, rDSP, VDD, CL] = deal(DAE.parms{:});
	NMOS = DSintSH_Ntype;
	PMOS = DSintSH_Ptype;

	[IDN, dIDN_dVGS, dIDN_dVDS] = feval(NMOS.f, Vin,e1,betaN,VTN);
	[IDP, dIDP_dVGS, dIDP_dVDS] = feval(PMOS.f, -(VDD-Vin),-(VDD-e1),betaP,VTP);
	Jf = dIDN_dVDS + dIDP_dVDS + 1/rDSN + 1/rDSP;
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	[betaN, VTN, betaP, VTP, rDSN, rDSP, VDD, CL] = deal(DAE.parms{:});
	Jq = CL;
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P_f = df_dp(x, PObj, DAE)
	P_f = sparse([]);
	% NO parameter derivative support yet
% end df_dp(...)

function P_q = dq_dp(x, PObj, DAE)
	P_q = sparse([]);
	% NO parameter derivative support yet
% end dq_dp(...)

function dfdu = df_du(x, u, DAE)
	e1 = x(1);
	Vin = u;
	[betaN, VTN, betaP, VTP, rDSN, rDSP, VDD, CL] = deal(DAE.parms{:});
	NMOS = DSintSH_Ntype;
	PMOS = DSintSH_Ptype;

	[IDN, dIDN_dVGS, dIDN_dVDS] = feval(NMOS.f, Vin,e1,betaN,VTN);
	[IDP, dIDP_dVGS, dIDP_dVDS] = feval(PMOS.f, -(VDD-Vin),-(VDD-e1),betaP,VTP);
	dfdu = dIDN_dVGS + dIDP_dVGS;
% end df_du(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	if (nargin > 1)
	   fprintf(2,'B(x, DAE) not supported yet (need tensor support first).\n');
	   return;
	end
	out = 1; % but not used
% end B(...)


%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = [1];
% end C(...)

function out = D(DAE)
	out = 0;
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = 0.5;
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	m = nNoiseSources(DAE);
	out = speye(m);
	% unit PSDs; all the action is moved to m(x,n)
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% NOTE: m should be for one-sided PSDs
	% M is of size neqns. n is of size nNoiseSources
	%
	M = dm_dn(x,n,DAE);
	out = M*n;
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	n = nunks(DAE);
	Jm = sparse([]);
	Jm(n,n) = 0;
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
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

