function out = vecXYtoLimitedVarsMatrix_ModSpec(inMOD)
    if ~isempty(inMOD.vecXY_to_limitedvars_matrix)
        out = inMOD.vecXY_to_limitedvars_matrix;
    else
        out = zeros(0, length(feval(inMOD.OtherIONames, inMOD)) +...
               length(feval(inMOD.InternalUnkNames, inMOD)));
    end
end % vecXYtoLimitedVarsMatrix_ModSpec


