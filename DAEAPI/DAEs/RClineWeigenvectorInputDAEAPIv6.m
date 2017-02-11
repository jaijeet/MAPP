function DAE = RClineWeigenvectorInput(uniqIDstr, nsegs,lineR,lineC)  % DAEAPIv6.2
%function DAE = RClineWeigenvectorInput(uniqIDstr, nsegs,lineR,lineC) 
% RC line with eigen vector input <TODO> Expand </TODO>
%author: J. Roychowdhury, 2010/03/06
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6';
	DAE.Usage = help('RClineDAEAPIv6');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, precompute stuff
	DAE.nsegs = nsegs;
	DAE.lineR = lineR;
	DAE.lineC = lineC;
	[DAE.Cmat, DAE.Gmat, DAE.bvec, DAE.cvec] = CGbc(nsegs,lineR,lineC);
	% now change bvec so that Ginv*bvec is an eigenvector of 
	%	Ginv*C
	A = inv(DAE.Gmat)*DAE.Cmat;
	[eigenvectors, eigenvalues] = eig(full(A));
	k=1;
	r = eigenvectors(:,k); % kth eigenvector of A
	DAE.bvec = DAE.Gmat*r;
	% end modifying bvec
	% DAE is Cmat xdot + Gmat x + bvec u(t)  = 0, y = cvec^T x
	DAE.uQSSvec = 'unassigned'; % should become a real scalar/vector
	DAE.utfunc = 'unassigned'; % should become a function call
	DAE.utargs = 'unassigned'; % should become a structure
	DAE.Uffunc = 'unassigned'; % should become a function call
	DAE.Ufargs = 'unassigned'; % should become a structure
	%
	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	% data: current values of parameters, can be changed by setparms
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
	DAE.NoiseStationaryComponentPSDmatrix = 'undefined'; % @NoiseStationaryComponentPSDmatrix;
	DAE.m = 'undefined'; % @m;
	DAE.dm_dx = 'undefined'; % @dm_dx;
	DAE.dm_dn = 'undefined'; % @dm_dn;
%
% end DAE "constructor"

% the circuit: 
%	there is one input: voltage source u(t), connected between node inp 
%		and ground. node inp is not an unknown in the system.
%	there are nsegs(>=1) unknown nodes in the circuit:
%		- segment i is connected between node i-1 and node i
%			- segment 1 is connected between node inp and node 1
%		- each segment consists of:
%			- a resistor R (between inp/i-1 and i)
%			- a capacitor C (between i and ground)
%	there is one output: the voltage and node nseg
%	
% unknowns are: x = [e1, ..., enseg]^T
% circuit equations are:
%	segment 1: (add to node 1 KCL) [e1-u(t)]/R + C d1/dt
%	segment i, 1<i<=nsegs:
%		add to node i-1 KCL: (eim1-ei)/R
%		add to node i KCL: (ei-eim1)/R + C dei/dt
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = DAE.nsegs;
% end nunks(...)

function out = neqns(DAE)
	out = DAE.nsegs;
% end neqns(...)

function out = ninputs(DAE)
	out = 1;
% end ninputs(...)

function out = noutputs(DAE)
	out = 1;
% end noutputs(...)

function out = nparms(DAE)
	out = 2; % R, C
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; %
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('RC line with %d segments', nunks(DAE));
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	for i=1:DAE.nsegs
		out{i} = sprintf('e%d', i);
	end
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	for i=1:DAE.nsegs
		out{i} = sprintf('KCL%d', i);
	end
% end eqnnames()

function out = inputnames(DAE)
	out = {'line driving voltage: E(t)'};
% end inputnames()

function out = outputnames(DAE)
	out = {'line end voltage'};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'R', 'C'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {DAE.lineR, DAE.lineC};
	%order:    {'R', 'C'};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, DAE)
	fout = DAE.Gmat * x;
% end f(...)

function qout = q(x, DAE)
	qout = DAE.Cmat * x;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	if (nargin > 0)
	   fprintf(2,'B(x, DAE) not supported yet (need tensor support first)\n');
	   return;
	end
	out = DAE.bvec;
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = DAE.cvec;
% end C(...)

function out = D(DAE)
%function out = D(x, DAE)
	out = 0;
% end D(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
	Jf = DAE.Gmat;
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	Jq = DAE.Cmat;
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

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = zeros(DAE.nsegs,1);
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

function [Cmat, Gmat, bvec, cvec] = CGbc(nsegs, R, C)
% unknowns are: x = [e1, ..., enseg]^T
% circuit equations are:
%	segment 1: (add to node 1 KCL) [e1-u(t)]/R + C d1/dt
%	segment i, 1<i<=nsegs:
%		add to node i-1 KCL: (eim1-ei)/R
%		add to node i KCL: (ei-eim1)/R + C dei/dt

	Cmat = sparse([]); Cmat(nsegs,nsegs) = 0;
	Gmat = sparse([]); Gmat(nsegs,nsegs) = 0;
	bvec = zeros(nsegs,1);
	cvec = zeros(1,nsegs); cvec(1,nsegs) = 1; % output = e(last node)
	g = 1/R;

	% i=1
	Gmat(1,1) = g;
	Cmat(1,1) = C;
	bvec(1,1) = -g;

	% i=2..nsegs
	for i=2:nsegs
		Gmat(i-1,i-1) = Gmat(i-1,i-1) + g;
		Gmat(i-1,i) = Gmat(i-1,i) - g;
		Gmat(i,i-1) = Gmat(i,i-1) - g;
		Gmat(i,i) = Gmat(i,i) + g;
		Cmat(i,i) = C;
	end
%end CGbc
