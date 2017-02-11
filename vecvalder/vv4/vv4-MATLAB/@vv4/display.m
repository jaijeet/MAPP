function display (obj)
    
    % this function displays vv4 objects, and 1-D arrays of vv4 objects
    
    n = length(obj);

    for idx = 1:1:n

        curr_obj = obj(idx);

        if n > 1
            disp(['Index ', num2str(idx), ':'])
        end

        if ~isa(curr_obj, 'vv4')
            disp('NOT a vv4 object:')
            disp(curr_obj)
        else
            disp('vv4 object: ');
            disp(['         idx = ', num2str(curr_obj.idx)]);
            disp(['        Type = ', curr_obj.Type]);
            if strcmp(curr_obj.Type, 'INDEP')
                disp(['        name = ', num2str(curr_obj.val)]);
            elseif strcmp(curr_obj.Type, 'CONST')
                disp(['         val = ', toString(curr_obj.val, 'disp')]);
            elseif strcmp(curr_obj.Type, 'FUNC')
                disp(['          op = ', curr_obj.op]);
                disp(['    children = ', num2str(curr_obj.children)]);
            else
                disp(['vv4 display: Unrecognized vv4 object type: ', curr_obj.Type]);
            end
            if idx ~= n
                disp(' ')
            end
        end

    end

end

