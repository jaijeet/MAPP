function DAE = inverterchain_floating(uniqIDstr, nstages, VDDs, betaNs, betaPs, VtNs, VtPs, RdsNs, RdsPs, CLs)
%function DAE = inverterchain_floating(uniqIDstr, nstages, VDDs, betaNs, betaPs, VtNs, VtPs, RdsNs, RdsPs, CLs)
%"floating" inverter chain - ie, input and output nodes floating
%author: J. Roychowdhury, 2008/10/11
% - nstages: number of inverter stages
% - VDDs: VDD to each inverter. If a single number, then the same value will used for all inverters; otherwise, it should
%	  be an array of size nstages. Default if not specified: 1.2V
% - betaNs: the beta of the N-MOSFET in each inverter. If a single number, then the same value will be used for all inverters; 
%	  otherwise, it should be an array of size nstages. Default if not specified: 1e-3 A/V^2
% - betaPs: as above, but for the P-MOSFET of each inverter. Default if not specified: 1e-3 A/V^2
% - VtNs: threshold voltages of the N-transistors; scalar or size-nstages array, as above. Default if not specified: 0.25V.
% - VtPs: threshold voltages of the P-transistors; scalar or size-nstages array, as above. Default if not specified: 0.25V.
% - RdsNs: RDS of the N-transistors; scalar or size-nstages array, as above. Default if not specified: 10Kohm.
% - RdsPs: RDS of the P-transistors; scalar or size-nstages array, as above. Default if not specified: 10Kohm.
% - CLs: load cap at the output of each inverter; scalar or size-nstages array, as above. Default if not specified: 1uF.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% CMOS inverter chain using SH inverters. This is not strict MNA, because the VDD and Vin
% node voltage unknowns have been eliminated.
% 
% n1 KCL: d/dt(CL*e1) + SH_ID_N(VGS=e0,VDS=e1) + SH_ID_P(VGS=-(VDD-e0), VDS=-(VDD-e1)) + e1/RDSn - (VDD-e1)/RDSp = 0.
% ni KCL, 1<i<nstages: d/dt(CL*ei) + SH_ID_N(VGS=eim1,VDS=ei) + SH_ID_P(VGS=-(VDD-eim1), VDS=-(VDD-ei)) + ei/RDSn - (VDD-ei)/RDSp = 0.
%	- assuming static AND dynamic currents into MOSFET gates are zero.
%
% there is no input. no outputs are defined.
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
	DAE.Usage = help('inverterchain_floating');
	if nargin < 1 
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff

	if nargin < 2
		nstages = 1;
	end

	DAE.nstages = nstages;


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
	%
	%DAE.B = @B;
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
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames_DAEAPI;
	DAE.getparms = @default_getparms_DAE;
	DAE.setparms = @default_setparms_DAE;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = 'undefined';
	%DAE.dq_dp  = 'undefined';
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
% functions for supporting noise
	% 
	DAE.nNoiseSources = @nNoiseSources;
	DAE.NoiseSourceNames = @NoiseSourceNames;
	DAE.NoiseStationaryComponentPSDmatrix = @NoiseStationaryComponentPSDmatrix;
	DAE.m = @m;
	DAE.dm_dx = @dm_dx;
	DAE.dm_dn = @dm_dn;
%
% process args
	% VDDs
	if nargin >= 3
		if 1 == length(VDDs)
			DAE.VDDs = ones(1,nstages)*VDDs;
		elseif nstages == length(VDDs)
			DAE.VDDs = VDDs;
		else
			fprintf(2, 'Error: VDDs is neither scalar nor of size %d', nstages);
			return;
		end
	else
		DAE.VDDs = ones(1,nstages)*1.2;
	end

	% betaNs
	if nargin >= 4
		if 1 == length(betaNs)
			DAE.betaNs = ones(1,nstages)*betaNs;
		elseif nstages == length(betaNs)
			DAE.betaNs = betaNs;
		else
			fprintf(2, 'Error: betaNs is neither scalar nor of size %d', nstages);
			return;
		end
	else
		DAE.betaNs = ones(1,nstages)*1e-3;
	end

	% betaPs
	if nargin >= 5
		if 1 == length(betaPs)
			DAE.betaPs = ones(1,nstages)*betaPs;
		elseif nstages == length(betaPs)
			DAE.betaPs = betaPs;
		else
			fprintf(2, 'Error: betaPs is neither scalar nor of size %d', nstages);
			return;
		end
	else
		DAE.betaPs = ones(1,nstages)*1e-3;
	end

	% VtNs
	if nargin >= 6
		if 1 == length(VtNs)
			DAE.VtNs = ones(1,nstages)*VtNs;
		elseif nstages == length(VtNs)
			DAE.VtNs = VtNs;
		else
			fprintf(2, 'Error: VtNs is neither scalar nor of size %d', nstages);
			return;
		end
	else
		DAE.VtNs = ones(1,nstages)*0.25;
	end

	% VtPs
	if nargin >= 7
		if 1 == length(VtPs)
			DAE.VtPs = ones(1,nstages)*VtPs;
		elseif nstages == length(VtPs)
			DAE.VtPs = VtPs;
		else
			fprintf(2, 'Error: VtPs is neither scalar nor of size %d', nstages);
			return;
		end
	else
		DAE.VtPs = ones(1,nstages)*0.25;
	end

	% RdsNs
	if nargin >= 8
		if 1 == length(RdsNs)
			DAE.RdsNs = ones(1,nstages)*RdsNs;
		elseif nstages == length(RdsNs)
			DAE.RdsNs = RdsNs;
		else
			fprintf(2, 'Error: RdsNs is neither scalar nor of size %d', nstages);
			return;
		end
	else
		DAE.RdsNs = ones(1,nstages)*1e4;
	end

	% RdsPs
	if nargin >= 9
		if 1 == length(RdsPs)
			DAE.RdsPs = ones(1,nstages)*RdsPs;
		elseif nstages == length(RdsPs)
			DAE.RdsPs = RdsPs;
		else
			fprintf(2, 'Error: RdsPs is neither scalar nor of size %d', nstages);
			return;
		end
	else
		DAE.RdsPs = ones(1,nstages)*1e4;
	end

	% CLs
	if nargin == 10
		if 1 == length(CLs)
			DAE.CLs = ones(1,nstages)*CLs;
		elseif nstages == length(CLs)
			DAE.CLs = CLs;
		else
			fprintf(2, 'Error: CLs is neither scalar nor of size %d', nstages);
			return;
		end
	else
		DAE.CLs = ones(1,nstages)*1e-6;
	end

	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	% data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE);
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = DAE.nstages+1;
% end nunks(...)

function out = neqns(DAE)
	out = DAE.nstages+1;
% end neqns(...)

function out = ninputs(DAE)
	out = 0; 
% end ninputs(...)

function out = noutputs(DAE)
	out = 0; % all state vars
% end noutputs(...)

function out = nparms(DAE)
	out = 8*DAE.nstages; % VDD, betaN, betaP, VtN, VtP, RdsN, RdsP, CL
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not modelled yet
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('floating CMOS inverter chain with %d stages', DAE.nstages);
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	for i = 0:DAE.nstages
		out{i+1} = sprintf('e%d', i);
	end
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	for i = 0:DAE.nstages
		out{i+1} = sprintf('KCL%d', i);
	end
% end eqnnames()

function out = inputnames(DAE)
	out = {};
% end inputnames()

function out = outputnames(DAE)
	out = unknames_DAEAPI(DAE);
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	for i = 1:DAE.nstages
		out{8*(i-1)+1} = sprintf('VDD%d', i);
		out{8*(i-1)+2} = sprintf('betaN%d', i);
		out{8*(i-1)+3} = sprintf('betaP%d', i);
		out{8*(i-1)+4} = sprintf('VtN%d', i);
		out{8*(i-1)+5} = sprintf('VtP%d', i);
		out{8*(i-1)+6} = sprintf('RdsN%d', i);
		out{8*(i-1)+7} = sprintf('RdsP%d', i);
		out{8*(i-1)+8} = sprintf('CL%d', i);
	end
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	for i = 1:DAE.nstages
		parmvals{8*(i-1)+1} = DAE.VDDs(i);
		parmvals{8*(i-1)+2} = DAE.betaNs(i);
		parmvals{8*(i-1)+3} = DAE.betaPs(i);
		parmvals{8*(i-1)+4} = DAE.VtNs(i);
		parmvals{8*(i-1)+5} = DAE.VtPs(i);
		parmvals{8*(i-1)+6} = DAE.RdsNs(i);
		parmvals{8*(i-1)+7} = DAE.RdsPs(i);
		parmvals{8*(i-1)+8} = DAE.CLs(i);
	end
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	% u(t) = Vin(t)
	% n1 KCL: d/dt(CL*e1) + SH_ID_N(VGS=Vin,VDS=e1) + SH_ID_P(VGS=-(VDD-Vin), VDS=-(VDD-e1)) + e1/RDSn - (VDD-e1)/RDSp = 0.
	% ni KCL, 1<i<nstages: d/dt(CL*ei) + SH_ID_N(VGS=eim1,VDS=ei) + SH_ID_P(VGS=-(VDD-eim1), VDS=-(VDD-ei)) + ei/RDSn - (VDD-ei)/RDSp = 0.

	for i=1:DAE.nstages
		eim1 = x(i);
		ei = x(i+1);

		%for i = 1:DAE.nstages
		%	parmvals{8*(i-1)+1} = DAE.VDDs(i);
		%	parmvals{8*(i-1)+2} = DAE.betaNs(i);
		%	parmvals{8*(i-1)+3} = DAE.betaPs(i);
		%	parmvals{8*(i-1)+4} = DAE.VtNs(i);
		%	parmvals{8*(i-1)+5} = DAE.VtPs(i);
		%	parmvals{8*(i-1)+6} = DAE.RdsNs(i);
		%	parmvals{8*(i-1)+7} = DAE.RdsPs(i);
		%	parmvals{8*(i-1)+8} = DAE.CLs(i);
		%end
		[VDD, betaN, betaP, VTN, VTP, rDSN, rDSP, CL] = deal(DAE.parms{8*(i-1)+1:8*i});

		NMOS = DSintSH_Ntype; % device object with function handles
		PMOS = DSintSH_Ptype; % device object with function handles

		IDN = feval(NMOS.f, eim1, ei, betaN, VTN);
		IDP = feval(PMOS.f, -(VDD-eim1), -(VDD-ei), betaP, VTP);

		fout(i+1,1) = IDN + IDP + ei/rDSN - (VDD-ei)/rDSP;
	end
	% i = 0 KCL
	fout(1,1) = 0; % doing this last so that vecvalder works right
% end f(...)

function qout = q(x, DAE)
	% ni KCL, 1<i<nstages: d/dt(CL*ei) + SH_ID_N(VGS=eim1,VDS=ei) + SH_ID_P(VGS=-(VDD-eim1), VDS=-(VDD-ei)) + ei/RDSn - (VDD-ei)/RDSp = 0.
	% i = 0 KCL
	for i=1:DAE.nstages
		CL = DAE.parms{8*i};
		ei = x(i+1);
		qout(i+1,1) = CL*ei;
	end
	qout(1,1) = 0;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)
	% u(t) = Vin(t)
	% n1 KCL: d/dt(CL*e1) + SH_ID_N(VGS=Vin,VDS=e1) + SH_ID_P(VGS=-(VDD-Vin), VDS=-(VDD-e1)) + e1/RDSn - (VDD-e1)/RDSp = 0.
	% ni KCL, 1<i<nstages: d/dt(CL*ei) + SH_ID_N(VGS=eim1,VDS=ei) + SH_ID_P(VGS=-(VDD-eim1), VDS=-(VDD-ei)) + ei/RDSn - (VDD-ei)/RDSp = 0.

	for i=1:DAE.nstages
		eim1 = x(i);
		ei = x(i+1);

		%for i = 1:DAE.nstages
		%	parmvals{8*(i-1)+1} = DAE.VDDs(i);
		%	parmvals{8*(i-1)+2} = DAE.betaNs(i);
		%	parmvals{8*(i-1)+3} = DAE.betaPs(i);
		%	parmvals{8*(i-1)+4} = DAE.VtNs(i);
		%	parmvals{8*(i-1)+5} = DAE.VtPs(i);
		%	parmvals{8*(i-1)+6} = DAE.RdsNs(i);
		%	parmvals{8*(i-1)+7} = DAE.RdsPs(i);
		%	parmvals{8*(i-1)+8} = DAE.CLs(i);
		%end
		[VDD, betaN, betaP, VTN, VTP, rDSN, rDSP, CL] = deal(DAE.parms{8*(i-1)+1:8*i});

		NMOS = DSintSH_Ntype; % device object with function handles
		PMOS = DSintSH_Ptype; % device object with function handles

		[IDN, dIDN_dVGS, dIDN_dVDS] = feval(NMOS.f, eim1, ei, betaN, VTN);
		[IDP, dIDP_dVGS, dIDP_dVDS] = feval(PMOS.f, -(VDD-eim1), -(VDD-ei), betaP, VTP);
		%fout(i+1,1) = IDN + IDP + ei/rDSN - (VDD-ei)/rDSP;
		Jf(i+1,i+1) = dIDN_dVDS + dIDP_dVDS + 1/rDSN + 1/rDSP;
		Jf(i+1,i) = dIDN_dVGS + dIDP_dVGS;
	end
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	% ni KCL, 1<i<nstages: d/dt(CL*ei) + SH_ID_N(VGS=eim1,VDS=ei) + SH_ID_P(VGS=-(VDD-eim1), VDS=-(VDD-ei)) + ei/RDSn - (VDD-ei)/RDSp = 0.
	for i=1:DAE.nstages
		CL = DAE.parms{8*i};
		Jq(i+1,i+1) = CL;
	end
% end dq_dx(...)

function dfdu = df_du(x, u, DAE)
	dfdu = [];
% end df_du(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
	out = ones(DAE.nstages+1,1)*0.5;
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx; % no limiting
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	error('inverterchain_floating: NoiseStationaryComponentPSDmatrix not supported yet');
	m = nNoiseSources(DAE);
	out = speye(m);
	% unit PSDs; all the action is moved to m(x,n)
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% NOTE: m should be for one-sided PSDs
	% M is of size neqns. n is of size nNoiseSources
	%
	ne = neqns(DAE);
	out = zeros(ne,1);
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	nu = nunks(DAE);
	ne = neqns(DAE);
	Jm = sparse(ne,nu);
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
	% M is of size neqns. n is of size nNoiseSources
	% NOTE: M should be for one-sided PSDs
	%
	error('inverterchain_floating: dm_dn not supported yet');
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
