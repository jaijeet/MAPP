function DAE = BJTdiffpair_DAEAPIv6(uniqIDstr) % DAEAPIv6.2+delta
% function DAE = BJTdiffpair_DAEAPIv6(uniqIDstr) % DAEAPIv6.2+delta
% An ideal-ish differential pair using Ebers-Moll BJTs. 
%author: J. Roychowdhury, 2011/09/26
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% An ideal-ish differential pair using Ebers-Moll BJTs. The emitters of 2 N-type BJTs are
% connected at node nE (node voltage eE). An ideal current source of DC value IE
% drains node E. The collector of the BJT on the left is connected
% to node nCL (node voltage eCL); that of the one on the right to node nCR (node
% voltage eCR). Resistors rL and rR connect from VDD to nodes nCL and nCR,
% respectively; similarly with capacitors CL and CR. 
%
% The BJT on the left has its base connected to Vin; that of the one on the right 
% connects to ground. The circuit is, therefore, not perfectly symmetric. This
% lack of symmetry shows up in different DC components at the two output nodes when HB is run
% with large Vin, and exacerbated if you use an insufficient number of harmonics.
%
% Equation system: Not strict MNA, because the VDD and Vin node voltage unknowns have been
% eliminated, leading to a smaller system of equations, of size 3.
%
% Unknowns: x = [eCL; eCR; eE].
%
% Equations:
% CL KCL: - d/dt(CL*(VDD-eCL)) -(VDD-eCL)/rL + left_BJT_IC(Vin-eE, eCL-eE);
% CR KCL: - d/dt(CR*(VDD-eCR)) -(VDD-eCR)/rR + right_BJT_IC(0-eE, eCR-eE);
% E  KCL: IE - left_BJT_IC(Vin-eE, eCL-eE) - left_BJT_IB(Vin-eE, eCL-eE)
%	  - right_BJT_IC(0-eE, eCR-eE) - right_BJT_IB(0-eE, eCR-eE);
% 
% The (single) input is Vin. A DC/QSS input of 0V has been put in. You can change
% it by calling DAE.set_uQSS(...).
%
% The (single) output is Vout = eCL - eCR.
%
% Note that since we cannot represent the effect of Vin as
% an additive input, we set the flag DAE.f_takes_inputs to 1. This means
% that f() becomes a function of 2 arguments: f(x,u). Similarly with df_dx.
% DAE.B(...) is not used when DAE.f_takes_inputs == 1.
%
% the DAE is: qdot(x) + f(x, u(t))  = 0.
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
%2013/09/27: Tianshi Wang <tianshi@berkeley.edu>: init/limiting related updates
%2011/09/26: Jaijeet Roychowdhury <jr@berkeley.edu>



%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string, ID: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('BJTdiffpair_DAEAPIv6');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff
	DAE.nameStr = sprintf('Diffpair with Ebers-Moll BJTs');
	DAE.unknameList = {'eCL', 'eCR', 'eE', 'vIN'};
	DAE.eqnnameList = {'CL_KCL', 'CR_KCL', 'E_KCL', 'IN_KVL'};
	DAE.inputnameList = {'Vin'};
	DAE.outputnameList = {'Vout=eCL-eCR'};

	DAE.parmnameList = setup_parmnames(DAE);
	DAE.parms = parmdefaults(DAE);
	%
	DAE.uQSSvec = 0.0; % 0V DC input
	DAE.uHBfunc = @(f, args) args.A*[0, 0.5, 0.5]; % cos(2*pi*f*t) F. coeffs in standard FFT order, M=1 <=> N=3
	uHBargs.A = 1;
	DAE.uHBargs = uHBargs;
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
	%
% QSS initial guess support
	% DAE.NRinitGuess = @NRinitGuess;
	%
% NR limiting support
	% DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	DAE.parmdefaults  = @parmdefaults;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp;
	%DAE.dq_dp  = @dq_dp;
	% data: current values of parameters, can be changed by setparms
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
%parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	% VDD, IE, rL, rR, CL, CR, {QL,QR}.{IsF, VtF, IsR, VtR, alphaF, alphaR}
	out = {'VDD', 'IE', 'rL', 'rR', 'CL', 'CR'};
	i = 7;
	Qs = {'QL', 'QR'};
	Qparms = {'IsF', 'VtF', 'IsR', 'VtR', 'alphaF', 'alphaR'};
	for j = 1:length(Qs)
		for k = 1:length(Qparms)
			out{i} = sprintf('%s_%s', Qs{j}, Qparms{k});
			i = i+1;
		end
	end
% end parmnames()

%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	%order: VDD, IE, rL, rR, CL, CR, {QL,QR}.{IsF, VtF, IsR, VtR, alphaF, alphaR}
	parmvals = {5, 2e-3, 2000, 2000, 1e-6, 1e-6};
	i = 7;
	Qs = {'QL', 'QR'};
	%Qparms = {'IsF', 'VtF', 'IsR', 'VtR', 'alphaF', 'alphaR'};
	Qparmvals = {1e-12, 0.025, 1e-12, 0.025, 0.99, 0.5};
	for j = 1:length(Qs)
		for k = 1:length(Qparmvals)
			parmvals{i} = Qparmvals{k};
			i = i+1;
		end
	end
% end parmdefaults(...)


%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	eCL = x(1); eCR = x(2); eE = x(3); eIN = x(4);
	Vin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	NBJT = EbersMoll_BJT;
	% CL KCL: -(VDD-eCL)/rL + left_BJT_IC(Vin-eE, eCL-eE);
	[QL_IC, QL_IB] = feval(NBJT.f, Vin-eE, eCL-eE, QL_IsF, QL_VtF, QL_IsR, QL_VtR, QL_alphaF, QL_alphaR);
	fout(1,1) = -(VDD-eCL)/rL + QL_IC;

	% CR KCL: -(VDD-eCR)/rR + right_BJT_IC(0-eE, eCR-eE);
	[QR_IC, QR_IB] = feval(NBJT.f, -eE, eCR-eE, QR_IsF, QR_VtF, QR_IsR, QR_VtR, QR_alphaF, QR_alphaR);
	fout(2,1) = -(VDD-eCR)/rR + QR_IC;

	% E  KCL: IE - left_BJT_IC(Vin-eE, eCL-eE) - left_BJT_IB(Vin-eE, eCL-eE)
	%	  - right_BJT_IC(0-eE, eCR-eE) - right_BJT_IB(0-eE, eCR-eE);
	fout(3,1) = IE - QL_IC - QL_IB - QR_IC - QR_IB;
	fout(4,1) = eIN - Vin;
% end f(...)

function qout = q(x, DAE)
	eCL = x(1); eCR = x(2); eE = x(3);

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end
	% CL KCL: - d/dt(CL*(VDD-eCL)) -(VDD-eCL)/rL + left_BJT_IC(Vin-eE, eCL-eE);
	qout(1,1) = -CL*(VDD-eCL);

	% CR KCL: - d/dt(CR*(VDD-eCR)) -(VDD-eCR)/rR + right_BJT_IC(0-eE, eCR-eE);
	qout(2,1) = -CR*(VDD-eCR);

	qout(3,1) = 0;
	qout(4,1) = 0;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)
	eCL = x(1); eCR = x(2); eE = x(3); eIN = x(4);
	Vin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	NBJT = EbersMoll_BJT;
	% CL KCL: -(VDD-eCL)/rL + left_BJT_IC(Vin-eE, eCL-eE);
	%                                      VBE      VCE
	%
	[QL_IC, QL_IB, dQL_IC_dVBE, dQL_IC_dVCE, dQL_IB_dVBE, dQL_IB_dVCE] = ...
		feval(NBJT.f, Vin-eE, eCL-eE, QL_IsF, QL_VtF, QL_IsR, QL_VtR, QL_alphaF, QL_alphaR);
	%fout(1) = -(VDD-eCL)/rL + QL_IC;
	%
	% x:	eCL	eCR	eE
	%	1	2	3
	Jf(1,1) = 1/rL + dQL_IC_dVCE; % HW3: FILL THIS IN
	Jf(1,2) = 0; % HW3: FILL THIS IN
	Jf(1,3) = - dQL_IC_dVBE - dQL_IC_dVCE; % HW3: FILL THIS IN

	% CR KCL: -(VDD-eCR)/rR + right_BJT_IC(0-eE, eCR-eE);
	%                                      VBE      VCE
	%
	[QR_IC, QR_IB, dQR_IC_dVBE, dQR_IC_dVCE, dQR_IB_dVBE, dQR_IB_dVCE] = ...
		feval(NBJT.f, -eE, eCR-eE, QR_IsF, QR_VtF, QR_IsR, QR_VtR, QR_alphaF, QR_alphaR);
	%fout(2,1) = -(VDD-eCR)/rR + QR_IC;
	%
	% x:	eCL	eCR	eE
	%	1	2	3
	Jf(2,1) =  0; 
	Jf(2,2) =  1/rR + dQR_IC_dVCE; 
	Jf(2,3) = - dQR_IC_dVBE - dQR_IC_dVCE; 

	% E  KCL: IE - left_BJT_IC(Vin-eE, eCL-eE) - left_BJT_IB(Vin-eE, eCL-eE)
	%                           VBE      VCE                  VBE      VCE
	%
	%	  - right_BJT_IC(0-eE, eCR-eE) - right_BJT_IB(0-eE, eCR-eE);
	%                         VBE    VCE                   VBE    VCE
	%
	%fout(3,1) = IE - QL_IC - QL_IB - QR_IC - QR_IB;
	%
	% x:	eCL	eCR	eE
	%	1	2	3
	Jf(3,1) =  - dQL_IC_dVCE - dQL_IB_dVCE; % HW3: FILL THIS IN
	Jf(3,2) =  - dQR_IC_dVCE - dQR_IB_dVCE; % HW3: FILL THIS IN
	Jf(3,3) =  dQL_IC_dVBE + dQL_IC_dVCE + dQL_IB_dVBE + dQL_IB_dVCE ...
		   + dQR_IC_dVBE + dQR_IC_dVCE + dQR_IB_dVBE + dQR_IB_dVCE; % HW3: FILL THIS IN

	Jf(4,4) = 1; 
% end df_dx(...)

function Jq = dq_dx(x, DAE)

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end
	Jq = zeros(feval(DAE.neqns,DAE),feval(DAE.nunks,DAE));
	% CL KCL: - d/dt(CL*(VDD-eCL)) -(VDD-eCL)/rL + left_BJT_IC(Vin-eE, eCL-eE);
	Jq(1,1) = CL;
	% CR KCL: - d/dt(CR*(VDD-eCR)) -(VDD-eCR)/rR + right_BJT_IC(0-eE, eCR-eE);
	Jq(2,2) = CR;

% end dq_dx(...)

function dfdu = df_du(x, u, DAE)
	eCL = x(1); eCR = x(2); eE = x(3); eIN = x(4);
	Vin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	NBJT = EbersMoll_BJT;

	% CL KCL: -(VDD-eCL)/rL + left_BJT_IC(Vin-eE, eCL-eE);
	%                                      VBE      VCE
	%
	[QL_IC, QL_IB, dQL_IC_dVBE, dQL_IC_dVCE, dQL_IB_dVBE, dQL_IB_dVCE] = ...
		feval(NBJT.f, Vin-eE, eCL-eE, QL_IsF, QL_VtF, QL_IsR, QL_VtR, QL_alphaF, QL_alphaR);
	%fout(1) = -(VDD-eCL)/rL + QL_IC;
	%
	% u:	Vin
	%	1
	dfdu(1,1) = dQL_IC_dVBE;

	% CR KCL: -(VDD-eCR)/rR + right_BJT_IC(0-eE, eCR-eE);
	%                                      VBE      VCE
	%
	[QR_IC, QR_IB, dQR_IC_dVBE, dQR_IC_dVCE, dQR_IB_dVBE, dQR_IB_dVCE] = ...
		feval(NBJT.f, -eE, eCR-eE, QR_IsF, QR_VtF, QR_IsR, QR_VtR, QR_alphaF, QR_alphaR);
	%fout(2,1) = -(VDD-eCR)/rR + QR_IC;
	%
	% u:	Vin
	%	1
	dfdu(2,1) =  0;

	% E  KCL: IE - left_BJT_IC(Vin-eE, eCL-eE) - left_BJT_IB(Vin-eE, eCL-eE)
	%                           VBE      VCE                  VBE      VCE
	%
	%	  - right_BJT_IC(0-eE, eCR-eE) - right_BJT_IB(0-eE, eCR-eE);
	%                         VBE    VCE                   VBE    VCE
	%
	%fout(3,1) = IE - QL_IC - QL_IB - QR_IC - QR_IB;
	%
	% u:	Vin
	%	1
	dfdu(3,1) =  - dQL_IC_dVBE - dQL_IB_dVBE;
	dfdu(4,1) =  - 1;
% end df_du(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = [1 -1 0 0]; % Vout = eCL - eCR
% end C(...)

function out = D(DAE)
	out = 0;
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	% x = [eCL; eCR; eE];
	out = [3; 3; -0.7; 0];
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
