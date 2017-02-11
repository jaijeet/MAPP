function MOD = ModSpec_skeleton_core()
%function MOD = ModSpec_skeleton_core()
%This defines the basic ModSpec API by setting up all the required fields
%(mostly to placeholders). The fields of MOD are:
%
% % name, descriptions, etc.
%    .ModelName:    (function handle) returns a short name for the model 
%                      structure/equations. (Eg, DAAV6, BSIM3))
%                      Use: modname = feval(MOD.ModelName, MOD)
%
%    .name:         (function handle) returns a short name for the element 
%                      (string). Use: elname = feval(MOD.name, MOD)
%
%    .description:  (function handle) returns a description (string) for
%                      the model.  Use: desc = feval(MOD.description, MOD)
%
% % parameter access
%    .parmnames/paramnames:    (function handle) returns a cell array of unique
%                      parameter names (strings). Use: names = ...
%                      feval(MOD.parmnames, MOD)
%              
%    .parmdefaults/paramdefaults: (function handle) returns a cell array of
%                      default parameter values.  Use: vals = ...
%                                   feval(MOD.parmdefaults, MOD)
%
%    .nparms/nparams: (function handle) returns an integer, the number of ...
%                       all parameters
%
% % variable name and index functions:
%    .IOnames:      (function handle) returns a cell array of all IO names
%                      (strings) for the device/model. 
%                      (Set up automatically for EE devices using NIL functions 
%                      defining node names and reference node name).
%                      Use: ionames = feval(MOD.IOnames, MOD)
%
%    .ExplicitOutputNames: (function handle) returning a cell array of 
%                      explicit output names (strings). The order specifies
%                      specifies the order of vecZ and the outputs of fe/qe.
%                      Use: eonames = feval(MOD.ExplicitOutputNames, MOD)
%
%    .OtherIONames: (function handle) returning a cell array of names
%                   (strings) of the otherIOs'. Defines the order of the
%                   unknowns in vecX. This is derived automatically
%                   Use: oionames = feval(MOD.OtherIONames, MOD)
%
%    .InternalUnkNames: (function handle) returning a cell array of
%                      internal unknown names (strings). Specifies the order 
%                      of vecY.
%                      Use: iunames = feval(MOD.InternalUnkNames, MOD)
%
%    .ImplicitEquationNames: (function handle) returning a cell array of
%                      the names (strings) of the implicit equations of the
%                      model.  Defines the order of the outputs of fi() and 
%                      qi().
%                      Use: ienames = feval(MOD.ImplicitEquationNames, MOD)
%
%    .uNames:       (function handle) returning a cell array of the names
%                      of the time-dep functions (ie, vecUs) in the model.
%                      Defines the order of vecU. Should be set up manually be
%                      the model writer.
%                      Use: unames = feval(MOD.uNames, MOD)
%
%  % Core model functions
%
%    .fe: (function handle) that evaluates fe. Use:
%               vecZf = feval(MOD.fe, vecX, vecY, vecU, MOD)
%            Returns a column vector of doubles.
%
%    .qe: (function handle) that evaluates qe. Use:
%               vecZq = feval(MOD.qe, vecX, vecY, MOD) 
%            Returns a column vector of doubles.
%
%    .fi: (function handle) that evaluates fi. Use:
%               vecWf = feval(MOD.fi, vecX, vecY, vecU, MOD) 
%            Returns a column vector of doubles.
%
%    .qi: (function handle) that evaluates qi. Use:
%               vecWq = feval(MOD.qi, vecX, vecY, MOD) 
%            Returns a column vector of doubles.
%
%    .fqei: (function handle) that evaluates fe/qe/fi/qi. Use:
%           [vecZf, vecZq, vecWf, vecWq] = fqei_all(vecX, vecY, vecU, flag, MOD)
%           where flag contains .fe, .fi, .qe, .qi fields each with possible
%           values 0/1
%
%    Requirement: return values of .fqei must be consistent with those of
%    fe/fi/qe/qi
%
%  % Output support
%    .OutputNames: (function handle) returning a cell array of output names
%                  (strings). Use:
%               onames = feval(MOD.OutputNames, MOD)
%            Returns a cell array of strings
%
%    .OutputMatrix: (function handle) returning the matrix that converts
%                   [vecZ, vecW] to vecO (corresponds to .OutputNames. Use:
%               outputMat = feval(MOD.OutputMatrix, MOD) 
%
%  % init/limiting support
%    
%    .support_initlimiting: (bool/int)
%           0 --> the model doesn't support init/limiting (default value)
%           1 --> the model supports init/limiting
%
%    When .support_initlimiting is 1, ModSpec API has to have
%    fields/requirements below:
%
%    .LimitedVarNames: (function handle) returning a cell array of the names
%                      of the limited variables (ie, vecUs) in the model.
%                      Defines the order of vecU. Should be set up manually be
%                      the model writer.
%                      Use: lvnames = feval(MOD.LimitedVarNames, MOD)
%
%    .vecXYtoLimitedVarsMatrix: (function handle) that returns a matrix. Use:
%            vecXY_to_vecLim_mat = feval(MOD.vecXYtoLimitedVarsMatrix, MOD)
%            such that when without init/limiting
%            vecLim = vecXY_to_vecLim_mat * [vecX; vecY];
%
%    .vecXYtoLimitedVars: (function handle) that returns col vector vecLim 
%            corresponding to LimitedVarNames when init/limiting is not in
%            effect. Use:
%            vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
%    TODO: figure out the proper dependency of the above two fields. Currently
%          vecXYtoLimitedVars is implemented on vecXYtoLimitedVarsMatrix.
%          It may be a better idea to flip the dependency.
%
%    .initGuess: (function handle) that returns col vector vecLim 
%            corresponding to LimitedVarNames when initialization is in effect.
%            Use:
%            vecLimInit = feval(MOD.initGuess, vecX, vecY, MOD);
%
%    .limiting: (function handle) that returns col vector vecLim 
%            corresponding to LimitedVarNames when limiting is in effect.
%            Use:
%            vecLimNew = feval(MOD.limiting, vecX, vecY, vecLimOld, vecU, MOD);
%
%    Requirements: when .support_initlimiting is 1, fe/fi/qe/qi/fqei should
%    support both calling syntax:
%    feval(MOD.fe, vecX, vecY, vecU, MOD)
%                     <--> feval(MOD.fe, vecX, vecY, vecLim, vecU, MOD)
%    feval(MOD.qe, vecX, vecY, MOD)
%                     <--> feval(MOD.qe, vecX, vecY, vecLim, MOD)
%    feval(MOD.fi, vecX, vecY, vecU, MOD)
%                     <--> feval(MOD.fi, vecX, vecY, vecLim, vecU, MOD)
%    feval(MOD.qi, vecX, vecY, MOD)
%                     <--> feval(MOD.qi, vecX, vecY, vecLim, MOD)
%    feval(MOD.fqei, vecX, vecY, vecU, flag, MOD)
%                     <--> feval(MOD.fqei, vecX, vecY, vecLim, vecU, flag, MOD)
%    when vecLim is not provided, it is calculated in fe/fi/qe/qi/fqei as
%    vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
%
%
%Examples
%--------
%  ModSpec_skeleton_core() is typically called at the beginning of a model
%  definition to set up the fields to default values. See, eg,
%  ModSpec_common_skeleton.m and resModSpec.m. 
%
%See also
%--------
%  
%  ModSpec, ModSpec_common_skeleton, ModSpec_common_add_ons,
%  ModSpec_derivative_add_ons, resModSpec, capModSpec, diodeModSpec,
%  vsrcModSpec, isrcModSpec, EbersMoll_BJT_ModSpec.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Authors: Jaijeet Roychowdhury, Tianshi Wang, Karthik Aadithya               %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% name, descriptions: 
	MOD.ModelName   = 'UNDEFINED: string'; % this is a short name for the model structure/equations
	MOD.name   = 'UNDEFINED: string'; % this is a short name for the element
	MOD.description = 'UNDEFINED: string'; % description

% parameter support: needs update for model/device/environment dichotomy
	MOD.parmnames = 'UNDEFINED: function handle returning a cell array of strings';
	MOD.paramnames = 'UNDEFINED: function handle returning a cell array of strings';
	MOD.parmdefaults  = 'UNDEFINED: function handle returning a cell array of values';
	MOD.paramdefaults  = 'UNDEFINED: function handle returning a cell array of values';
	% derived number of parms
	MOD.nparms = @(inMOD) length(feval(inMOD.parmnames, inMOD));
	MOD.nparams = @(inMOD) length(feval(inMOD.parmnames, inMOD));

% variable name and index functions:
	MOD.IOnames  = 'UNDEFINED: function handle returning a cell array of strings'; % cell array of all IO names. Should be of size 2n
		% auto set up (for EE devices) using NIL functions defining node names and reference node name
	MOD.ExplicitOutputNames  = 'UNDEFINED: function handle returning a cell array of strings'; % cell array, specifies order of vecZ and fe/qe
		% should be written manually
	MOD.InternalUnkNames  = 'UNDEFINED: function handle returning a cell array of strings'; % cell array, specifies order of vecY. 
		% should be written  manually
	MOD.ImplicitEquationNames = 'UNDEFINED: function handle returning a cell array of strings';
		% specifies order of fi and qi
		% should be written manually.
	MOD.uNames  = 'UNDEFINED: function handle returning a cell array of strings'; % names of the time-dep functions, specifies order of vecU
		% should be written manually.

	% derived from IOnames and ExplicitOutputIndices
	MOD.OtherIONames  = 'UNDEFINED: function handle returning a cell array of strings'; % cell array, specifies order of vecX

% Core functions: fe, qe, fi, qi:
	MOD.fi = 'UNDEFINED: function handle returning a column vector of doubles'; % fi(vecX, vecY, vecU, MOD)
	MOD.fe = 'UNDEFINED: function handle returning a column vector of doubles'; % fe(vecX, vecY, vecU, MOD)
	MOD.qi = 'UNDEFINED: function handle returning a column vector of doubles'; % qi(vecX, vecY, MOD)
	MOD.qe = 'UNDEFINED: function handle returning a column vector of doubles'; % qe(vecX, vecY, MOD)
	MOD.fqei = 'UNDEFINED: function handle returning vectors of doubles'; % fqei(vecX, vecY, vecU, MOD)
		% [fe, fi, qe, qi] = feval(MOD.fqei, vecX, vecY, vecU, MOD);

%  % Output support
	MOD.OutputNames = 'UNDEFINED: function handle returning a cell array of strings'; % cell array, specifies order of vecO
	MOD.OutputMatrix = 'UNDEFINED: function handle returning a matrix'; % transformation matrix from [vecZ; vecW] to vecO

% Newton-Raphson initialization/limiting support
	MOD.support_initlimiting = 0; % set up by default as 0, if init/limiting is
	                              % ever needed, turn it to be 1
	%
	MOD.vecXYtoLimitedVarsMatrix = 'UNDEFINED: function handle returning a matrix'; % transformation matrix from [vecX; vecY] to vecLim
	MOD.vecXYtoLimitedVars = 'UNDEFINED: function handle returning a column vector of doubles'; % transforms vecX, vecY to vecLim
	MOD.LimitedVarNames = 'UNDEFINED: function handle returning a cell array of strings'; % cell array, specifies order of vecLim
	%
	MOD.initGuess = 'UNDEFINED: function handle returning a column vector of doubles';
	    % vecLim = initGuess(vecU, MOD);
	%
	MOD.limiting = 'UNDEFINED: function handle returning a column vector of doubles';
	    % vecLim = limiting(vecX,vecY,vecLimOld, vecU, MOD);

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support
end % ModSpec_skeleton_core
