function DAE = nestedFoldsDAE(uniqIDstr) 
%function DAE = nestedFoldsDAE(uniqIDstr)   
% This is just a DAE version (for testing purposes) of test_ArcCont_folds_nested.m
%author: J. Roychowdhury, 2009/11/08; updates 2011/11/05
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %0.5*x + tanh(-x) has a max and a min as a function of x, somewhere in the range [-1, 1]
% %g(x, lambda) = 0.5*x + tanh(-x) - lambda = 0 should have folds
% slope1 = 0.5;%0.9;
% slope2 = 0.3;
% g_h = @(y, args) [y(1,1)*slope1 + tanh(-y(1,1)) - y(3,1); y(2,1)*slope2 + tanh(-y(2,1)) - y(3,1)];
% dg_dxLambda_h = @(y, args) [slope1-dtanh(-y(1,1)), 0, -1; 0, slope2-dtanh(-y(2,1)), -1];
%
% n = 2 system
% x = [y(1); y(2)]
%
% 1 input: lambda
% 2 outputs: y(1) and y(2)
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
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('nestedFoldsDAE');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff
	DAE.nameStr = sprintf('nested folds DAE');
	DAE.unknameList = {'y1', 'y2'}; 
	DAE.eqnnameList = {'eq1', 'eq2'}; 
	DAE.inputnameList = {'lambda'};
	DAE.outputnameList = DAE.unknameList;

	DAE.parmnameList = {'slope1', 'slope2'};

	% Parameters from Figure 2 of Goldbeter's paper
	DAE.parm_defaults = {0.5, 0.3};

	DAE.parms = DAE.parm_defaults;
% f, q: 
	DAE.f_takes_inputs = 0;
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx;
	DAE.dq_dx = @dq_dx;
	%DAE.df_du = @df_du;
	%DAE.df_dp = @df_dp;
	%
% input-related functions
% output-related functions
	% what makes sense here for transient, LTISSS, etc.?
	DAE.B = @B;
	DAE.C = @C;
	DAE.D = @D;
	%
% names
	DAE.time_units = 'sec';
	%
% QSS initial guess support
	DAE.QSSinitGuess = @QSSinitGuess;
	%
% parameter support - see also input- and output-related function sections
	%DAE.parmdefaults  = @parmdefaults;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp;
	%DAE.dq_dp  = @dq_dp;
	% data: current values of parameters, can be changed by setparms
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
%

% input-related functions
	% discontinued: DAE.b = @btransient; DAE.bQSS; DAE.bLTISSS; 
	% setting a transient input function (for the current source I)
	mysin = @(t,args) sin(2*pi*args.f*t);
	args.f = 5e6;
	DAE = set_utransient(mysin, args, DAE);
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, DAE)
	y1 = x(1); y2 = x(2);
	[slope1, slope2] = deal(DAE.parms{:});

	%y(1,1)*slope1 + tanh(-y(1,1)) - y(3,1);
	fout(1,1) = slope1*y1 + tanh(-y1); % - lambda taken care of by B

	%y(2,1)*slope2 + tanh(-y(2,1)) - y(3,1)
	fout(2,1) = slope2*y2 + tanh(-y2); % - lambda taken care of by B
% end f(...)

function qout = q(x, DAE)
	qout = zeros(2,1);
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
	y1 = x(1); y2 = x(2);
	[slope1, slope2] = deal(DAE.parms{:});


	%y(2,1)*slope2 + tanh(-y(2,1)) - y(3,1)

	% y1	y2
	% 1	2

	%y(1,1)*slope1 + tanh(-y(1,1)) - y(3,1);
	Jf(1,1) = slope1 - dtanh(-y1);

	%y(2,1)*slope2 + tanh(-y(2,1)) - y(3,1)
	%fout(2,1) = slope2*y2 + tanh(-y2); % - lambda taken care of by B
	Jf(2,2) = slope2 - dtanh(-y2);
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	Jq = sparse(2,2);
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	%y(1,1)*slope1 + tanh(-y(1,1)) - y(3,1);
	%y(2,1)*slope2 + tanh(-y(2,1)) - y(3,1)
	out = [-1; -1]; %
% end B(...)

% set_utransient is in set_utransient.m
% utransient is in utransient.m
% set_uQSS is in set_uQSS.m
% uQSS is in uQSS.m
% set_uLTISSS is in set_uLTISSS.m
% uLTISSS is in uLTISSS.m

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = [1,0; 0,1];
% end C(...)

function out = D(DAE)
	out = [0;0];
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	if u < 0
		out = [-1;-1]; % 
	else
		out = [1;1]; % 
	end
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs = 'No internal functions exposed by this DAE system.';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
