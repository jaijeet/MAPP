function DAE = diodeCapIsrc_daeAPIv6(uniqIDstr) 
%function DAE = diodeCapIsrc_daeAPIv6(uniqIDstr)   
% ISRC-diode-capacitor circuit
%author: J. Roychowdhury, 2008/03/06; updates for 219A, 2011/09/18-29
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% ISRC-diode-capacitor circuit, scalar NA equation
% n1 KCL: C d/dt e1 - diode(-e1; Is, Vt) + I(t) = 0
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


%Changelog:
%---------
%2014/01/31: Tianshi Wang <tianshi@berkeley.edu>: nargin checks for backward
%            compatibility
%2013/09/25: Tianshi Wang <tianshi@berkeley.edu>: init/limiting related updates
%2008/03/06: Jaijeet Roychowdhury <jr@berkeley.edu>




%
%
%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('diodeCapIsrc_daeAPIv6');
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

	% setting the QSS/DC input value (for the current source I, in this case)
	DAE.uQSSvec = 1e-3; % DC value of input is set here. Can be updated during runtime with set_uQSS.

	% setting a transient input function (for the current source I)
	mycos = @(t,args) cos(2*pi*args.f*t);
	args.f = 1000;
	DAE = feval(DAE.set_utransient, mycos, args, DAE);
% sizes: 
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.ninputs = @ninputs;
	DAE.noutputs = @noutputs;
	DAE.nlimitedvars = @nlimitedvars;
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
	DAE.support_initlimiting = 1;
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
	% first derivatives with respect to parameters - for sensitivities
	DAE.df_dp  = @df_dp;
	DAE.dq_dp  = @dq_dp;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = 1;
% end nunks(...)

function out = neqns(DAE)
	out = 1;
% end neqns(...)

function out = ninputs(DAE)
	out = 1; % I(t)
% end ninputs(...)

function out = noutputs(DAE)
	out = 1; % e1(t)
% end noutputs(...)

function out = nlimitedvars(DAE)
	out = 0; 
% end noutputs(...)

function out = nparms(DAE)
	out = 3; % Is, Vt, C
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('isrc-diode-capacitor circuit');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	for i = 1:1
		out{i} = sprintf('e%d', i);
	end
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out{1} = sprintf('KCL%d', 1);
% end eqnnames()

function out = inputnames(DAE)
	out = {'I(t)'};
% end inputnames()

function out = outputnames(DAE)
	out = {'e1(t)'};
% end outputnames()

function out = limitedvarnames(DAE)
	out = {};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'Is', 'Vt', 'C'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {1e-12, 0.025, 1e-6};
	%order:{'Is', 'Vt', 'C'};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, xlim, DAE)
	if 2 == nargin
		DAE = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end
	e1 = x(1);
	%idxIs = find(strcmp(DAE.parms, 'Is'));
	%idxVt = find(strcmp(DAE.parms, 'Vt'));
	%Is = parms{idxIs}; Vt = parms{idxVt};
	[Is, Vt, C] = deal(DAE.parms{:});

	dobj = diode;
	% n1 KCL: C d/dt e1 - diode(-e1; Is, Vt) + I(t) = 0
	fout(1,1) = -feval(dobj.f,-e1,Is,Vt);
% end f(...)

function qout = q(x, xlim, DAE)
	if 2 == nargin
		DAE = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end
	e1 = x(1);
	%idxIs = find(strcmp(DAE.parms, 'Is'));
	%idxVt = find(strcmp(DAE.parms, 'Vt'));
	%Is = parms{idxIs}; Vt = parms{idxVt};
	[Is, Vt, C] = deal(DAE.parms{:});

	% n1 KCL: C d/dt e1 - diode(-e1; Is, Vt) + I(t) = 0
	qout(1,1) = C*e1;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, xlim, DAE)
	if 2 == nargin
		DAE = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end
	e1 = x(1);
	%idxIs = find(strcmp(DAE.parms, 'Is'));
	%idxVt = find(strcmp(DAE.parms, 'Vt'));
	%Is = parms{idxIs}; Vt = parms{idxVt};
	[Is, Vt, C] = deal(DAE.parms{:});

	% n1 KCL: C d/dt e1 - diode(-e1; Is, Vt) + I(t) = 0
	dobj = diode;
	[Id, Jf] = feval(dobj.f, -e1, Is, Vt);

	if 2 == nargin
		Jf = Jf + ...
		       feval(DAE.df_dxlim, x, xlim, DAE)...
		       *feval(DAE.xTOxlimMatrix, DAE);
	end
% end df_dx(...)

function Jq = dq_dx(x, xlim, DAE)
	if 2 == nargin
		DAE = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end

	e1 = x(1);
	%idxIs = find(strcmp(DAE.parms, 'Is'));
	%idxVt = find(strcmp(DAE.parms, 'Vt'));
	%Is = parms{idxIs}; Vt = parms{idxVt};
	[Is, Vt, C] = deal(DAE.parms{:});

	% n1 KCL: C d/dt e1 - diode(-e1; Is, Vt) + I(t) = 0
	Jq = C;

	if 2 == nargin
		Jq = Jq + ...
		       feval(DAE.dq_dxlim, x, xlim, DAE) ...
		       *feval(DAE.xTOxlimMatrix, DAE);
	end
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	if (nargin > 1)
	   fprintf(2,'B(x, DAE) not supported yet (needs tensor support first).\n');
	   return;
	end
	out = 1; %
% end B(...)


%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = [1];
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
	out = -0.5;
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
