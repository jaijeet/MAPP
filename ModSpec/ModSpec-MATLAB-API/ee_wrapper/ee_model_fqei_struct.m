function out = ee_model_fqei_struct(vecX, vecY, vecLim, vecU, flag, MOD)
%Author: Bichen Wu <bichen@berkeley.edu> 05/21/2014

%Changlog:
%---------
%2014-07-26: Tianshi Wang <tianshi@berkeley.edu>: added flag.qi/qe checks.
%     Without them, when evaluating qe or qi, vecU is often set to be [],
%     but for vsrc or isrc, fieldname will contain u_names, causing cvals
%     to be shorter than fieldnames.
    if 0 == flag.fi && 0 == flag.fe
        fieldnames = {MOD.OtherIO_names{:}, MOD.internal_unk_names{:}, ...
                        MOD.limited_var_names{:}, MOD.parm_names{:}};
    else
        fieldnames = {MOD.OtherIO_names{:}, MOD.internal_unk_names{:}, ...
                        MOD.limited_var_names{:}, MOD.u_names{:}, ...
                        MOD.parm_names{:}};
    end

    oof = vecX; % vecX should never be empty if the device has any IOs
    if ~isempty(vecY)
        oof = [oof; vecY];
    end
    if ~isempty(vecLim)
        oof = [oof; vecLim];
    end
    if 0 == flag.fi && 0 == flag.fe
    else
        if ~isempty(vecU)
            oof = [oof; vecU];
        end
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
    out = ee_model_qstruct(vecX, vecY, vecLim, MOD);
    for idx = 1 : 1 : length(MOD.u_names)
        eval(['out.', MOD.u_names{idx}, ' = vecU(idx,1);']);
    end
    %}
    
    out.flag = flag;
end

