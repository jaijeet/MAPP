
function vecLim = vecXYtoLimitedVars_ModSpec(vecX, vecY, inMOD)
    vecXY_to_limitedvars_matrix = feval(inMOD.vecXYtoLimitedVarsMatrix, inMOD);
    if ~isempty(vecXY_to_limitedvars_matrix)
        if isempty(vecY)
            vecLim = vecXY_to_limitedvars_matrix * [vecX];
        elseif isempty(vecX)
            vecLim = vecXY_to_limitedvars_matrix * [vecY];
        else
            vecLim = vecXY_to_limitedvars_matrix * [vecX;vecY];
        end
    else
        vecLim = [];
    end
end % vecXYtoLimitedVars_ModSpec

