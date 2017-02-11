% ModSpec is MAPP's way of specifying a device. A ModSpec object should have
% the following API functions:
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
%                      parameter names (strings). 
%                      Use: names = feval(MOD.parmnames, MOD)
%              
%    .parmdefaults/paramdefaults: (function handle) returns a cell array of
%                      default parameter values.  
%                      Use: vals = feval(MOD.parmdefaults, MOD)
%
%    .nparms/nparams: (function handle) returns an integer, the number of all
%                      parameters
%
%    .getparms/getparams: (function handle) returns the current value of some
%                      or all parameters.
%                      Use: allparmvals = feval(MOD.getparms, MOD)
%                                OR
%                           parmval = feval(MOD.getparms, 'my_parm', MOD)
%                                OR
%                           parmvals = feval(MOD.getparms, {'parm1', ...
%                                                                'parm2', MOD)
%
%    .setparms/setparams: (function handle) sets the current value of some
%                      or all parameters.
%                      Use: MOD = feval(MOD.setparms, allparmvals, MOD)
%                           % allparmvals should be a cell array of all
%                           % parameter values
%                                OR
%                           MOD = feval(MOD.setparms, 'my_parm', newval, MOD)
%                                OR
%                           MOD = feval(MOD.getparms, {'parm1', 'parm2'}, ...
%                                       {newval1, newval2}, MOD)
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
%                      (strings) of the otherIOs'. Defines the order of the
%                      unknowns in vecX. This is derived automatically
%                      Use: oionames = feval(MOD.OtherIONames, MOD)
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
%           where flag contains .fe, .fi, .qe, .qi fields, each with a possible
%           value of 0 or 1.
%
%    Requirements: return values of .fqei must be consistent with those of
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
%    .support_initlimiting: (bool/logical/int)
%           0 --> the model doesn't support init/limiting (default value)
%           1 --> the model supports init/limiting
%
%    When .support_initlimiting is 1, ModSpec API has to have the
%    fields/requirements below:
%
%    .LimitedVarNames: (function handle) that returns a cell array of the names
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
%    .vecXYtoLimitedVars: (function handle) that returns a col vector vecLim 
%            corresponding to LimitedVarNames when init/limiting is not in
%            effect. Use:
%            vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
%    TODO: figure out the proper dependency of the above two fields. Currently
%          vecXYtoLimitedVars is implemented based on vecXYtoLimitedVarsMatrix.
%          It may be a better idea to flip the dependency.
%
%    .initGuess: (function handle) that returns a col vector vecLim 
%            corresponding to LimitedVarNames when initialization is in effect.
%            Use:
%            vecLimInit = feval(MOD.initGuess, vecU, MOD);
%
%    .limiting: (function handle) that returns a col vector vecLim 
%            corresponding to LimitedVarNames when limiting is in effect.
%            Use:
%            vecLimNew = feval(MOD.limiting, vecX, vecY, vecLimOld, vecU, MOD);
%
%    Requirements: when .support_initlimiting is 1, fe/fi/qe/qi/fqei should
%    support both calling syntaxes:
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
%  % initiate a ModSpec object
%  MOD = exampleModSpec('M1');
%
%  % runs all ModSpecAPI functions, checks the sizes of return values
%  check_ModSpec(MOD);
%
%See also
%--------
%  
%  ModSpec, ModSpec_concepts, ModSpec_wrapper, resModSpec, capModSpec, 
%  diodeModSpec, vsrcModSpec, isrcModSpec, EbersMoll_BJT_ModSpec
