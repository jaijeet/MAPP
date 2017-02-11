function out = vv4 (firstarg, secondarg, thirdarg)
%function out = vv4 (firstarg, secondarg, thirdarg)
%vv4 constructor.
%
% This is vv4, an object-oriented utility that helps export ModSpec models to 
% other formats.
%
% Each vv4 object (obj) contains the following fields:
%
%     obj.idx: the idx (1-based) of the current object in vv4_global_array
%
%     obj.Type: a string specifying the vv4 object's type. Supported types 
%               include 'INDEP', 'CONST', and 'FUNC'.
%
%     obj.name: name of the object (currently useful only for INDEP objects)
%
%     obj.val: a value associated with the vv4 object (currently useful only 
%              for CONST objects)
%
%     obj.op: a short string describing the operation carried out by this vv4 
%             object. Examples include 'SIN', 'COS', 'STRCMP', etc. (currently 
%             useful only for FUNC objects)
%
%     obj.children: a row vector of 1-based vv4_global_array indices indicating 
%                   the vv4 objects used as arguments for the op function above
%                   (currently useful only for FUNC objects)
%
% Author: Aadithya V. Karthik, Jul 1 2014
%
    global vv4_global_array;

    hash_const = 0; % 0 if you don't want to hash, 1 if you want to hash

    if nargin == 0
        % no built-in vv4 function uses this
        % but sometimes, MATLAB tries to upconvert an empty matrix or such into 
        % vv4 at which time this function is called with no arguments
        % for now I'm just returning a CONST 0 vv4 in this case
        out = vv4('CONST', 0.0);
        return;
    end

    if nargin == 1
        % no built-in vv4 function uses this
        % but sometimes, MATLAB tries to upconvert constants to vv4, at which 
        % time this function is called with one argument, the value of the 
        % constant being upconverted
        out = vv4('CONST', firstarg);
        return;
    end

    % I assume nargin == 2 or nargin == 3
    S.idx = length(vv4_global_array) + 1;
    S.Type = firstarg;
    if strcmp(S.Type, 'INDEP')
        S.name = secondarg;
        S.val = 0.0;
        S.op = '';
        S.children = [];
    elseif strcmp(S.Type, 'CONST')
        S.name = '';
        S.val = secondarg;
        S.op = '';
        S.children = [];
    elseif strcmp(S.Type, 'FUNC')
        S.name = '';
        S.val = 0.0;
        S.op = secondarg;
        S.children = thirdarg;
    end

    if hash_const > 0.5 && strcmp(S.Type, 'CONST')
        match_found = 0;
        for idx = 1:1:length(vv4_global_array)
            curr = vv4_global_array(idx);
            if ~strcmp(curr.Type, 'CONST')
                continue;
            end
            if isinteger(curr.val) && isinteger(S.val) && curr.val == S.val
                match_found = 1;
                matching_const = curr;
            elseif isfloat(curr.val) && isfloat(S.val) && curr.val == S.val
                match_found = 1;
                matching_const = curr;
            elseif ischar(curr.val) && ischar(S.val) && strcmp(curr.val, S.val)
                match_found = 1;
                matching_const = curr;
            elseif islogical(curr.val) && islogical(S.val) && curr.val == S.val
                match_found = 1;
                matching_const = curr;
            end
            if match_found > 0.5
                out = matching_const;
                return;
            end
        end
    end

    out = class(S, 'vv4');
    vv4_global_array = [vv4_global_array; out];

end

