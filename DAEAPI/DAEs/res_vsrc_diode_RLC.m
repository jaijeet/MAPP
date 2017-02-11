function DAE = res_vsrc_diode_RLC(uniqIDstr) 
%function DAE = res_vsrc_diode_RLC(uniqIDstr)   
%A circuit consisting of voltage source, diode and RLC 
%author: J. Roychowdhury, 2009/11/29
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: (basis of 144/244 midterm2 question, Fall 2011)
% 
% [ gnd - R1 - Vsrc(t) - diode> - R || L || C - gnd ] 
%            e0        e1       e2
%
% unknowns are: e0, e1, e2, iL, iE
% MNA equations are:
%
% 	KCL0: -iE + e0/R1				= 0
% 	KCL1: iE + diode(e1-e2)				= 0
%	KCL2: -diode(e1-e2) + e2/R2 + d/dt (C*e2) + iL	= 0
%	LBCR: d/dt (L*iL) - e2 				= 0
%	EBCR: e1 - e0 - E(t)				= 0
%
% 1 input: E(t)
% 2 outputs: e1(t), e2(t)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See DAEAPIv6_doc.m for documentation on the DAEAPIv6 functions here.
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
	%DAE.version = 'DAEAPIv6.2';
	%DAE.Usage = help('res_VSRC_diode_RLC');
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
	DAE.parms = parmdefaults(DAE);
	%
	% The following 'unassigned' assignments prevent the appropriate analyses from running unless the inputs
	% are set up right. You should always keep these, and update later as appropriate.
	DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
	DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
	DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
	DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
	DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. should become a structure

	% setting a DC input of 0V
	DAE.uQSSvec = 0; 

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
	out = 5;
% end nunks(...)

function out = neqns(DAE)
	out = 5;
% end neqns(...)

function out = ninputs(DAE)
	out = 1; % E(t)
% end ninputs(...)

function out = noutputs(DAE)
	out = 1; % e2(t)
% end noutputs(...)

function out = nparms(DAE)
	out = 6; %
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('res_VSRC_diode_RLC: gnd-R1-Vsrc(t)-diode>-R||L||C-gnd');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out{1} = sprintf('e0');
	out{2} = sprintf('e1');
	out{3} = sprintf('e2');
	out{4} = sprintf('iL');
	out{5} = sprintf('iE');
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out{1} = sprintf('KCL0');
	out{2} = sprintf('KCL1');
	out{3} = sprintf('KCL2');
	out{4} = sprintf('BCRL');
	out{5} = sprintf('BCRE');
% end eqnnames()

function out = inputnames(DAE)
	out = {'E(t)'};
% end inputnames()

function out = outputnames(DAE)
	out = {'e2(t)'};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'R1', 'R2', 'C', 'L', 'Is', 'Vt'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m

%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {1, 	1e4, 	1e-6, 1e-9, 1e-12, 0.025};
		% {'R1', 'R2', 'C', 	'L', 'Is', 'Vt'};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, DAE)
	e0 = x(1); e1 = x(2); e2 = x(3); iL = x(4); iE = x(5);
	[R1, R2, C1, L, Is, Vt] = deal(DAE.parms{:});

	dobj = diode;
	id = feval(dobj.f, e1-e2, Is, Vt);

	% 	KCL0: -iE + e0/R1				= 0
	fout(1,1) = -iE + e0/R1;

	% 	KCL1: iE + diode(e1-e2)				= 0
	fout(2,1) = iE + id;

	%	KCL2: -diode(e1-e2) + e2/R2 + d/dt (C*e2) + iL	= 0
	fout(3,1) = -id + e2/R2 + iL;

	%	LBCR: d/dt (L*iL) - e2 				= 0
	fout(4,1) = -e2;

	%	EBCR: e1 - e0 - E(t)				= 0
	fout(5,1) = e1 - e0;
% end f(...)

function qout = q(x, DAE)
	e0 = x(1); e1 = x(2); e2 = x(3); iL = x(4); iE = x(5);
	[R1, R2, C1, L, Is, Vt] = deal(DAE.parms{:});

	qout = 0*x;

	%	KCL2: -diode(e1-e2) + e2/R2 + d/dt (C*e2) + iL	= 0
	qout(3,1) = C1*e2;

	%	LBCR: d/dt (L*iL) - e2 				= 0
	qout(4,1) = L*iL;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
	e0 = x(1); e1 = x(2); e2 = x(3); iL = x(4); iE = x(5);
	[R1, R2, C1, L, Is, Vt] = deal(DAE.parms{:});

	dobj = diode;
	[id, did_de1me2] = feval(dobj.f, e1-e2, Is, Vt);

	Jf = sparse(5,5);

	% e0	e1	e2	iL	iE
	% 1	2	3	4	5
	
	% 	KCL0: -iE + e0/R1				= 0
	%	fout(1,1) = -iE + e0/R1;
	Jf(1,1) = 1/R1;
	Jf(1,5) = -1;

	% 	KCL1: iE + diode(e1-e2)				= 0
	%	fout(2,1) = iE + id;
	Jf(2,2) = did_de1me2;
	Jf(2,3) = - did_de1me2;
	Jf(2,5) = 1;

	%	KCL2: -diode(e1-e2) + e2/R2 + d/dt (C*e2) + iL	= 0
	%	fout(3,1) = -id + e2/R2 + iL;
	Jf(3,2) = -did_de1me2;
	Jf(3,3) = did_de1me2 + 1/R2;
	Jf(3,4) = 1;

	%	LBCR: d/dt (L*iL) - e2 				= 0
	%	fout(4,1) = -e2;
	Jf(4,3) = -1;

	%	EBCR: e1 - e0 - E(t)				= 0
	%	fout(5,1) = e1 - e0;
	Jf(5,1) = -1;
	Jf(5,2) = 1;
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	e0 = x(1); e1 = x(2); e2 = x(3); iL = x(4); iE = x(5);
	[R1, R2, C1, L, Is, Vt] = deal(DAE.parms{:});

	Jq = sparse(5,5);

	% e0	e1	e2	iL	iE
	% 1	2	3	4	5

	%	KCL2: -diode(e1-e2) + e2/R2 + d/dt (C*e2) + iL	= 0
	%	qout(3,1) = C*e2;
	Jq(3,3) = C1;

	%	LBCR: d/dt (L*iL) - e2 				= 0
	%	qout(4,1) = L*iL;
	Jq(4,4) = L;
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	%	EBCR: e1 - e0 - E(t)				= 0
	out = [0;0;0;0;-1];
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = [0,0,1,0,0;]; % e2
% end C(...)

function out = D(DAE)
	out = [0;0];
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = [0; 0.3; 0.0; 0; 0]; % 0.3 gets the diode going
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx; % limiting not put in yet
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	m = nNoiseSources(DAE);
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
