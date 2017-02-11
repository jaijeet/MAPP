function DAE = ArcContDAE(uniqIDstr, n, tangent_fn_handle, funcargs) 
%function DAE = ArcContDAE(uniqIDstr, n, tangent_fn_handle, funcargs) 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The is a DAEAPI description of the Arclength Continuation ODE:
% 	d/ds [x(s); lambda(s)] - tangent( dg_dxLambda(x(s), lambda(s)) ) = 0;
%
% s is the arclength. Not to be confused with the Laplace variable s.
%
% - n is the dimension of x (and of g). Lambda is a _single_ scalar parameter.
%
% [NOT NEEDED:
% - g_handle is a function handle that evaluates g. It should be callable as:
%   - gout = feval(g_handle, [x; lambda], funcargs);
%   - gout should be column vector of size n.
% ]
%
% - tangent_fn_handle is a function handle that returns a normalized tangent
%   vector in the right direction. It should be callable as:
%   - tangent = feval(tangent_fn_handle, [x; lambda], funcargs);
%   - funcargs.priorTangent must be available (an n-vector of norm 1),
%     tangent_fn_handle needs to use it to set the direction.
%
% - to facilitate updates of priorTangent, a special function 
%   DAE.SetPriorTangent is available for ArcContDAE. To use it, simply do
%   DAE = feval(DAE.SetPriorTangent, newtangent, DAE);
%
% - funcargs should also have information pertaining to:
%   - NRlimiting
%   - QSSinitGuess
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2011/11/25                                         %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%
% version, help string, ID: 
    DAE = DAEAPI_common_skeleton(); % default template
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('ArcContDAE');
	if nargin < 4
		fprintf(2,'error: ArcContDAE needs 4 arguments');
		DAE.Usage
		DAE = [];
		return;
	else
		DAE.uniqIDstr = uniqIDstr;
		DAE.n = n;
		DAE.tangent_fn_handle = tangent_fn_handle;
		DAE.funcargs = funcargs;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff
	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	DAE.parms = parmdefaults(DAE);
	%
	DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
	DAE.utfunc =  'unassigned'; % needed for transient analysis. Should become a function call.
	DAE.utargs =  'unassigned'; % needed for transient analysis. Should become a structure.
	DAE.Uffunc =  'unassigned'; % needed for AC/SSS analysis. Should become a function call.
	DAE.Ufargs =  'unassigned'; % needed for AC/SSS analysis. should become a structure
	%
% sizes: 
	DAE.nunks    = @nunks;
	DAE.neqns    = @neqns;
	DAE.ninputs  = @ninputs;
	DAE.noutputs = @noutputs;
	%
% f, q: 
	DAE.f_takes_inputs = 0; % there are no inputs
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx;
	DAE.dq_dx = @dq_dx; 
	%DAE.df_du = @df_du; not needed: f_takes_inputs = 0;
	%
% input-related functions
	DAE.set_utransient = @set_utransient; % must be vectorized wrt t
	DAE.utransient = @utransient;
	DAE.set_uQSS = @set_uQSS;
	DAE.uQSS = @uQSS;
	DAE.set_uLTISSS = @set_uLTISSS; % must be vectorized wrt f
	DAE.uLTISSS = @uLTISSS;
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
	DAE.QSSinitGuess = @QSSinitGuess; % FIXME: need to do something sensible here with funcargs
	%
% NR limiting support
	DAE.NRlimiting = @NRlimiting; % FIXME: need to do something sensible here with funcargs
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames_DAEAPI;
	DAE.getparms  = @default_getparms_DAE;
	DAE.setparms  = @default_setparms_DAE;
	% first derivatives with respect to parameters - for sensitivities
	DAE.df_dp  = 'undefined';
	DAE.dq_dp  = 'undefined';
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
% extra functions for Arclength Continuation
	DAE.DAEupdateFuncPerTimepoint = @DAEupdateFuncPerTimepoint;
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = DAE.n + 1; % y = [x;lambda]
% end nunks(...)

function out = neqns(DAE)
	out = DAE.n + 1; % tangent vector has this many entries
% end neqns(...)

function out = ninputs(DAE)
	out = 0;
% end ninputs(...)

function out = noutputs(DAE)
	out = 0; 
% end noutputs(...)

function out = nparms(DAE)
	out = 0; 
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; %
% end nNoiseSources(...)

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('ArcContDAE');
% end daename()

%unknames is in unknames.m
function out = setup_unknames(DAE)
	for i=1:DAE.n
		out{i} = sprintf('x%d',i);
	end
	out{DAE.n+1} = sprintf('lambda');
% end unknames()

%eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	for i=1:DAE.n
		out{i} = sprintf('eqn%d',i);
	end
% end eqnnames()

function out = inputnames(DAE)
	out = {};
% end inputnames()

function out = outputnames(DAE)
	out = {};
% end outputnames()

%parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(y, DAE)
	% 	d/ds [x(s); lambda(s)] - tangent( dg_dxLambda(x(s), lambda(s)) ) = 0;
	% y = [x; lambda];
	% x = y(1:(end-1),1);
	% lambda = y(end,1);

	% prior to this call, DAE.funcargs.priorTangent should have
	% been set using DAE.SetPriorTangent. tangent_fn_handle
	% needs priorTangent to determine the tangent vector
	% uniquely
	[fout, success] = feval(DAE.tangent_fn_handle, y, DAE.funcargs);
	fout = -fout;
	% TODO: need to modify DAEAPI/NR/LMS/etc to use success
% end f(...)

function qout = q(y, DAE)
	qout = y;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% df_dx is not needed for solving the arclength continuation DAE, but our
% implementation of NR evaluates it even for explicit methods like FE. So we 
% return zeros.
function Jf = df_dx(y, DAE)
	Jf = sparse(DAE.n+1, DAE.n+1);
% end df_dx

function Jq = dq_dx(y, DAE)
	Jq = speye(DAE.n+1,DAE.n+1);
% end dq_dx

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	out = []; % but not used
% end B(...)

% set_utransient is in set_utransient.m
% utransient is in utransient.m
% set_uQSS is in set_uQSS.m
% uQSS is in uQSS.m
% set_uLTISSS is in set_uLTISSS.m
% uLTISSS is in uLTISSS.m

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = [];
% end C(...)

function out = D(DAE)
	out = [];
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = zeros(DAE.n,1); % should be updated to something more sensible
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, uold, DAE)
	newdx = dx; % should be updated to something more sensible
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	% unit PSDs; all the action is moved to m(x,n)
	out = 'undefined';
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
function outDAE = DAEupdateFuncPerTimepoint(snew, ynew, DAE)
    % DAE.funcargs is the entire ArcContAnalObj - ArcCont.m, lines 378-381
    dbglvl = DAE.funcargs.ArcContParms.dbglvl;
    if dbglvl >= 2
        % to detect if walked over a bifurcation, print out sign of 
        % det(dH_dy(y); t'(y));
	    [tangent, success, J] = feval(DAE.tangent_fn_handle, ...
                ynew, DAE.funcargs); % TODO: worry about using success
        detsign = sign(det([J; tangent']));
        if detsign ~= DAE.funcargs.priorDetSign
            fprintf(2, '\tat lambda=%g: just stepped over a simple bifurcation point\n', ... 
                ynew(end,1));
        end
        if dbglvl >= 3
            fprintf(2, '\tsign(det([J; tangent'']))=%g\n', detsign);
        end
        DAE.funcargs.priorDetSign = detsign;
    else
	    [tangent, success] = feval(DAE.tangent_fn_handle, ...
                    ynew, DAE.funcargs); % TODO: worry about using success
    end
	DAE.funcargs.priorTangent = tangent;
	outDAE = DAE;
% end DAEupdateFuncPerTimepoint
