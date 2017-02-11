function out = DAE_Bstruct (DAE)
    % parameters
    for idx = 1 : 1 : length(DAE.parmnameList)
        eval ( ['out.', DAE.parmnameList{idx}, ' = DAE.parms{idx};'] );
    end

	out.DAE = DAE;
end

