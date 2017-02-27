function MOD = setparms_vapp(varargin)
% SETPARMS_VAPP is the substitute for the default setparms_ModSpec function,
% for models translated with VAPP.
%
% The extra functionality in setparms_vapp is:
%
% 1. Keep extra info about which parms are set via the setparms function.
%       > this is required for the $param_given() function in Verilog-A
% 2. Change the unknowns in the model if a parameter affects their type or
% number.
%       > This is required for node collapse.
% 
% Usage: same as setparms_ModSpec, i.e., either
%
% setparms_vapp({'parm_1', 'parm_2', parm_3}, {val_1, val_2, val_3}, MOD);
%
% or
%
% setparms_vapp({{'parm_1', val_1}, {'parm_2', val_2}, {'parm_3', val_3}}, MOD);
%
% or
%
% setparms_vapp('single_parm_name', single_parm_val, MOD);
%
% or
%
% setparms_vapp({'single_parm_name', single_parm_val}, MOD);

    nCellArr = nargin - 1;

    if nCellArr < 1
        error(['Insufficient number of input arguments. Please see the',...
               ' help for "setparms_vapp" or "setparms_ModSpec" for examples.']);
    elseif nCellArr > 2
        error(['Too many input arguments. Please see the help for',...
               ' "setparms_vapp" or "setparms_ModSpec" for examples.']);
    elseif nCellArr == 1
        parmNameValArr = varargin{1};

        if iscell(parmNameValArr{1}) == false
            parmNameValArr = {{parmNameValArr{1}, parmNameValArr{2}}};
        end

        nParm = numel(parmNameValArr);
        parmNameArr = cell(1, nParm);
        parmValArr = cell(1, nParm);

        for i = 1:nParm
            parmNameValPair = parmNameValArr{i};
            parmNameArr{i} = parmNameValPair{1};
            parmValArr{i} = parmNameValPair{2};
        end
    elseif nCellArr == 2
        parmNameArr = varargin{1};
        parmValArr = varargin{2};

        if iscell(parmNameArr) == false
            parmNameArr = {parmNameArr};
        end

        if iscell(parmValArr) == false
            parmValArr = {parmValArr};
        end

        nParm = numel(parmNameArr);
    end

    MOD = varargin{end};

    % Irrespective of what the original input format was, at this point we have
    % two cell arrays (parmNameArr and parmValArr).

    modParmNameArr = MOD.parm_names;
    parmIdxVec = zeros(1, nParm);
    for i = 1:nParm
        parmIdx = find(strcmp(parmNameArr{i}, modParmNameArr));
        if isempty(parmIdx) == true
            error('Error setting parameter %s: parameter not found', parmNameArr{i});
        end
        parmIdxVec(i) = parmIdx;
        MOD.parm_given_flag(parmIdx) = 1;
    end

    MOD = setparms_ModSpec(parmNameArr, parmValArr, MOD);
end
