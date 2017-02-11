function DAE = TwoReactionChainDAEAPIv6_2(uniqIDstr)
%function DAE = TwoReactionChainDAEAPIv6_2(uniqIDstr)
%Two reaction chains 
%author: J. Roychowdhury, 2009/10/11; 2011/10/11 (API v6_2 updates)
%%%%
%
%% FIXME: needs updates for noise
%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%

% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('TwoReactionChainDAEAPIv6_2');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, assign inputs, precompute stuff
	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE); % data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE);
	%
	DAE.uQSSvec = 'unassigned'; % should become a real scalar/vector
	DAE.utfunc = 'unassigned'; % should become a function call
	DAE.utargs = 'unassigned'; % should become a structure
	DAE.Uffunc = 'unassigned'; % should become a function call
	DAE.Ufargs = 'unassigned'; % should become a structure
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
	out = 5;
% end nunks(...)

function out = neqns(DAE)
	out = 5;
% end neqns(...)

function out = ninputs(DAE)
	out = 0;
% end ninputs(...)

function out = noutputs(DAE)
	out = 5; % [A], [B], [C], [D], [E] 
% end noutputs(...)

function out = nparms(DAE)
	out = 1; % ks - an array.
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0;
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = '2 reactions: A +  B <-> C, C + D <-> E + A';
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out = {'[A]', '[B]', '[C]', '[D]', '[E]'};
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out = {'d[A]/dt', 'd[B]/dt', 'd[C]/dt', 'd[D]/dt', 'd[E]/dt'};
% end eqnnames()

function out = inputnames(DAE)
	out = {};
% end inputnames()

function out = outputnames(DAE)
	out = unknames_DAEAPI(DAE);
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'ks'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	ks(1) = 1.9; % k1: sec^(-1)
	ks(2) = 0.3; %1.3; k2: sec^(-1)
	ks(3) = 1.4; % k3: sec^(-1)
	ks(4) = 0.4; %1.3;  % k4: sec^(-1)

	parmvals = {ks};
% end parmdefaults(...)



%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = f(x, DAE)

	%stoichmat = [ ...
	%	sA1, sA2; ... % determines d/dt [A]
	%	sB , 0  ; ... % determines d/dt [B]
	%	sC1, sC2; ... % determines d/dt [C]
	%	0  , sD ; ... % determines d/dt [D]
	%	0  , sE ; ... % determines d/dt [E]
	%];

	parms = feval(DAE.getparms, DAE);
	ratevec = forwardratefunc(x, parms, DAE);
	stoichmat = stoichmatfunc(DAE);

	out = stoichmat*ratevec;
% end f(...)

function out = q(x, DAE)
	out = -x;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)

	use_finite_diffs = 0;

	if 1 == use_finite_diffs
		n = nunks(DAE);
		delta = 1e-5;
		deltaxs = ones(n,1)*delta;

		fxnom = f(x, DAE); % fxnom is a column vec
		for i=1:n
			xp = x; xp(i) = xp(i) + deltaxs(i); % perturb ith comp.
			fx = f(xp, DAE); % fx is col
			Jf(:,i) = (fx-fxnom)/deltaxs(i);
		end
	else % 0==use_finite_diffs
		parms = feval(DAE.getparms,DAE);
		dR = dforwardratefunc(x, parms, DAE);
		stoichmat = stoichmatfunc(DAE);
		Jf = stoichmat*dR;
	end
% end df_dx(...)

function Jq = dq_dx(x, DAE)
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
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx; % no limiting
% end NRlimiting

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
	ifs.stoichmatfunc = @stoichmatfunc;
	ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
	ifs.forwardratefunc = @forwardratefunc;
	ifs.forwardratefuncUsage = 'feval(forwardratefunc, x, parms, DAE)';
	ifs.dforwardratefunc = @dforwardratefunc;
	ifs.dforwardratefuncUsage = 'feval(dforwardratefunc, x, parms, DAE)';
% end internalfuncs

function stoichmat = stoichmatfunc(DAE)
	sA1 = -1;  % stoichiometric coeff for A, first reaction
	sA2 = +1;  % stoichiometric coeff for A, second reaction
	sB = -1;  % stoichiometric coeff for B
	sC1 = +1; % stoichiometric coeff for C, first reaction
	sC2 = -1; % stoichiometric coeff for C, second reaction
	sD = -1; % stoichiometric coeff for D
	sE = +1; % stoichiometric coeff for E

	stoichmat = [ ...
		sA1, sA2; ... % determines d/dt [A]
		sB , 0  ; ... % determines d/dt [B]
		sC1, sC2; ... % determines d/dt [C]
		0  , sD ; ... % determines d/dt [D]
		0  , sE ; ... % determines d/dt [E]
	];
% end stoichmatfunc

function forwardrates = forwardratefunc(x, parms, DAE)
		ks = parms{1};
		stoichmat = stoichmatfunc(DAE);

		sA1 = stoichmat(1,1); sA2 = stoichmat(1,2);
		sB  = stoichmat(2,1);
		sC1 = stoichmat(3,1); sC2 = stoichmat(3,2);
		sD  = stoichmat(4,2);
		sE  = stoichmat(5,2);

		k1 = ks(1); k2=ks(2); k3=ks(3); k4=ks(4);

		concA = x(1,1); concB = x(2,1); concC = x(3,1); concD = x(4,1);
		concE = x(5,1);

		rate1 = k1*concA^abs(sA1)*concB^abs(sB) ...
					- k2*concC^abs(sC1);
		rate2 = k3*concC^abs(sC2)*concD^abs(sD) ...
					- k4*concE^abs(sE)*concA^abs(sA2);

		forwardrates = [rate1; rate2];
% end forwardratesfunc

function dR = dforwardratefunc(x, parms, DAE)
		ks = parms{1};
		stoichmat = stoichmatfunc(DAE);

		sA1 = stoichmat(1,1); sA2 = stoichmat(1,2);
		sB  = stoichmat(2,1);
		sC1 = stoichmat(3,1); sC2 = stoichmat(3,2);
		sD  = stoichmat(4,2);
		sE  = stoichmat(5,2);

		k1 = ks(1); k2=ks(2); k3=ks(3); k4=ks(4);

		concA = x(1,1); concB = x(2,1); concC = x(3,1); concD = x(4,1);
		concE = x(5,1);

		%rate1 = k1*concA^abs(sA1)*concB^abs(sB) - k2*concC^abs(sC1);
		dR(1,:) = [k1*abs(sA1)*concA^(abs(sA1)-1)*concB^abs(sB), ...
			   k1*concA^abs(sA1)*abs(sB)*concB^(abs(sB)-1), ...
			   - k2*abs(sC1)*concC^(abs(sC1)-1), ...
			   0, ...
			   0];
		%rate2=k3*concC^abs(sC2)*concD^abs(sD)-k4*concE^abs(sE)*concA^abs(sA2);
		dR(2,:) = [- k4*concE^abs(sE)*abs(sA2)*concA^(abs(sA2)-1), ...
				0, ...
			   k3*abs(sC2)*concC^(abs(sC2)-1)*concD^abs(sD), ...
			   k3*concC^abs(sC2)*abs(sD)*concD^(abs(sD)-1), ...
			   - k4*abs(sE)*concE^(abs(sE)-1)*concA^abs(sA2)];
% end dforwardratefunc
%%%%%%%%%%%%%%%% END INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
