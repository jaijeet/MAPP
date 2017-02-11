function DAE = LCtanhOsc(uniqIDstr) % DAEAPIv6.2+delta
%function DAE = LCtanhOsc(uniqIDstr) % DAEAPIv6.2+delta
%Negative resistance LC oscillator: a parallel RLC tank, with an nonlinear element with a negative resistance about zero.
%2015/01/07, JR: fixed a scaling bug in Jf: multiplication by iLscaling was missing.
%author: J. Roychowdhury, 2012/06/08, 2012/06/21
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% The equations are for a simple -ve resistance LC oscillator: a parallel
%	RLC tank, with an nonlinear element with a negative resistance
%	about zero.
%
%	the equations are:
%
%	n1 KCL: d/dt (C v_1) + v_1/R + i_L + satval*tanh(Gn/satval*v_1) + Iin(t)= 0
%	inductor KVL: d/dt (L i_L) - v_1 = 0
%
%	f(x,u) for the above is:
%	f(x,u) = [+ v_1/R + i_L + satval*tanh(Gn/satval *  v_1) + Iin(t); ...
%		  - v_1];
%
%	q(x) for the above is:
%	q(x) = [C*v_1; L*i_L];
%
%	Gn should be negative and of absolute value greater than 1/R, for
%	the oscillator to oscillate. satval*R will determine, roughly, the
%	amplitude of oscillation.
%
%	Iin(t) is an external input used to perturb the oscillator (eg, for
%	injection locking).
%
% the DAE is: d/dt[q(x)] + f(x, u(t))  = 0.
%
% the outputs are: y(t) = C*x(t) + D*u(t)
%
% see 0_DAEAPIv6_doc.m for a description of the functions here.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
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
	DAE.Usage = help('LCtanhOsc');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff
	DAE.nameStr = sprintf('LC oscillator with tanh negative resistor');
	DAE.unknameList = {'eC', 'iL'};
	DAE.eqnnameList = {'n1-KCL', 'L-KVL'};
	DAE.inputnameList = {'Iin'};
	DAE.outputnameList = {'eC', 'iL'};

	DAE.parmnameList = {'L', 'CAP', 'R', 'Gn', 'satval', 'iLscaling', 'KCLscaling'};
		% be careful, especially, not to use names already defined for DAEAPI -
		% in particular B, C, and D are DAEAPI functions.
	R = 100;
	%Gn = -3 * 1/R; %more nonlinear
	epsilon = 0.1; % if epsilon is > 0, it will have a non-zero limit cycle
	Gn = -(1+epsilon) * 1/R;
	satval = 1/R;
	%DAE.parm_defaults = {4.869e-7/2/pi, 2e-12/2/pi, R, Gn, satval, 1e-3, 1e3}; 
	DAE.parm_defaults = {4.869e-7/2/pi, 2e-12/2/pi, R, Gn, satval, 1, 1}; 
		% L/C chosen for about 1G osc frequency
	DAE.parms = DAE.parm_defaults;
	%
	DAE.uQSSvec = 0.0; % Iin = 0
	DAE.utfunc = @(t, args) 0;
	DAE.utargs = [];
	DAE.uHBfunc = @(f, args) [0];
	DAE.uHBargs = [];
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
	DAE.D = @D;
	%
% names
	%
% QSS initial guess support
	DAE.QSSinitGuess = @QSSinitGuess;
	%
% NR limiting support
	DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	%DAE.parmdefaults  = @parmdefaults;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp;
	%DAE.dq_dp  = @dq_dp;
	% data: current values of parameters, can be changed by setparms
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
%
end
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	eC = x(1); iL = x(2);
	Iin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = feval(DAE.parmnames, DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	fout(1,1) = KCLscaling*(eC/R + iL*iLscaling + satval*tanh(Gn/satval * eC) + Iin);
	fout(2,1) = -eC;
end
% end f(...)

function qout = q(x, DAE)
	eC = x(1); iL = x(2);

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = feval(DAE.parmnames, DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	qout(1,1) = KCLscaling*CAP*eC;
	qout(2,1) = L*iL*iLscaling;
end
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)
	eC = x(1); iL = x(2);
	Iin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = feval(DAE.parmnames, DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	Jf(1,1) = KCLscaling*(1/R + Gn*dtanh(Gn/satval * eC));
	Jf(1,2) = KCLscaling*iLscaling*1;
	Jf(2,1) = - 1;
	Jf(2,2) = 0;
	Jf = sparse(Jf);
end
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = feval(DAE.parmnames, DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	Jq = sparse(diag([KCLscaling*CAP,L*iLscaling]));
end
% end dq_dx(...)

function dfdu = df_du(x, u, DAE)
	%{
	eC = x(1); iL = x(2); 
	Iin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = feval(DAE.parmnames, DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end
	%}

	dfdu(1,1) = 1;
	dfdu(2,1) = 0;
	dfdu = sparse(dfdu);
end
% end df_du(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = eye(2);
end
% end C(...)

function out = D(DAE)
	out = sparse(2,1);
end
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	% x = [eCL; eCR; eE];
	out = zeros(feval(DAE.nunks,DAE),1);
end
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx;
end
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	m = nNoiseSources(DAE);
	out = speye(m);
	% unit PSDs; all the action is moved to m(x,n)
end
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% NOTE: m should be for one-sided PSDs
	% M is of size neqns. n is of size nNoiseSources
	%
	M = dm_dn(x,n,DAE);
	out = M*n;
end
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	n = nunks(DAE);
	Jm = sparse([]);
	Jm(n,n) = 0;
end
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
end
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs = 'No internal functions exposed by this DAE system.';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
end
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
