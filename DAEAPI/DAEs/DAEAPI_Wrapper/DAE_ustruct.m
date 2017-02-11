function out = DAE_ustruct (U, DAE)

    out = DAE_Bstruct (DAE);

    % U -> inputnames
    for idx = 1 : 1 : length(DAE.inputnameList)
        eval ( ['out.', DAE.inputnameList{idx}, ' = U(idx,1);'] );
    end

end

