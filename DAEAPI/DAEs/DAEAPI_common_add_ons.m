function outDAE = DAEAPI_common_add_ons(DAE)
%function outDAE = DAEAPI_common_add_ons()
%Augments the virtual base class DAEAPI_skeleton_core with various data members.
%This augments the virtual base class DAEAPI_skeleton_core with various data members that are commonly used for many DAEAPIs.
%It also some name and other functions to use these data members.
%
%Typically, this will be used as follows:
%DAE = DAEAPI_skeleton_core;
%DAE = DAEAPI_common_add_ons(DAE);
%followed by further setting up the DAE's data members
%and functions.
%author: J. Roychowdhury, 2011/05/31
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% version, help string: 
	% DAE.Usage = help('DAEAPI_common_add_ons');
	%
	% set up name and parameter lists
	DAE.uniqIDstr = '';
	DAE.nameStr = '';
	DAE.unknameList = {};
	DAE.eqnnameList = {};
	DAE.inputnameList = {};
	DAE.outputnameList = {};
	DAE.limitedvarnameList = {};
	DAE.x_to_xlim_matrix = [];
	DAE.parmnameList =  {};
	DAE.parm_defaults = {};
	DAE.parms = {};
	%
% names
	DAE.uniqID   = @(DAEarg) DAEarg.uniqIDstr;
	DAE.daename   = @(DAEarg) DAEarg.nameStr;
	DAE.name   = @(DAEarg) feval(DAEarg.daename, DAEarg);
	DAE.DAEname   = @(DAEarg) feval(DAEarg.daename, DAEarg);
	DAE.renameUnks = @renameUnks_DAEAPI; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.renameEqns = @renameEqns_DAEAPI; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.renameParms = @renameParms_DAEAPI; % in utils/; but this should be a helper/friend function, not part of the API
	%
% parameter support - see also input- and output-related function sections
	DAE.parmdefaults  = @(DAEarg) DAEarg.parm_defaults;
	DAE.paramdefaults  = @(DAEarg) feval(DAEarg.parmdefaults, DAEarg);
	DAE.parmnames = @(DAEarg) DAEarg.parmnameList;
	DAE.paramnames = @(DAEarg) feval(DAEarg.parmnames, DAEarg);
	DAE.unknames  = @(DAEarg) DAEarg.unknameList; 
	DAE.eqnnames  = @(DAEarg) DAEarg.eqnnameList; 
	DAE.inputnames  = @(DAEarg) DAEarg.inputnameList; 
	DAE.outputnames  = @(DAEarg) DAEarg.outputnameList; 
	DAE.limitedvarnames  = @(DAEarg) DAEarg.limitedvarnameList;
	DAE.getparms  = @default_getparms_DAE; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.getparm  = @default_getparms_DAE; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.getparams  = @default_getparms_DAE; % params more natural for some
	DAE.getparam  = @default_getparms_DAE; % params more natural for some
	DAE.setparms  = @default_setparms_DAE; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.setparm  = @default_setparms_DAE; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.setparams  = @default_setparms_DAE; % params more natural for some
	DAE.setparam  = @default_setparms_DAE; % params more natural for some
	DAE.unkidx  = @unkidx_DAEAPI; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.eqnidx  = @eqnidx_DAEAPI; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.inputidx  = @inputidx_DAEAPI; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.outputidx  = @outputidx_DAEAPI; % in utils/; but this should be a helper/friend function, not part of the API
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp; % not implemented yet
	%DAE.dq_dp  = @dq_dp; % not implemented yet
	%

	DAE.f_takes_inputs = 1; % default is f(x, xlim, u)

	DAE.time_units = 'sec'; % unit of time. Used for plot labels, mainly.

% init
	DAE.NRinitGuess = @(u, DAEarg) zeros(feval(DAEarg.nlimitedvars, DAEarg),1); % default is zeros
	DAE.QSSinitGuess = @(u, DAEarg) zeros(feval(DAEarg.nunks, DAEarg),1); % default is zeros

% limiting
	DAE.xTOxlimMatrix = @xTOxlimMatrix_DAEAPI;
	% DAE.xTOxlim = @(x, DAEarg) feval(DAEarg.xTOxlimMatrix, DAEarg) * x; % commented out by JR 2014/07/05
	DAE.xTOxlim = @default_xTOxlim_DAEAPI; % JR, 2014/07/05

	DAE.NRlimiting = @(x, xlimOld, u, DAEarg) feval(DAEarg.xTOxlim, x, DAEarg); % default is no limiting

% noise
	DAE.NoiseSourceNames = @(DAEarg) {};

    DAE.f = @default_f;
    DAE.q = @default_q;
    %
    DAE.fq = @default_fq;
	outDAE = DAE;
end
% end DAEAPI_common_add_ons "constructor"

function out = xTOxlimMatrix_DAEAPI(DAE)
	if isempty(DAE.x_to_xlim_matrix)
		out = zeros(0, feval(DAE.nunks, DAE)); % JR: Tianshi, is this right?
	else
		out = DAE.x_to_xlim_matrix;
	end
end

function out = default_xTOxlim_DAEAPI(x, DAE)
	if isempty(DAE.x_to_xlim_matrix)
        out = [];
    else
		out = DAE.x_to_xlim_matrix*x;
    end
end

function fout = default_f(varargin)
%function fout = default_f(x, xlim, u, DAE)
% xlim is optional, u is also optional depending on f_takes_inputs
    DAE = varargin{end};
    flag.f = 1; flag.q = 0;
    [fout, qout] = feval(DAE.fq, varargin{1:end-1}, flag, DAE);
end % default_f

function qout = default_q(varargin)
%function qout = default_q(x, xlim, DAE)
% xlim is optional
    DAE = varargin{end};
    flag.f = 0; flag.q = 1;
	if 1 == DAE.f_takes_inputs
		u = zeros(DAE.ninputs(DAE), 1);
		[fout, qout] = feval(DAE.fq, varargin{1:end-1}, u, flag, DAE);
	else
		[fout, qout] = feval(DAE.fq, varargin{1:end-1}, flag, DAE);
	end
end % default_q

function [fout, qout] = default_fq(varargin)
%function [fout, qout] = default_fq(x, xlim, u, flag, DAE)
% xlim is optional
    DAE = varargin{end};
	flag = varargin{end-1};
    if 1 == flag.f
		fout = feval(DAE.f, varargin{1:end-2}, DAE);
    else
        fout = [];
    end

    if 1 == flag.q
		if 1 == DAE.f_takes_inputs
			qout = feval(DAE.q, varargin{1:end-3}, DAE);
		else
			qout = feval(DAE.q, varargin{1:end-2}, DAE);
		end
    else
        qout = [];
    end
end % default_fq
