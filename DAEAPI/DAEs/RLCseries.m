function DAE = RLCseries(uniqIDstr)  % DAEAPIv6.2
%function DAE = RLCseries(uniqIDstr)  % DAEAPIv6.2
% RLC series cricuit with voltage source
%author: J. Roychowdhury, 2011/09/19
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% node unknowns are: vC, v2, v1, iL, iE
% MNA equations are:
%
%	C dvC/dt + (vC-v2)/R = 0
%	iL + (v2-vC)/R = 0
%	-iL + iE = 0
% 	L diL/dt = v2-v1
%	v1 - E(T) = 0
%
% E(t) is the input, set to sin(2*pi*f*t), f=5e6. The entire state vector x 
% is the output.
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
	DAE.Usage = help('RLCseries');
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

	% setting a transient input function (for the current source I)
	mysin = @(t,args) sin(2*pi*args.f*t);
	args.f = 5e6;
	DAE = feval(DAE.set_utransient, mysin, args, DAE);
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
	out = 5;
% end nunks(...)

function out = neqns(DAE)
	out = 5;
% end neqns(...)

function out = ninputs(DAE)
	out = 1; % E
% end ninputs(...)

function out = noutputs(DAE)
	out = nunks(DAE); % all x is the output
% end noutputs(...)

function out = nparms(DAE)
	out = 3; % {'R', 'C', 'L'};
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('RLC series tank circuit');
% end daename()

function out = setup_unknames(DAE)
	%unknowns are: vC, v2, v1, iL, iE - in this order
	out = {'vC', 'v2', 'v1', 'iL', 'iE'};
% end unknames()

% unknames is in unknames.m
function out = setup_eqnnames(DAE)
	out = {'nC-KCL', 'n2-KCL', 'n1-KCL', 'L-BCR', 'E-BCR'};
% end eqnnames()

% eqnnames is in eqnnames.m
function out = inputnames(DAE)
	out = {'E(t)'};
% end inputnames()

function out = outputnames(DAE)
	out = unknames(DAE);
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'R', 'C', 'L'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {1, 1e-6, 1e-9};
	% order: {'R', 'C', 'L'};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, DAE)

	vC = x(1); v2 = x(2); v1 = x(3); iL = x(4); iE = x(5);
	%oof = struct2cell(parms); % fieldnames, orderfields can be useful
	[R, C, L] = deal(DAE.parms{:});

	fout(1,1) = (vC-v2)/R; 				% nC KCL
	fout(2,1) = iL - (vC-v2)/R;			% n2 KCL
	fout(3,1) = -iL + iE;				% n1 KCL
	fout(4,1) = v1 - v2;				% L BCR
	fout(5,1) = v1;					% E BCR, f component
% end f(...)

function qout = q(x, DAE)
	vC = x(1); v2 = x(2); v1 = x(3); iL = x(4); iE = x(5);
	%oof = struct2cell(parms); % fieldnames, orderfields can be useful
	[R, C, L] = deal(DAE.parms{:});

	qout(1,1) = C*vC;
	qout(2,1) = 0;
	qout(3,1) = 0;
	qout(4,1) = L*iL;
	qout(5,1) = 0;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
	vC = x(1); v2 = x(2); v1 = x(3); iL = x(4); iE = x(5);
	%oof = struct2cell(DAE.parms); % fieldnames, orderfields can be useful
	[R, C, L] = deal(DAE.parms{:});

	Jf = zeros(5,5);
	% x = {'vC', 'v2', 'v1', 'iL', 'iE'};
	%       1      2    3     4      5

	%fout(1,1) = (vC-v2)/R;	% vC KCL
	Jf(1,1) = 1/R;
	Jf(1,2) = -1/R;

	%fout(2,1) = iL - (vC-v2)/R;		% n2 KCL
	Jf(2,1) = -1/R;
	Jf(2,2) = 1/R;
	Jf(2,4) = 1;

	%fout(3,1) = -iL + iE;			% n1 KCL
	Jf(3,4) = -1;
	Jf(3,5) = 1;

	%fout(4,1) = v1 - v2;			% L BCR
	Jf(4,2) = -1;
	Jf(4,3) = 1;

	%fout(5,1) = v1 - E;			% E BCR
	Jf(5,3) = 1;
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	%oof = struct2cell(parms); % fieldnames, orderfields can be useful
	[R, C, L] = deal(DAE.parms{:});
	% x = {'vC', 'v2', 'v1', 'iL', 'iE'};
	%       1      2    3     4      5

	Jq = zeros(5,5);

	% qout(1,1) = C*vC;
	Jq(1,1) = C;

	% qout(4,1) = L*iL;
	Jq(4,4) = L;
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	if (nargin > 1)
	   fprintf(2,'Usage: B(x, DAE) not supported yet (need tensor support first).\n');
	   return;
	end
	out = zeros(neqns(DAE),ninputs(DAE));
	out(5,1) = -1; % E BCR: v1 - E = 0, E is the input u(t)
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
%function out = C(DAE)
	out = eye(nunks(DAE));;
% end C(...)

function out = D(DAE)
	out = 0;
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P_f = df_dp(x, PObj, DAE)
	P_f = sparse([]);
	% NO parameter derivative support yet
% end df_dp(...)

function P_q = dq_dp(x, PObj, DAE)
	P_q = sparse([]);
	% NO parameter derivative support yet
% end dq_dp(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = zeros(nunks(DAE),1); % note: zeros is a really bad guess.
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
