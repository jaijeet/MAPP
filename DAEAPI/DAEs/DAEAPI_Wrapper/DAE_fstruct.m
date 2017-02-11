function out = DAE_fstruct (X, XLIM, U, DAE)

    out = DAE_qstruct (X, XLIM, DAE);

    % U -> inputnames
    for idx = 1 : 1 : length(DAE.inputnameList)
        eval ( ['out.', DAE.inputnameList{idx}, ' = U(idx,1);'] );
    end
end
