% This script runs code in Examples sections in various help topics to check
% whether the code is broken by changes to MAPP.

% The help topics to be checked are organized in help_topics (cellarray of
% strings).

% This script assumes that code to be excuted under each help topic is always
% displayed between 
% 
% Examples   and    See also
% --------          --------
% 
% 

help_topics = {};
help_topics = {help_topics{:}, 'op'};
help_topics = {help_topics{:}, 'ac'};
help_topics = {help_topics{:}, 'dcsweep'};
% help_topics = {help_topics{:}, 'transient'};
    %TODO: breaks because an extra section in between Examples and See also

help_topics = {help_topics{:}, 'NR'};
help_topics = {help_topics{:}, 'AlgebraicFunction'};

help_topics = {help_topics{:}, 'add_element'};

help_topics = {help_topics{:}, 'vsrcRCL_ckt'};
help_topics = {help_topics{:}, 'fullWaveRectifier_ckt'};
help_topics = {help_topics{:}, 'BJTdiffpair_ckt'};
help_topics = {help_topics{:}, 'SH_char_curves_ckt'};
help_topics = {help_topics{:}, 'SHdiffpair_ckt'};
help_topics = {help_topics{:}, 'SHinverter_ckt'}; %TODO: imaginary parts?
help_topics = {help_topics{:}, 'SHringosc3_ckt'};
help_topics = {help_topics{:}, 'MVS_char_curves_ckt'};
help_topics = {help_topics{:}, 'MVSamp_ckt'};
help_topics = {help_topics{:}, 'MVSinverter_ckt'};
help_topics = {help_topics{:}, 'MVSringosc3_ckt'};


for c = 1:length(help_topics)
    help_topic = help_topics{c};

    fprintf('\n')
    fprintf('---------------------------------------------------\n')
    fprintf('running examples in help %s;\n', help_topic);
    fprintf('---------------------------------------------------\n')

    help_string = evalc(sprintf('help %s;', help_topic));
    %break help_string to lines (cellarray of strings)
    [lines, matches] = strsplit(help_string, char(10));

    % find_*** are cellarrays. In them, if an entry starts with 2, it means ***
    % is at the beginning of the line.
    find_See_also = strfind(lines, 'See also');
    find_Examples = strfind(lines, 'Examples');
    find_dashes = strfind(lines, '--------');

    example_started = 0;
    command = '';
    for d = 1:length(lines) % inefficient double for loop
        line = lines{d};
        if ~isempty(find_dashes{d}) && find_dashes{d}(1) == 2
        % The line starts with dashes
            if d~=1 && ~isempty(find_Examples{d-1}) && find_Examples{d-1}(1)==2
            % The line is 'Examples' before dashes
                example_started = 1;
                continue;
            end
        end
        if ~isempty(find_See_also{d}) && find_See_also{d}(1) == 2
        % The line starts with See also
            example_started = 0;
        end
        if example_started
            if ~isempty(find_Examples{d}) && find_Examples{d}(1) == 2
                % sometimes there are multiple Examples, in which case
                % code execution should be skipped
            else
                % get rid of bold hypertext
                line = regexprep(line, '</?strong>', '');
                fprintf('%s\n', line);

                command = [command, char(10), line];
            end
        end
    end
    eval(command);
    fprintf('Press any key to continue...\n');
    pause;
    close all;
end
