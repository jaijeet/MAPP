function DAE = dampedSHM(uniqIDstr, lambda, alpha) 
%function DAE = dampedSHM(uniqIDstr, lambda, alpha)   
%DAE for damped simple harmonic motion
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The DAE for damped SHM (see 290a Spring 2014 slides on oscillators)
% 
% \ddot{x} = -lambda^2 x + alpha*lambda*xdot, written as:
% 	d/dt [x; y] = lambda*[alpha, -1; 1, 0] *[x; y]
% 
% lambda = 2*pi*f, where f is the natural frequency of oscillation when
%	there is no damping.
%
% alpha is the damping term. Its absolute value should be in the range [0, 2)
%   for oscillatory responses (complex eigenvalues); 2 for critical damping;
%   and >2 for fully damped (real eigenvalues). It should be negative.
% 
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
%2014/03/01: created: Jaijeet Roychowdhury <jr@berkeley.edu> 
%
%
%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('parallelRLC');
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
	if nargin > 1 && ~isempty(lambda)
		DAE = feval(DAE.setparms, 'lambda', lambda, DAE);
	end
	if nargin > 2 && ~isempty(alpha)
		DAE = feval(DAE.setparms, 'alpha', alpha, DAE);
	end
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = 2;
% end nunks(...)

function out = neqns(DAE)
	out = 2;
% end neqns(...)

function out = ninputs(DAE)
	out = 0; 
% end ninputs(...)

function out = noutputs(DAE)
	out = 2; % x, y
% end noutputs(...)

function out = nparms(DAE)
	out = 2; % lambda, alpha
% end nparms(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('damped SHM: ddot{x}=-lambda^2 x + lambda*alpha*dot{x}');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out{1} = sprintf('x');
	out{2} = sprintf('y');
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out{1} = sprintf('dx/dt');
	out{2} = sprintf('dy/dt');
% end eqnnames()

function out = inputnames(DAE)
	out = {};
% end inputnames()

function out = outputnames(DAE)
	out = {'x(t)', 'y(t)'};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'lambda', 'alpha'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {2*pi*1000, 0.01}; % lambda, alpha
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(eks, DAE)
	[lambda, alpha] = deal(DAE.parms{:});
	fout = - lambda*[alpha, -1; 1, 0]*eks;
% end f(...)

function qout = q(eks, DAE)
	qout = eks;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
	[lambda, alpha] = deal(DAE.parms{:});
	Jf = - lambda*[alpha, -1; 1, 0];
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	Jq = eye(2);
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	out = []; %
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = eye(2);
% end C(...)

function out = D(DAE)
	out = [];
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
