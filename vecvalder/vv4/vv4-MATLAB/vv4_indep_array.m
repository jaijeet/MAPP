function out = vv4_indep_array (count, names)
    
    % this function creates and returns an independent array of valder objects
        % count: integer
            % how many independent valder objects to create
        % names: cell array of strings, of size count
            % the names for the independent variables created

    out = [];
    
    if isempty(names)
        names = {};
        for idx = 1:1:count
            names = [names, ['INDEP_', num2str(idx)]];
        end
    end

    for idx = 1:1:count
        obj = vv4('INDEP', names{idx});
        out = [out; obj];
    end

end

