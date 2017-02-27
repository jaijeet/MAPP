function out = model_exerciser_func(varargin)
%function out = model_exerciser_func(idx, varargin, MEO)
%
% Arguments:
%  - idx: integer scalar or row vector. If it is an integer, it is the index of
%          this function in DAE outputs. If it is a 2-by-1 vector, it is the
%          index of this scalar function in doutputs_dinputs,
%  - varargin: many variables, including inputs and parms.
%               Parms are optional, and are given as parmname/parmval pairs.
%  - MEO: model exerciser object. It should have at least MEO.DAE
%              field, which is a DAE object.
%
    idx = varargin{1};
    MEO = varargin{end}{end}; % varargin{end} is a cell array, it can be
                                   % 1. {MEO} or 
                                   % 2. {parmname1, parmval1, ..., MEO}
    input_cell_array = {varargin{2:end-1}};
    % include parms also in input_cell_array 
    if 1 < length(varargin{end})
        % adds in {parmname1, parmval1, parmname2, parmval2}
        input_cell_array = {input_cell_array{:}, varargin{end}{1:end-1}};
    end

    [uDC, sweepVars, MEO.DAE] = model_exerciser_parse_inputs(...
                            input_cell_array, MEO.DAE);
    % Note: uQSS and parms are set up already in the returned DAE.

    DAE = MEO.DAE;
    % 3 scenarios: calculate a scalar, 1D sweep, 2D sweep  --> a dumb but reliable way
    if 0 == length(sweepVars)
        fprintf('calculating DC operating point...\n');
        dcop = dot_op(DAE);
        qssSol = dcop.getSolution(dcop);
        if 1 == length(idx)
            % qssSol is the vector x. Now we get y = C*x + D*uDC.
            outs = DAE.C(DAE)*qssSol + DAE.D(DAE)*uDC;
            out = outs(idx);
        elseif 2 == length(idx)
            fprintf('calculating output sensitivity at DC operating point...\n');
            inObj = Inputs(DAE);
            SENS = QSSsens(DAE, qssSol, uDC, inObj, 'input');
            outObj = StateOutputs(DAE);
            adjoint = 0; % no point having adjoint
            % The inefficiency is due to the lack of flexibility in DAE outputs.
            SENS = SENS.solve(outObj, adjoint, SENS);
            sol = SENS.getSolution(SENS);
            % sol.Sy is dx_du. Now we get dy_du = C*sol + D. D is optional for MNA.
            outs = DAE.C(DAE)*sol.Sy + DAE.D(DAE);
            out = outs(idx(1), idx(2));
        else
            % TODO: error
        end
    elseif 1 == length(sweepVars)
        fprintf('running DC sweep...\n');
        if strcmp(sweepVars{1}.inputORparm, 'input')
            swp = dcsweep(DAE, [], sweepVars{1}.name, sweepVars{1}.vals);
        else % if strcmp(sweepVars{1}.inputORparm, 'parm')
            swp = dcsweep(DAE, [], sweepVars{1}.name_in_DAE, sweepVars{1}.vals, 0);
        end
        [pts, sols] = swp.getSolution(swp);
        if 1 == length(idx)
            % sols are xs, convert to ys = C*sols. D is neglected because of MNA.
            outs = DAE.C(DAE)*sols;
            out = outs(idx, :);
        elseif 2 == length(idx)
            uDCs = swp.inputs;
            fprintf('calculating output sensitivities...\n');
            inObj = Inputs(DAE);
            outObj = StateOutputs(DAE);
            for c = 1:length(pts)
                uDC = uDCs(:, c);
                qssSol = sols(:, c);
                SENS = QSSsens(DAE, qssSol, uDC, inObj, 'input');
                adjoint = 0;
                SENS = SENS.solve(outObj, adjoint, SENS);
                sol = SENS.getSolution(SENS);
                % sol.Sy is dx_du. Now we get dy_du = C*sol + D. D is optional for MNA.
                outs = DAE.C(DAE)*sol.Sy + DAE.D(DAE);
                out(1, c) = outs(idx(1), idx(2));
            end % for
        else
            % TODO: error
        end
    else % 2 <= length(sweepVars)
        fprintf('running 2D DC sweep...\n');
        if strcmp(sweepVars{1}.inputORparm, 'input')
            if strcmp(sweepVars{2}.inputORparm, 'input')
                swp = dcsweep2(DAE, [], sweepVars{1}.name, sweepVars{1}.vals, 1, ...
                                        sweepVars{2}.name, sweepVars{2}.vals, 1);
            else % if strcmp(sweepVars{2}.inputORparm, 'parm')
                swp = dcsweep2(DAE, [], sweepVars{1}.name, sweepVars{1}.vals, 1, ...
                                 sweepVars{2}.name_in_DAE, sweepVars{2}.vals, 0);
            end
        else % if strcmp(sweepVars{1}.inputORparm, 'parm')
            if strcmp(sweepVars{2}.inputORparm, 'input')
                swp = dcsweep2(DAE, [], sweepVars{1}.name_in_DAE, sweepVars{1}.vals, 0, ...
                                               sweepVars{2}.name, sweepVars{2}.vals, 1);
            else % if strcmp(sweepVars{2}.inputORparm, 'parm')
                swp = dcsweep2(DAE, [], sweepVars{1}.name_in_DAE, sweepVars{1}.vals, 0, ...
                                        sweepVars{2}.name_in_DAE, sweepVars{2}.vals, 0);
            end
        end
        [pts1, pts2, sols] = swp.getSolution(swp);
        if 1 == length(idx)
            % sols are xs, convert to ys = C*sols. D is neglected because of MNA.
            for c = 1:size(sols, 3)
                outs(:, :, c) = DAE.C(DAE)*sols(:, :, c);
            end
            outs = permute(outs, [2 3 1]);
            out = outs(:, :, idx);
        elseif 2 == length(idx)
            uDCs = swp.inputs;
            fprintf('calculating output sensitivities...\n');
            inObj = Inputs(DAE);
            outObj = StateOutputs(DAE);
            for c = 1:length(pts1)
            for d = 1:length(pts2)
                uDC = uDCs(:, c, d);
                qssSol = sols(:, c, d);
                SENS = QSSsens(DAE, qssSol, uDC, inObj, 'input');
                adjoint = 0;
                SENS = SENS.solve(outObj, adjoint, SENS);
                sol = SENS.getSolution(SENS);
                % sol.Sy is dx_du. Now we get dy_du = C*sol + D. D is optional for MNA.
                outs = DAE.C(DAE)*sol.Sy + DAE.D(DAE);
                out(c, d) = outs(idx(1), idx(2));
            end % for d
            end % for c
        else
            % TODO: error
        end
        if 3 <= length(sweepVars)
            for c = 3:length(sweepVars)
                fprintf('Warning: sweeping input %s is ignored.\n', sweepVars{c}.name);
            end
        end
    end
    out = full(out);
end
