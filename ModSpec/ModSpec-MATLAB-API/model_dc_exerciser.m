function MEO = model_dc_exerciser(MOD)

%

    % In this model exerciser, we are going to connect each terminal of the device
    % model to an independent voltage or current source. Then we can evaluate and
    % plot various model functions while sweeping the values of these independent
    % sources. 
    % 
    % Now we are going to ask you to specify whether to connect a voltage source (V)
    % or a current source (I) to each terminal.
    % 
    % Choose V or I for terminal d. [V]:
    % Choose V or I for terminal g. [V]:
    % Choose V or I for terminal s. [V]:

    fprintf('\n');
    fprintf('In this model exerciser, we are going to connect each terminal of the device\n');
    fprintf('model to an independent voltage or current source. Then we can evaluate and\n');
    fprintf('plot various model functions while sweeping the values of these independent\n');
    fprintf('sources. \n');
    fprintf('\n');

    fprintf('Now we are going to ask you to specify whether to connect a voltage source (V)\n');
    fprintf('or a current source (I) to each terminal.\n');
    fprintf('\n');

    terminal_names = MOD.NIL.NodeNames(MOD);
    terminal_VorIs = {};
    for c = 1:length(terminal_names)
        terminal_name = terminal_names{c}; 
        prompt = sprintf('Choose V or I for terminal %s. [V]: ', terminal_name);
        while(1)
            str = input(prompt, 's');
            if isempty(str) || strcmp(str, 'V') || strcmp(str, 'v')
                terminal_VorIs{c} = 'V'; 
                fprintf('Terminal %s is connected to a voltage source V%s.\n', terminal_name, terminal_name);
                break;
            elseif strcmp(str, 'I') || strcmp(str, 'i')
                terminal_VorIs{c} = 'I'; 
                fprintf('Terminal %s is connected to a current source I%s.\n', terminal_name, terminal_name);
                break;
            else
                fprintf('Please type either V or I.\n');
            end
        end
    end
    MEO.terminal_VorIs = terminal_VorIs;

    MEO.MOD = MOD;

    % construct circuit
    fprintf('\n\nconstructing test bench circuit...\n');
    ckt.cktname = 'Model Exerciser Circuit';
    ckt.nodenames = terminal_names;
        % set up a unique ground name, not fully tested yet
        uniquegroundname = 'gnd';
        found = 1;
        while(found)
            idx = strmatch(uniquegroundname, terminal_names);
            if isempty(idx)
                found = 0;
            else
                found = 1;
                uniquegroundname = [uniquegroundname, sprintf('%d', randi(10)-1)];
            end
        end
    ckt.groundnodename = uniquegroundname;
    ckt = add_element(ckt, MOD, 'M', terminal_names);
    for c = 1:length(terminal_names)
        terminal_name = terminal_names{c}; 
        if strcmp(terminal_VorIs{c}, 'V')
            ckt = add_element(ckt, vsrcModSpec(), ['V', terminal_name], {terminal_name, uniquegroundname});
        else % if strcmp(terminal_VorIs{c}, 'I')
            ckt = add_element(ckt, isrcModSpec(), ['I', terminal_name], {terminal_name, uniquegroundname});
        end
    end
    MEO.ckt = ckt;

    % construct DAE
    fprintf('converting circuit into DAE...\n');
    DAE = MNA_EqnEngine(ckt);

    % add to DAE outputs all the quantities we are interested in
    % Note: outputs are modified through output_matrix, output_names.
    %       May not be robust.
    output_names = {};
    for c = 1:length(terminal_names)
        terminal_name = terminal_names{c}; 
        if strcmp(terminal_VorIs{c}, 'V')
            output_names = {output_names{:}, ['I', terminal_name]};
            unk_name = ['V', terminal_name, ':::ipn'];
            idx = DAE.unkidx(unk_name, DAE);
            output_matrix(c, idx) = -1;
        else % if strcmp(terminal_VorIs{c}, 'I')
            output_names = {output_names{:}, ['V', terminal_name]};
            unk_name = ['e_', terminal_name];
            idx = DAE.unkidx(unk_name, DAE);
            output_matrix(c, idx) = 1;
        end
    end
    DAE.output_names = output_names;
    DAE.output_matrix = output_matrix;
    DAE.Dmat = zeros(length(output_names), DAE.ninputs(DAE)); % always zero for MNA
    %
    DAE.outputnames = @(inDAE) inDAE.output_names;
    DAE.noutputs = @(inDAE) length(inDAE.output_names);
    DAE.C = @(inDAE) inDAE.output_matrix;
    DAE.D = @(inDAE) inDAE.Dmat;
    MEO.output_names = output_names;
    % done modifying DAE's outputs
    % TODO: There should be better ways of doing this.

    % modify DAE input names, get rid of ":::E" and ":::I"
    input_names = DAE.inputnames(DAE);
    for c = 1:length(terminal_names)
        terminal_name = terminal_names{c}; 
        if strcmp(terminal_VorIs{c}, 'V')
            input_name = ['V', terminal_name, ':::E'];
            idx = DAE.inputidx(input_name, DAE);
            input_names{idx} = ['V', terminal_name];
        else % if strcmp(terminal_VorIs{c}, 'I')
            input_name = ['I', terminal_name, ':::I'];
            idx = DAE.inputidx(input_name, DAE);
            input_names{idx} = ['I', terminal_name];
        end
    end
    DAE.input_names = input_names;
    DAE.inputnames = @(inDAE) inDAE.input_names;
    MEO.input_names = input_names;
    % done renaming DAE's inputs
    MEO.DAE = DAE;

    % construct model exerciser function handles
    fprintf('setting up model exerciser functions...\n');
    input_names = DAE.inputnames(DAE); % redundant
    output_names = DAE.outputnames(DAE); % redundant
    % argument string from inputs
    argstr = '';
    for c = 1:length(input_names)
        argstr = sprintf('%s%s, ', argstr, input_names{c});
    end
    argstr = sprintf('%svarargin', argstr);

    % output functions
    for c = 1:length(output_names)
        commandstr = sprintf('MEO.%s = @(%s) model_exerciser_func(%d, %s);', output_names{c}, argstr, c, argstr);
        eval(commandstr);
    end

    % output derivative functions
    for c = 1:length(output_names)
        for d = 1:length(input_names)
            funcname = ['d', output_names{c}, '_d', input_names{d}];
            commandstr = sprintf('MEO.%s = @(%s) model_exerciser_func([%d, %d], %s);', funcname, argstr, c, d, argstr);
            eval(commandstr);
        end
    end

    % set up some function handles
    % 1) display the model exerciser:
    MEO.display = @model_exerciser_display;
    MEO.print = @model_exerciser_display; % same as display

    % 2) look up the usage of functions in the model exerciser:
    MEO.help = @model_exerciser_help;
    MEO.plot = @model_exerciser_plot;

    fprintf('...the model exerciser object (MEO) of the %s model has been created.\n\n', MOD.ModelName(MOD));

    MEO.display(MEO);


    %fprintf('To see the internal structure of MEO, you can run:\n');
    %fprintf('    MEO.display(MEO);\n');
    %fprintf('\n');
end % model_dc_exerciser constructor

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

    [uDC, sweepVars, MEO.DAE] = parse_inputs(...
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

function model_exerciser_display(MEO)
%function model_exerciser_display(MEO)
%

    %fprintf('This is a model exerciser object (MEO) for %s model.\n', MEO.MOD.ModelName(MEO.MOD));
    %fprintf('It is a structure with the following function fields:\n');

    DAE = MEO.DAE;
    % list model exerciser functions
    terminal_VorIs = MEO.terminal_VorIs;
    input_names = MEO.input_names;
    output_names = MEO.output_names;

    % argument string from inputs
    argstr = '';
    for c = 1:length(input_names)
        argstr = sprintf('%s%s, ', argstr, input_names{c});
    end
    argstr_no_MEO = argstr;
    argstr = sprintf('%sMEO', argstr);

    % Examples
    % --------
    % 
    %     % Note: the examples below are auto-generated using arbitrarily-chosen
    %     %       numbers, therefore may not generate good plots.
    % 
    %     % Example 1: sweep Vd, plot Id
    %     Vd = 0:0.1:1; Vg = 1; Vs = 0; Vb = 0;
    %     MEO.plot('Id', Vd, Vg, Vs, Vb, MEO);
    % 
    %     % The line below evaluates Id without plotting
    %     % MEO.Id(Vd, Vg, Vs, Vb, MEO)
    % 
    %     % You can also sweep parameter values and plot
    %     % Vd = 1; Vg = 1; Vs = 0; Vb = 0;
    %     % MEO.plot('Id', Vd, Vg, Vs, Vb, 'Beta', 0.26:0.001:0.27, MEO);
    % 
    %     % Example 2: sweep Vd, plot dId_dVd
    %     Vd = 0:0.1:1; Vg = 1; Vs = 0; Vb = 0;
    %     MEO.plot('dId_dVd', Vd, Vg, Vs, Vb, MEO);
    %     
    %     % Example 3: sweep both Vd and Vg, plot Id
    %     Vd = 0:0.1:1; Vg = 0:0.1:1; Vs = 0; Vb = 0;
    %     MEO.plot('Id', Vd, Vg, Vs, Vb, MEO);
    % 
    % For this to work, we need strings:
    % 
    % output_example = 'Id'; % first in outputnames
    % derivative_example = 'dId_dVd'; % first in outputnames, first in inputnames
    % 
    % v_nominal_val = '1';
    % i_nominal_val = '1e-3';
    % Use these only for the first two terminals. Use 0 for the rest.
    % Always use 0 for ref (last terminal).
    % 
    % input1 = 'Vd';
    % input2 = 'Vd';
    % 
    % parm_example = 'Beta'; % choose the one in the middle.
    % % Why: first one may be version or type, last severals are normally GMIN,
    % %      smoothing, maxslope.
    % 
    % parm_nominal_val = 0.26:0.001:0.27; % default value x1:x0.01:x1.1
    % % If default value is 0, use 0:0.1:1.
    % 

    parm_names = MEO.MOD.parmnames(MEO.MOD);
    parm_defaults = MEO.MOD.parmdefaults(MEO.MOD);
    if length(input_names) > 0 && length(output_names) > 0 
        % We want users to be able to cut and paste code in Examples section,
        % so we need to "invent" some values and ranges for inputs.
        % See notes above.
        output_example = output_names{1};
        derivative_example = ['d', output_names{1}, '_d', input_names{1}];
        v_nominal_val = '1';
        i_nominal_val = '1e-3';
        v_nominal_range = '0:0.1:1';
        i_nominal_range = '0:0.001:0.01';
        input1 = input_names{1};
        no_parms = 1;
        if length(parm_names) > 0
            no_parms = 0;
            pid = ceil(length(parm_names)/2);
            parm_example = parm_names{pid};
            parm_example_default = parm_defaults{pid};
            if isnumeric(parm_example_default)
                if 0 == parm_example_default
                    parm_nominal_range = '0:0.1:1';
                else
                    parm_nominal_range = sprintf('%g*(1:0.01:1.1)', parm_example_default);
                end
            else
                no_parms = 1;
            end
        end
        no_input2 = 1;
        if length(input_names) > 1
            no_input2 = 0;
            input2 = input_names{2};
        end

        fprintf('\n');
        fprintf('How to use the model exerciser object (examples)\n');
        fprintf('------------------------------------------------\n');
        fprintf('    %% Note: the examples below are auto-generated using arbitrarily-chosen\n');
        fprintf('    %%       ranges, just for illustration. Better to pick your own ranges. \n');
        fprintf('\n');
        fprintf('    %% Example 1: sweep %s, plot %s\n', input1, output_example);
        str = '    ';
        for c = 1:length(input_names)
            input_name = input_names{c};
            VorI = terminal_VorIs{c};
            if 1 == c
            % the input to sweep
                if strcmp(VorI, 'V')
                    str = sprintf('%s%s = %s; ', str, input_name, v_nominal_range);
                else
                    str = sprintf('%s%s = %s; ', str, input_name, i_nominal_range);
                end
            elseif 2 == c && length(input_names) ~= c
            % OK to use nominal values
                if strcmp(VorI, 'V')
                    str = sprintf('%s%s = %s; ', str, input_name, v_nominal_val);
                else
                    str = sprintf('%s%s = %s; ', str, input_name, i_nominal_val);
                end
            else
            % just use 0
                str = sprintf('%s%s = %s; ', str, input_name, '0');
            end
        end
        sweep1D_str = str;
        fprintf('%s\n', str);
        fprintf('    MEO.plot(''%s'', %s);\n', output_example, argstr);
        fprintf('\n');
        fprintf('    %% The line below evaluates %s without plotting\n', output_example);
        fprintf('    %% MEO.%s(%s)\n',  output_example, argstr);
        fprintf('\n');
        if ~no_parms
            fprintf('    %% You can also sweep parameter values and plot\n');
            str = '    % ';
            for c = 1:length(input_names)
                input_name = input_names{c};
                VorI = terminal_VorIs{c};
                if 2 >= c && length(input_names) ~= c
                % OK to use nominal values
                    if strcmp(VorI, 'V')
                        str = sprintf('%s%s = %s; ', str, input_name, v_nominal_val);
                    else
                        str = sprintf('%s%s = %s; ', str, input_name, i_nominal_val);
                    end
                else
                % just use 0
                    str = sprintf('%s%s = %s;', str, input_name, '0');
                end
            end
            fprintf('%s\n', str);
            fprintf('    %% MEO.plot(''%s'', %s''%s'', %s, MEO);\n', output_example, argstr_no_MEO, parm_example, parm_nominal_range);
            fprintf('\n');
        end
        fprintf('    %% Example 2: sweep %s, plot %s\n', input1, derivative_example);
        fprintf('%s\n', sweep1D_str);
        fprintf('    MEO.plot(''%s'', %s);\n', derivative_example, argstr);
        fprintf('\n');
        if ~no_input2
            fprintf('    %% Example 3: sweep both %s and %s, plot %s\n', input1, input2, output_example); 
            str = '    ';
            for c = 1:length(input_names)
                input_name = input_names{c};
                VorI = terminal_VorIs{c};
                if 1 == c
                % the input to sweep
                    if strcmp(VorI, 'V')
                        str = sprintf('%s%s = %s; ', str, input_name, v_nominal_range);
                    else
                        str = sprintf('%s%s = %s; ', str, input_name, i_nominal_range);
                    end
                elseif 2 == c
                % OK to use nominal values
                    if strcmp(VorI, 'V')
                        str = sprintf('%s%s = %s; ', str, input_name, v_nominal_range);
                    else
                        str = sprintf('%s%s = %s; ', str, input_name, i_nominal_range);
                    end
                else
                % just use 0
                    str = sprintf('%s%s = %s; ', str, input_name, '0');
                end
            end
            sweep1D_str = str;
            fprintf('%s\n', str);
            fprintf('    MEO.plot(''%s'', %s);\n', output_example, argstr);
            fprintf('\n');
        end
    end % if lengths > 0

    % prints the names of functions and derivatives
    fprintf('\nThe model exerciser object (MEO) has the following functions available for use:\n');
    fprintf('\n');
    % output functions
    for c = 1:length(output_names)
        fprintf('MEO.%s(%s);\n', output_names{c}, argstr);
    end

    fprintf('\n');
    % output derivative functions
    for c = 1:length(output_names)
        for d = 1:length(input_names)
            funcname = ['d', output_names{c}, '_d', input_names{d}];
            fprintf('MEO.%s(%s);\n', funcname, argstr);
        end
    end

end % display

function model_exerciser_plot(varargin)
%function model_exerciser_plot(funcname, varargin, MEO)
%
% Arguments:
%  - funcname: string, name of the function to plot. 
%  - varargin: input variables to the function, including inputs and
%               parameters. Among them, parms are optional,
%               and are given as parmname/parmval pairs.
%  - MEO: model exerciser object.
%
    funcname = varargin{1};
    MEO = varargin{end};

    if isfield(MEO, funcname)
    else
        fprintf('Error: %s is not a function field of the model exerciser.\n', funcname);
        return;
    end

    input_cell_array = {varargin{2:end-1}};

    [uDC, sweepVars, MEO.DAE] = parse_inputs(...
                            input_cell_array, MEO.DAE);

    command = sprintf('feval(MEO.%s, varargin{2:end});', funcname);
    out = eval(command);

    % 3 scenarios: calculate a scalar, 1D sweep, 2D sweep  --> a dumb but reliable way
    if 0 == length(sweepVars)
        fprintf('Error: at least one input should be a vector for plotting.\n');
        return;
    elseif 1== length(sweepVars)
        figure;
        plot(sweepVars{1}.vals, out, '.-');
            set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            xlabel(convert_to_printable_name(sweepVars{1}.name),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            ylabel(convert_to_printable_name(funcname),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            title(convert_to_printable_name(funcname),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            set(gcf,'color','white');
            box on; grid on;
    else % 2 <= length(sweepVars)
        % 3D plot
        figure;
        surf(sweepVars{2}.vals, sweepVars{1}.vals, out);
            set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            xlabel(convert_to_printable_name(sweepVars{2}.name),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            ylabel(convert_to_printable_name(sweepVars{1}.name),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            zlabel(convert_to_printable_name(funcname),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            title(convert_to_printable_name(funcname),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            set(gcf,'color','white');
            box on; grid on;
        % 2D plot 1
        figure;
        legends = {};
        for c = 1:length(sweepVars{1}.vals)
            col = getcolorfromindex(gca(), c); marker = getmarkerfromindex(c);
            plot(sweepVars{2}.vals, out(c, :), sprintf('%s-', marker), 'Color', col, 'MarkerSize', 5);
            legends{c} = sprintf('%s=%0.2g', sweepVars{1}.name, sweepVars{1}.vals(c));
            hold on;
        end
            set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            xlabel(convert_to_printable_name(sweepVars{2}.name),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            ylabel(convert_to_printable_name(funcname),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            title(convert_to_printable_name(funcname),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            set(gcf,'color','white');
            box on; grid on;
            legend(legends{:});
        % 2D plot 2
        figure;
        legends = {};
        for c = 1:length(sweepVars{2}.vals)
            col = getcolorfromindex(gca(), c); marker = getmarkerfromindex(c);
            plot(sweepVars{1}.vals, out(:, c).', sprintf('%s-', marker), 'Color', col, 'MarkerSize', 5);
            legends{c} = sprintf('%s=%0.2g', sweepVars{2}.name, sweepVars{2}.vals(c));
            hold on;
        end
            set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            xlabel(convert_to_printable_name(sweepVars{1}.name),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            ylabel(convert_to_printable_name(funcname),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            title(convert_to_printable_name(funcname),'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            set(gcf,'color','white');
            box on; grid on;
            legend(legends{:});
    end
end

function [uDC, sweepVars, DAE] = parse_inputs(input_cell_array, DAE)
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
end % parse_inputs

function out = convert_to_printable_name(in)
%function out = convert_to_printable_name(in)
%
% This function converts a name string to a new string such that it is suitable
% to use for labels and titles of plots. It substitutes underscore '_' with
% '\_'.
%
    out = regexprep(in, '_', '\\_');
end % convert_to_printable_name
