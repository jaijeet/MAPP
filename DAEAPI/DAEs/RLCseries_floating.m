function DAE = RLCseries_floating(uniqIDstr, Rin, Lin, Cin)  % DAEAPIv6.2
%function DAE = RLCseries_floating(uniqIDstr, Rin, Lin, Cin)  % DAEAPIv6.2
% A floating series RLC circuit:
%author: J. Roychowdhury, 2011/09/19
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% A floating series RLC circuit:
% n1 - R - n2 - L - n3 - C - n4
%
% unknowns are:  e1,    e2,   e3,   e4,   iL (to the right)
% equations are: KCL1, KCL2, KCL3, KCL4, BCR_L
%
% KCL1: (e1-e2)/R  	    + noise_R(t) = 0
% KCL2: (e2-e1)/R + iL      - noise_R(t) = 0
% KCL3: -iL + C d/dt(e3-e4) 		 = 0
% KCL4: C d/dt(e4-e3)	    		 = 0
% BCRL: L d/dt iL - (e2-e3) 		 = 0
%
% no inputs or outputs are defined. A single noise source
% (for R) is defined.
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






%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('RLCseries_floating');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set inputs, precompute stuff

	DAE.defaultparms = {Rin, Lin, Cin};

	% The following 'unassigned' assignments prevent the appropriate analyses from running unless the inputs
	% are set up right. You should always keep these, and update later as appropriate.
	DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
	DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
	DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
	DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
	DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. Should become a structure

	%
	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	% data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE);
	%

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
	DAE.parmdefaults = @parmdefaults;
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
	out = 0; % E
% end ninputs(...)

function out = noutputs(DAE)
	out = 0; % 
% end noutputs(...)

function out = nparms(DAE)
	out = 3; % {'R', 'C', 'L'};
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 1; % 
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('floating series RLC circuit');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out = {'e1', 'e2', 'e3', 'e4', 'iL'};
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out = {'KCL1', 'KCL2', 'KCL3', 'KCL4', 'BCRL'};
% end eqnnames()

function out = inputnames(DAE)
	out = {};
% end inputnames()

function out = outputnames(DAE)
	out = {};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'R', 'L', 'C'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {'R'};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m

%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = DAE.defaultparms;
	% order: {'R', 'L', 'C'};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, DAE)
	e1 = x(1); e2 = x(2); e3 = x(3); e4 = x(4); iL = x(5);
	[R, L, C] = deal(DAE.parms{:});

	% KCL1: (e1-e2)/R  	    = 0
	% KCL2: (e2-e1)/R + iL      = 0
	% KCL3: -iL + C d/dt(e3-e4) = 0
	% KCL4: C d/dt(e4-e3)	    = 0
	% BCRL: L d/dt iL - (e2-e3) = 0

	fout(1,1) = (e1-e2)/R; 				% n1 KCL
	fout(2,1) = (e2-e1)/R + iL;			% n2 KCL
	fout(3,1) = -iL;				% n3 KCL
	fout(4,1) = 0;					% n4 KCL
	fout(5,1) = -(e2-e3);				% L BCR
% end f(...)

function qout = q(x, DAE)
	e1 = x(1); e2 = x(2); e3 = x(3); e4 = x(4); iL = x(5);
	[R, L, C] = deal(DAE.parms{:});

	% KCL1: (e1-e2)/R  	    = 0
	% KCL2: (e2-e1)/R + iL      = 0
	% KCL3: -iL + C d/dt(e3-e4) = 0
	% KCL4: C d/dt(e4-e3)	    = 0
	% BCRL: L d/dt iL - (e2-e3) = 0

	qout(1,1) = 0;
	qout(2,1) = 0;
	qout(3,1) = C*(e3-e4);
	qout(4,1) = C*(e4-e3);
	qout(5,1) = L*iL;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
	e1 = x(1); e2 = x(2); e3 = x(3); e4 = x(4); iL = x(5);
	[R, L, C] = deal(DAE.parms{:});

	% KCL1: (e1-e2)/R  	    = 0
	% KCL2: (e2-e1)/R + iL      = 0
	% KCL3: -iL + C d/dt(e3-e4) = 0
	% KCL4: C d/dt(e4-e3)	    = 0
	% BCRL: L d/dt iL - (e2-e3) = 0

	Jf = sparse(5,5);
	% x = {'e1', 'e2', 'e3', 'e4', 'iL'};
	%       1      2    3     4      5

	%fout(1) = (e1-e2)/R; 				% n1 KCL
	Jf(1,1) = 1/R;
	Jf(1,2) = -1/R;

	%fout(2) = (e2-e1)/R + iL;			% n2 KCL
	Jf(2,1) = -1/R;
	Jf(2,2) = 1/R;
	Jf(2,5) = 1;

	%fout(3,1) = -iL;				% n3 KCL
	Jf(3,5) = -1;

	%fout(4,1) = 0;					% n4 KCL

	%fout(5,1) = -(e2-e3);				% L BCR
	Jf(5,2) = -1;
	Jf(5,3) = 1;
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	e1 = x(1); e2 = x(2); e3 = x(3); e4 = x(4); iL = x(5);
	[R, L, C] = deal(DAE.parms{:});

	% KCL1: (e1-e2)/R  	    = 0
	% KCL2: (e2-e1)/R + iL      = 0
	% KCL3: -iL + C d/dt(e3-e4) = 0
	% KCL4: C d/dt(e4-e3)	    = 0
	% BCRL: L d/dt iL - (e2-e3) = 0

	Jq = sparse(5,5);
	% x = {'e1', 'e2', 'e3', 'e4', 'iL'};
	%       1      2    3     4      5

	%qout(1) = 0;
	%qout(2) = 0;

	%qout(3) = C*(e3-e4);
	Jq(3,3) = C;
	Jq(3,4) = -C;

	%qout(4) = C*(e4-e3);
	Jq(4,3) = -C;
	Jq(4,4) = C;

	%qout(5) = L*iL;
	Jq(5,5) = L;
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	out = [];
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
%function out = C(DAE)
	out = [];
% end C(...)

function out = D(DAE)
	out = [];
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = zeros(nunks(DAE),1);
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
	k = 1.3806503e-23; % Boltzmann's const
	q = 1.60217646e-19; % electronic charge
	T = 300; % Kelvin; absolute temperature FIXME: this should be a parameter

	[R, L, C] = deal(DAE.parms{:});

	out = 4*k*T/R;
	% 
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% NOTE: m should be for one-sided PSDs
	% M is of size neqns. n is of size nNoiseSources
	
	% KCL1: (e1-e2)/R  	    + noise_R(t) = 0
	% KCL2: (e2-e1)/R + iL      - noise_R(t) = 0
	% KCL3: -iL + C d/dt(e3-e4) 		 = 0
	% KCL4: C d/dt(e4-e3)	    		 = 0
	% BCRL: L d/dt iL - (e2-e3) 		 = 0

	out = zeros(5,1);

	out(1,1) = n;
	out(2,1) = -n;
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	Jm = sparse(5,5);
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
	% M is of size neqns. n is of size nNoiseSources
	% NOTE: M should be for one-sided PSDs
	%
	M = sparse(5,1);
	M(1,1) = 1;
	M(2,1) = -1;
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs = 'No internal functions exposed by this DAE system.';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
