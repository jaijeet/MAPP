function DAE = make_DAE(DAEdata, uniqIDstr) % DAEAPIv6.2+delta
%function DAE = make_DAE(DAEdata, uniqIDstr) % DAEAPIv6.2+delta
%returns a DAE (using DAEAPI_common_skeleton) formed from data in DAEdata.
%author: J. Roychowdhury, 2012/06/28
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%returns a DAE (using DAEAPI_common_skeleton) formed from data in DAEdata.
%DAEdata should contain the following fields:
% DAEdata.nameStr
% DAEdata.unknameList
% DAEdata.eqnnameList
% DAEdata.inputnameList
% DAEdata.outputnameList
% DAEdata.parmnameList
% DAEdata.parm_defaults
% 
% One of the following sets of functions should be defined:
%   DAEdata.f
%   DAEdata.df_dx (can be [], in which case df_dx_auto will be used)
%   DAEdata.df_du (can be [], in which case df_du_auto will be used)
%   DAEdata.q
%   DAEdata.dq_dx (can be [], in which case dq_dx_auto will be used)
%   DAEdata.fq_args
% or
%   DAEdata.fqJ
%   DAEdata.fq_args
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string, ID: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('make_DAE');
	if nargin < 2
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff
	DAE.nameStr = DAEdata.nameStr;
	DAE.unknameList = DAEdata.unknameList;
	DAE.eqnnameList = DAEdata.eqnnameList;
	DAE.inputnameList = DAEdata.inputnameList;
	DAE.outputnameList = DAEdata.outputnameList;

	DAE.parmnameList = DAEdata.parmnameList;
	DAE.parm_defaults = DAEdata.parm_defaults;

	DAE.parms = DAEdata.parm_defaults;

	%
% f, q: 
	DAE.fq_args = DAEdata.fq_args;
	DAE.f_takes_inputs = 1;
    if isfield(DAEdata, 'fqJ')
        DAE.int_fqJ = DAEdata.fqJ;
        DAE.fqJ = @fqJ;
    else
        if isfield(DAEdata, 'f')
            DAE.int_f = DAEdata.f;
            DAE.f = @f;
        end
        if isfield(DAEdata, 'q')
            DAE.int_q = DAEdata.q;
            DAE.q = @q;
        end
        %
        % df, dq
        if isfield(DAEdata, 'df_dx') && ~isempty(DAEdata.df_dx)
            DAE.int_df_dx = DAEdata.df_dx;
            DAE.df_dx = @df_dx;
        end
        if isfield(DAEdata, 'dq_dx') && ~isempty(DAEdata.dq_dx)
            DAE.int_dq_dx = DAEdata.dq_dx;
            DAE.dq_dx = @dq_dx;
        end
    end
	if isfield(DAEdata, 'df_du') && ~isempty(DAEdata.df_du)
		DAE.int_df_du = DAEdata.df_du;
		DAE.df_du = @df_du;
	end
	%
end
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	fout = feval(DAE.int_f, x, u, DAE.fq_args);
end
% end f(...)

function qout = q(x, DAE)
	qout = feval(DAE.int_q, x, DAE.fq_args);
end
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)
	Jf = feval(DAE.int_df_dx, x, u, DAE.fq_args);
end
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	Jq = feval(DAE.int_dq_dx, x, DAE.fq_args);
end
% end dq_dx(...)

function dfdu = df_du(x, u, DAE)
	dfdu = feval(DAE.int_df_du, x, u, DAE.fq_args);
end
% end df_du(...)

function fqJout = fqJ(varargin)
	fq = feval(DAE.int_fqJ, varargin{:}, DAE.fq_args);
end
% end fqJ(...)


%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
