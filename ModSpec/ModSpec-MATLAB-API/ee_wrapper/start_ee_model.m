function start_ee_model()
% This is the model starter for EE models. TODO: detailed documentation
% To enter a new device in MAPP, just run:
% >> start_ee_model;

    % clc;
    % model name
    prompt = '\nPlease enter the model''s name (e.g., my_r_model): ';
    while(1)
        str = input(prompt, 's');
        if ~isempty(str) && isvarname(str)
            model_name = str; break;
        elseif isempty(str)
            fprintf('Model name cannot be empty.\n');
        else
            fprintf('Model name has to be a valid MATLAB identifier.\n');
        end
    end

    % terminal_names
    %   * the last one is reference, just assume it, then print this information out.
    prompt = '\nPlease enter the number of terminals in the model (e.g., 2): ';
    while(1)
        str = input(prompt, 's');
        num = str2num(str);
        if ~isempty(num) && 0 == rem(num, 1)
            nterminals = num; break;
        else
            fprintf('Please enter a positive integer.\n');
        end
    end

    num_texts = {'first', 'second', 'third', 'fourth', 'fifth', 'sixth', ...
      'seventh', 'eighth', 'ninth', 'tenth', 'eleventh', 'twelfth', 'thirteenth'};

    %   * No. 1 this is the order.
    %   * No. 2 last one is ref.

    fprintf(2, '\n    We are going to ask you to enter the names of the\n');
    fprintf(2, '    external nodes for the model. Before you do, you will\n');
    fprintf(2, '    want to decide the order in which to list the nodes''\n');
    fprintf(2, '    names. The order is important to keep in mind because\n');
    fprintf(2, '    (1) you must use the same order when using the model in\n');
    fprintf(2, '    your circuit/system netlist, and (2) the last node you\n');
    fprintf(2, '    specify is automatically assumed to be the\n');
    fprintf(2, '    device/model''s local reference or common node -- ie, all\n');
    fprintf(2, '    voltage/current branches will be defined with respect to\n');
    fprintf(2, '    the last node.\n\n');
    fprintf(2, '    For example, standard bulk-referenced 4-terminal MOS\n');
    fprintf(2, '    models typically have the node order drain, gate,\n');
    fprintf(2, '    source, bulk (d g s b); 3-terminal (source referenced)\n');
    fprintf(2, '    MOS models have the order (d g s). In MAPP/ModSpec,\n');
    fprintf(2, '    specifying these would automatically create, and give\n');
    fprintf(2, '    you access to, branches (db, gb, sb) for the 4-terminal\n');
    fprintf(2, '    case, and (ds, gs) for the 3 terminal case -- ie, the\n');
    fprintf(2, '    device equations you write can use the voltages and/or\n');
    fprintf(2, '    currents through these branches. These branch voltages\n');
    fprintf(2, '    and currents will be named (vdb, vgb, vsb, idb, igb,\n');
    fprintf(2, '    isb) for the 4-terminal case, and (vds, vgs, ids, igs)\n');
    fprintf(2, '    for the 3-terminal one.\n\n');
    fprintf(2, '    As another example, if you specify (p n) to be the node\n');
    fprintf(2, '    names of a two-terminal element, it will create the\n');
    fprintf(2, '    branch pn, which means you can use vpn and/or ipn in\n');
    fprintf(2, '    your equations.\n\n');
    fprintf(2, '    Hit Enter when ready to enter the names of your nodes: ');
    pause;
    fprintf(2, '\n');

    terminal_names = {};
    for c = 1:nterminals
        if c <= 13
            num_text = num_texts{c};
        elseif 1 == mod(c, 10)
            num_text = sprintf('%dst', c);
        elseif 1 == mod(c, 10)
            num_text = sprintf('%dnd', c);
        elseif 1 == mod(c, 10)
            num_text = sprintf('%drd', c);
        else
            num_text = sprintf('%dth', c);
        end
        if c ~= nterminals
            prompt = sprintf('\nName of the %s terminal (e.g., %c): ', num_text, ('a'-1+c));
        else
            prompt = sprintf('\nName of the last terminal (reference terminal, e.g., ref): ');
        end
        while(1)
            str = input(prompt, 's');
            if ~isempty(str)
                terminal_names = {terminal_names{:}, str}; break;
            else
                fprintf('Terminal name cannot be empty.\n');
            end
        end
    end

    refname = terminal_names{nterminals};
    for c=1:nterminals-1
    %TODO: assumed nterminals >= 2, which is assumed everywhere in MAPP...
    %      otherwise, no IOs for ee model...
        IO_names{c} = sprintf('v%s%s', terminal_names{c}, refname);
        IO_names{c+nterminals-1} = sprintf('i%s%s', terminal_names{c}, refname);
        eg_names{c} = sprintf('i%s%s', terminal_names{c}, refname);
    end
    IOstr = cell2str_nobrackets(IO_names);
    egstr = cell2str_nobrackets(eg_names);

    % clc;
    while(1)
        fprintf('\n');
        fprintf('The I/O names for this model are:\n');
        fprintf('\n');
        fprintf('    %s\n', IOstr);

        fprintf('\n');
        
        fprintf('Among them, which one(s) can be expressed explicitly \nin your model equations?\n');
        fprintf('    For example, if a resistor (with nodes p and n) is\n');
        fprintf('    written as ipn = vpn/R, ipn is explicitly available\n');
        fprintf('    in terms of vpn, so you should enter ipn. If,\n');
        fprintf('    instead, you choose to write the resistor''s equation\n');
        fprintf('    as vpn = ipn*R, then you should enter vpn. And if\n');
        fprintf('    you choose to write the resistor in implicit form,\n');
        fprintf('    ie, as vpn - ipn*R = 0, then you don''t have any of\n');
        fprintf('    your IOs explicitly expressed in terms of the\n');
        fprintf('    others, so just hit Enter (ie, don''t write\n');
        fprintf('    anything).\n\n');

        fprintf('Please enter all the explicit I/O names, (e.g., %s): ', egstr);

        str = input('', 's');
        if isempty(str)
            fprintf('\nNotice: the model has no explicit I/Os.\n');
            explicit_out_names = {};
            break;
        else
            str = regexprep(str, ',', ' ');
            explicit_out_names = strsplit(str, ' ');
            failed = 0;
            for c = length(explicit_out_names)
                eio = explicit_out_names{c};
                idx_in_IOs = find(strcmp(eio, IO_names));
                if length(idx_in_IOs) ~= 1
                    fprintf('\nExplicit I/O %s not found exactly once in I/Os, please try again.\n', eio);
                    failed = 1;
                end
            end
            if ~failed
                break;
            end
        end
    end

    % internal unk names
    prompt = '\nEnter the names of the model''s internal unknowns (e.g., unk1, unk2).\nIf there are no internal unknowns, just hit enter: ';
    str = input(prompt, 's');
    if isempty(str)
        % fprintf('Notice: the model has no internal unknowns.\n'); break;
        internal_unk_names = {};
    else
        str = regexprep(str, ',', ' ');
        internal_unk_names = strsplit(str, ' ');
    end

    % implicit eqn names
    niens = nterminals-1 - length(explicit_out_names) + length(internal_unk_names);
    if niens > 0
        fprintf('\nThe model has %d implicit equation(s).', niens);
        prompt = '\nWould you like to specify their names? Y/N [N]: ';
        while(1)
            str = input(prompt, 's');
            if isempty(str) || strcmp(str, 'n') || strcmp(str, 'N')
                implicit_eqn_names = {};
                break;
            elseif strcmp(str, 'y') || strcmp(str, 'Y')
                implicit_eqn_names = {};
                for c = 1:niens
                    if c <= 13
                        num_text = num_texts{c};
                    elseif 1 == mod(c, 10)
                        num_text = sprintf('%dst', c);
                    elseif 1 == mod(c, 10)
                        num_text = sprintf('%dnd', c);
                    elseif 1 == mod(c, 10)
                        num_text = sprintf('%drd', c);
                    else
                        num_text = sprintf('%dth', c);
                    end
                    prompt = sprintf('\nName of the %s implicit equation (e.g., eqn_%d): ', num_text, c);
                    while(1)
                        str = input(prompt, 's');
                        if ~isempty(str)
                            implicit_eqn_names = {implicit_eqn_names{:}, str};
                            break;
                        else
                            fprintf('\nImplicit equation name cannot be empty.');
                        end
                    end
                end
                break;
            else
                fprintf('\nNotice: implicit equation names are set up automatically.\n');
                implicit_eqn_names = {};
                break;
            end
        end
    else
        implicit_eqn_names = {};
    end

    % Step 2: process model information, e.g., assemble internal_unks based
    %         on internal nodes and other internal unks.

    % Step 3: write wrapper code based on the following model information:
    %         model_name
    %         terminal_names
    %         explicit_out_names
    %         internal_unk_names
    %         implicit_eqn_names
    %         parm_names
    %         parm_vals

%%%%%%%%% step 3 test %%%%%%%%%%%
% model_name = 'SH_MOS';
% terminal_names = {'d', 'g', 's'};
% explicit_out_names = {'ids', 'igs'};
% internal_unk_names = {};
% implicit_eqn_names = {};
% IO_names = {'vds', 'vgs', 'ids', 'igs'};
% parm_names = {'Is', 'VT'};
% parm_vals = {1e-12, 0.026};
%%%%%% end of step 3 test %%%%%%%

    % ---------------------------------------------------------
    eon_str = cell2str_nobrackets(explicit_out_names);
    io_str = cell2str_nobrackets(explicit_out_names);
    % parm_str = cell2str_nobrackets(parm_names);
    otherIO_names = setdiff(IO_names, explicit_out_names);
    oion_str = cell2str_nobrackets(otherIO_names);
    iun_str = cell2str_nobrackets(internal_unk_names);

    if isempty(explicit_out_names)
		explicit_out_q_names = {};
		explicit_out_f_names = {};
    else
		explicit_out_q_names = strcat(explicit_out_names, '_qe');
		explicit_out_f_names = strcat(explicit_out_names, '_fe');
    end

    explicit_out_f_str = cell2str_nobrackets(explicit_out_f_names);
    explicit_out_q_str = cell2str_nobrackets(explicit_out_q_names);

    niens = length(terminal_names)-1 - length(explicit_out_names) + length(internal_unk_names);
    niens_zeros = {};
    for c= 1:niens
        niens_zeros = {niens_zeros{:}, '0'};
    end
    niens_zeros_str = cell2str_nobrackets(niens_zeros); % '0, 0, 0, ..., 0' niens zeros

    if isempty(iun_str)
        input_str = oion_str;
    else
        input_str = sprintf('%s, %s', oion_str, iun_str);
    end
    % ---------------------------------------------------------

    % fid = 1;
    filename = sprintf('%s.m', model_name);
    fid = fopen(filename, 'w');

    print_ind(fid, 0, sprintf('%%%% This is the template file for %s generated by', model_name));
	% datestr = date;
    % c = clock;
    % timestr = sprintf('%d%d:%d%d:%d%d 24-hour format', floor(c(4)/10), mod(c(4),10), floor(c(5)/10), mod(c(5),10), floor(c(6)/10), mod(round(c(6)),10));
    % print_ind(fid, 0, sprintf('%%%% MAPP''s Model Starter, %s %s.', datestr, timestr));
    str = [datestr(now(), 'yyyy-mmm-dd--HH-MM-SS'), ' (24-hour format)'];
    print_ind(fid, 0, sprintf('%%%% MAPP''s Model Starter, %s.', str));
    print_ind(fid, 0, '%%');
    print_ind(fid, 0, '%% Your model''s equations are in the following format:');
    print_ind(fid, 0, '%%');
    if ~isempty(explicit_out_names)
		eon_str_col =  regexprep(eon_str, ',', ';');
		print_ind(fid, 0, '%% Equations for the explicit outputs:');
		print_ind(fid, 0, sprintf('%%%%   [%s] = d/dt(qe(...)) + fe(...); % or qe/fe', eon_str_col));
		print_ind(fid, 0, '%%   - Please fill in your code in the functions qe');
		print_ind(fid, 0, sprintf('%%%%     and fe below to compute and return [%s].', eon_str_col));
		print_ind(fid, 0, '%%     See the comments within these functions.');
		print_ind(fid, 0, '%%   - Note: You don''t need to (and should not!) attempt');
		print_ind(fid, 0, '%%     to handle the d/dt operator within your code. The');
		print_ind(fid, 0, '%%     simulator will handle d/dt automatically. You');
		print_ind(fid, 0, '%%     should only provide, in qe(...), the quantities');
		print_ind(fid, 0, '%%     that are differentiated - eg, charges and fluxes.');
		print_ind(fid, 0, '%%');
    else
		print_ind(fid, 0, '%% The model has no explicit equations.');
		print_ind(fid, 0, '%%');
    end
    if niens > 0
		print_ind(fid, 0, '%% Other (implicit) equations:');
		if 1 == niens  % the simplest dumbest way
			print_ind(fid, 0, '%%   out = d/dt qi(...) + fi(...); ');
		elseif 2 == niens
			print_ind(fid, 0, '%%   [out_1; out_2] = d/dt qi(...) + fi(...); ');
		elseif 3 == niens
			print_ind(fid, 0, '%%   [out_1; out_2; out_3] = d/dt qi(...) + fi(...); ');
		else % 4 <= niens
			print_ind(fid, 0, sprintf('%%%%   [out_1; out_2; ...; out_%d] = d/dt qi(...) + fi(...); ', niens));
        end
		print_ind(fid, 0, '%%   - Please fill in appropriate code in the functions qi');
		print_ind(fid, 0, '%%     and fi below - see the comments within these functions.');
		print_ind(fid, 0, '%%   - Note: ONLY after the system is SOLVED SUCCESSFULLY');
		print_ind(fid, 0, '%%           by the simulator will');
		if 1 == niens  % the simplest dumbest way
			print_ind(fid, 0, '%%           out = 0.');
		elseif 2 == niens
			print_ind(fid, 0, '%%           [out_1; out_2] = [0; 0].');
		elseif 3 == niens
			print_ind(fid, 0, '%%           [out_1; out_2; out_3] = [0; 0; 0].');
		else % 4 <= niens
			print_ind(fid, 0, sprintf('%%%%           [out_1; out_2; ...; out_%d] = [0; 0; ...; 0].', niens));
        end
		print_ind(fid, 0, '%%');
    end

    % ---------------------------------------------------------
    new_line(fid);
    print_ind(fid, 0, sprintf('function MOD = %s()', model_name));
    print_ind(fid, 1, 'MOD = ee_model();');
    print_ind(fid, 1, sprintf('MOD = add_to_ee_model(MOD, ''name'', ''%s'');', model_name));
    print_ind(fid, 1, sprintf('MOD = add_to_ee_model(MOD, ''terminals'', {%s});', cell2str_w_quotes(terminal_names)));
    print_ind(fid, 1, sprintf('MOD = add_to_ee_model(MOD, ''explicit_outs'', {%s});', cell2str_w_quotes(explicit_out_names)));
    if ~isempty(internal_unk_names)
        print_ind(fid, 1, sprintf('MOD = add_to_ee_model(MOD, ''internal_unks'', {%s});', cell2str_w_quotes(internal_unk_names)));
    end
    if ~isempty(implicit_eqn_names)
        print_ind(fid, 1, sprintf('MOD = add_to_ee_model(MOD, ''implicit_eqn_names'', {%s});', cell2str_w_quotes(implicit_eqn_names)));
    end

    new_line(fid);
    print_ind(fid, 1, '%% Please enter the parameter(s) using the following template:');
    print_ind(fid, 1, '%% MOD = add_to_ee_model(MOD, ''parms'', {''parm1_name'', default_val1});');
    print_ind(fid, 1, '%%                                             ^            ^         ');
    print_ind(fid, 1, '%%                                              CHANGE THESE          ');
    print_ind(fid, 1, '%% MOD = add_to_ee_model(MOD, ''parms'', {''parm2_name'', default_val2});');
    print_ind(fid, 1, '%%                                             ^            ^         ');
    print_ind(fid, 1, '%%                                              CHANGE THESE          ');
    print_ind(fid, 1, 'DELETE THIS LINE WHEN DONE ENTERING YOUR PARAMETERS');
    % for c = 1:length(parm_names) %TODO: multiple parms in one line for pretty print
    %     print_ind(fid, 1, sprintf('MOD = add_to_ee_model(MOD, ''parms'', {''%s'', %g});', parm_names{c}, parm_vals{c}));
    %          %TODO: check numerical accuracy --- whether %g loses digits
    % end

    new_line(fid);
    if ~isempty(explicit_out_names)
		print_ind(fid, 1, 'MOD = add_to_ee_model(MOD, ''fe'', @fe);');
		print_ind(fid, 1, 'MOD = add_to_ee_model(MOD, ''qe'', @qe);');
    end
    if niens > 0
        print_ind(fid, 1, 'MOD = add_to_ee_model(MOD, ''fi'', @fi);');
        print_ind(fid, 1, 'MOD = add_to_ee_model(MOD, ''qi'', @qi);');
    end
    new_line(fid);
    print_ind(fid, 1, 'MOD = finish_ee_model(MOD);');
    print_ind(fid, 0, sprintf('end %%%% %s', model_name));

    % ---------------------------------------------------------
	%{
	template = ['\nfunction out = fORq_template(S)', ...
	'\n    %% You need to fill in this function with equations', ...
	'\n    %% for the explicit output(s) of your device model.', ...
	'\n    %%', ...
	'\n    %% The explicit outputs you entered in the model starter', ...
	'\n    %% are:', ...
	'\n    %%   eon_template', ...
	'\n    %%', ...
	'\n    %% These explicit outputs are returned in out, which', ...
	'\n    %% is a vector (of size neon_template in this case). It MUST BE', ...
	'\n    %% a COLUMN VECTOR (not a row vector). Please set', ...
	'\n    %% up your explicit outputs like this:', ...
	'\n    %%', ...
	'output_template', ...
	'\n    %%', ...
	'\n    %% Below, the first line you will see is v2struct(S).', ...
	'\n    %% This populates your workspace within this function', ...
	'\n    %% with variables corresponding to the device''s parameters', ...
	'\n    %% and relevant branch voltages/currents.', ...
	'\n    %% These variables are available in this function''s local', ...
	'\n    %% scope, so you can use them directly in your code below.', ...
	'\n    %%', ...
	'\n    %% For example, if you defined parameters R and C above', ...
	'\n    %% using lines of the form', ...
	'\n    %%   MOD = add_to_ee_model(MOD, ''parms'', {''R'', 1000.0}),', ...
	'\n    %%   MOD = add_to_ee_model(MOD, ''parms'', {''C'', 1e-6}),', ...
	'\n    %% then you can use R and C anywhere in your code below, eg,', ...
	'\n    %%   tau = R*C;', ...
	'\n    %%', ...
	'\n    %% In the same way, you also have access to the following', ...
	'\n    %% relevant branch quantities, using which your code', ...
	'\n    %% should compute the entries of out as described above:', ...
	'\n    %%   vpn', ...
	'\n    %% (You do not have access to ipn because it is an', ...
	'\n    %%  an explicit output).', ...
	'\n  ', ...
	'\n    v2struct(S);', ...
	'\n  ', ...
	'\n    PLEASE PUT YOUR CODE SETTING UP out HERE'];

	% fORq_template: f
	% eon_template: ipn
	% neon_template: 1
	% output_template: '\n    %% out(1,1) = <some code that returns ipn>;'
	%}

    % ---------------------------------------------------------

    if ~isempty(explicit_out_names)
		new_line(fid);
		print_ind(fid, 0, 'function out = fe(S)');
		print_ind(fid, 1, '%% You need to fill in this function with equations');
		print_ind(fid, 1, '%% for the explicit output(s) of your device model.');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% The explicit outputs you entered in the model starter');
		print_ind(fid, 1, '%% are:');
		print_ind(fid, 1, sprintf('%%%%   %s', eon_str));
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% The algebraic parts of these explicit outputs, i.e.,');
		print_ind(fid, 1, sprintf('%%%% %s, are returned in out, which', explicit_out_f_str));
		print_ind(fid, 1, sprintf('%%%% is a vector (of size %d in this case). It MUST BE', length(explicit_out_names)));
		print_ind(fid, 1, '%% a COLUMN VECTOR (not a row vector). Please set');
		print_ind(fid, 1, '%% up your explicit outputs like this:');
		print_ind(fid, 1, '%%');
		for c = 1:length(explicit_out_names)
			print_ind(fid, 1, sprintf('%%%% out(%d,1) = <some code that returns %s>;', c, explicit_out_f_names{c}));
		end
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% Below, the first line you will see is v2struct(S).');
		print_ind(fid, 1, '%% This populates your workspace within this function');
		print_ind(fid, 1, '%% with variables corresponding to the device''s parameters');
		print_ind(fid, 1, '%% and relevant branch voltages/currents.');
		print_ind(fid, 1, '%% These variables are available in this function''s local');
		print_ind(fid, 1, '%% scope, so you can use them directly in your code below');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% For example, if you defined parameters R and C above');
		print_ind(fid, 1, '%% using lines of the form');
		print_ind(fid, 1, '%%   MOD = add_to_ee_model(MOD, ''parms'', {''R'', 1000.0}),');
		print_ind(fid, 1, '%%   MOD = add_to_ee_model(MOD, ''parms'', {''C'', 1e-6}),');
		print_ind(fid, 1, '%% then you can use R and C anywhere in your code below, eg,');
		print_ind(fid, 1, '%%   tau = R*C;');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% In the same way, you also have access to the following');
		print_ind(fid, 1, '%% relevant branch quantities and internal unknowns, using');
		print_ind(fid, 1, '%% which your code should compute the entries of out as ');
		print_ind(fid, 1, '%% described above:');
		print_ind(fid, 1, sprintf('%%%%   %s', oion_str));
		print_ind(fid, 1, sprintf('%%%%   %s', iun_str));
		if 1 == length(explicit_out_names)
			print_ind(fid, 1, sprintf('%%%% (You do not have access to %s because it is an', eon_str));
			print_ind(fid, 1, '%%  an explicit output).');
		elseif length(explicit_out_names) >= 2
			print_ind(fid, 1, sprintf('%%%% (You do not have access to %s because they are', eon_str));
			print_ind(fid, 1, '%%  explicit outputs).');
		end
		new_line(fid);
		print_ind(fid, 1, 'v2struct(S);');
		new_line(fid);
		print_ind(fid, 1, '%% PLEASE PUT YOUR CODE SETTING UP out HERE');

		% print_ind(fid, 1, '%%');
		% print_ind(fid, 1, '%% The format of the model''s explicit equation(s):');
		% print_ind(fid, 1, '%%');
		% if 0 == niens
		%     print_ind(fid, 1, sprintf('%%%% [%s] = d/dt q(%s) + f(%s);', eon_str, input_str, input_str));
		% else
		%     print_ind(fid, 1, sprintf('%%%% [%s] = d/dt qe(%s) + fe(%s);', eon_str, input_str, input_str));
		% end
		% print_ind(fid, 1, '%%');
		% print_ind(fid, 1, 'v2struct(S);');
		% print_ind(fid, 1, '%% v2struct unpacks variables from input S and gives you access to');
		% print_ind(fid, 1, '%% all the parameter(s) defined above,');
		% if isempty(internal_unk_names)
		%     print_ind(fid, 1, sprintf('%%%% and electrical quantity(ies) %s.', oion_str));
		% else
		%     print_ind(fid, 1, sprintf('%%%% electrical quantity(ies) %s, and %s.', oion_str, iun_str));
		% end
		new_line(fid);
		if isempty(explicit_out_names)
			print_ind(fid, 1, 'out = [];');
		else
			for c = 1:length(explicit_out_names)
				print_ind(fid, 1, sprintf('%s = ... FILL THIS IN', explicit_out_f_names{c}));
			end
			new_line(fid);
			for c = 1:length(explicit_out_names)
				print_ind(fid, 1, sprintf('out(%d, 1) = %s;', c, explicit_out_f_names{c}));
			end
		end

		print_ind(fid, 0, 'end %% fe');

		% ---------------------------------------------------------
		new_line(fid);
		print_ind(fid, 0, 'function out = qe(S)');
		print_ind(fid, 1, '%% You need to fill in this function with equations');
		print_ind(fid, 1, '%% for the explicit output(s) of your device model.');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% The explicit outputs you entered in the model starter');
		print_ind(fid, 1, '%% are:');
		print_ind(fid, 1, sprintf('%%%%   %s', eon_str));
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% The d/dt parts of these explicit outputs, i.e.,');
		print_ind(fid, 1, sprintf('%%%% %s, are returned in out, which', explicit_out_q_str));
		print_ind(fid, 1, sprintf('%%%% is a vector (of size %d in this case). It MUST BE', length(explicit_out_names)));
		print_ind(fid, 1, '%% a COLUMN VECTOR (not a row vector). Please set');
		print_ind(fid, 1, '%% up your explicit outputs like this:');
		print_ind(fid, 1, '%%');
		for c = 1:length(explicit_out_names)
			print_ind(fid, 1, sprintf('%%%% out(%d,1) = <some code that returns %s>;', c, explicit_out_q_names{c}));
		end
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% Below, the first line you will see is v2struct(S).');
		print_ind(fid, 1, '%% This populates your workspace within this function');
		print_ind(fid, 1, '%% with variables corresponding to the device''s parameters');
		print_ind(fid, 1, '%% and relevant branch voltages/currents.');
		print_ind(fid, 1, '%% These variables are available in this function''s local');
		print_ind(fid, 1, '%% scope, so you can use them directly in your code below');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% For example, if you defined parameters R and C above');
		print_ind(fid, 1, '%% using lines of the form');
		print_ind(fid, 1, '%%   MOD = add_to_ee_model(MOD, ''parms'', {''R'', 1000.0}),');
		print_ind(fid, 1, '%%   MOD = add_to_ee_model(MOD, ''parms'', {''C'', 1e-6}),');
		print_ind(fid, 1, '%% then you can use R and C anywhere in your code below, eg,');
		print_ind(fid, 1, '%%   tau = R*C;');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% In the same way, you also have access to the following');
		print_ind(fid, 1, '%% relevant branch quantities and internal unknowns, using');
		print_ind(fid, 1, '%% which your code should compute the entries of out as ');
		print_ind(fid, 1, '%% described above:');
		print_ind(fid, 1, sprintf('%%%%   %s', oion_str));
		print_ind(fid, 1, sprintf('%%%%   %s', iun_str));
		if 1 == length(explicit_out_names)
			print_ind(fid, 1, sprintf('%%%% (You do not have access to %s because it is an', eon_str));
			print_ind(fid, 1, '%%  an explicit output).');
		elseif length(explicit_out_names) >= 2
			print_ind(fid, 1, sprintf('%%%% (You do not have access to %s because they are', eon_str));
			print_ind(fid, 1, '%%  explicit outputs).');
		end
		new_line(fid);
		print_ind(fid, 1, 'v2struct(S);');
		new_line(fid);
		print_ind(fid, 1, '%% PLEASE PUT YOUR CODE SETTING UP out HERE');
		new_line(fid);

		if isempty(explicit_out_names)
			print_ind(fid, 1, 'out = [];');
		else
			for c = 1:length(explicit_out_names)
				print_ind(fid, 1, sprintf('%s = ... FILL THIS IN', explicit_out_q_names{c}));
			end
			new_line(fid);
			for c = 1:length(explicit_out_names)
				print_ind(fid, 1, sprintf('out(%d, 1) = %s;', c, explicit_out_q_names{c}));
			end
		end

		print_ind(fid, 0, 'end %% qe');

    end
    % ---------------------------------------------------------
	autoiens = 0;
	if isempty(implicit_eqn_names)
		for c = 1:niens
			implicit_eqn_names = {implicit_eqn_names{:}, sprintf('implicit_equation_%d', c)};
		end
        autoiens = 1;
	end
    % Note: from here, implicit_eqn_names and niens are consistent
    % ---------------------------------------------------------
    if 0 ~= niens
        new_line(fid);
		print_ind(fid, 0, 'function out = fi(S)');
		print_ind(fid, 1, '%% You need to fill in this function with the algebraic');
		print_ind(fid, 1, '%% parts of the implicit equations of your device model.');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% The implicit equations have the following format:');
		print_ind(fid, 1, '%%');
        for c = 1:niens
            if 1 == c
				str = '%% [';
			end
            if niens == c
				str = [str, implicit_eqn_names{c}];
				str = [str, '] = d/dt qi(...) + fi(...);'];
			else
				str = [str, implicit_eqn_names{c}];
				str = [str, ';'];
				str = [str, '\n    %%  '];
			end
        end
        print_ind(fid, 1, str);
        print_ind(fid, 1, '%%');
        if autoiens 
            print_ind(fid, 1, '%% Implicit equation names are automatically set up in this model.');
			print_ind(fid, 1, '%%');
        end
		print_ind(fid, 1, '%% The values of the algebraic parts of the equations above,');
		print_ind(fid, 1, '%% i.e., fi(...), are returned in out, which is a vector');
		print_ind(fid, 1, sprintf('%%%% (of size %d in this case). It MUST BE a COLUMN VECTOR', niens));
		print_ind(fid, 1, '%% (not a row vector). Please set up your outputs like this:');
		print_ind(fid, 1, '%%');
        for c=1:length(implicit_eqn_names)
			print_ind(fid, 1, sprintf('%%%% out(%d,1) = <algebraic part of %s>;', c, implicit_eqn_names{c}));
        end
		print_ind(fid, 1, '%%');

		print_ind(fid, 1, '%% Below, the first line you will see is v2struct(S).');
		print_ind(fid, 1, '%% This populates your workspace within this function');
		print_ind(fid, 1, '%% with variables corresponding to the device''s parameters');
		print_ind(fid, 1, '%% and relevant branch voltages/currents.');
		print_ind(fid, 1, '%% These variables are available in this function''s local');
		print_ind(fid, 1, '%% scope, so you can use them directly in your code below');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% For example, if you defined parameters R and C above');
		print_ind(fid, 1, '%% using lines of the form');
		print_ind(fid, 1, '%%   MOD = add_to_ee_model(MOD, ''parms'', {''R'', 1000.0}),');
		print_ind(fid, 1, '%%   MOD = add_to_ee_model(MOD, ''parms'', {''C'', 1e-6}),');
		print_ind(fid, 1, '%% then you can use R and C anywhere in your code below, eg,');
		print_ind(fid, 1, '%%   tau = R*C;');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% In the same way, you also have access to the following');
		print_ind(fid, 1, '%% relevant branch quantities and internal unknowns, using');
		print_ind(fid, 1, '%% which your code should compute the entries of out as ');
		print_ind(fid, 1, '%% described above:');
		print_ind(fid, 1, sprintf('%%%%   %s', oion_str));
		print_ind(fid, 1, sprintf('%%%%   %s', iun_str));
		if 1 == length(explicit_out_names)
			print_ind(fid, 1, sprintf('%%%% (You do not have access to %s because it is an', eon_str));
			print_ind(fid, 1, '%%  an explicit output).');
		elseif length(explicit_out_names) >= 2
			print_ind(fid, 1, sprintf('%%%% (You do not have access to %s because they are', eon_str));
			print_ind(fid, 1, '%%  explicit outputs).');
		end
		new_line(fid);
		print_ind(fid, 1, 'v2struct(S);');
		new_line(fid);
		print_ind(fid, 1, '%% PLEASE PUT YOUR CODE SETTING UP out HERE');
		new_line(fid);

		for c = 1:length(implicit_eqn_names)
			print_ind(fid, 1, sprintf('%%%% algebraic part of %s', implicit_eqn_names{c}));
			print_ind(fid, 1, sprintf('out(%d, 1) = ... FILL THIS IN;', c));
		end
        print_ind(fid, 0, 'end %% fi');

        % ---------------------------------------------------------
        new_line(fid);
		print_ind(fid, 0, 'function out = qi(S)');
		print_ind(fid, 1, '%% You need to fill in this function with the d/dt');
		print_ind(fid, 1, '%% parts of the implicit equations of your device model.');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% The implicit equations have the following format:');
		print_ind(fid, 1, '%%');
        for c = 1:niens
            if 1 == c
				str = '%% [';
			end
            if niens == c
				str = [str, implicit_eqn_names{c}];
				str = [str, '] = d/dt qi(...) + fi(...);'];
			else
				str = [str, implicit_eqn_names{c}];
				str = [str, ';'];
				str = [str, '\n    %%  '];
			end
        end
        print_ind(fid, 1, str);
        print_ind(fid, 1, '%%');
        if autoiens 
            print_ind(fid, 1, '%% Implicit equation names are automatically set up in this model.');
			print_ind(fid, 1, '%%');
        end
		print_ind(fid, 1, '%% The values of the d/dt parts of the equations above,');
		print_ind(fid, 1, '%% i.e., qi(...), are returned in out, which is a vector');
		print_ind(fid, 1, sprintf('%%%% (of size %d in this case). It MUST BE a COLUMN VECTOR', niens));
		print_ind(fid, 1, '%% (not a row vector). Please set up your outputs like this:');
		print_ind(fid, 1, '%%');
        for c=1:length(implicit_eqn_names)
			print_ind(fid, 1, sprintf('%%%% out(%d,1) = <d/dt part of %s>;', c, implicit_eqn_names{c}));
        end
		print_ind(fid, 1, '%%');

		print_ind(fid, 1, '%% Below, the first line you will see is v2struct(S).');
		print_ind(fid, 1, '%% This populates your workspace within this function');
		print_ind(fid, 1, '%% with variables corresponding to the device''s parameters');
		print_ind(fid, 1, '%% and relevant branch voltages/currents.');
		print_ind(fid, 1, '%% These variables are available in this function''s local');
		print_ind(fid, 1, '%% scope, so you can use them directly in your code below');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% For example, if you defined parameters R and C above');
		print_ind(fid, 1, '%% using lines of the form');
		print_ind(fid, 1, '%%   MOD = add_to_ee_model(MOD, ''parms'', {''R'', 1000.0}),');
		print_ind(fid, 1, '%%   MOD = add_to_ee_model(MOD, ''parms'', {''C'', 1e-6}),');
		print_ind(fid, 1, '%% then you can use R and C anywhere in your code below, eg,');
		print_ind(fid, 1, '%%   tau = R*C;');
		print_ind(fid, 1, '%%');
		print_ind(fid, 1, '%% In the same way, you also have access to the following');
		print_ind(fid, 1, '%% relevant branch quantities and internal unknowns, using');
		print_ind(fid, 1, '%% which your code should compute the entries of out as ');
		print_ind(fid, 1, '%% described above:');
		print_ind(fid, 1, sprintf('%%%%   %s', oion_str));
		print_ind(fid, 1, sprintf('%%%%   %s', iun_str));
		if 1 == length(explicit_out_names)
			print_ind(fid, 1, sprintf('%%%% (You do not have access to %s because it is an', eon_str));
			print_ind(fid, 1, '%%  an explicit output).');
		elseif length(explicit_out_names) >= 2
			print_ind(fid, 1, sprintf('%%%% (You do not have access to %s because they are', eon_str));
			print_ind(fid, 1, '%%  explicit outputs).');
		end
		new_line(fid);
		print_ind(fid, 1, 'v2struct(S);');
		new_line(fid);
		print_ind(fid, 1, '%% PLEASE PUT YOUR CODE SETTING UP out HERE');
		new_line(fid);

		for c = 1:length(implicit_eqn_names)
			print_ind(fid, 1, sprintf('%%%% d/dt part of %s', implicit_eqn_names{c}));
			print_ind(fid, 1, sprintf('out(%d, 1) = ... FILL THIS IN;', c));
		end
        print_ind(fid, 0, 'end %% qi');
    end

    % ---------------------------------------------------------
    if 1 ~= fid
        fclose(fid);
    end

    fprintf('\n');
	fprintf('===============================================================\n');
    fprintf('The ModSpec model is created in %s.\n', filename);
    fprintf('\n');
    fprintf('Next steps:\n');
    fprintf('    Step 1: Define model parameters.\n');
	fprintf('    Step 2: Fill in the functions fe, qe, fi and qi.\n');
    fprintf('\n');
	fprintf('Please see the comments, especially those marked \n');
	fprintf('"FILL THIS IN", in the model file %s to complete the model.\n', filename);
	fprintf('===============================================================\n');

end % start_ee_model

function out = cell2str_nobrackets(cellin)
%function out = cell2str_nobrackets(cellin)
%MATLAB function to convert cell elements to a string, without the brackets
    out = '';
    n = length(cellin);
    for i = 1:n
        out = strcat(out, cellin{i});
        if i ~= n
            out = strcat(out, ',');
        end
    end
    out = regexprep(out, ',', ', ');
end

function out = cell2str_w_quotes(cellin)
%function out = cell2str_w_quotes(cellin)
%MATLAB function to convert cell elements to a string, without the brackets
% with quotes
    out = '';
    n = length(cellin);
    for i = 1:n
        out = strcat(out, '''');
        out = strcat(out, cellin{i});
        out = strcat(out, '''');
        if i ~= n
            out = strcat(out, ',');
        end
    end
    out = regexprep(out, ',', ', ');
end

function print_ind(fid, ind, str)
    ind_str = '';
    for c = 1:ind 
        ind_str = sprintf('%s    ', ind_str);
    end
    fprintf(fid, sprintf('%s%s\n', ind_str, str));
end

function new_line(fid)
    fprintf(fid, '\n');
end
