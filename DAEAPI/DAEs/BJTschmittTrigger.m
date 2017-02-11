function DAE = BJTschmittTrigger(uniqIDstr) % DAEAPIv6.2+delta
%function DAE = BJTschmittTrigger(uniqIDstr) % DAEAPIv6.2+delta
% A BJT Schmitt trigger circuit.
% See 2011-11-23-Note-22-22_schmitt_trigger.xoj.
%author: J. Roychowdhury, 2011/11/23
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% A BJT Schmitt trigger circuit. See 2011-11-23-Note-22-22_schmitt_trigger.xoj.
%
% Equation system: Not strict MNA, because the VCC and Vin node voltage unknowns have been
% eliminated, leading to a smaller system of equations, of size 4.
%
% Unknowns: x = [e1; e2; e3; e4].
%
% Equations:
% KCL1: (e1 - VCC)/RC1 + (e1-e3)/RD1 + IC_Q1(VBE=Vin-e2, VCE=e1-e2) + d/dt (C1*(e1-VCC)) = 0
% KCL2: e2/RE - IE_Q1(VBE=Vin-e2, VCE=e1-e2) - IE_Q2(VBE=e3-e2, VCE=e4-e2) = 0
% KCL3: (e3-31)/RD1 + e3/RD2 + IB_Q2(VBE=e3-e2, VCE=e4-e2) = 0
% KCL4: (e4-VCC)/RC2 + IC_Q2(VBE=e3-e2, VCE=e4-e2) + d/dt (C2*(e4-VCC)) = 0
% 
% The (single) input is Vin. A DC/QSS input of 0V has been put in. You can change
% it by calling DAE.set_uQSS(...).
%
% The (single) output is Vout = e4
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







%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string, ID: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('BJTschmittTrigger');
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
	DAE.parms = parmdefaults(DAE);
	%
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
	DAE.df_dx = @df_dx_DAEAPI_auto;
	DAE.dq_dx = @dq_dx_DAEAPI_auto;
	DAE.df_du = @df_du_DAEAPI_auto;
	%
% input-related functions
	% discontinued: DAE.b = @btransient; DAE.bQSS; DAE.bLTISSS; 
	%
	DAE.B = @B;
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
	DAE.getparms  = @default_getparms_DAE;
	DAE.setparms  = @default_setparms_DAE;
	% first derivatives with respect to parameters - for sensitivities
	DAE.df_dp  = @df_dp_DAEAPI_auto;
	DAE.dq_dp  = @dq_dp_DAEAPI_auto;
	% data: current values of parameters, can be changed by setparms
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

% set DC input
	DAE = feval(DAE.set_uQSS, 'Vin', 2.0, DAE); %  DC input
% set transient input
	utargs = [];
	utfunc = @(t, args) 0.5 + (2.5-0.5)*pulse(t/1e-4, 0.1, 0.4, 0.5, 0.9);
	DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = 4;
% end nunks(...)

function out = neqns(DAE)
	out = 4;
% end neqns(...)

function out = ninputs(DAE)
	out = 1; % Vin
% end ninputs(...)

function out = noutputs(DAE)
	out = 1; % Vout = e4
% end noutputs(...)

function out = nparms(DAE)
	out = 20; % VCC, RC1, RE, RD1, RD2, RC2, C1, C2, {Q1,Q2}.{IsF, VtF, IsR, VtR, alphaF, alphaR}
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('BJT Schmitt Trigger');
% end daename()

%unknames is in unknames.m
function out = setup_unknames(DAE)
	out = {'e1', 'e2', 'e3', 'e4'};
% end unknames()

%eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out = {'KCL1', 'KCL2', 'KCL3', 'KCL4'};
% end eqnnames()

function out = inputnames(DAE)
	out = {'Vin'};
% end inputnames()

function out = outputnames(DAE)
	out = {'Vout=e4'};
% end outputnames()

%parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	% VCC, RC1, RE, RD1, RD2, RC2, C1, C2 {Q1,Q2}.{IsF, VtF, IsR, VtR, alphaF, alphaR}
	out = {'VCC', 'RC1', 'RE', 'RD1', 'RD2', 'RC2', 'C1', 'C2'};
	i = 9;
	Qs = {'Q1', 'Q2'};
	Qparms = {'IsF', 'VtF', 'IsR', 'VtR', 'alphaF', 'alphaR'};
	for j = 1:length(Qs)
		for k = 1:length(Qparms)
			out{i} = sprintf('%s_%s', Qs{j}, Qparms{k});
			i = i+1;
		end
	end
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	%order: VCC, RC1, RE, RD1, RD2, RC2, C1, C2, {Q1,Q2}.{IsF, VtF, IsR, VtR, alphaF, alphaR}
	parmvals = {5, 500, 100, 100, 300, 500, 1e-8, 1e-8};
	i = 9;
	Qs = {'Q1', 'Q2'};
	%Qparms = {'IsF', 'VtF', 'IsR', 'VtR', 'alphaF', 'alphaR'};
	Qparmvals = {1e-12, 0.025, 1e-12, 0.025, 0.99, 0.5};
	for j = 1:length(Qs)
		for k = 1:length(Qparmvals)
			parmvals{i} = Qparmvals{k};
			i = i+1;
		end
	end
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	e1 = x(1); e2 = x(2); e3 = x(3); e4 = x(4);
	Vin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:nparms(DAE)
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	NBJT = EbersMoll_BJT;
	[Q1_IC, Q1_IB] = feval(NBJT.f, Vin-e2, e1-e2, Q1_IsF, Q1_VtF, Q1_IsR, Q1_VtR, Q1_alphaF, Q1_alphaR);
	Q1_IE = Q1_IC + Q1_IB;
	[Q2_IC, Q2_IB] = feval(NBJT.f, e3-e2, e4-e2, Q2_IsF, Q2_VtF, Q2_IsR, Q2_VtR, Q2_alphaF, Q2_alphaR);
	Q2_IE = Q2_IC + Q2_IB;

	% KCL1: (e1 - VCC)/RC1 + (e1-e3)/RD1 + IC_Q1(VBE=Vin-e2, VCE=e1-e2) = 0
	fout(1,1) = (e1-VCC)/RC1 + (e1-e3)/RD1 + Q1_IC;
	%fout(1,1) = (e1-VCC)/RC1 + Q1_IC;

	% KCL2: e2/RE - IE_Q1(VBE=Vin-e2, VCE=e1-e2) - IE_Q2(VBE=e3-e2, VCE=e4-e2) = 0
	fout(2,1) = e2/RE - Q1_IE - Q2_IE;
	%fout(2,1) = e2/RE - Q1_IE;

	% KCL3: (e3-e1)/RD1 + e3/RD2 + IB_Q2(VBE=e3-e2, VCE=e4-e2) = 0
	fout(3,1) = (e3-e1)/RD1 + e3/RD2 + Q2_IB;
	%fout(3,1) = (e3-Vin)/RD1 + e3/RD2;

	% KCL4: (e4-VCC)/RC2 + IC_Q2(VBE=e3-e2, VCE=e4-e2) = 0
	fout(4,1) = (e4-VCC)/RC2 + Q2_IC;
	%fout(4,1) = (e4-VCC)/RC2;
% end f(...)

function qout = q(x, DAE)
	e1 = x(1); e2 = x(2); e3 = x(3); e4 = x(4);

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:nparms(DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	%qout = sparse(4,4)*x + sparse(4,1)*VCC; % ugly hack for vecvalder

	qout(1,1) = C1*(e1-VCC);
	qout(4,1) = C2*(e4-VCC);
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% done via vecvalder (df_dx_auto, dq_dx_auto and du_dx_auto)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	if (nargin > 1)
	   fprintf(2,'out = B(x, DAE) not supported yet (no tensor support).\n');
	   return;
	end
	out = 1; % but not used
% end B(...)


%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = [0 0 0 1]; % Vout = e4
% end C(...)

function out = D(DAE)
	out = 0;
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	% x = [e1; e2; e3; e4];
	out = [4; u-0.7; u; 4];
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, uold, DAE)
	e1_dx = dx(1); e2_dx = dx(2); e3_dx = dx(3); e4_dx = dx(4);
	e1_old = xold(1); e2_old = xold(2); e3_old = xold(3); e4_old = xold(4);
	Vin_old = uold;

	alpha = 1;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:nparms(DAE)
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	% Q1 forward diode
	Q1forwardDiode_oldx = Vin_old - e2_old;
	Q1forwardDiode_dx = - e2_dx;
	if abs(Q1forwardDiode_dx) > 1.0e-5
		vcrit = Q1_VtF * log(Q1_VtF / (sqrt(2) * Q1_IsF));
		Q1forwardDiode_newdx = pnjlim_dx(Q1forwardDiode_dx, Q1forwardDiode_oldx, Q1_VtF, vcrit);
		alpha = Q1forwardDiode_newdx/Q1forwardDiode_dx;
	end

	% Q1 reverse diode
	Q1reverseDiode_oldx = Vin_old - e1_old;
	Q1reverseDiode_dx = - e1_dx;
	if abs(Q1reverseDiode_dx) > 1.0e-5
		vcrit = Q1_VtR * log(Q1_VtR / (sqrt(2) * Q1_IsR));
		Q1reverseDiode_newdx = pnjlim_dx(Q1reverseDiode_dx, Q1reverseDiode_oldx, Q1_VtR, vcrit);
		alpha = min(Q1reverseDiode_newdx/Q1reverseDiode_dx, alpha);
	end

	% Q2 forward diode
	Q2forwardDiode_oldx = e3_old - e2_old;
	Q2forwardDiode_dx = e3_dx - e2_dx;
	if abs(Q2forwardDiode_dx) > 1.0e-5
		vcrit = Q2_VtF * log(Q2_VtF / (sqrt(2) * Q2_IsF));
		Q2forwardDiode_newdx = pnjlim_dx(Q2forwardDiode_dx, Q2forwardDiode_oldx, Q2_VtF, vcrit);
		alpha = Q2forwardDiode_newdx/Q2forwardDiode_dx;
	end

	% Q2 reverse diode
	Q2reverseDiode_oldx = e3_old - e4_old;
	Q2reverseDiode_dx = e3_dx - e4_dx;
	if abs(Q2reverseDiode_dx) > 1.0e-5
		vcrit = Q2_VtR * log(Q2_VtR / (sqrt(2) * Q2_IsR));
		Q2reverseDiode_newdx = pnjlim_dx(Q2reverseDiode_dx, Q2reverseDiode_oldx, Q2_VtR, vcrit);
		alpha = min(Q2reverseDiode_newdx/Q2reverseDiode_dx, alpha);
	end
	newdx = dx*alpha;
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	% unit PSDs; all the action is moved to m(x,n)
	out = 'undefined';
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
	k = 1.3806503e-23; % Boltzmann's const
	q = 1.60217646e-19; % electronic charge
	T = 300; % Kelvin; absolute temperature FIXME: this should be a parameter

	M = 'undefined';
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
