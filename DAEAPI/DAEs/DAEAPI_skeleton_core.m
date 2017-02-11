function DAE = DAEAPI_skeleton_core()
%function DAE = DAEAPI_skeleton_core()
%This is the core of a virtual base class for DAEAPI. It defines a template for the API.
%The core restricts itself
%to defining the "official" DAEAPI functions only.
%
%Note that most/all of the size functions are defined
%to work correctly.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% version, help string: 
	DAE.version = 'DAEAPI v6.2+';
	DAE.Usage = help('DAEAPI_skeleton_core');
	%
% sizes: 
	DAE.nunks = @(DAEarg) length(feval(DAEarg.unknames,DAEarg)); 
	DAE.neqns = @(DAEarg) length(feval(DAEarg.eqnnames,DAEarg)); 
	DAE.ninputs = @(DAEarg) length(feval(DAEarg.inputnames,DAEarg)); 
	DAE.noutputs = @(DAEarg) length(feval(DAEarg.outputnames,DAEarg)); 
	DAE.nlimitedvars = @(DAEarg) length(feval(DAEarg.limitedvarnames, DAEarg)); 
	%
% f, q: 
	DAE.f_takes_inputs = 'undefined';
	DAE.f = 'undefined'; % should become a function handle
	DAE.q = 'undefined'; % should become a function handle
	DAE.fq = 'undefined'; % should become a function handle
	%
% df, dq
	DAE.df_dx = 'undefined';
	DAE.df_dxlim = 'undefined';
	DAE.df_du = 'undefined';
	DAE.dq_dx = 'undefined';
	DAE.dq_dxlim = 'undefined';
	DAE.fqJ = 'undefined'; % should become a function handle
	%
% input-related functions
	DAE.set_utransient = 'undefined'; % must be vectorized wrt t; defined in utils/
	DAE.utransient = 'undefined'; % defined in utils
	DAE.set_uMultitime = 'undefined'; % defined in utils/
	DAE.uMultitime = 'undefined'; % defined in utils
	DAE.set_uQSS = 'undefined'; % defined in utils
	DAE.uQSS = 'undefined'; % defined in utils
	DAE.set_uLTISSS = 'undefined'; % must be vectorized wrt f; defined in utils/
	DAE.uLTISSS = 'undefined'; % defined in utils
	DAE.uHB = 'undefined'; % defined in utils/
	DAE.set_uHB = 'undefined'; %  defined in utils/
	%
	DAE.B = 'undefined';
	%
% output-related functions
	DAE.C = 'undefined';
	DAE.D = 'undefined';
	%
% names
	DAE.uniqID   = 'undefined'; % uniqIDstr is not part of the API: @(DAEarg) DAEarg.uniqIDstr;
	DAE.daename   = 'undefined'; % nameStr is not part of the API: @(DAEarg) DAEarg.nameStr;
	DAE.unknames  = 'undefined'; % should become a valid function handle
	DAE.eqnnames  = 'undefined'; % should become a valid function handle
	DAE.inputnames  = 'undefined';  % should become a valid function handle
	DAE.outputnames  = 'undefined'; % should become a valid function handle
	DAE.limitedvarnames = 'undefined'; % should become a valid function handle
	%{ 
	these are not part of the API
	DAE.renameUnks = @renameUnks; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.renameEqns = @renameEqns; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.renameParms = @renameParms; % in utils/; but this should be a helper/friend function, not part of the API
	%}
	%
	DAE.time_units = 'undefined'; % unit of time. Used for plot labels, mainly.
% QSS initial guess support
	% xinit = DAE.QSSinitGuess(u, DAEarg);
	DAE.NRinitGuess = 'undefined';
	DAE.QSSinitGuess = 'undefined'; % tianshi: only used for keeping backward compatibility
	%
% NR limiting support
    DAE.support_initlimiting = 0; % set up by default as 0, if init/limiting is
	                              % ever needed, turn it to be 1
	DAE.xTOxlim = 'undefined';
	DAE.xTOxlimMatrix = 'undefined';
	% xlim = DAE.NRlimiting(x, xlimOld, u, DAEarg);
	DAE.NRlimiting = 'undefined';
	DAE.dNRlimiting_dx = 'undefined';
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @(DAEarg) length(feval(DAEarg.parmnames,DAEarg));
	DAE.nparams = @(DAEarg) length(feval(DAEarg.parmnames,DAEarg));
	DAE.parmdefaults  = 'undefined'; % parm_defaults is not part of the API @(DAEarg) DAEarg.parm_defaults;
	DAE.paramdefaults  = 'undefined'; % param more natural for some
	DAE.parmnames = 'undefined'; % parmnameList is not part of the API @(DAEarg) DAEarg.parmnameList;
	DAE.paramnames = 'undefined'; % param more natural for some
	%{
	these should not be a part of the API
	DAE.getparms  = @default_getparms_DAE; % in utils/; but this should be a helper/friend function, not part of the API
	DAE.setparms  = @default_setparms_DAE; % in utils/; but this should be a helper/friend function, not part of the API
	%}
	% first derivatives with respect to parameters - for sensitivities
	DAE.dfq_dp  = 'undefined';
	DAE.df_dp  = 'undefined';
	DAE.dq_dp  = 'undefined';
	%
% helper functions exposed by DAE
	DAE.internalfuncs = 'undefined';
	%
% functions for supporting noise
	% 
	DAE.nNoiseSources = @(DAEarg) length(feval(DAEarg.NoiseSourceNames,DAEarg));
	DAE.NoiseSourceNames = 'undefined';
	DAE.NoiseStationaryComponentPSDmatrix = 'undefined';% @NoiseStationaryComponentPSDmatrix;
	DAE.m = 'undefined'; %@m;
	DAE.dm_dx = 'undefined'; %@dm_dx;
	DAE.dm_dn = 'undefined'; %@dm_dn;
	%
end
% end DAEAPI_skeleton_core "constructor"
