function print_test_names(alltests)    
%print_test_names(alltests)
%Print names of the input tests.
%
%Input
%-----
%    - alltests 
%        A cell array containing MAPPtest struct. 
%
%Example
%-------
%    alltests = allMAPPtest_AC();
%    print_test_names(alltests);
%
%See also
%--------
%
%    defaultMAPPtests.m, allMAPPtests.m
%


    if isa(alltests,'cell')
        for i=1:length(alltests)
            if isfield(alltests{i}, 'name');
                fprintf('%d.\t\t%s\n', i, alltests{i}.name);
            else
                fprintf('%d.\t\tdata type struct not supported\n',i);
            end
        end
    else
        fprintf('Input type error\n');
        return;
    end
