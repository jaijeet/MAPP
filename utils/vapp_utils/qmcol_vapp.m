function out = qmcol_vapp(condition, thenStatement, elseStatement)
    if condition
        out = thenStatement;
    else
        out = elseStatement;
    end
end
