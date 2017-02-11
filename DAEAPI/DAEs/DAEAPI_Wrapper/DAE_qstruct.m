function out = DAE_qstruct (X, XLIM, DAE)
    
    % X -> unknames
    for idx = 1 : 1 : length(DAE.unknameList)
        eval ( ['out.', DAE.unknameList{idx}, ' = X(idx,1);'] );
    end

    % XLIM -> limitedvarnames
    for idx = 1 : 1 : length(DAE.limitedvarnameList)
        eval ( ['out.', DAE.limitedvarnameList{idx}, ' = XLIM(idx,1);'] );
    end

    % parameters
    for idx = 1 : 1 : length(DAE.parmnameList)
        eval ( ['out.', DAE.parmnameList{idx}, ' = DAE.parms{idx};'] );
    end

	out.DAE = DAE;
end

