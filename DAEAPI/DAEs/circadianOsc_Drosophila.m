function DAE = circadianOsc_Drosophila(uniqIDstr) % DAEAPIv6.2+delta
%function DAE = circadianOsc_Drosophila(uniqIDstr) % DAEAPIv6.2+delta
% Model for Circadian Oscillations in the Drosophila Period Protein
%author: J. Roychowdhury, 2012/06/14
%	- based on code originally written by Shatam Agarwal, summer 2007
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The System:
%
% See "A Model for Circadian Oscillations in the Drosophila Period Protein (PER)"
% by Albert Goldbeter, published in
% Proceedings: Biological Sciences, Vol. 261, No. 1362 (Sep. 22, 1995), pp 319-324.
% Available electronically at www.jstor.org
%
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
	DAE.Usage = help('circadianOsc_Drosophila');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff
	DAE.nameStr = sprintf('Goldbeter Drosophila circadian model');
	DAE.unknameList = {'Mp', 'P0', 'P1', 'P2', 'Pn'}; % Mp is PER mRNA
	DAE.eqnnameList = strcat({'d/dt['}, DAE.unknameList, {']'});
	DAE.inputnameList = {};
	DAE.outputnameList = DAE.unknameList;

	DAE.parmnameList = {...
		'KI', ...
		'n'  , ...
		'vs', ...
		'vm', ...
		'Km', ...
		'ks', ...
		'V1', ...
		'K1', ...
		'V2', ...
		'K2', ...
		'V3', ...
		'K3', ...
		'V4', ...
		'K4', ...
		'vd', ...
		'Kd', ...
		'k1', ...
		'k2', ...
	};


	%{ Where did Shatam get these?
	DAE.parm_defaults = {...
		2,   ...	% Ki = 2;
		4,   ...	% n =  4;
		0.5, ...	% vs = 0.5;
		0.3, ...	% vm = 0.3;
		0.2, ...	% Km = 0.2;
		2.0, ...	% ks = 2.0;
		6.0, ...	% v1 = 6.0;
		1.5, ...	% K1 = 1.5;
		3.0, ...	% v2 = 3.0;
		2.0, ...	% K2 = 2.0;
		6.0, ...	% v3 = 6.0;
		1.5, ...	% K3 = 1.5;
		3.0, ...	% v4 = 3.0;
		2.0, ...	% K4 = 2.0;
		1.5, ...	% vd = 1.5;
		0.1, ...	% Kd = 0.1;
		2.0, ...	% k1 = 2.0;
		1.0, ...        % k2 = 1.0;
	};
	%}

	% Parameters from Figure 2 of Goldbeter's paper
	DAE.parm_defaults = {...
		1,   ...	% KI = 1 uMole;
		4,   ...	% n =  4;
		0.76,...	% vs = 0.76 uMole/hr;
		0.65,...	% vm = 0.65 uMole/hr;
		0.5, ...	% Km = 0.5 uMole;
		0.38,...	% ks = 0.38/hr;
		3.2, ...	% V1 = 3.2 uMole/hr;
		2,   ...	% K1 = 2 uMole;
		1.58, ...	% V2 = 1.58 uMole/hr;
		2.0, ...	% K2 = 2 uMole;
		5.0, ...	% V3 = 5.0 uMole/hr;
		2.0, ...	% K3 = 2 uMole;
		2.5, ...	% V4 = 2.5 uMole/hr;
		2.0, ...	% K4 = 2 uMole;
		0.95, ...	% vd = 0.95 uMole/hr;
		0.2, ...	% Kd = 0.2 uMole;
		1.9, ...	% k1 = 1.9/hr;
		1.3, ...        % k2 = 1.3/hr;
	};

	DAE.parms = DAE.parm_defaults;
	%
	DAE.uQSSvec = [];
	DAE.utfunc = @(t, args) [];
	DAE.utargs = [];
	DAE.uHBfunc = @(f, args) [];
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
	DAE.df_dp = @df_dp;
	%
% input-related functions
% output-related functions
	% what makes sense here for transient, LTISSS, etc.?
	DAE.C = @C;
	DAE.D = @D;
	%
% names
	DAE.time_units = 'hour';
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
	%{
	% create variables of the same names as the unknowns and assign
	% them the values in x
	unknames = feval(DAE.unknames,DAE);
	for i = 1:feval(DAE.nunks,DAE)
		evalstr = sprintf('%s = x(i,1);', unknames{i});
		eval(evalstr);
	end
	%}

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = feval(DAE.parmnames, DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	fout(1,1) = vs*(KI^n)/((KI^n)+(x(5)^n)) - vm*x(1)/(Km+x(1));
	fout(2,1) = ks*x(1) - V1*x(2)/(K1+x(2)) + V2*x(3)/(K2+x(3));
	fout(3,1) = V1*x(2)/(K1+x(2)) - V2*x(3)/(K2+x(3)) -  V3*x(3)/(K3+x(3)) + V4*x(4)/(K4+x(4));
	fout(4,1) = k2*x(5) - k1*x(4) + V3*x(3)/(K3+x(3)) - V4*x(4)/(K4+x(4))  - vd*x(4)/(Kd+x(4));
	fout(5,1) = k1*x(4) - k2*x(5);
end
% end f(...)

function qout = q(x, DAE)
	qout = -x;
end
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	Jf = zeros(5,5);
	Jf(1,1) = -vm*Km/((Km+x(1))^2);
	Jf(1,5) = -vs*(KI^n)*n*(x(5)^(n-1))/(((KI^n)+(x(5)^n))^2);
	Jf(2,1) = ks;
	Jf(2,2) = -V1*K1/((K1+x(2))^2);
	Jf(2,3) = V2*K2/((K2+x(3))^2);
	Jf(3,2) = V1*K1/((K1+x(2))^2);
	Jf(3,3) = -V2*K2/((K2+x(3))^2) - V3*K3/((K3+x(3))^2);
	Jf(3,4) = V4*K4/((K4+x(4))^2);
	Jf(4,3) = V3*K3/((K3+x(3))^2);
	Jf(4,4) = -V4*K4/((K4+x(4))^2) -vd*Kd/((Kd+x(4))^2) - k1;
	Jf(4,5) = k2;
	Jf(5,4) = k1;
	Jf(5,5) = -k2;

	Jf = sparse(Jf);
end
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	Jq = -eye(5);
end
% end dq_dx(...)

function dfdu = df_du(x, u, DAE)
	%{
	eC = x(1); iL = x(2); 
	Iin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end
	%}
	dfdu = sparse(5,0);
end
% end df_du(...)

function dfdp = df_dp(x, u, DAE)
	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end

	dfdp = zeros(5,18);
	dfdp(1,1) = vs*x(5)^n*n*KI^(n-1)/((KI^n+x(5)^n)^2);
	dfdp(1,3) = KI^n/(KI^n+x(5)^n);
	dfdp(1,4) = -x(1)/(Km+x(1));
	dfdp(1,5) = vm*x(1)/((Km+x(1))^2);
	dfdp(2,6) = x(1);
	dfdp(2,7) = -x(2)/(K1+x(2));
	dfdp(2,8) = V1*x(2)/((K1+x(2))^2);
	dfdp(2,9) = x(3)/(K2+x(3));
	dfdp(2,10) = -V2*x(3)/((K2+x(3))^2);
	dfdp(3,7) = x(2)/(K1+x(2));
	dfdp(3,8) = -V1*x(2)/((K1+x(2))^2);
	dfdp(3,9) = -x(3)/(K2+x(3));
	dfdp(3,10) = V2*x(3)/((K2+x(3))^2);
	dfdp(3,11) = -x(3)/(K3+x(3));
	dfdp(3,12) = V3*x(3)/((K3+x(3))^2);
	dfdp(3,13) = x(4)/(K4+x(4));
	dfdp(3,14) = -V4*x(4)/((K4+x(4))^2);
	dfdp(4,11) = x(3)/(K3+x(3));
	dfdp(4,12) = -V3*x(3)/((K3+x(3))^2);
	dfdp(4,13) = -x(4)/(K4+x(4));
	dfdp(4,14) = V4*x(4)/((K4+x(4))^2);
	dfdp(4,15) = -x(4)/(Kd+x(4));
	dfdp(4,16) = vd*x(4)/((Kd+x(4))^2);
	dfdp(4,17) = -x(4);
	dfdp(4,18) = x(5);
	dfdp(5,17) = x(4);
	dfdp(5,18) = -x(5);
end % df_dp

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = eye(5);
end
% end C(...)

function out = D(DAE)
	out = sparse(5,0);
end
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	% x = [eCL; eCR; eE];
	out = zeros(5,1);
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
