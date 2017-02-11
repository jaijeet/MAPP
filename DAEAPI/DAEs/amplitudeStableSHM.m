function DAE = amplitudeStableSHM(uniqIDstr, lambda, alpha, k) 
%function DAE = amplitudeStableSHM(uniqIDstr, lambda, alpha, k)   
%DAE for damped simple harmonic motion
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The DAE (damped SHM + nonlinear positive damping)
%
% 
% d/dt [x; y] = lambda*[alpha, -1; 1, 0] *[x; y] + [alpha*lambda*h(x); 0]
%  is equivalent to
% \ddot{x} = -lambda^2 x + alpha*lambda*xdot*(1 + h'(x))
% 
% lambda = 2*pi*f, where f is the natural frequency of oscillation when
%          there is no damping.
% alpha is the damping term. Its absolute value should be in the range [0, 2)
% 	for oscillatory responses (complex eigenvalues); 2 for critical damping;
% 	and >2 for fully damped (real eigenvalues). It should be negative.
%
% h(z) is the nonlinear positive damping term. If its max slope is -1 or
% greater, the system should oscillate. Here, we take it to be:
%
% 	h(z) = tanh(k*z), which has a max slope of k. A good value for k might
%	be -(1+epsilon).
%
% default values: lambda
%	lambda = 2*pi*1000
%	alpha = -0.01
%	k = -1.05
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
%2014/03/02: created: Jaijeet Roychowdhury <jr@berkeley.edu> 
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
	%DAE.nparms = @nparms;
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
	if nargin > 3 && ~isempty(k)
		DAE = feval(DAE.setparms, 'k', k, DAE);
	end
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end uniqID()

function out = daename(DAE)
	out = sprintf('amplitude-stable SHM: ddot{x}=-lambda^2 x + lambda*alpha*dot{x}(1+h''(x))');
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
	out = {'lambda', 'alpha', 'k'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {2*pi*1000, -0.01, -1.05}; % lambda, alpha, k
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(eks, DAE)
	[lambda, alpha, k] = deal(DAE.parms{:});
	fout = - lambda*[alpha, -1; 1, 0]*eks - [alpha*lambda*tanh(k*eks(1)); 0];
% end f(...)

function qout = q(eks, DAE)
	qout = eks;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(eks, DAE)
	[lambda, alpha, k] = deal(DAE.parms{:});
	Jf = - lambda*[alpha, -1; 1, 0];
	Jf(1,1) = Jf(1,1) - k*alpha*lambda*dtanh(k*eks(1));
% end df_dx(...)

function Jq = dq_dx(eks, DAE)
	Jq = eye(2);
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	out = zeros(2, 0); %
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = eye(2);
% end C(...)

function out = D(DAE)
	out = zeros(2, 0); %
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
