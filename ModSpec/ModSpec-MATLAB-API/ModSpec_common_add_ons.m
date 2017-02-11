function outMOD = ModSpec_common_add_ons(MOD)
%function outMOD = ModSpec_common_add_ons(MOD)
%This defines additional data members for a common way of implementing the
%ModSpec API. It also defines default API functions that use these data
%members.
%INPUT args:
%   MOD         - base for ModSpec object
%OUTPUT:
%   outMOD      - ModSpec object with default data members and API functions.

%author: J. Roychowdhury.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% common data members
    MOD.uniqID = 'UNDEFINED: string';
    MOD.model_name = 'UNDEFINED: string';
    MOD.model_description = 'UNDEFINED: string';

    MOD.parm_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.parm_defaultvals = {'UNDEFINED:', 'cell', 'array', 'of', 'values'};
    MOD.parm_vals = {'UNDEFINED:', 'cell', 'array', 'of', 'values'};
    MOD.parm_given = []; % default: empty; will contain indices of parameters that have been
                         % set by add_element or by calls to setparms

    MOD.explicit_output_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.internal_unk_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.implicit_equation_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.u_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.NIL.node_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.NIL.refnode_name = 'UNDEFINED: string';
    MOD.IO_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.OtherIO_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.NIL.io_types = {'UNDEFINED:', 'cell', 'array', 'of', 'strings', '''v''', 'or', '''i'''};
    MOD.NIL.io_nodenames = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};

    MOD.output_names = {};
    MOD.output_matrix = [];

    MOD.limited_var_names = {};
    MOD.vecXY_to_limitedvars_matrix = [];

% default API functions, using the above data members
    MOD.name = @(inMOD) inMOD.uniqID;
    MOD.ModelName = @(inMOD) inMOD.model_name;
    MOD.description = @(inMOD) inMOD.model_description;
    %
    MOD.getparms = @getparms_ModSpec;
    MOD.getparams = @(varargin) MOD.getparms(varargin{:});
    MOD.setparms = @setparms_ModSpec;
    MOD.setparams = @(varargin) MOD.setparms(varargin{:});
    MOD.parmnames = @(inMOD) inMOD.parm_names;
    MOD.paramnames = @(varargin) MOD.parmnames(varargin{:});
    MOD.getparmtypes = @getparmtypes_ModSpec;
    MOD.getparamtypes = @(varargin) MOD.getparamtypes(varargin{:});
    MOD.parmdefaults = @(inMOD) inMOD.parm_defaultvals;
    MOD.paramdefaults = @(varargin) MOD.parmdefaults(varargin{:});
    %
    MOD.ExplicitOutputNames = @(inMOD) inMOD.explicit_output_names;
    MOD.IOnames = @(inMOD) inMOD.IO_names;
    MOD.OtherIONames = @(inMOD) inMOD.OtherIO_names;
    MOD.uNames = @(inMOD) inMOD.u_names;
    MOD.InternalUnkNames = @(inMOD) inMOD.internal_unk_names;
    MOD.ImplicitEquationNames = @(inMOD) inMOD.implicit_equation_names;
    %
    MOD.OutputNames = @(inMOD) inMOD.output_names;
    MOD.OutputMatrix = @OutputMatrix_ModSpec;
    %
    MOD.LimitedVarNames = @(inMOD) inMOD.limited_var_names;
    MOD.vecXYtoLimitedVarsMatrix = @vecXYtoLimitedVarsMatrix_ModSpec;
    MOD.vecXYtoLimitedVars = @vecXYtoLimitedVars_ModSpec;
    MOD.initGuess = @default_initGuess;
    MOD.limiting = @default_limiting;
    %
    MOD.fe = @default_fe;
    MOD.fi = @default_fi;
    MOD.qe = @default_qe;
    MOD.qi = @default_qi;
    %
    MOD.fqei = @default_fqei;

    outMOD = MOD;
end % ModSpec_common_add_ons

function vecLim = default_initGuess(vecU, inMOD)
    vecLim = zeros(size(feval(inMOD.LimitedVarNames, inMOD), 2),1);
end % default_initGuess

function vecLim = default_limiting(vecX,vecY,vecLimOld, vecU, inMOD)
    vecLim = feval(inMOD.vecXYtoLimitedVars, vecX, vecY, inMOD);
end % default_limiting

function [feout, qeout, fiout, qiout] = default_fqei(varargin)
%function [feout, qeout, fiout, qiout] = default_fqei(vecX, vecY, vecLim, vecU, flag, MOD)
% vecLim is optional
    MOD = varargin{end};
	flag = varargin{end-1};
    if 1 == flag.fe
		feout = feval(MOD.fe, varargin{1:end-2}, MOD);
    else
        feout = [];
    end

    if 1 == flag.qe
        qeout = feval(MOD.qe, varargin{1:end-3}, MOD);
    else
        qeout = [];
    end

    if 1 == flag.fi
        fiout = feval(MOD.fi, varargin{1:end-2}, MOD);
    else
        fiout = [];
    end

    if 1 == flag.qi
        qiout = feval(MOD.qi, varargin{1:end-3}, MOD);
    else
        qiout = [];
    end
end % default_fqei

function feout = default_fe(varargin)
%function feout = default_fe(vecX, vecY, vecLim, vecU, MOD)
% vecLim is optional
    MOD = varargin{end};
    flag.fe = 1; flag.qe = 0; flag.fi = 0; flag.qi = 0;
    [feout, qeout, fiout, qiout] = feval(MOD.fqei, varargin{1:end-1}, flag, MOD);
end % default_fe

function qeout = default_qe(varargin)
%function qeout = default_qe(vecX, vecY, vecLim, MOD)
% vecLim is optional
    MOD = varargin{end};
    flag.fe = 0; flag.qe = 1; flag.fi = 0; flag.qi = 0;
    [feout, qeout, fiout, qiout] = feval(MOD.fqei, varargin{1:end-1}, [], flag, MOD);
end % default_qe

function fiout = default_fi(varargin)
%function fiout = default_fi(vecX, vecY, vecLim, vecU, MOD)
% vecLim is optional
    MOD = varargin{end};
    flag.fe = 0; flag.qe = 0; flag.fi = 1; flag.qi = 0;
    [feout, qeout, fiout, qiout] = feval(MOD.fqei, varargin{1:end-1}, flag, MOD);
end % default_fi

function qiout = default_qi(varargin)
%function qiout = default_qi(vecX, vecY, vecLim, MOD)
% vecLim is optional
    MOD = varargin{end};
    flag.fe = 0; flag.qe = 0; flag.fi = 0; flag.qi = 1;
    [feout, qeout, fiout, qiout] = feval(MOD.fqei, varargin{1:end-1}, [], flag, MOD);
end % default_qi
