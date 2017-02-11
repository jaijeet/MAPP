function out = OutputMatrix_ModSpec(inMOD)
    if ~isempty(inMOD.output_matrix)
        out = inMOD.output_matrix;
    else
        out = zeros(0, length(feval(inMOD.ExplicitOutputNames, inMOD)) +...
               length(feval(inMOD.ImplicitEquationNames, inMOD)));
    end
end % vecXYtoLimitedVarsMatrix_ModSpec

