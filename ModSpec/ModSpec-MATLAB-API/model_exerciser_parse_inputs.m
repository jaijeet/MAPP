function [uDC, sweepVars, DAE] = model_exerciser_parse_inputs(input_cell_array, DAE)
%
% TODO: 
%
    sweepVars = {};

    input_names = DAE.inputnames(DAE);
    ninputs = length(input_names);
    if 0 == ninputs
        uDC = []; % shouldn't happen TODO: warnings
    else
        for c = 1:ninputs
            if 1 < length(input_cell_array{c})
                uDC(c, 1) = input_cell_array{c}(1);
                sweepVar.name = input_names{c};
                sweepVar.inputORparm = 'input';
                sweepVar.idx = c;
                sweepVar.vals = input_cell_array{c};
                sweepVars = {sweepVars{:}, sweepVar};
                clear sweepVar;
            else
                uDC(c, 1) = input_cell_array{c};
            end
        end
    end

    DAE = DAE.set_uQSS(uDC, DAE);

    % handle parameters:
    offset = ninputs;
    if offset < length(input_cell_array)
        parmpairs = {input_cell_array{(offset+1):end}}; % {parmname1, parmval1, parmname2, parmval2}
        if 0 ~= mod(length(parmpairs), 2)
            error('parameters must be provided in name/val pairs.');
        end
        for c = 1:length(parmpairs)/2
            if 1 < length(parmpairs{2*c}) && ~ischar(parmpairs{2*c})
            %TODO: proper support of parm sweeping requires knowing parm type.
            %      Unlike inputs, where a vector indicates a variable to sweep,
            %      parms can be vectors or even matrices themselves.
                sweepVar.inputORparm = 'parm';
                sweepVar.name = parmpairs{2*c-1};
                sweepVar.name_in_DAE = ['M:::', parmpairs{2*c-1}];
                sweepVar.vals = parmpairs{2*c};
                DAE = DAE.setparms(sweepVar.name_in_DAE, parmpairs{2*c}(1), DAE);
                sweepVars = {sweepVars{:}, sweepVar};
                clear sweepVar;
            else
                parmname_in_DAE = ['M:::', parmpairs{2*c-1}];
                DAE = DAE.setparms(parmname_in_DAE, parmpairs{2*c}, DAE);
            end
        end
    end
end % model_exerciser_parse_inputs
