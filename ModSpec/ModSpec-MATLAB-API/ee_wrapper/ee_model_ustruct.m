function out = ee_model_ustruct (vecU, MOD)
%Author: Karthik V Aadithya, 2013/11
    
% Changelog
% ---------
%2014/02/09: Tianshi Wang, <tianshi@berkeley.edu>: added vecLim in q
%2013/11: Karthik V Aadithya, <aadithya@berkeley.edu>

    %{
    out = [];

    % vecU -> u_names
    for idx = 1 : 1 : length(MOD.u_names)
        eval ( ['out.', MOD.u_names{idx}, ' = vecU(idx,1);'] );
    end

    % parameters
	parm_vals = MOD.getparms(MOD);
    for idx = 1 : 1 : length(MOD.parm_names)
        eval ( ['out.', MOD.parm_names{idx}, ' = parm_vals{idx};'] );
    end
    %}


    if ~isempty(MOD.u_names)
        fieldnames = MOD.u_names;
        oof = vecU;
        if isobject(oof) % ie, vecvalder
            cvals = oof{:};
        else % numeric/logical
            cvals = num2cell(oof);
        end
    else
        fieldnames = {};
        cvals = {};
    end

    if ~isempty(MOD.parm_vals)
        fieldnames = {fieldnames{:}, MOD.parm_names{:}};
        cvals = {cvals{:}, MOD.parm_vals{:}};
    end

    out = cell2struct(cvals, fieldnames, 2);
end
