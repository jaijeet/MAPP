function out = vv4_array_to_string(arr, num_format)
    
    % converts a vv4 array (assumed to be 1D) into a string
    
    if nargin == 0
        arr = [];
    end

    if nargin < 2
        num_format = '%1.12e';
    end

    global vv4_global_array;

    output_idxs = [];
    for idx = 1:1:length(arr)
        vv4_obj = arr(idx);
        if ~isa(vv4_obj, 'vv4')
            vv4_obj = vv4('CONST', vv4_obj);
        end
        output_idxs = [output_idxs, vv4_obj.idx];
    end

    out = '';

    for idx = 1:1:size(vv4_global_array, 1)

        S = vv4_global_array(idx);

        out = [out, num2str(S.idx), ' ', S.Type];
        if strcmp(S.Type, 'CONST')
            % a constant, which could be a numeric or a Bool or a string
            if isinteger(S.val)
                out = [out, ' INT ', int2str(S.val)];
            elseif isfloat(S.val)
                out = [out, ' FLOAT ', num2str(S.val, num_format)];
            elseif ischar(S.val)
                out = [out, ' CHAR ', '''', S.val, ''''];
            elseif islogical(S.val)
                if S.val
                    out = [out, ' BOOL True'];
                else
                    out = [out, ' BOOL False'];
                end
            else
                error(['ERROR: Unrecognized CONST type for vv4 object: ', toString(S.val)]);
            end
        elseif strcmp(S.Type, 'INDEP')
            out = [out, ' ', S.name];
        elseif strcmp(S.Type, 'FUNC')
            out = [out, ' ', S.op];
            children = S.children;
            for tmp_idx = 1:1:length(children)
                out = [out, ' ', int2str(children(tmp_idx))];
            end
        else
            error(['ERROR: Unrecognized vv4 object type: ', S.Type]);
        end

        out = [out, '\n'];

    end

    for idx = 1:1:length(output_idxs)
        out = [out, 'OUT ', int2str(idx), ' ', int2str(output_idxs(idx)), '\n'];
    end

end

