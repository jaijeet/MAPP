function DAE = coupledRCdiodeSpringsMasses(uniqIDstr)  % DAEAPIv6.2
%function DAE = coupledRCdiodeSpringsMasses(uniqIDstr)  % DAEAPIv6.2
% A vsrc-R-C-diode system, bidirectionally coupled with a system of 2 springs and 2 masses.
%author: J. Roychowdhury, 2011/11/01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The System: an vsrc-R-C-diode system, bidirectionally coupled
%	with a system of 2 springs and 2 masses. See 
%	HW5-144-244-Fall-2011.xoj for the system diagram.
%
% the 7 unknowns are: e1, e2, iE, x1, v1, x2, v2
% the 7 equations are:
% 
% % ckt equations
% e1 KCL   : (e1-e2)/R + iE = 0
% e2 KCL   : (e2-e1)/R + C d/dt e2(t) - a1 v1^2 + diode(e2) = 0
% E(t) BCR : e1 - E(t) = 0
% % mech equations
% m1 F=ma  : m1 d/dt v1(t) + k1*(x1-l1) - k2*(x2-x1-l2) = 0
% v1 defn  : d/dt x1 - v1 = 0
% m2 F=ma  : m2 d/dt v2(t) + k2*(x2-x1-l2) - a2*e2(t) = 0
% v2 defn  : d/dt x2 - v2 = 0
%
% E(t) is the single input, also called u(t). 
% y(t) = [e2; x1; x2] are the outputs.
%
% There are 12 parameters in the system:
% 	R, C, Is, Vt, a1, a2, m1, m2, k1, k2, l1, l2
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See DAEAPIv6_doc.m for documentation on the DAEAPIv6.2 functions here.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%
%
%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('coupledRCdiodeSpringsMasses');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set inputs, precompute stuff
	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	% data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE);

	%
	% The following 'unassigned' assignments prevent the appropriate analyses from running unless the inputs
	% are set up right. You should always keep these, and update later as appropriate.
	DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
	DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
	DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
	DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
	DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. Should become a structure

	% setting the QSS/DC input value (for the voltage source E, in this case)
	DAE.uQSSvec = 0; % DC value of input is set here. Can be updated during runtime with set_uQSS.

	% setting a transient input function (for the current source I)
	%mycos = @(t,args) cos(2*pi*args.f*t);
	%args.f = 1000;
	%DAE = set_utransient(mycos, args, DAE);
% sizes: 
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.ninputs = @ninputs;
	DAE.noutputs = @noutputs;
	%
% f, q: 
	DAE.f_takes_inputs = 0;
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx;
	DAE.dq_dx = @dq_dx;
	%DAE.df_du = @df_du;
	%
% input-related functions
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
	DAE.NoiseStationaryComponentPSDmatrix = @NoiseStationaryComponentPSDmatrix;
	DAE.m = @m;
	DAE.dm_dx = @dm_dx;
	DAE.dm_dn = @dm_dn;
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = 7; % FILL IN YOUR STUFF HERE
% end nunks(...)

function out = neqns(DAE)
	out = 7; % FILL IN YOUR STUFF HERE
% end neqns(...)

function out = ninputs(DAE)
	out = 1; % E % FILL IN YOUR STUFF HERE
% end ninputs(...)

function out = noutputs(DAE)
	out = 3; % [e2; x1; x2] are the outputs. % FILL IN YOUR STUFF HERE
% end noutputs(...)

function out = nparms(DAE)
	out = 12; % R, C, Is, Vt, a1, a2, m1, m2, k1, k2, l1, l2 - in this order % FILL IN YOUR STUFF HERE
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('vsrc-RC-diode <-> 2-spring-2-mass system'); % FILL IN YOUR STUFF HERE
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	%unknowns are: e1, e2, iE, x1, v1, x2, v2 - in this order
	out = {'e1', 'e2', 'iE', 'x1', 'v1', 'x2', 'v2'}; % FILL IN YOUR STUFF HERE
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	% e1 KCL   : (e1-e2)/R + iE = 0
	% e2 KCL   : (e2-e1)/R + C d/dt e2(t) - a1 v1^2 + diode(e2) = 0
	% E(t) BCR : e1 - E(t) = 0
	% % mech equations
	% m1 F=ma  : m1 d/dt v1(t) + k1*(x1-l1) - k2*(x2-x1-l2) = 0
	% v1 defn  : d/dt x1 - v1 = 0
	% m2 F=ma  : m2 d/dt v2(t) + k2*(x2-x1-l2) - a2*e2(t) = 0
	% v2 defn  : d/dt x2 - v2 = 0
	out = {'e1-KCL', 'e2-KCL', 'E-BCR', 'm1-FeqMA', 'v1-defn', 'm2-FeqMA', 'v2-defn'}; % FILL IN YOUR STUFF HERE
% end eqnnames()

function out = inputnames(DAE)
	out = {'E(t)'}; % FILL IN YOUR STUFF HERE
% end inputnames()

function out = outputnames(DAE)
	% y(t) = [e2; x1; x2; v1; v2] are the outputs, in this order.
	out = {'e2', 'x1', 'x2'}; % FILL IN YOUR STUFF HERE
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	% R, C, Is, Vt, a1, a2, m1, m2, k1, k2, l1, l2 - in this order 
	out = {'R', 'C', 'Is', 'Vt', 'a1', 'a2', 'm1', 'm2', 'k1', 'k2', 'l1', 'l2'}; % FILL IN YOUR STUFF HERE
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	% parmvals = {100000, 1e-6, 1e-12, 0.025,  1e-5  ,  1,    1,    1.5,  10,   15,   0.1,  0.05}; % FILL IN YOUR STUFF HERE
	parmvals = {100, 1e-2, 1e-12, 0.025,  -0.1,  10,   0.1,  0.15,  100, 150,  0.1,  0.05}; % FILL IN YOUR STUFF HERE
	% order: {   'R',  'C', 'Is',   'Vt', 'a1', 'a2',  'm1', 'm2', 'k1', 'k2', 'l1', 'l2'}; 
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, DAE)
	%{'e1',    'e2',      'iE',      'x1',      'v1',       'x2',      'v2'}; 
	e1 = x(1); e2 = x(2); iE = x(3); x1 = x(4); v1 = x(5); x2 = x(6); v2 = x(7);
	[R, C, Is, Vt, a1, a2, m1, m2, k1, k2, l1, l2] = deal(DAE.parms{:});

	diod = diode;

	% e1 KCL   : (e1-e2)/R + iE = 0
	fout(1,1) = (e1-e2)/R + iE;

	% e2 KCL   : (e2-e1)/R + C d/dt e2(t) - a1 v1^2 + diode(e2) = 0
	fout(2,1) = (e2-e1)/R - a1*v1.^2 + feval(diod.f, e2, Is, Vt);

	% E(t) BCR : e1 - E(t) = 0
	fout(3,1) = e1; % -E(t) comes through B*u(t)

	% m1 F=ma  : m1 d/dt v1(t) + k1*(x1-l1) - k2*(x2-x1-l2) = 0
	fout(4,1) = k1*(x1-l1) - k2*(x2-x1-l2);

	% v1 defn  : d/dt x1 - v1 = 0
	fout(5,1) = -v1;	

	% m2 F=ma  : m2 d/dt v2(t) + k2*(x2-x1-l2) - a2*e2(t) = 0
	fout(6,1) = k2*(x2-x1-l2) - a2*e2;

	% v2 defn  : d/dt x2 - v2 = 0
	fout(7,1) = -v2;
% end f(...)

function qout = q(x, DAE)
	%{'e1',    'e2',      'iE',      'x1',      'v1',       'x2',      'v2'}; 
	e1 = x(1); e2 = x(2); iE = x(3); x1 = x(4); v1 = x(5); x2 = x(6); v2 = x(7);
	[R, C, Is, Vt, a1, a2, m1, m2, k1, k2, l1, l2] = deal(DAE.parms{:});

	% e2 KCL   : (e2-e1)/R + C d/dt e2(t) - a1 v1^2 + diode(e2) = 0
	qout(2,1) = C*e2;

	% e1 KCL   : (e1-e2)/R + iE = 0
	qout(1,1) = 0;

	% E(t) BCR : e1 - E(t) = 0
	qout(3,1) = 0;

	% m1 F=ma  : m1 d/dt v1(t) + k1*(x1-l1) - k2*(x2-x1-l2) = 0
	qout(4,1) = m1*v1;

	% v1 defn  : d/dt x1 - v1 = 0
	qout(5,1) = x1;

	% m2 F=ma  : m2 d/dt v2(t) + k2*(x2-x1-l2) - a2*e2(t) = 0
	qout(6,1) = m2*v2;

	% v2 defn  : d/dt x2 - v2 = 0
	qout(7,1) = x2;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
	%{'e1',    'e2',      'iE',      'x1',      'v1',       'x2',      'v2'}; 
	e1 = x(1); e2 = x(2); iE = x(3); x1 = x(4); v1 = x(5); x2 = x(6); v2 = x(7);
	[R, C, Is, Vt, a1, a2, m1, m2, k1, k2, l1, l2] = deal(DAE.parms{:});

	Jf = sparse(7,7); % empty 7x7 sparse matrix
	diod = diode;

	% order of unknowns, ie, Jacobian column indices
	%{'e1',    'e2',      'iE',      'x1',      'v1',       'x2',      'v2'}; 
	%  1        2          3          4          5           6          7

	% e1 KCL   : (e1-e2)/R + iE = 0
	%fout(1,1) = (e1-e2)/R + iE;
	Jf(1,1) = 1/R;
	Jf(1,2) = -1/R;
	Jf(1,3) = 1;

	% e2 KCL   : (e2-e1)/R + C d/dt e2(t) - a1 v1^2 + diode(e2) = 0
	%fout(2,1) = (e2-e1)/R - a1*v1.^2 + feval(diod.f, e2, Is, Vt);
	[Id, dId_dvd] = feval(diod.f, e2, Is, Vt);
	Jf(2,1) = -1/R;
	Jf(2,2) = 1/R + dId_dvd;
	Jf(2,5) = -2*a1*v1;

	% E(t) BCR : e1 - E(t) = 0
	%fout(3,1) = e1; % -E(t) comes through B*u(t)
	Jf(3,1) = 1;

	% m1 F=ma  : m1 d/dt v1(t) + k1*(x1-l1) - k2*(x2-x1-l2) = 0
	%fout(4,1) = k1*(x1-l1) - k2*(x2-x1-l2);
	Jf(4,4) = k1+k2;
	Jf(4,6) = -k2;

	% v1 defn  : d/dt x1 - v1 = 0
	%fout(5,1) = -v1;	
	Jf(5,5) = -1;

	% m2 F=ma  : m2 d/dt v2(t) + k2*(x2-x1-l2) - a2*e2(t) = 0
	%fout(6,1) = k2*(x2-x1-l2) - a2*e2;
	Jf(6,4) = -k2;
	Jf(6,6) = k2;
	Jf(6,2) = -a2;

	% v2 defn  : d/dt x2 - v2 = 0
	%fout(7,1) = -v2;
	Jf(7,7) = -1;
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	%{'e1',    'e2',      'iE',      'x1',      'v1',       'x2',      'v2'}; 
	e1 = x(1); e2 = x(2); iE = x(3); x1 = x(4); v1 = x(5); x2 = x(6); v2 = x(7);
	[R, C, Is, Vt, a1, a2, m1, m2, k1, k2, l1, l2] = deal(DAE.parms{:});

	Jq = sparse(7,7); % empty 7x7 sparse matrix

	% order of unknowns, ie, Jacobian column indices
	%{'e1',    'e2',      'iE',      'x1',      'v1',       'x2',      'v2'}; 
	%  1        2          3          4          5           6          7

	% e1 KCL   : (e1-e2)/R + iE = 0
	%qout(1,1) = 0;

	% e2 KCL   : (e2-e1)/R + C d/dt e2(t) - a1 v1^2 + diode(e2) = 0
	%qout(2,1) = C*e2;
	Jq(2,2) = C;

	% E(t) BCR : e1 - E(t) = 0
	%qout(3,1) = 0;

	% m1 F=ma  : m1 d/dt v1(t) + k1*(x1-l1) - k2*(x2-x1-l2) = 0
	%qout(4,1) = m1*v1;
	Jq(4,5) = m1;

	% v1 defn  : d/dt x1 - v1 = 0
	%qout(5,1) = x1;
	Jq(5,4) = 1;

	% m2 F=ma  : m2 d/dt v2(t) + k2*(x2-x1-l2) - a2*e2(t) = 0
	%qout(6,1) = m2*v2;
	Jq(6,7) = m2;

	% v2 defn  : d/dt x2 - v2 = 0
	%qout(7,1) = x2;
	Jq(7,6) = 1;
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)

	out = sparse(neqns(DAE),ninputs(DAE)); % empty neqns x ninputs matrix

	% only E(t) BCR contributes to B: third equation
	% E(t) BCR : e1 - E(t) = 0
	out(3,1) = -1;
% end B(...)

% set_utransient is in set_utransient.m
% utransient is in utransient.m
% set_uQSS is in set_uQSS.m
% uQSS is in uQSS.m
% set_uLTISSS is in set_uLTISSS.m
% uLTISSS is in uLTISSS.m

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	nouts = noutputs(DAE);
	nu = nunks(DAE);
	out = sparse(nouts, nu);

	% order of unknowns, ie, column indices of C
	%{'e1',    'e2',      'iE',      'x1',      'v1',       'x2',      'v2'}; 
	%  1        2          3          4          5           6          7

	% y(t) = [e2; x1; x2;] are the outputs, ie, row indices of C
	%          1  2   3  

	%e2
	out(1,2) = 1;

	%x1
	out(2,4) = 1;

	%x2
	out(3,6) = 1;
% end C(...)

function out = D(DAE)
	nouts = noutputs(DAE);
	out = sparse(nouts,1); % zero vector of size noutputs x ninputs
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = zeros(nunks(DAE),1); % note: zeros is usually a really bad guess.
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	% Bichen: returning dx is not compatible with current NR init/limiting 
	%		  nlimitedvars is 0, so NRlimiting should return []
	% newdx = dx;
	newdx = [];
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	out = 'undefined';
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
	ne = neqns(DAE);
	nu = nunks(DAE);
	Jm = sparse(ne,nu);
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
