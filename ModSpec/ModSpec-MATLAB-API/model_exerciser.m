function MEO = model_exerciser(MOD)

%

%function MEO = model_exerciser(MOD)
%
% model exerciser constructor
% TODO: with a bunch of options: what are they?
% 
%Argument(s):
%  MOD: a ModSpec structure/object. See help ModSpec.
%
%Output(s):
% MEO: a model exerciser structure/object with the following fields:
%
%    function member(s):
%
%      1) display the model exerciser:
%
%      .print: function handle, prints the data/function fields of MEO,
%              use:
%          MEO.print(MEO);
%
%      .display: function handle, same as MEO.print, prints the
%                data/function fields of MEO, use:
%          MEO.display(MEO);
%
%      2) look up the usage of functions in the model exerciser:
%
%      .help: function handle, prints help strings for member functions of
%             MEO, use:
%          MEO.help('didb_dvdb', MEO);
%          MEO.help('print', MEO);
%          MEO.help('plot', MEO);
%
%      3) run model functions:
%
%      Many function handles representing fe/fi/qe/qi and their derivatives.
%      For example (MVS_1_0_1_ModSpec):
%      .idb, derived from MOD.fe, use:
%          out = MEO.idb(vdb, vgb, vsb, vdib, vsib, MEO);
%          or out = MEO.idb(vdb, vgb, vsb, vdib, vsib, ...
%                   parmname1, parmval1, parmname2, parmval2, MEO);
%          examples:
%          a) out = MEO.idb(0.5, 1, 0, 0.5, 0, MEO);
%          b) outvec = MEO.idb(0.1:0.1:1, 1, 0, 0.5, 0, MEO);
%          c) out = MEO.idb(0.5, 1, 0, 0.5, 0, 'W', 1e-7, MEO);
%          d) outvec = MEO.idb(0.5, 1, 0, 0.5, 0, 'W', 1e-7:1e-7:1e-6, ...
%                                MEO);
%      .KCLf_di, derived from MOD.fi.
%      .KCLq_di, derived from MOD.qi.
%      .dids_dvgb, derived from MOD.dfe_dvecX.
%      .dfKCL_di_dvdib, derived from MOD.dfi_dvecY.
%
%      4) plot model functions:
%
%      .plot: function handle, run and plot the model functions, use:
%          MEO.plot(funcname, funcarg1, funcarg2, ..., MEO);
%            funcname (string ) is the name of the model function to be plotted
%            funcarg1, funcarg2,... are inputs to the model function, normally
%                bias voltages. Use MEO.help(funcname) to find out more
%                about these inputs.
%          examples:
%          a) MEO.plot('idb', 0.1:0.1:1, 1, 0, 0.5, 0, MEO);
%          b) MEO.plot('idb', 0.1:0.1:1, 0.5:0.1:1.5, 0, 0.5, 0,MEO);
%             % will generate 3D plot
%          c) MEO.plot('idb', 0.5, 1, 0, 0.5, 0, 'W', 1e-7:1e-7:1e-6, ...
%                          MEO);
%          d) MEO.plot('idb', 0.5, 1, 0, 0.5, 0, 'W', 1e-7:1e-7:1e-6, ...
%                          'Lgdr', 1e-7:1e-7:1e-6, MEO);
%             % will generate 3D plot
%
%    data member(s):
%      .MOD: ModSpec object of the model. "help ModSpec" for more detail.
%      .internal_func_list: cellarray of MATLAB structures, encapsulating
%            information for each model function. Each structure contains
%            the following fields:
%            .name: string
%            .type: string, 'core', 'output', 'custom'
%            .fORq: string, 'f', 'q', it determines whether it takes vecU as
%                   an input
%            for 'core':
%                .fqeiname: string
%                .idx: index in fqei or dfqei
%            for 'output':
%                .idx: index in outputs
%
%            TODO: highly inefficient, maybe all right, considering only
%            MEO.help uses it.
%
%      .internal_der_list: cellarray of MATLAB structures, encapsulating
%            information for each derivative of each model function. Each
%            structure contains the following fields:
%            .name: string
%                .funcname: string, an element in internal_func_list
%                .argname: string, an element in internal_arg_list
%
%      .internal_arg_list: cellarray of MATLAB structures, encapsulating
%            information for each variable in vecX/vecY/vecU. Each structure
%            contains the following fields:
%            .name: string
%            .vecXYUname: string, 'vecX', 'vecY' or 'vecU'
%            .idx: index in fqei or dfqei
%
%Examples
%--------
%
% % create a model_exerciser object from a ModSpec object:
% MOD = MVS_1_0_1_ModSpec;
% MEO = model_exerciser(MOD);
%
% % display data/function fields of the model_exerciser object
% MEO.display(MEO);
%
% % look up the calling syntax of MEO.idb
% MEO.help('idb', MEO);
%
% % run MEO.idb at some bias voltages
% idb = MEO.idb(0.5, 1, 0, 0.5, 0, MEO)
% idbs = MEO.idb(0.1:0.1:0.5, 1, 0, 0.5, 0, MEO)
%
% % plot MEO.idb w.r.t. vdb at some bias voltages
% MEO.plot('idb', 0.1:0.1:0.5, 1, 0, 0.5, 0, MEO);
%
% %TODO: more examples
% %TODO: change this example to SH_MOS, which is less confusing
%
%See also
%--------
%
% TODO
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Changelog:
%------------
%2015/03/25: Tianshi Wang <tianshi@berkeley.edu>: created and documented

    MEO.MOD = MOD;

    % 1) display the model exerciser:
    MEO.display = @model_exerciser_display;
    MEO.print = @model_exerciser_display; % same as display

    % 2) look up the usage of functions in the model exerciser:
    MEO.help = @model_exerciser_help;

    MEO.plot = @model_exerciser_plot;

    % 3) construct argument/function/derivative lists:

    % 3.1) construct list for arguments of model functions:
        internal_arg_list = {};
        % unroll vecX variables
        vecXnames = MOD.OtherIONames(MOD);
        names = convert2validName(vecXnames);
        for c = 1:length(names)
            arg_data.name = names{c};
            arg_data.vecXYUname = 'vecX';
            arg_data.idx = c;
            internal_arg_list = {internal_arg_list{:}, arg_data};
        end

        % unroll vecY variables
        vecYnames = MOD.InternalUnkNames(MOD);
        names = convert2validName(vecYnames);
        for c = 1:length(names)
            arg_data.name = names{c};
            arg_data.vecXYUname = 'vecY';
            arg_data.idx = c;
            internal_arg_list = {internal_arg_list{:}, arg_data};
        end

        % unroll vecU variables
        vecUnames = MOD.uNames(MOD);
        names = convert2validName(vecUnames);
        for c = 1:length(names)
            arg_data.name = names{c};
            arg_data.vecXYUname = 'vecU';
            arg_data.idx = c;
            internal_arg_list = {internal_arg_list{:}, arg_data};
        end

    % 3.2) construct internal model functions list:
        internal_func_list = {};

        % explicit equations fe/qe
        eonames = MOD.ExplicitOutputNames(MOD);
        eonames = convert2validName(eonames);
        % unroll fe functions
        names = eoname2fname(eonames);
        for c = 1:length(names)
            func_data.name = names{c};
            func_data.type = 'core';
            func_data.fORq = 'f';
            func_data.fqeiname = 'fe';
            func_data.idx = c;
            internal_func_list = {internal_func_list{:}, func_data};
        end
        % unroll qe functions
        names = eoname2qname(eonames);
        for c = 1:length(names)
            func_data.name = names{c};
            func_data.type = 'core';
            func_data.fORq = 'q';
            func_data.fqeiname = 'qe';
            func_data.idx = c;
            internal_func_list = {internal_func_list{:}, func_data};
        end

        % implicit equations fi/qi
        ienames = MOD.ImplicitEquationNames(MOD);
        ienames = convert2validName(ienames);
        % unroll fi functions
        names = iename2fname(ienames);
        for c = 1:length(names)
            func_data.name = names{c};
            func_data.type = 'core';
            func_data.fORq = 'f';
            func_data.fqeiname = 'fi';
            func_data.idx = c;
            internal_func_list = {internal_func_list{:}, func_data};
        end
        % unroll qi functions
        names = iename2qname(ienames);
        for c = 1:length(names)
            func_data.name = names{c};
            func_data.type = 'core';
            func_data.fORq = 'q';
            func_data.fqeiname = 'qi';
            func_data.idx = c;
            internal_func_list = {internal_func_list{:}, func_data};
        end

        % TODO: output functions

    % 3.3) construct internal model derivative list:
        internal_der_list = {};
        for c = 1:length(internal_func_list)
            the_func = internal_func_list{c};
            for d = 1:length(internal_arg_list)
                the_arg = internal_arg_list{d};
                the_der.name = ['d', the_func.name, '_d', the_arg.name];
                if strcmp('core', the_func.type);
                    the_der.type = 'core';
                    the_der.funcname = ['d', the_func.fqeiname, '_d', the_arg.vecXYUname];
                    the_der.fqeiname = the_func.fqeiname; 
                    the_der.vecXYUname = the_arg.vecXYUname;
                elseif strcmp('output', the_func.type);
                    the_der.type = 'output';
                    the_der.funcname = ['d', the_func.outputname, '_d', the_arg.vecXYUname];
                    the_der.vecXYUname = the_arg.vecXYUname;
                else %TODO: warning
                end
                the_der.fORq = the_func.fORq;
                the_der.idx = [the_func.idx, the_arg.idx];
                internal_der_list = {internal_der_list{:}, the_der};
            end
        end

    % These three statements are here (before the definitions of all model
    % functions, instead of at the end) so that they won't show up at the end
    % when displaying the object in the command window.
    MEO.internal_arg_list = internal_arg_list;
    MEO.internal_func_list = internal_func_list;
    MEO.internal_der_list = internal_der_list;

    % 4) construct function handles:
        argstr = '';
        argstr_noU = '';
        for c = 1:length(internal_arg_list)
            argstr = sprintf('%s%s, ', argstr, internal_arg_list{c}.name);
            if ~strcmp('vecU', internal_arg_list{c}.vecXYUname)
                argstr_noU = sprintf('%s%s, ', argstr_noU, internal_arg_list{c}.name);
            end
        end
        argstr = sprintf('%svarargin', argstr);
        argstr_noU = sprintf('%svarargin', argstr_noU);

        for c = 1:length(internal_func_list)
            the_func = internal_func_list{c};
            if strcmp('core', the_func.type);
                funcname = the_func.fqeiname;
            elseif strcmp('output', the_func.type);
                funcname = the_func.outputname;
            end
            if strcmp('f', the_func.fORq);
                commandstr = sprintf('MEO.%s = @(%s) model_exerciser_func(''%s'', ''f'', %d, %s);', the_func.name, argstr, funcname, the_func.idx, argstr);
            else % strcmp('q', the_func.type);
                commandstr = sprintf('MEO.%s = @(%s) model_exerciser_func(''%s'', ''q'', %d, %s);', the_func.name, argstr_noU, funcname, the_func.idx, argstr_noU);
            end
            eval(commandstr);
        end

        for c = 1:length(internal_der_list)
            the_der = internal_der_list{c};
            funcname = the_der.funcname;
            if strcmp('f', the_der.fORq);
                commandstr = sprintf('MEO.%s = @(%s) model_exerciser_func(''%s'', ''f'', [%d, %d], %s);', the_der.name, argstr, funcname, the_der.idx(1), the_der.idx(2), argstr);
            else % strcmp('q', the_func.type);
                commandstr = sprintf('MEO.%s = @(%s) model_exerciser_func(''%s'', ''q'', [%d, %d], %s);', the_der.name, argstr_noU, funcname, the_der.idx(1), the_der.idx(2), argstr_noU);
            end
            % commandstr = sprintf('MEO.%s = @(%s) model_exerciser_dfqei(''%s'', [%d, %d], %s);', the_func.name, argstr, funcname, the_func.idx(1), the_func.idx(2), argstr);
            eval(commandstr);
        end

    fprintf('\n');
    fprintf('The model exerciser object (MEO) of the %s model is created.\n', MOD.ModelName(MOD));
    fprintf('To see the strucuture of MEO, you can run:\n');
    fprintf('    MEO.display(MEO);\n');
    fprintf('\n');
end

function out = model_exerciser_func(varargin)
%function out = model_exerciser_func(funcname, idx, varargin, MEO)
%
% Arguments:
%  - funcname: string, 'fe', 'qe', 'fi', 'qi',
%                      or 'dfe_dvecX', 'dfi_dvecY', etc.
%  - idx: integer, the index of this scalar function in fe/qe/fi/qi.
%         or 2-by-1 vector, the index of this scalar function in dfe_dvecX,
%         dqe_dvecY, etc.
%  - varargin: many variables, including other IOs, internal unks, internal
%               sources and parms. They are in the following order:
%               other IOs (vecX names), internal unks (vecY names), internal
%               sources (vecU names), parms. Among them, parms are optional,
%               and are given as parmname/parmval pairs.
%  - MEO: model exerciser object. It should have at least MEO.MOD
%              field, which is a ModSpec object.
%               
%
    funcname = varargin{1};
    fORq = varargin{2};
    idx = varargin{3};
    MEO = varargin{end}{end}; % varargin{end} is a cell array, it can be
                                   % 1. {MEO} or 
                                   % 2. {parmname1, parmval1, ..., MEO}
    input_cell_array = {varargin{4:end-1}};
    % include parms also in input_cell_array 
    if 1 < length(varargin{end})
        % adds in {parmname1, parmval1, parmname2, parmval2}
        input_cell_array = {input_cell_array{:}, varargin{end}{1:end-1}};
    end

    [vecX, vecY, vecU, sweepVars, MEO.MOD] = parse_inputs(...
                            input_cell_array, fORq, MEO.MOD);

    % 3 scenarios: calculate a scalar, 1D sweep, 2D sweep  --> a dumb but reliable way
    if 0 == length(sweepVars)
        if strcmp('f', fORq)
            command = sprintf('feval(%s, vecX, vecY, vecU, MEO.MOD);', strcat('MEO.MOD.', funcname));
        else
            command = sprintf('feval(%s, vecX, vecY, MEO.MOD);', strcat('MEO.MOD.', funcname));
        end
        outs = eval(command);
        if 1 == length(idx)
            out = outs(idx);
        else
            out = outs(idx(1), idx(2));
        end
    elseif 1 == length(sweepVars)
        for c = 1:length(sweepVars{1}.vals)
            if strcmp('vecX', sweepVars{1}.vecXYUorParm)
                vecX(sweepVars{1}.idx) = sweepVars{1}.vals(c);
            elseif strcmp('vecY', sweepVars{1}.vecXYUorParm)
                vecY(sweepVars{1}.idx) = sweepVars{1}.vals(c);
            elseif strcmp('vecU', sweepVars{1}.vecXYUorParm)
                vecU(sweepVars{1}.idx) = sweepVars{1}.vals(c);
            else % if strcmp('Parm', sweepVars{1}.vecXYUorParm)
                MEO.MOD = MEO.MOD.setparms(sweepVars{1}.name, sweepVars{1}.vals(c), MEO.MOD);
            end

            if strcmp('f', fORq)
                command = sprintf('feval(%s, vecX, vecY, vecU, MEO.MOD);', strcat('MEO.MOD.', funcname));
            else
                command = sprintf('feval(%s, vecX, vecY, MEO.MOD);', strcat('MEO.MOD.', funcname));
            end
            outs = eval(command);
            if 1 == length(idx)
                out(c, 1) = outs(idx);
            else
                out(c, 1) = outs(idx(1), idx(2));
            end
        end
    else % 2 <= length(sweepVars)
        for c = 1:length(sweepVars{1}.vals)
        for d = 1:length(sweepVars{2}.vals)
            if strcmp('vecX', sweepVars{1}.vecXYUorParm)
                vecX(sweepVars{1}.idx) = sweepVars{1}.vals(c);
            elseif strcmp('vecY', sweepVars{1}.vecXYUorParm)
                vecY(sweepVars{1}.idx) = sweepVars{1}.vals(c);
            elseif strcmp('vecU', sweepVars{1}.vecXYUorParm)
                vecU(sweepVars{1}.idx) = sweepVars{1}.vals(c);
            else % if strcmp('Parm', sweepVars{1}.vecXYUorParm)
                MEO.MOD = MEO.MOD.setparms(sweepVars{1}.name, sweepVars{1}.vals(c), MEO.MOD);
            end
            if strcmp('vecX', sweepVars{2}.vecXYUorParm)
                vecX(sweepVars{2}.idx) = sweepVars{2}.vals(d);
            elseif strcmp('vecY', sweepVars{2}.vecXYUorParm)
                vecY(sweepVars{2}.idx) = sweepVars{2}.vals(d);
            elseif strcmp('vecU', sweepVars{2}.vecXYUorParm)
                vecU(sweepVars{2}.idx) = sweepVars{2}.vals(d);
            else % if strcmp('Parm', sweepVars{2}.vecXYUorParm)
                MEO.MOD = MEO.MOD.setparms(sweepVars{2}.name, sweepVars{2}.vals(d), MEO.MOD);
            end

            if strcmp('f', fORq)
                command = sprintf('feval(%s, vecX, vecY, vecU, MEO.MOD);', strcat('MEO.MOD.', funcname));
            else
                command = sprintf('feval(%s, vecX, vecY, MEO.MOD);', strcat('MEO.MOD.', funcname));
            end
            outs = eval(command);
            if 1 == length(idx)
                out(c, d) = outs(idx);
            else
                out(c, d) = outs(idx(1), idx(2));
            end
        end % d
        end % c
        if 3 <= length(sweepVars)
            for c = 3:length(sweepVars)
                fprintf('Warning: sweeping input %s is ignored.\n', sweepVars{c}.name);
            end
        end
    end
    out = full(out);
end

function model_exerciser_help(funcname, MEO)
%function model_exerciser_help(funcname, MEO)
%
% Arguments:
%  - funcname: string, name of the function to look up. 
%  - MEO: model exerciser object. It should have at least MEO.MOD
%              field, which is a ModSpec object.
%

    if isfield(MEO, funcname)
    else
        fprintf('Error: %s is not a function field of the model exerciser.\n', funcname);
        return;
    end

    if strcmp(funcname, 'display')
    elseif strcmp(funcname, 'print')
    elseif strcmp(funcname, 'help')
    elseif strcmp(funcname, 'plot')
        % Example printout:
        %
        %function out = MEO.plot(funcname, arg1, arg2, ...)
        %
        %This function plots the results of MEO.funcname, which is one of MEO's member functions.
        %arg1, arg2, ... are all the arguments of funcname.
        %
        %To see a list of member functions in the model exerciser object, run
        %
        %    >> MEO.display(MEO);
        %
        %You can use MEO.help(funcname, MEO) to look up the usage of funcname, i.e. to
        %see what arguments arg1, arg2, ... should be.
        %
        %For example:
        %
        disp('function out = MEO.plot(funcname, arg1, arg2, ...)');
        fprintf('\n');
        disp('This function plots the results of MEO.funcname, which is one of MEO''s member functions.');
        disp('arg1, arg2, ... are all the arguments of funcname.');
        fprintf('\n');
        disp('To see a list of member functions in the model exerciser object, run');
        fprintf('\n');
        disp('    >> MEO.display(MEO);');
        fprintf('\n');
        disp('You can use MEO.help(funcname, MEO) to look up the usage of funcname, i.e. to');
        disp('see what arguments arg1, arg2, ... should be.');
        fprintf('\n');
            if ~isempty(MEO.internal_func_list)
                fprintf('For example:\n');
                funcname =  MEO.internal_func_list{1}.name;
                fprintf('    MEO.help(''%s'', MEO);\n', funcname);
            end

    else
        internal_func_list = MEO.internal_func_list;
        internal_der_list = MEO.internal_der_list;
        internal_arg_list = MEO.internal_arg_list;
        argstr = '';
        argstr_noU = '';
        for c = 1:length(internal_arg_list)
            argstr = sprintf('%s%s, ', argstr, internal_arg_list{c}.name);
            if ~strcmp('vecU', internal_arg_list{c}.vecXYUname)
                argstr_noU = sprintf('%s%s, ', argstr_noU, internal_arg_list{c}.name);
            end
        end
        argstr = sprintf('%sparmname1, parmval1, ..., MEO', argstr);
        argstr_noU = sprintf('%sparmname1, parmval1, ..., MEO', argstr_noU);

        found = 0;
        idx = find_by_name(funcname, MEO.internal_func_list);
        if ~isempty(idx)
            the_func = MEO.internal_func_list{idx};
            isder = 0;
            found = 1;
        end
        idx = find_by_name(funcname, MEO.internal_der_list);
        if ~isempty(idx)
            the_func = MEO.internal_der_list{idx};
            isder = 1;
            found = 1;
        end
        if ~found
            fprintf('Error: %s is not a function field of the model exerciser.\n', funcname);
            return;
        end

% Example printout:
%
%function out = Idb(vdb, vgb, vsb, vdib, vsib, pname1, pval1, ..., MEO)            title
%
%This function corresponds to fe(1,1): the No.1 entry of the algebraic part of          description
%the model's explicit equation.
%
%An input (IO, internal unknown or parmameter value) can be a scalar or a               notes on inputs
%vector.
% - When only one input is a vector, the function is evaluated by sweeping this
%   input; out is then a column vector containing the results.
% - When two inputs are vectors, a 2D sweep is performed; out is a matrix with
%   its first dimension corresponding to the first vector input.
% - When more than two inputs are vectors, the extra vectors after the first two
%   will be treated as scalars with only their first entries used in evaluation.
%
%Arguments:                                                                             arguments
%  - vdb, vgb, vsb: IO properties.
%  - vdib, vsib: internal unknowns.
%  - pname1, pval1, ... (parameters):
%
%    Parameters are provided as comma-separated pairs of pname-pval arguments:          notes on parms
%      - pname: string, must be specified inside single quotes (' ').
%      - pval: corresponding value for pname.
%            Available pnames (case-sensitive) and their default pvals:                 available parms
%                'version'  1.01
%                'Type'     1
%                'W'        1e-4
%                'Lgdr'     80e-7
%                'dLg'      10.5e-7
%                'Cg'       2.2e-6
%                'etov'     1.3e-3
%                'delta'    0.10
%
%    You can specify several name and value pair arguments in any order as              more notes on parms
%        pname1, pval1, ..., pnameN, pvalN.
%
%Output:                                                                                output
%  - out: a scalar, or a column vector, or a matrix depending on the inputs.

        % title
        if strcmp('f', the_func.fORq)
            fprintf('function out = %s(%s)\n\n', funcname, argstr);
        else
            fprintf('function out = %s(%s)\n\n', funcname, argstr_noU);
        end

        % description

        if ~isder
            % This function corresponds to fe(1, 1): the No.1 entry of the
            % algebraic part of the model's explicit equation.
            % name: fe
            % idx: 1
            % algebraicORdifferential: algebraic 
            % functype: explicit

            if strcmp('core', the_func.type)
                name = the_func.fqeiname;
                idx = the_func.idx;
                if strcmp('f', the_func.fORq)
                    algebraicORdifferential = 'algebraic';
                else
                    algebraicORdifferential = 'differential';
                end
                if strcmp('e', name(2))
                    functype = 'explicit';
                else
                    functype = 'implicit';
                end
            elseif strcmp('output', the_func.type)
                name = 'output';
                idx = the_func.idx;
                if strcmp('f', the_func.fORq)
                    algebraicORdifferential = 'algebraic';
                else
                    algebraicORdifferential = 'differential';
                end
                functype = 'output';
            end
            str = sprintf('This function corresponds to %s(%d, 1): the No.%d entry of the %s part of the model''s %s equation.\n',...
                  name, idx, idx, algebraicORdifferential, functype);
            strcell = wrap_line(str, 80);
            for c = 1:length(strcell)
                disp(strcell{c});
            end
        else % isder
            % This function corresponds to dfe_dvecX(1, 1): the derivative of
            % the No.1 entry of the algebraic part of the model's explicit
            % equation with respect to the No.1 entry of the model's other IOs.
            % name: dfe_dvecX
            % idx: [1, 1]
            % algebraicORdifferential: algebraic 
            % functype: explicit
            % argtype: other IOs

            if strcmp('core', the_func.type)
                name = the_func.funcname;
                idx = the_func.idx;
                if strcmp('f', the_func.fORq)
                    algebraicORdifferential = 'algebraic';
                else
                    algebraicORdifferential = 'differential';
                end
                if strcmp('e', the_func.fqeiname(2))
                    functype = 'explicit';
                else
                    functype = 'implicit';
                end
                if strcmp('vecX', the_func.vecXYUname)
                    argtype = 'other IOs';
                elseif strcmp('vecY', the_func.vecXYUname)
                    argtype = 'internal unknowns';
                else % if strcmp('vecU', the_func.vecXYUname)
                    argtype = 'internal sources';
                end 
            elseif strcmp('output', the_func.type)
                name = 'output';
                idx = the_func.idx;
                if strcmp('f', the_func.fORq)
                    algebraicORdifferential = 'algebraic';
                else
                    algebraicORdifferential = 'differential';
                end
                functype = 'output';
                if strcmp('vecX', the_func.vecXYUname)
                    argtype = 'other IOs';
                elseif strcmp('vecY', the_func.vecXYUname)
                    argtype = 'internal unknowns';
                else % if strcmp('vecU', the_func.vecXYUname)
                    argtype = 'internal sources';
                end 
            end
            str = sprintf('This function corresponds to %s(%d, %d): the derivative of the No.%d entry of the %s part of the model''s %s equation, with respect to the No.%d entry of the model''s %s.\n',...
                  name, idx(1), idx(2), idx(1), algebraicORdifferential, functype, idx(2), argtype);
            strcell = wrap_line(str, 80);
            for c = 1:length(strcell)
                disp(strcell{c});
            end
        end % if ~isder

        % notes on inputs
        disp('An input (IO, internal unknown or parmameter value) can be a scalar or a');
        disp('vector.');
        disp('- When only one input is a vector, the function is evaluated by sweeping this');
        disp('  input; out is then a column vector containing the results.');
        disp('- When two inputs are vectors, a 2D sweep is performed; out is a matrix with');
        disp('  its first dimension corresponding to the first vector input.');
        disp('- When more than two inputs are vectors, the extra vectors after the first two');
        disp('  will be treated as scalars with only their first entries used in evaluation.');
        fprintf('\n');

        disp('To plot the results of this function, use');
        disp('MEO.plot(this_function_name, Arguments_of_this_function);');
        fprintf('\n');

        % arguments
        disp('Arguments:');
        eonames = MEO.MOD.ExplicitOutputNames(MEO.MOD);
        oionames = MEO.MOD.OtherIONames(MEO.MOD);
        if ~isempty(oionames)
            fprintf(' - %s: IO property(ies).\n', strjoin(oionames, ', '));
        end
        iunames = MEO.MOD.InternalUnkNames(MEO.MOD);
        if ~isempty(iunames)
            fprintf(' - %s: internal unknown(s).\n', strjoin(iunames, ', '));
        end
        disp(' - pname1, pval1, ... (parameters):');
        fprintf('\n');

        % available parms

        disp('           Available pnames (case-sensitive) and their default pvals:');
        disp('                       [TODO]');
        fprintf('\n');
       
        % more notes on parms
        disp('   You can specify several name and value pair arguments in any order as');
        disp('       pname1, pval1, ..., pnameN, pvalN.');
        fprintf('\n');

        % output
        disp('Output:');
        disp(' - out: a scalar, or a column vector, or a matrix depending on the inputs.');
    end % if
end

function model_exerciser_display(MEO)
%function model_exerciser_display(MEO)
%
% Arguments:
%  - MEO: model exerciser object. It should have at least MEO.MOD
%              field, which is a ModSpec object.
%               

    fprintf('This is a model exerciser object (MEO) for %s model.\n', MEO.MOD.ModelName(MEO.MOD));
    fprintf('It is a structure with the following function fields:\n');

    internal_arg_list = MEO.internal_arg_list;
    internal_func_list = MEO.internal_func_list;
    internal_der_list = MEO.internal_der_list;
    argstr = '';
    argstr_noU = '';
    for c = 1:length(internal_arg_list)
        argstr = sprintf('%s%s, ', argstr, internal_arg_list{c}.name);
        if ~strcmp('vecU', internal_arg_list{c}.vecXYUname)
            argstr_noU = sprintf('%s%s, ', argstr_noU, internal_arg_list{c}.name);
        end
    end
    % argstr = sprintf('%sparmname1, parmval1, ..., MEO', argstr);
    % argstr_noU = sprintf('%sparmname1, parmval1, ..., MEO', argstr_noU);
    argstr_no_MEO = argstr;
    argstr = sprintf('%sMEO', argstr);
    argstr_noU = sprintf('%sMEO', argstr_noU);

    fprintf('\n');
    fprintf('model core functions:\n');
    found = 0;
    for c = 1:length(internal_func_list)
        the_func = internal_func_list{c};
        if strcmp('core', the_func.type);
            found = 1;
            funcname = the_func.fqeiname; % TODO: change both 'fqeiname' and 'outputname' to just 'name'
            if strcmp('f', the_func.fORq);
                fprintf('  MEO.%s(%s);\n', the_func.name, argstr);
            else % strcmp('q', the_func.type);
                fprintf('  MEO.%s(%s);\n', the_func.name, argstr_noU);
            end
        end
    end
    if ~found
        fprintf('  None.\n');
    end

    % fprintf('\n');
    % fprintf('model output functions:\n');
    found = 0;
    for c = 1:length(internal_func_list)
        the_func = internal_func_list{c};
        if strcmp('output', the_func.type);
            if 0 == found % first one
                fprintf('\n');
                fprintf('model output functions:\n');
            end
            found = 1;
            funcname = the_func.outputname;
            if strcmp('f', the_func.fORq);
                fprintf('  MEO.%s(%s);\n', the_func.name, argstr);
            else % strcmp('q', the_func.type);
                fprintf('  MEO.%s(%s);\n', the_func.name, argstr_noU);
            end
        end
    end

    fprintf('\n');
    fprintf('model core derivatives:\n');
    found = 0;
    for c = 1:length(internal_der_list)
        the_der = internal_der_list{c};
        funcname = the_der.funcname;
        if strcmp('core', the_func.type);
            found = 1;
            funcname = the_func.fqeiname;
            if strcmp('f', the_der.fORq);
                fprintf('  MEO.%s(%s);\n', the_der.name, argstr);
            else % strcmp('q', the_func.type);
                fprintf('  MEO.%s(%s);\n', the_der.name, argstr_noU);
            end
        end
    end
    if ~found
        fprintf('  None.\n');
    end

    % fprintf('\n');
    % fprintf('model output derivatives:\n');
    found = 0;
    for c = 1:length(internal_der_list)
        the_der = internal_der_list{c};
        funcname = the_der.funcname;
        if strcmp('output', the_func.type);
            if 0 == found % first one
                % fprintf('\n');
                % fprintf('model output derivatives:\n');
            end
            found = 1;
            funcname = the_func.outputname;
            if strcmp('f', the_der.fORq);
                fprintf('  MEO.%s(%s);\n', the_der.name, argstr);
            else % strcmp('q', the_func.type);
                fprintf('  MEO.%s(%s);\n', the_der.name, argstr_noU);
            end
        end
    end

    fprintf('\n');
    fprintf('Please use MEO.help() to see more detailed descriptions of each function.\n');
    if ~isempty(internal_func_list)
        fprintf('For example:\n');
        funcname =  internal_func_list{1}.name;
        fprintf('    MEO.help(''%s'', MEO);\n', funcname);
    end

    % The duplicated and ugly code below was adapted from model_dc_exerciser,
    % since this Examples section is more useful.
    parm_names = MEO.MOD.parmnames(MEO.MOD);
    parm_defaults = MEO.MOD.parmdefaults(MEO.MOD);
    if length(MEO.internal_arg_list) > 0 && length(MEO.internal_func_list) > 0 
        % We want users to be able to cut and paste code in Examples section,
        % so we need to "invent" some values and ranges for inputs.
        % See notes in model_dc_exerciser.
        output_example = MEO.internal_func_list{1}.name;
        derivative_example = MEO.internal_der_list{1}.name;
        v_nominal_val = '1';
        i_nominal_val = '1e-3';
        v_nominal_range = '0:0.1:1';
        i_nominal_range = '0:0.001:0.01';
        input1 = MEO.internal_arg_list{1}.name;
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
        if length(MEO.internal_arg_list) > 1
            no_input2 = 0;
            input2 = MEO.internal_arg_list{2}.name;
        end

        fprintf('\n');
        fprintf('Examples\n');
        fprintf('--------\n');
        fprintf('    %% Note: the examples below are auto-generated using arbitrarily-chosen\n');
        fprintf('    %%       numbers. They may not generate good-looking plots.\n');
        fprintf('\n');
        fprintf('    %% Example 1: sweep %s, plot %s\n', input1, output_example);
        str = '    ';
        for c = 1:length(MEO.internal_arg_list)
            input_name = MEO.internal_arg_list{c}.name;
            if 1 == c
            % the input to sweep
                if strcmp(input_name(1), 'v')
                    str = sprintf('%s%s = %s; ', str, input_name, v_nominal_range);
                else
                    str = sprintf('%s%s = %s; ', str, input_name, i_nominal_range);
                end
            elseif 2 == c 
            % OK to use nominal values
                if strcmp(input_name(1), 'v')
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
            for c = 1:length(MEO.internal_arg_list)
                input_name = MEO.internal_arg_list{c}.name;
                if 2 >= c 
                % OK to use nominal values
                    if strcmp(input_name(1), 'v')
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
            for c = 1:length(MEO.internal_arg_list)
                input_name = MEO.internal_arg_list{c}.name;
                if 1 == c
                % the input to sweep
                    if strcmp(input_name(1), 'v')
                        str = sprintf('%s%s = %s; ', str, input_name, v_nominal_range);
                    else
                        str = sprintf('%s%s = %s; ', str, input_name, i_nominal_range);
                    end
                elseif 2 == c
                % OK to use nominal values
                    if strcmp(input_name(1), 'v')
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
end

function model_exerciser_plot(varargin)
%function model_exerciser_plot(funcname, varargin, MEO)
%
% Arguments:
%  - funcname: string, name of the function to plot. 
%  - varargin: many variables, including other IOs, internal unks, internal
%               sources and parms. They are in the following order:
%               other IOs (vecX names), internal unks (vecY names), internal
%               sources (vecU names), parms. Among them, parms are optional,
%               and are given as parmname/parmval pairs.
%  - MEO: model exerciser object. It should have at least MEO.MOD
%              field, which is a ModSpec object.
%
    funcname = varargin{1};
    MEO = varargin{end};

    if isfield(MEO, funcname)
    else
        fprintf('Error: %s is not a function field of the model exerciser.\n', funcname);
        return;
    end

    input_cell_array = {varargin{2:end-1}};

    % Unfortunately, looping through functions is necessary, since we need
    % more that the functiona name and also need fORq to proceed.
    idx = find_by_name(funcname, MEO.internal_func_list);
    if isempty(idx)
        idx = find_by_name(funcname, MEO.internal_der_list);
        if isempty(idx)
            fprintf('Error: %s is not a function field of the model exerciser.\n', funcname);
            return;
        else
            fORq = MEO.internal_der_list{idx}.fORq;
        end
    else
        fORq = MEO.internal_func_list{idx}.fORq;
    end

    [vecX, vecY, vecU, sweepVars, MEO.MOD] = parse_inputs(...
                            input_cell_array, fORq, MEO.MOD);

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
            title([convert_to_printable_name(funcname), '()'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
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
            title([convert_to_printable_name(funcname), '()'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
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
            title([convert_to_printable_name(funcname), '()'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
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
            title([convert_to_printable_name(funcname), '()'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
            set(gcf,'color','white');
            box on; grid on;
            legend(legends{:});
    end
end

function [vecX, vecY, vecU, sweepVars, MOD] = parse_inputs(...
                            input_cell_array, fORq, MOD)
%function [vecX, vecY, vecU, sweepVars, MOD] = parse_inputs(...
%                            input_cell_array, fORq, MOD)
%
% TODO: 
%
    sweepVars = {};
    vecXnames = MOD.OtherIONames(MOD);
    nvecX = length(vecXnames);
    offset = 0;
    if 0 == nvecX
        vecX = [];
    else
        for c = 1:nvecX
            if 1 < length(input_cell_array{offset+c})
                vecX(c, 1) = input_cell_array{offset+c}(1);
                sweepVar.name = vecXnames{c};
                sweepVar.vecXYUorParm = 'vecX';
                sweepVar.idx = c;
                sweepVar.vals = input_cell_array{offset+c};
                sweepVars = {sweepVars{:}, sweepVar};
            else
                vecX(c, 1) = input_cell_array{offset+c};
            end
        end
    end

    vecYnames = MOD.InternalUnkNames(MOD);
    nvecY = length(vecYnames);
    offset = nvecX;
    if 0 == nvecY
        vecY = [];
    else
        for c = 1:nvecY
            if 1 < length(input_cell_array{offset+c})
                vecY(c, 1) = input_cell_array{offset+c}(1);
                sweepVar.name = vecYnames{c};
                sweepVar.vecXYUorParm = 'vecY';
                sweepVar.idx = c;
                sweepVar.vals = input_cell_array{offset+c};
                sweepVars = {sweepVars{:}, sweepVar};
                clear sweepVar;
            else
                vecY(c, 1) = input_cell_array{offset+c};
            end
        end
    end

    if strcmp('f', fORq)
        vecUnames = MOD.uNames(MOD);
        nvecU = length(vecUnames);
        offset = nvecX + nvecY;
        if 0 == nvecU
            vecU = [];
        else
            for c = 1:nvecU
                if 1 < length(input_cell_array{offset+c})
                    vecU(c, 1) = input_cell_array{offset+c}(1);
                    sweepVar.name = vecUnames{c};
                    sweepVar.vecXYUorParm = 'vecU';
                    sweepVar.idx = c;
                    sweepVar.vals = input_cell_array{offset+c};
                    sweepVars = {sweepVars{:}, sweepVar};
                    clear sweepVar;
                else
                    vecU(c, 1) = input_cell_array{offset+c};
                end
            end
        end
    else
        vecU = [];
    end

    % handle parameters:
    if strcmp('f', fORq)
        offset = nvecX + nvecY + nvecU;
    else % if strcmp('q', fORq)
        offset = nvecX + nvecY;
    end
    if offset < length(input_cell_array)
        parmpairs = {input_cell_array{(offset+1):end}}; % {parmname1, parmval1, parmname2, parmval2}
        if 0 ~= mod(length(parmpairs), 2)
            error('parameters must be provided in name/val pairs.');
        end
        for c = 1:length(parmpairs)/2
            if 1 < length(parmpairs{2*c}) && ~ischar(parmpairs{2*c})
            %TODO: proper support of parm sweeping requires knowing parm type.
            %      Unlike vecXYU, where a vector indicates a variable to sweep,
            %      parms can be vectors themselves.
                MOD = MOD.setparms(parmpairs{2*c-1}, parmpairs{2*c}(1), MOD);
                sweepVar.vecXYUorParm = 'Parm';
                sweepVar.name = parmpairs{2*c-1};
                sweepVar.vals = parmpairs{2*c};
                sweepVars = {sweepVars{:}, sweepVar};
                clear sweepVar;
            else
                MOD = MOD.setparms(parmpairs{2*c-1}, parmpairs{2*c}, MOD);
            end
        end
    end
end % parse_inputs

function idx = find_by_name(funcname, incell)
%function idx = find_by_name(funcname, incell)
%
% TODO: 
% finds only the first one
%
    idx = [];
    for c = 1:length(incell)
        if strcmp(funcname, incell{c}.name)
            idx = c; return;
        end
    end
end % find_by_name

function outstrORcell = convert2validName(instrORcell)
%function outstrORcell = convert2validName(instrORcell)
%
% This function converts an invalid name string to a valid MATLAB name string.
% It can also convert a cell array of invalid name strings to one with valid
% MATLAB name strings.
%
% "A valid MATLAB variable name is a character string of letters, digits, and
%  underscores, such that the first character is a letter, and the length of
%  the string is less than or equal to the value returned by the namelengthmax
%  function."
%
% Notes:
%   1) It converts each invalid character to an underscore '_';
%      convert2validName('KCL-di')  returns 'KCL_di'
%      convert2validName('a/b') returns 'a_b'
%      convert2validName('a->b')  returns 'a__b'
%   2) If instr starts with non-alphabetical char, it adds 'x' in fron of it:
%      convert2validName('1b') returns 'x1b'
%   3) TODO: It doesn't check for namelengthmax (normally 63).
%
% Arguments:
%  - instrORcell: string or cell array of strings, normally invalid names
%         containing '-', '/', '->', or begins with non-alphabetical character.
%               
    % outstrORcell = matlab.lang.makeValidName(instrORcell);
    outstrORcell = genvarname(instrORcell);


    % % old version: unpreferred as it converts '-' to '0x2D'
    % outstrORcell = genvarname(instrORcell);
    
    if isstr(instrORcell)
        if ~strcmp(outstrORcell, instrORcell)
            fprintf('Note: name ''%s'' converted to ''%s''.\n', instrORcell, outstrORcell);
        end
    elseif iscell(instrORcell)
        for c = 1:length(instrORcell)
            if ~strcmp(outstrORcell{c}, instrORcell{c})
                fprintf('Note: name ''%s'' converted to ''%s''.\n', instrORcell{c}, outstrORcell{c});
            end
        end
    else
        % TODO: warning?
    end
end % convert2validName

function outstrORcell = eoname2qname(instrORcell)
%function outstrORcell = eoname2qname(instrORcell)
%
% This function converts explicit output names for electrical models (vxx, ixx)
% to their corresponding charge/flux function names (PHIxx, Qxx).
%
% Arguments:
%  - instrORcell: string or cell array of strings, usually explicit output
%        names of electrical models (vxx, ixx), should be valid MATLAB
%        variable/function names (returned by convert2validName).

    % outstrORcell = regexprep(instrORcell, '^v', 'PHI');
    % outstrORcell = regexprep(outstrORcell, '^i', 'Q');
    if ~isempty(instrORcell)
        outstrORcell = strcat(instrORcell, '_qe');
    else
        outstrORcell = instrORcell;
    end

    if isstr(instrORcell)
        if ~strcmp(outstrORcell, instrORcell)
            fprintf('Note: explicit equation for ''%s'': differential (d/dt) part named as ''%s''.\n', instrORcell, outstrORcell);
        end
    elseif iscell(instrORcell)
        for c = 1:length(instrORcell)
            if ~strcmp(outstrORcell{c}, instrORcell{c})
                fprintf('Note: explicit equation for ''%s'': differential (d/dt) part named as ''%s''.\n', instrORcell{c}, outstrORcell{c});
            end
        end
    else
        % TODO: warning?
    end
end % eoname2qname

function outstrORcell = eoname2fname(instrORcell)
%function outstrORcell = eoname2fname(instrORcell)
%
% This function converts explicit output names for electrical models (vxx, ixx)
% to their corresponding function names (Vxx, Ixx).
%
% Arguments:
%  - instrORcell: string or cell array of strings, usually explicit output
%        names of electrical models (vxx, ixx), should be valid MATLAB
%        variable/function names (returned by convert2validName).

    % outstrORcell = regexprep(instrORcell, '^v', 'V');
    % outstrORcell = regexprep(outstrORcell, '^i', 'I');
    if ~isempty(instrORcell)
        outstrORcell = strcat(instrORcell, '_fe');
    else
        outstrORcell = instrORcell;
    end

    if isstr(instrORcell)
        if ~strcmp(outstrORcell, instrORcell)
            fprintf('Note: explicit equation for ''%s'': algebraic part named as ''%s''.\n', instrORcell, outstrORcell);
        end
    elseif iscell(instrORcell)
        for c = 1:length(instrORcell)
            if ~strcmp(outstrORcell{c}, instrORcell{c})
                fprintf('Note: explicit equation for ''%s'': algebraic part named as ''%s''.\n', instrORcell{c}, outstrORcell{c});
            end
        end
    else
        % TODO: warning?
    end
end % eoname2fname

function outstrORcell = iename2fname(instrORcell)
%function outstrORcell = iename2fname(instrORcell)
%
% This function names the algebraic parts of implicit equations (KCL_xx,
% KVL_xx) by attaching 'f' at their beginning (fKCL_xx, fKVL_xx).
%
% Arguments:
%  - instrORcell: string or cell array of strings, should be valid MATLAB
%        variable/function names (returned by convert2validName).

    % outstrORcell = strcat('f', instrORcell);
    if ~isempty(instrORcell)
        outstrORcell = strcat(instrORcell, '_fi');
    else
        outstrORcell = instrORcell;
    end

    if isstr(instrORcell)
        if ~strcmp(outstrORcell, instrORcell)
            fprintf('Note: implicit equation ''%s'': algebraic part named as ''%s''.\n', instrORcell, outstrORcell);
        end
    elseif iscell(instrORcell)
        for c = 1:length(instrORcell)
            if ~strcmp(outstrORcell{c}, instrORcell{c})
                fprintf('Note: implicit equation ''%s'': algebraic part named as ''%s''.\n', instrORcell{c}, outstrORcell{c});
            end
        end
    else
        % TODO: warning?
    end
end % iename2fname

function outstrORcell = iename2qname(instrORcell)
%function outstrORcell = iename2qname(instrORcell)
%
% This function names the differential (d/dt) parts of implicit equations
% (KCL_xx, KVL_xx) by attaching 'q' at their beginning (qKCL_xx, qKVL_xx).
%
% Arguments:
%  - instrORcell: string or cell array of strings, should be valid MATLAB
%        variable/function names (returned by convert2validName).

    % outstrORcell = strcat('q', instrORcell);
    if ~isempty(instrORcell)
        outstrORcell = strcat(instrORcell, '_qi');
    else
        outstrORcell = instrORcell;
    end

    if isstr(instrORcell)
        if ~strcmp(outstrORcell, instrORcell)
            fprintf('Note: implicit equation ''%s'': differential (d/dt) part named as ''%s''.\n', instrORcell, outstrORcell);
        end
    elseif iscell(instrORcell)
        for c = 1:length(instrORcell)
            if ~strcmp(outstrORcell{c}, instrORcell{c})
                fprintf('Note: implicit equation ''%s'': differential (d/dt) part named as ''%s''.\n', instrORcell{c}, outstrORcell{c});
            end
        end
    else
        % TODO: warning?
    end
end % iename2qname

function outcell = wrap_line(instr, maxchars)
%function outcell = wrap_line(instr)
%
% This function wrap a long line str and converts it into a cell array of
% string with each string not longer than maxchars (unless the string is one
% word longer than maxchars).
%

    % exp = sprintf('(.{1,%d})(?:\\s+|$)', maxchars, maxchars);
    exp = sprintf('(\\S\\S{%d,}|.{1,%d})(?:\\s+|$)', maxchars, maxchars);

    % an example of exp: '(\S\S{80,}|.{1,80})(?:\s+|$)'
    % (\S\S{80,}|.{1,80}) matches either a non-whitespace character followed by
    % 80 or more non-whitespace characters (long word), OR any sequence of between 1 and
    % 80 characters;
    % (?:\s+|$) some whitespaces or end-of-line

    % regular expression adapted from
    % http://www.mathworks.com/matlabcentral/fileexchange/9909-line-wrap-a-string

    tokens = regexp(instr, exp, 'tokens');
    % tokens is a cell array of a cell array.

    outcell = {};
    for c = 1:length(tokens)
        outcell = {outcell{:}, tokens{c}{1}};
    end
end % wrap_line

function out = convert_to_printable_name(in)
%function out = convert_to_printable_name(in)
%
% This function converts a name string to a new string such that it is suitable
% to use for labels and titles of plots. It substitutes underscore '_' with
% '\_'.
%
    out = regexprep(in, '_', '\\_');
end % convert_to_printable_name
