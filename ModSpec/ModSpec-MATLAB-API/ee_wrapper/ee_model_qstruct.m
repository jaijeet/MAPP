
function out = ee_model_qstruct (vecX, vecY, vecLim, MOD)
%Author: Karthik V Aadithya, 2013/11
    
% Changelog
% ---------
%2014/02/09: Tianshi Wang, <tianshi@berkeley.edu>: added vecLim in q
%2013/11: Karthik V Aadithya, <aadithya@berkeley.edu>

    % vecX -> OtherIO_names
    %{
    for idx = 1 : 1 : length(MOD.OtherIO_names)
        eval ( ['out.', MOD.OtherIO_names{idx}, ' = vecX(idx,1);'] );
    end

    % vecY -> internal_unk_names
    for idx = 1 : 1 : length(MOD.internal_unk_names)
        eval ( ['out.', MOD.internal_unk_names{idx}, ' = vecY(idx,1);'] );
    end

    % vecLim -> limited_var_names
    for idx = 1 : 1 : length(MOD.limited_var_names)
        eval ( ['out.', MOD.limited_var_names{idx}, ' = vecLim(idx,1);'] );
    end

    % parameters
	parm_vals = MOD.getparms(MOD);
    for idx = 1 : 1 : length(MOD.parm_names)
        eval ( ['out.', MOD.parm_names{idx}, ' = parm_vals{idx};'] );
    end
    %}

    fieldnames = {MOD.OtherIO_names{:}, MOD.internal_unk_names{:}, ...
                    MOD.limited_var_names{:}, MOD.parm_names{:}};

    oof = vecX; % vecX should never be empty if the device has any IOs
    if ~isempty(vecY)
        oof = [oof; vecY];
    end
    if ~isempty(vecLim)
        oof = [oof; vecLim];
    end

    if isobject(oof) % ie, vecvalder
        cvals = oof{:};
    else % numeric/logical
        cvals = num2cell(oof);
    end
    cvals = {cvals{:}, MOD.parm_vals{:}};
    out = cell2struct(cvals, fieldnames, 2);
end

