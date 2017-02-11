function [filename, is_new, ok] = run_ModSpec_functions(MOD, name, lastarg)
%========================================================
% function [filename, is_new, ok] = run_ModSpec_functions(MOD, name, lastarg)
% Author: Tianshi Wang, 2012-11-17
%
% Usage: (1) run_ModSpec_functions(MOD, name)
%     If no lastarg or lastarg is anything but 'update'
%     run all functions in MOD, print test results 
%     on screen.
%
%     (2) run_ModSpec_functions(MOD, name, 'update')
%     Update test-data when you are satisfied with
%     the current MOD.
%
% Inputs:  MOD      --> model to test
%          name     --> name of the function that generates MOD. 
%                  Consistent with .mat file
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
%TODO: 
% 1. add tests for fqei/initGuess/limiting when support_initlimiting is 1
% 2. probably need to get rid of tests for NIL, it is not part of ModSpec API
%
%Changelog:
%---------
%2014/08/02: Tianshi Wang <tianshi@berkeley.edu>: added ok as an output
%2014/07/24: Tianshi Wang <tianshi@berkeley.edu>: updated according to help
%            ModSpecAPI, removed usage, spicekey, etc.
%2012/11/17: Tianshi Wang <tianshi@berkeley.edu>
%
if nargin < 1
    % help strings
    fprintf('Usage: (1) run_ModSpec_functions(MOD, name)\n');
    fprintf('    Run all functions in MOD, print test results \n');
    fprintf('    on screen.\n');
    fprintf('       (2) run_ModSpec_functions(MOD, name, ''update'')\n');
    fprintf('    Update test-data when you are satisfied with\n');
    fprintf('    the current MOD.\n');
    fprintf('Outputs: [filename, is_new] \n');
    fprintf('        is_new==1 if the .mat file is created by this function\n');
    return;
elseif nargin < 2
    % help strings
    fprintf('Usage: (1) run_ModSpec_functions(MOD, name)\n');
    fprintf('       (2) run_ModSpec_functions(MOD, name, ''update'')\n');
    fprintf('run:   run_ModSpec_functions() for help strings\n');
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
% run ModelName
test.mnm = feval(MOD.ModelName, MOD);
if update
    fprintf(1, 'ModelName: %s\n', test.mnm);
else
    if is_equal(test.mnm, ref.mnm)
        print_success('ModelName');
    else
        print_failure('ModelName', test.mnm, ref.mnm);
        ok = 0;
    end
end

%===========================================================
% run name
test.nm = feval(MOD.name, MOD);
if update
    fprintf(1, 'element name (id): ''%s''\n', test.nm);
else
    if is_equal(test.nm, ref.nm)
        print_success('element name (id)');
    else
        print_failure('element name (id)', test.nm, ref.nm);
        ok = 0;
    end
end

%===========================================================
% run description
test.desc = feval(MOD.description, MOD);
if update
    fprintf(1, 'description: %s\n\n', test.desc);
else
    if is_equal(test.desc, ref.desc)
        print_success('description');
    else
        print_failure('description', test.desc, ref.desc);
        ok = 0;
    end
end

%===========================================================
% run NIL.NodeNames
test.nnames = feval(MOD.NIL.NodeNames, MOD);
if update
    fprintf(1, 'NIL.NodeNames: %s\n', cell2str(test.nnames));
else
    if is_equal(test.nnames, ref.nnames)
        print_success('NIL.NodeNames');
    else
        print_failure('NIL.NodeNames', test.nnames, ref.nnames);
        ok = 0;
    end
end

%===========================================================
% run NIL.RefNodeName
test.rnn = feval(MOD.NIL.RefNodeName, MOD);
if update
    fprintf(1, 'NIL.RefNodeName: %s\n\n', test.rnn);
else
    if is_equal(test.rnn, ref.rnn)
        print_success('NIL.RefNodeName');
    else
        print_failure('NIL.RefNodeName', test.rnn, ref.rnn);
        ok = 0;
    end
end

%===========================================================
% run IOnames (derived from NIL.NodeNames and NIL.RefNodeName)
test.ionames = feval(MOD.IOnames, MOD);
if update
    fprintf(1, 'IOnames (derived): %s\n', cell2str(test.ionames));
else
    if is_equal(test.ionames, ref.ionames)
        print_success('IOnames (derived)');
    else
        print_failure('IOnames (derived)', test.ionames, ref.ionames);
        ok = 0;
    end
end

%===========================================================
% run NIL.IOtypes
test.iotypes = feval(MOD.NIL.IOtypes, MOD);
if update
    fprintf(1, 'NIL.IOtypes (derived): %s\n', cell2str(test.iotypes));
else
    if is_equal(test.iotypes, ref.iotypes)
        print_success('NIL.IOtypes (derived)');
    else
        print_failure('NIL.IOtypes (derived)', test.iotypes, ref.iotypes);
        ok = 0;
    end
end

%===========================================================
% run NIL.IOnodeNames
test.ionn = feval(MOD.NIL.IOnodeNames, MOD);
if update
    fprintf(1, 'NIL.IOnodeNames (derived): %s\n\n', cell2str(test.ionn));
else
    if is_equal(test.ionn, ref.ionn)
        print_success('NIL.IOnodeNames (derived)');
    else
        print_failure('NIL.IOnodeNames (derived)', test.ionn, ref.ionn);
        ok = 0;
    end
end

%===========================================================
% run ExplicitOutputNames
test.eons = feval(MOD.ExplicitOutputNames, MOD);
if update
    fprintf(1, 'ExplicitOutputNames: %s\n', cell2str(test.eons));
else
    if is_equal(test.eons, ref.eons)
        print_success('ExplicitOutputNames');
    else
        print_failure('ExplicitOutputNames', test.eons, ref.eons);
        ok = 0;
    end
end

%===========================================================
% run OtherIONames (derived from IOnames and ExplicitOutputNames)
test.oions = feval(MOD.OtherIONames, MOD);
if update
    fprintf(1, 'OtherIONames (derived): %s\n\n', cell2str(test.oions));
else
    if is_equal(test.oions, ref.oions)
        print_success('OtherIONames (derived)');
    else
        print_failure('OtherIONames (derived)', test.oions, ref.oions);
        ok = 0;
    end
end

%===========================================================
% run InternalUnkNames
test.iuns = feval(MOD.InternalUnkNames, MOD);
if update
    fprintf(1, 'InternalUnkNames: %s\n', cell2str(test.iuns));
else
    if is_equal(test.iuns, ref.iuns)
        print_success('InternalUnkNames');
    else
        print_failure('InternalUnkNames', test.iuns, ref.iuns);
        ok = 0;
    end
end

%===========================================================
% run ImplicitEquationNames
test.iens = feval(MOD.ImplicitEquationNames, MOD);
if update
    fprintf(1, 'ImplicitEquationNames: %s\n\n', cell2str(test.iens));
else
    if is_equal(test.iens, ref.iens)
        print_success('ImplicitEquationNames');
    else
        print_failure('ImplicitEquationNames', test.iens, ref.iens);
        ok = 0;
    end
end

%===========================================================
% run uNames
test.unames = feval(MOD.uNames, MOD);
if update
    fprintf(1, 'uNames: %s\n\n', cell2str(test.unames));
else
    if is_equal(test.unames, ref.unames)
        print_success('uNames');
    else
        print_failure('uNames', test.unames, ref.unames);
        ok = 0;
    end
end

%===========================================================
% run parmnames
test.parmnames = feval(MOD.parmnames, MOD);
if update
    fprintf(1, 'parmnames: %s\n', cell2str(test.parmnames));
else
    if is_equal(test.parmnames, ref.parmnames)
        print_success('parmnames');
    else
        print_failure('parmnames');
        ok = 0;
    end
end

%===========================================================
% run parmdefaults
% test.parmdefaults = feval(MOD.parmdefaults, MOD);
% if update
%     fprintf(1, 'parmdefaults: %s\n', cell2str(test.parmdefaults));
% else
%     if is_equal(test.parmdefaults, ref.parmdefaults)
%         print_success('parmdefaults');
%     else
%         print_failure('parmdefaults');
%         ok = 0;
%     end
% end

%===========================================================
% parmdefaults
parmvals = feval(MOD.parmdefaults, MOD);

if length(parmvals) > 0
    % setparms
    parmvals{end} = (2*parmvals{end}+0.5);
    MOD = feval(MOD.setparms, parmvals, MOD);

    % getparms
    newpvals = feval(MOD.getparms, MOD);
    err = parmvals{end} - newpvals{end};
    if 0 == err
        print_success('setparms');
    else
        print_failure('setparms');
        ok = 0;
    end
end % if


%===========================================================
%   dynamic tests: test fe, qe, fi, qi on different cases
%   random  tests: test fe, qe, fi, qi on random cases
%===========================================================
%
%
if update && ~exist(filename)
    n_dtests = 2;
    n_rtests = 1;
    [test.dtests, test.rtests] = generate_cases_ModSpec...
         (n_dtests, n_rtests, MOD);
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
    end
    if random
        rand('seed',  etime(clock, [1900, 1, 1, 0, 0, 0]));
        fprintf(1, '--------------------------------------------\n');
        fprintf(1, '      random testing on case %d             \n', c-n_dtests);
        vecX = rand(length(test.oions),1); %fprintf(1, '\nvecX rand(%d=length(OtherIOs))\n', length(vecX));
        vecY = rand(length(test.iuns),1); %fprintf(1, 'vecY rand(%d=length(InternalUnkNames))\n', length(vecY));
        vecU = rand(length(test.unames),1); %fprintf(1, 'vecU rand(%d=length(uNames))\n\n', length(vecU));
    else 
        fprintf(1, '--------------------------------------------\n');
        fprintf(1, '      dynamic testing on case %d            \n', c);
        testc = test.dtests{c};
        vecX = testc.vecX;
        vecY = testc.vecY;
        vecU = testc.vecU;
        if exist(filename)
            refc = ref.dtests{c};
        end
    end

    %===========================================================
    % run fe(vecX, vecY, vecU) to get vecZf
    testc.vecZf = feval(MOD.fe, vecX, vecY, vecU, MOD);
    if update
        fprintf(1, 'running vecZf=fe(vecX,vecY,vecU):\n\t');
        testc.vecZf
    else
        if ~random && is_equal(testc.vecZf, refc.vecZf) || ...
           random  && ~is_nan(testc.vecZf)
            print_success('fe');
        else
            print_failure('fe');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dfe_dvecX(vecX, vecY, vecU) 
    testc.dvecZf_dvecX = feval(MOD.dfe_dvecX, vecX, vecY, vecU, MOD);
    if update
        fprintf(1, 'running dvecZf_dvecX=dfe_dvecX(vecX,vecY,vecU):\n\t');
        testc.dvecZf_dvecX
    else
        if ~random && is_equal(testc.dvecZf_dvecX, refc.dvecZf_dvecX) || ...
           random  && ~is_nan(testc.dvecZf_dvecX)
            print_success('dfe_dvecX');
        else
            print_failure('dfe_dvecX');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dfe_dvecY(vecX, vecY, vecU) 
    testc.dvecZf_dvecY = feval(MOD.dfe_dvecY, vecX, vecY, vecU, MOD);
    if update
        fprintf(1, 'running dvecZf_dvecY=dfe_dvecY(vecX,vecY,vecU):\n\t');
        testc.dvecZf_dvecY
    else
        if ~random && is_equal(testc.dvecZf_dvecY, refc.dvecZf_dvecY) || ...
           random  && ~is_nan(testc.dvecZf_dvecY)
            print_success('dfe_dvecY');
        else
            print_failure('dfe_dvecY');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dfe_dvecU(vecX, vecY, vecU) 
    testc.dvecZf_dvecU = feval(MOD.dfe_dvecU, vecX, vecY, vecU, MOD);
    if update
        fprintf(1, 'running dvecZf_dvecU=dfe_dvecU(vecX,vecY,vecU):\n\t');
        testc.dvecZf_dvecU
    else
        if ~random && is_equal(testc.dvecZf_dvecU, refc.dvecZf_dvecU) || ...
           random  && ~is_nan(testc.dvecZf_dvecU)
            print_success('dfe_dvecU');
        else
            print_failure('dfe_dvecU');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run qe(vecX, vecY, vecU) to get vecZq
    testc.vecZq = feval(MOD.qe, vecX, vecY, MOD);
    if update
        fprintf(1, 'running vecZq=qe(vecX,vecY,vecU):\n\t');
        testc.vecZq
    else
        if ~random && is_equal(testc.vecZq, refc.vecZq) || ...
           random  && ~is_nan(testc.vecZq)
            print_success('qe');
        else
            print_failure('qe');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dqe_dvecX(vecX, vecY, vecU) 
    testc.dvecZq_dvecX = feval(MOD.dqe_dvecX, vecX, vecY, MOD);
    if update
        fprintf(1, 'running dvecZq_dvecX=dqe_dvecX(vecX,vecY,vecU):\n\t');
        testc.dvecZq_dvecX
    else
        if ~random && is_equal(testc.dvecZq_dvecX, refc.dvecZq_dvecX) || ...
           random  && ~is_nan(testc.dvecZq_dvecX)
            print_success('dqe_dvecX');
        else
            print_failure('dqe_dvecX');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dqe_dvecY(vecX, vecY, vecU) 
    testc.dvecZq_dvecY = feval(MOD.dqe_dvecY, vecX, vecY, MOD);
    if update
        fprintf(1, 'running dvecZq_dvecY=dqe_dvecY(vecX,vecY,vecU):\n\t');
        testc.dvecZq_dvecY
    else
        if ~random && is_equal(testc.dvecZq_dvecY, refc.dvecZq_dvecY) || ...
           random  && ~is_nan(testc.dvecZq_dvecY)
            print_success('dqe_dvecY');
        else
            print_failure('dqe_dvecY');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run fi(vecX, vecY, vecU) to get vecWf
    testc.vecWf = feval(MOD.fi, vecX, vecY, vecU, MOD);
    if update
        fprintf(1, 'running vecWf=fi(vecX,vecY,vecU):\n\t');
        testc.vecWf
    else
        if ~random && is_equal(testc.vecWf, refc.vecWf) || ...
           random  && ~is_nan(testc.vecWf)
            print_success('fi');
        else
            print_failure('fi');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dfi_dvecX(vecX, vecY, vecU) 
    testc.dvecWf_dvecX = feval(MOD.dfi_dvecX, vecX, vecY, vecU, MOD);
    if update
        fprintf(1, 'running dvecWf_dvecX=dfi_dvecX(vecX,vecY,vecU):\n\t');
        testc.dvecWf_dvecX
    else
        if ~random && is_equal(testc.dvecWf_dvecX, refc.dvecWf_dvecX) || ...
           random  && ~is_nan(testc.dvecWf_dvecX)
            print_success('dfi_dvecX');
        else
            print_failure('dfi_dvecX');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dfi_dvecY(vecX, vecY, vecU) 
    testc.dvecWf_dvecY = feval(MOD.dfi_dvecY, vecX, vecY, vecU, MOD);
    if update
        fprintf(1, 'running dvecWf_dvecY=dfi_dvecY(vecX,vecY,vecU):\n\t');
        testc.dvecWf_dvecY
    else
        if ~random && is_equal(testc.dvecWf_dvecY, refc.dvecWf_dvecY) || ...
           random  && ~is_nan(testc.dvecWf_dvecY)
            print_success('dfi_dvecY');
        else
            print_failure('dfi_dvecY');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dfi_dvecU(vecX, vecY, vecU) 
    testc.dvecWf_dvecU = feval(MOD.dfi_dvecU, vecX, vecY, vecU, MOD);
    if update
        fprintf(1, 'running dvecWf_dvecU=dfi_dvecU(vecX,vecY,vecU):\n\t');
        testc.dvecWf_dvecU
    else
        if ~random && is_equal(testc.dvecWf_dvecU, refc.dvecWf_dvecU) || ...
           random  && ~is_nan(testc.dvecWf_dvecU)
            print_success('dfi_dvecU');
        else
            print_failure('dfi_dvecU');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run qi(vecX, vecY, vecU) to get vecWq
    testc.vecWq = feval(MOD.qi, vecX, vecY, MOD);
    if update
        fprintf(1, 'running vecWq=qi(vecX,vecY,vecU):\n\t');
        testc.vecWq
    else
        if ~random && is_equal(testc.vecWq, refc.vecWq) || ...
           random  && ~is_nan(testc.vecWq)
            print_success('qi');
        else
            print_failure('qi');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dqi_dvecX(vecX, vecY, vecU) 
    testc.dvecWq_dvecX = feval(MOD.dqi_dvecX, vecX, vecY, MOD);
    if update
        fprintf(1, 'running dvecWq_dvecX=dqi_dvecX(vecX,vecY,vecU):\n\t');
        testc.dvecWq_dvecX
    else
        if ~random && is_equal(testc.dvecWq_dvecX, refc.dvecWq_dvecX) || ...
           random  && ~is_nan(testc.dvecWq_dvecX)
            print_success('dqi_dvecX');
        else
            print_failure('dqi_dvecX');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

    %===========================================================
    % run dqi_dvecY(vecX, vecY, vecU) 
    testc.dvecWq_dvecY = feval(MOD.dqi_dvecY, vecX, vecY, MOD);
    if update
        fprintf(1, 'running dvecWq_dvecY=dqi_dvecY(vecX,vecY,vecU):\n\t');
        testc.dvecWq_dvecY
    else
        if ~random && is_equal(testc.dvecWq_dvecY, refc.dvecWq_dvecY) || ...
           random  && ~is_nan(testc.dvecWq_dvecY)
            print_success('dqi_dvecY');
        else
            print_failure('dqi_dvecY');
            ok = 0;
            vecX
            vecY
            vecU
        end
    end

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
