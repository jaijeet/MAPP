function [filename, is_new, ok] = run_DAEAPI_functions(DAE, name, lastarg)
%========================================================
% function [filename, is_new, ok] = run_DAEAPI_functions(DAE, name, lastarg)
% Author: Tianshi Wang, 2012-11-20
%
% Usage: (1) run_DAEAPI_functions(DAE, name)
%     If no lastarg or lastarg is anything but 'update'
%     run all functions in DAE, print test results 
%     on screen.
%
%     (2) run_DAEAPI_functions(DAE, name, 'update')
%     Update test-data when you are satisfied with
%     the current DAE.
%
% Inputs:  DAE      --> DAE to test
%          name     --> name of the function that generates
%            DAE. 
%            Consistent with .mat file
%          lastarg  --> 'update' or nothing
%      
% Outputs: filename --> name of the .mat file
%          is_new   --> 1 the .mat is newly created by this function
%                       0 the .mat exists before this function
%          ok       --> 1 if tests against ref data all passed
%                         or running in 'update' mode
%                       0 if tests against ref data failed
%
%========================================================
%
if nargin < 1
    % help strings
    fprintf('Usage: (1) run_DAEAPI_functions(DAE, name)\n');
    fprintf('    Run all functions in DAE, print test results \n');
    fprintf('    on screen.\n');
    fprintf('       (2) run_DAEAPI_functions(DAE, name, ''update'')\n');
    fprintf('    Update test-data when you are satisfied with\n');
    fprintf('    the current DAE.\n');
    fprintf('Outputs: [filename, is_new] \n');
    fprintf('        is_new==1 if the .mat file is created by this function\n');
    return;
elseif nargin < 2
    % help strings
    fprintf('Usage: (1) run_DAEAPI_functions(DAE, name)\n');
    fprintf('       (2) run_DAEAPI_functions(DAE, name, ''update'')\n');
    fprintf('run:   run_DAEAPI_functions() for help strings\n');
    return;
elseif nargin < 3
    update = 0;
else
    update = is_equal(lastarg, 'update');
end
%
filename = sprintf('%s.mat', name);
if exist(filename) 
    load(filename); % get ref in workspace
    is_new = 0;
else
    is_new = 1;
    if ~update
        error(sprintf('Test-data file %s doesn''t exist, do update first!',filename));
    end
end

ok = 1;

%===========================================================
fprintf(1, '--------------------------------------------\n');
fprintf(1, '               static testing               \n');
%
%===========================================================
% run nunks
test.nunks = feval(DAE.nunks, DAE);
if update
    fprintf(1, 'nunks: %s\n', test.nunks);
else
    if is_equal(test.nunks, ref.nunks)
        print_success('nunks');
    else
        print_failure('nunks', test.nunks, ref.nunks);
        ok = 0;
    end
end

%===========================================================
% run neqns
test.neqns = feval(DAE.neqns, DAE);
if update
    fprintf(1, 'neqns: %s\n', test.neqns);
else
    if is_equal(test.neqns, ref.neqns)
        print_success('neqns');
    else
        print_failure('neqns', test.neqns, ref.neqns);
        ok = 0;
    end
end

%===========================================================
% run ninputs
test.ninputs = feval(DAE.ninputs, DAE);
if update
    fprintf(1, 'ninputs: %s\n', test.ninputs);
else
    if is_equal(test.ninputs, ref.ninputs)
        print_success('ninputs');
    else
        print_failure('ninputs', test.ninputs, ref.ninputs);
        ok = 0;
    end
end

%===========================================================
% run noutputs
test.noutputs = feval(DAE.noutputs, DAE);
if update
    fprintf(1, 'noutputs: %s\n', test.noutputs);
else
    if is_equal(test.noutputs, ref.noutputs)
        print_success('noutputs');
    else
        print_failure('noutputs', test.noutputs, ref.noutputs);
        ok = 0;
    end
end

%===========================================================
% run nparms
test.nparms = feval(DAE.nparms, DAE);
if update
    fprintf(1, 'nparms: %s\n', test.nparms);
else
    if is_equal(test.nparms, ref.nparms)
        print_success('nparms');
    else
        print_failure('nparms', test.nparms, ref.nparms);
        ok = 0;
    end
end

%===========================================================
% run uniqID
test.uniqID = feval(DAE.uniqID, DAE);
if update
    fprintf(1, 'uniqID: %s\n', test.uniqID);
else
    if is_equal(test.uniqID, ref.uniqID)
        print_success('uniqID');
    else
        print_failure('uniqID', test.uniqID, ref.uniqID);
        ok = 0;
    end
end

%===========================================================
% run daename
test.daename = feval(DAE.daename, DAE);
if update
    fprintf(1, 'daename: %s\n', test.daename);
else
    if is_equal(test.daename, ref.daename)
        print_success('daename');
    else
        print_failure('daename', test.daename, ref.daename);
        ok = 0;
    end
end

%===========================================================
% run unknames
test.unknames = feval(DAE.unknames, DAE);
if update
    fprintf(1, 'unknames: %s\n', cell2str(test.unknames));
else
    if is_equal(test.unknames, ref.unknames)
        print_success('unknames');
    else
        print_failure('unknames', test.unknames, ref.unknames);
        ok = 0;
    end
end

%===========================================================
% run eqnnames
test.eqnnames = feval(DAE.eqnnames, DAE);
if update
    fprintf(1, 'eqnnames: %s\n', cell2str(test.eqnnames));
else
    if is_equal(test.eqnnames, ref.eqnnames)
        print_success('eqnnames');
    else
        print_failure('eqnnames', test.eqnnames, ref.eqnnames);
        ok = 0;
    end
end

%===========================================================
% run inputnames
test.inputnames = feval(DAE.inputnames, DAE);
if update
    fprintf(1, 'inputnames: %s\n', cell2str(test.inputnames));
else
    if is_equal(test.inputnames, ref.inputnames)
        print_success('inputnames');
    else
        print_failure('inputnames', test.inputnames, ref.inputnames);
        ok = 0;
    end
end

%===========================================================
% run outputnames
test.outputnames = feval(DAE.outputnames, DAE);
if update
    fprintf(1, 'outputnames: %s\n', cell2str(test.outputnames));
else
    if is_equal(test.outputnames, ref.outputnames)
        print_success('outputnames');
    else
        print_failure('outputnames', test.outputnames, ref.outputnames);
        ok = 0;
    end
end

%===========================================================
% run parmnames
test.parmnames = feval(DAE.parmnames, DAE);
if update
    fprintf(1, 'parmnames: %s\n', cell2str(test.parmnames));
else
    if is_equal(test.parmnames, ref.parmnames)
        print_success('parmnames');
    else
        print_failure('parmnames', test.parmnames, ref.parmnames);
        ok = 0;
    end
end

%===========================================================
% getparms and setparms 
parmvals = feval(DAE.parmdefaults, DAE);

if length(parmvals) > 0
    % setparms
    parmvals{end} = 100;
    DAE = feval(DAE.setparms, parmvals, DAE);

    % getparms
    newpvals = feval(DAE.getparms, DAE);
    err = parmvals{end} - newpvals{end};
    if 0 == err
        print_success('setparms');
    else
        print_failure('setparms');
        ok = 0;
    end
end % if

%===========================================================
test.B = feval(DAE.B, DAE);
if update
    test.B
else
    if is_equal(test.B, ref.B)
        print_success('B');
    else
        print_failure('B', test.B, ref.B);
        ok = 0;
    end
end

%===========================================================
test.C = feval(DAE.C, DAE);
if update
    test.C
else
    if is_equal(test.C, ref.C)
        print_success('C');
    else
        print_failure('C', test.C, ref.C);
        ok = 0;
    end
end

%===========================================================
test.D = feval(DAE.D, DAE);
if update
    test.D
else
    if is_equal(test.D, ref.D)
        print_success('D');
    else
        print_failure('D', test.D, ref.D);
        ok = 0;
    end
end

%===========================================================
%   dynamic tests: test f, q on different cases
%           test init/limiting
%   random  tests: test f, q on random cases
%           test init/limiting
%===========================================================

if update && ~exist(filename)
    n_dtests = 2;
    n_rtests = 1;
    [test.dtests, test.rtests] = generate_cases_DAEAPI...
         (n_dtests, n_rtests, DAE);
else
    n_dtests = length(ref.dtests);
    n_rtests = ref.rtests{1};
    test.dtests = ref.dtests;
    test.rtests = ref.rtests;
end
%
random = 0;
%
for c = 1 : (n_dtests+n_rtests)
    if c > n_dtests
        random = 1;
        rand('seed',  etime(clock, [1900, 1, 1, 0, 0, 0]));
    end
    if random
        fprintf(1, '--------------------------------------------\n');
        fprintf(1, '      random testing on case %d             \n', c-n_dtests);
        x = rand(test.nunks,1); 
        u = rand(test.ninputs,1); 
    else 
        fprintf(1, '--------------------------------------------\n');
        fprintf(1, '      dynamic testing on case %d            \n', c);
        testc = test.dtests{c};
        x = testc.x;
        u = testc.u;
        if exist(filename)
            refc = ref.dtests{c};
        end
    end


	format long;
    %===========================================================
    % run f
    if 0 == DAE.f_takes_inputs
        testc.f_of_x = feval(DAE.f, x, DAE);
    else
        testc.f_of_x = feval(DAE.f, x, u, DAE);
    end
    if update
        fprintf(1, 'running f_of_x=f(x, u):\n\t');
        testc.f_of_x
    else
        if ~random && is_equal(testc.f_of_x, refc.f_of_x) || ...
           random  && ~is_nan(testc.f_of_x)
            print_success('f');
        else
            print_failure('f');
			ok = 0;
            x
            if 1 == DAE.f_takes_inputs
            u
            end
        end
    end

    %===========================================================
    % run df_dx
    if 0 == DAE.f_takes_inputs
        testc.df_dx = feval(DAE.df_dx, x, DAE);
    else
        testc.df_dx = feval(DAE.df_dx, x, u, DAE);
    end
    if update
        fprintf(1, 'running df_dx=df_dx(x, u):\n\t');
        testc.df_dx
    else
        if ~random && is_equal(testc.df_dx, refc.df_dx) || ...
           random  && ~is_nan(testc.df_dx)
            print_success('df_dx');
        else
            print_failure('df_dx');
			ok = 0;
            x
            if 1 == DAE.f_takes_inputs
            u
            end
        end
    end

    %===========================================================
    % run df_du 
    if 1 == DAE.f_takes_inputs
        testc.df_du = feval(DAE.df_du, x, u, DAE);
        if update
            fprintf(1, 'running df_du=df_du(x, u):\n\t');
            testc.df_du
        else
            if ~random && is_equal(testc.df_du, refc.df_du) || ...
               random  && ~is_nan(testc.df_du)
                print_success('df_du');
            else
                print_failure('df_du');
				ok = 0;
                x
                if 1 == DAE.f_takes_inputs
                u
                end
            end
        end % if update
    end

    %===========================================================
    % run q
    testc.q_of_x = feval(DAE.q, x, DAE);
    if update
        fprintf(1, 'running q_of_x=q(x, u):\n\t');
        testc.q_of_x
    else
        if ~random && is_equal(testc.q_of_x, refc.q_of_x) || ...
           random  && ~is_nan(testc.q_of_x)
            print_success('q');
        else
            print_failure('q');
			ok = 0;
            x
        end
    end % if update

    %===========================================================
    % run dq_dx
    testc.dq_dx = feval(DAE.dq_dx, x, DAE);
    if update
        fprintf(1, 'running dq_dx=dq_dx(x, u):\n\t');
        testc.dq_dx
    else
        if ~random && is_equal(testc.dq_dx, refc.dq_dx) || ...
           random  && ~is_nan(testc.dq_dx)
            print_success('dq_dx');
        else
            print_failure('dq_dx');
			ok = 0;
            x
        end
    end % if update

    if ~random
        test.dtests{c} = testc;
    end
end % for c

fprintf(1, '--------------------------------------------\n');

if update
    ref = test;
    save(filename, 'ref');
end
    
end % function

function print_success(name)
    blanks = repmat(' ', 1, abs(30-length(name)));
    fprintf(1, 'testing %s...%s pass \n', name, blanks);
end % print_success

function print_failure(name, test_results, reference_results)
    blanks = repmat(' ', 1, 30-length(name));
    fprintf(1, 'testing %s...%s_fail_\n', name, blanks);
    if nargin ==  3
        % fprintf(1, 'testing results \n');
        test_results
        % fprintf(1, 'reference results \n');
        reference_results
    elseif nargin ==  2
        fprintf(1, 'testing results \n');
        test_results
    end
end % print_failure

function out = is_nan(a)
% check whether a contains NaN entry
% inputs can be scalars, vectors or matrices
index = isnan(a);
out = ~(0== nnz(index));
end % is_nan

function out = is_equal(a, b)
% compares whether two inputs are equal to each other
% inputs can be strings, scalars, vectors or matrices
%
abstol = 1e-14;
reltol = 1e-6;
%
classa = class(a);
classb = class(b);
%
if ~strcmp(classa, classb)
    out = 0;
    return; 
end % if class
%
if strcmp('char', classa)
    out = strcmp(a, b);
elseif strcmp('cell', classa)
    index = [];
    for c = 1:length({a{1:end}})
        index(c) = 1 - is_equal(a{c}, b{c});
    end
    out = 0== nnz(index);
else
    % out = isequal(a, b);
    if size(a, 1) == size(b, 1) && ...
       size(a, 2) == size(b, 2)
        index = [];
        index = abs(a - b) > reltol * max(abs(a),abs(b)) + abstol;
        out = 0== nnz(index);
    elseif 0 == size(a, 1) * size(a, 2) && ...
           0 == size(b, 1) * size(b, 2) 
        % when a=[], b=sparse([]), a is 0-by-0, b is 1-by-0
        % a-b will return error. But actually a==b
        out = 1;
    else
        out = 0;
    end
end % if class is char

end % is_equal

