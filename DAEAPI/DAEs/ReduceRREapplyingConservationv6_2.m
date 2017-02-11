function DAE = ReduceRREapplyingConservationv6_2(uniqIDstr, RREbaseDAE, initconcs)
%function DAE = ReduceRREapplyingConservation(uniqIDstr, RREbaseDAE, initconcs)
%Produces a DAE object of reduced size that eliminates unknowns using conservation (via SVDs)
%	argument1: DAEAPIv6.2 object for a RRE (TwoReactionChainDAEAPIv6_2.m is
%		an exemplar); 
%	argument2: vector of initial concentrations
%
%	produces a DAE object of reduced size that eliminates unknowns using
%	conservation (via SVDs)
%
% 	this API is DAEAPIv6.2 compliant
%
%see DAEAPIv6_doc.m for a description of the functions here.
%
% author: J. Roychowdhury, 2009/10/11; v6.2 updates, 2011/10/11
%
%%%%

%Changelog:
%---------
%2014/07/27: Tianshi Wang <tianshi@berkeley.edu>: deleted init/limiting related
%            stuff
%2014/01/31: Tianshi Wang <tianshi@berkeley.edu>: nargin checks for backward
%            compatibility
%2013/09/28: Tianshi Wang <tianshi@berkeley.edu>: init/limiting related updates
%2009/10/11: Jaijeet Roychowdhury <jr@berkeley.edu>

% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('ReduceRREapplyingConservationv6_2');
	if 2 == nargin
		initconcs = RREbaseDAE;
		RREbaseDAE = uniqIDstr;
		uniqIDstr = '';
	end
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, assign inputs, precompute stuff
	DAE.uQSSvec = 'unassigned'; % should become a real scalar/vector
	DAE.utfunc = 'unassigned'; % should become a function call
	DAE.utargs = 'unassigned'; % should become a structure
	DAE.Uffunc = 'unassigned'; % should become a function call
	DAE.Ufargs = 'unassigned'; % should become a structure
	%
	%
	DAE.internalstuff.baseDAE = RREbaseDAE;
	DAE.internalstuff.initconcs = initconcs;
	%
 	% set up conservation via SVD
	ifsBase = feval(RREbaseDAE.internalfuncs, RREbaseDAE);
	stoichmat = feval(ifsBase.stoichmatfunc, RREbaseDAE);
	%
	[nReactants, nReactions] = size(stoichmat);
	nConservation = nReactants - nReactions; % assuming >0, and that
		% all singular values are nonzero, which may not always be true
 	[U, S, V] = svd(stoichmat); % stoichmat = U*S*V';
		% Warning: assuming nReactants > nReactions, and that all
		% singular values are nonzero.
	DAE.internalstuff.nReactants = nReactants;
	DAE.internalstuff.nReactions = nReactions;
	DAE.internalstuff.nConservation = nConservation;
	%
	DAE.internalstuff.SigmaR = S(1:nReactions,1:nReactions);
	DAE.internalstuff.VT = V';
	DAE.internalstuff.U = U;
	%
	% define the new unknowns y = U'*xorig <=> xorig = U y
	% conservation is: y((nReactions+1):end) = const
	%
	% calculate conservation constants and initial conditions for reduced
	y = U'*initconcs;
	DAE.internalstuff.yRinit = y(1:nReactions);
 	% last nConservation rows of U' are the conserved quantities
	DAE.internalstuff.yConsts = y((nReactions+1):end,1);

	% yR = y(1:nReactions) are the new unknowns for the reduced DAE
	% the reduced DAE is:
	% d/dt yR(t) = SigmaR*VT*ratevec(yR)
	%
	% computing ratevec of yR:
	% 1. map yR to xorig:  set y = [yR; yConsts]
	% 2. get x = U*y
	% 3. evaluate ratevec = RREbaseDAE.reactionRates(x)
	% 
	% then return freduced(yR) = SigmaR*VT*ratevec

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
	% DAE.QSSinitGuess = @QSSinitGuess;
	%
% NR limiting support
	% DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames_DAEAPI;
	DAE.getparms  = @default_getparms_DAE;
	DAE.setparms  = @default_setparms_DAE;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp; % not implemented yet
	%DAE.dq_dp  = @dq_dp; % not implemented yet
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
% functions for supporting noise
	% 
	DAE.nNoiseSources = @nNoiseSources;
	DAE.NoiseSourceNames = @NoiseSourceNames;
	DAE.NoiseStationaryComponentPSDmatrix = 'undefined';% @NoiseStationaryComponentPSDmatrix;
	DAE.m = 'undefined'; %@m;
	DAE.dm_dx = 'undefined'; %@dm_dx;
	DAE.dm_dn = 'undefined'; %@dm_dn;
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = DAE.internalstuff.nReactions;
% end nunks(...)

function out = neqns(DAE)
	out = DAE.internalstuff.nReactions;
% end neqns(...)

function out = ninputs(DAE)
	out = 0;
% end ninputs(...)

function out = noutputs(DAE)
	out = DAE.internalstuff.nReactions; % all reduced states are outputs
% end noutputs(...)

function out = nparms(DAE)
	out = 0; % parms inherited from RREbaseDAE, no additional parms
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0;
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	baseDAE = DAE.internalstuff.baseDAE;
	baseDAEname = feval(baseDAE.daename, baseDAE);
	out = sprintf('RRE DAEs reduced by identifying conservation laws using SVDs for %s\n', baseDAEname);
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	nReactions = DAE.internalstuff.nReactions;
	for i=1:nReactions
		out{i} = sprintf('yR%d', i);
	end
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	nReactions = DAE.internalstuff.nReactions;
	for i=1:nReactions
		out{i} = sprintf('d(yR%d)/dt', i);
	end
% end eqnnames()

function out = inputnames(DAE)
	out = {};
% end inputnames()

function out = outputnames(DAE)
	out = unknames(DAE);
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {};
% end parmdefaults(...)

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = f(yR, DAE)
	%y = [yR; DAE.internalstuff.yConsts];
	%x = DAE.internalstuff.U*y;
	x = map_yR_to_x(yR, DAE);

	baseDAE = DAE.internalstuff.baseDAE;
	ifsBase = feval(baseDAE.internalfuncs, baseDAE);
	parmsBase = feval(baseDAE.parmdefaults, baseDAE);
	SigmaR = DAE.internalstuff.SigmaR;
	VT = DAE.internalstuff.VT;

	forwardrates = feval(ifsBase.forwardratefunc, x, parmsBase, baseDAE);
	out = SigmaR*VT*forwardrates;
% end f(...)

function out = q(yR, DAE)
	out = -yR;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(yR, DAE)
	y = [yR; DAE.internalstuff.yConsts];

	nReactions = DAE.internalstuff.nReactions;
	nReactants = DAE.internalstuff.nReactants;
	nConservation = DAE.internalstuff.nConservation;

	dy_dyR = [eye(nReactions); zeros(nConservation,nReactions)]; % nReactants * nReactions
	x = DAE.internalstuff.U*y;
	%dx_dy = DAE.internalstuff.U; % nReactions*nReactions

	baseDAE = DAE.internalstuff.baseDAE;
	ifsBase = feval(baseDAE.internalfuncs, baseDAE);
	parmsBase = feval(baseDAE.parmdefaults, baseDAE);
	SigmaR = DAE.internalstuff.SigmaR;
	VT = DAE.internalstuff.VT;

	dforwardrates = feval(ifsBase.dforwardratefunc, x, parmsBase, baseDAE);
	Jfx = SigmaR*VT*dforwardrates; % this is rectangular: has nReactants cols
	%Jf = Jfx*dx_dy*dy_dyR;
	Jf = Jfx*DAE.internalstuff.U*dy_dyR; % this is square: nReactions*nReactions
% end df_dx(...)

function Jq = dq_dx(yR, DAE)
	n = nunks(DAE);
	Jq = -eye(n);
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	if (nargin > 1)
	   fprintf(2,'B(x, DAE) not supported yet (need tensor support first).\n');
	   return;
	end
	out = [];
% end B(...)


%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	n = nunks(DAE);
	out = speye(n,n);
% end C(...)

function out = D(DAE)
%function out = D(x, DAE)
	out = [];
% end D(...)


%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = zeros(nunks(DAE),1); 
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	out = [];
	% unit PSDs; all the action is moved to m(x,n)
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% M is of size neqns. n is of size nNoiseSources
	%
	out = [];
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	Jm = [];
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
	M = [];
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs.map_yR_to_x = @map_yR_to_x;
	ifs.map_yR_to_x_Usage = 'feval(map_yR_to_x, yR, DAE)';
% end internalfuncs

function x = map_yR_to_x(yR, DAE)
	y = [yR; DAE.internalstuff.yConsts];
	x = DAE.internalstuff.U*y;
% end internalfuncs
%%%%%%%%%%%%%%%% END INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
