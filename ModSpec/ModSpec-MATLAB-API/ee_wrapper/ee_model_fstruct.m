function out = ee_model_fstruct (vecX, vecY, vecLim, vecU, MOD)
%Author: Karthik V Aadithya, 2013/11

% Changelog
% ---------
%2014/02/09: Tianshi Wang, <tianshi@berkeley.edu>: added vecLim in f
%2013/11: Karthik V Aadithya, <aadithya@berkeley.edu>

    
    fieldnames = {MOD.OtherIO_names{:}, MOD.internal_unk_names{:}, ...
                    MOD.limited_var_names{:}, MOD.u_names{:}, ...
                    MOD.parm_names{:}};

    oof = vecX; % vecX should never be empty if the device has any IOs
    if ~isempty(vecY)
        oof = [oof; vecY];
    end
    if ~isempty(vecLim)
        oof = [oof; vecLim];
    end
    if ~isempty(vecU)
        oof = [oof; vecU];
    end

    if isobject(oof) % ie, vecvalder
        cvals = oof{:};
    else % numeric/logical
        cvals = num2cell(oof);
    end
    cvals = {cvals{:}, MOD.parm_vals{:}};
    out = cell2struct(cvals, fieldnames, 2);

    % vecU -> u_names
    %{
    out = ee_model_qstruct (vecX, vecY, vecLim, MOD);
    for idx = 1 : 1 : length(MOD.u_names)
        eval ( ['out.', MOD.u_names{idx}, ' = vecU(idx,1);'] );
    end
    %}

end

