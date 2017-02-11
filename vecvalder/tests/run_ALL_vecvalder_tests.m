function success = run_ALL_vecvalder_tests(j, quiet)
    
    if nargin < 1 || isempty(j)
        j = 1;
    end
    
    if nargin < 2 || isempty(quiet)
        quiet = 0;
    end

    DAEAPI_dx_ders = (2 == exist('test_DAEAPI_dfq_dx') || 6 == exist('test_DAEAPI_dfq_dx'));
    DAEAPI_dp_ders = (2 == exist('test_DAEAPI_dfq_dp') || 6 == exist('test_DAEAPI_dfq_dp'));

    i = 0;
    i = i+1; scriptnames{i} = 'test_vecvalder_abs';
    i = i+1; scriptnames{i} = 'test_vecvalder_and';
    i = i+1; scriptnames{i} = 'test_vecvalder_asinh';
    i = i+1; scriptnames{i} = 'test_vecvalder_asin';
    i = i+1; scriptnames{i} = 'test_vecvalder_atan';
    i = i+1; scriptnames{i} = 'test_vecvalder_constructor';
    i = i+1; scriptnames{i} = 'test_vecvalder_cosh';
    i = i+1; scriptnames{i} = 'test_vecvalder_cos';
    i = i+1; scriptnames{i} = 'test_vecvalder_cross';
    i = i+1; scriptnames{i} = 'test_vecvalder_dot';
    i = i+1; scriptnames{i} = 'test_vecvalder_eq';
    i = i+1; scriptnames{i} = 'test_vecvalder_exp';
    i = i+1; scriptnames{i} = 'test_vecvalder_ge';
    i = i+1; scriptnames{i} = 'test_vecvalder_gt';
    i = i+1; scriptnames{i} = 'test_vecvalder_le';
    i = i+1; scriptnames{i} = 'test_vecvalder_log10';
    i = i+1; scriptnames{i} = 'test_vecvalder_logical';
    i = i+1; scriptnames{i} = 'test_vecvalder_log';
    i = i+1; scriptnames{i} = 'test_vecvalder_lt';
    i = i+1; scriptnames{i} = 'test_vecvalder_max';
    i = i+1; scriptnames{i} = 'test_vecvalder_min';
    i = i+1; scriptnames{i} = 'test_vecvalder_minus';
    i = i+1; scriptnames{i} = 'test_vecvalder_mod';
    i = i+1; scriptnames{i} = 'test_vecvalder_mpower';
    i = i+1; scriptnames{i} = 'test_vecvalder_mrdivide';
    i = i+1; scriptnames{i} = 'test_vecvalder_mtimes';
    i = i+1; scriptnames{i} = 'test_vecvalder_ne';
    i = i+1; scriptnames{i} = 'test_vecvalder_or';
    i = i+1; scriptnames{i} = 'test_vecvalder_plus';
    i = i+1; scriptnames{i} = 'test_vecvalder_power';
    i = i+1; scriptnames{i} = 'test_vecvalder_rdivide';
    i = i+1; scriptnames{i} = 'test_vecvalder_sign2';
    i = i+1; scriptnames{i} = 'test_vecvalder_sign';
    i = i+1; scriptnames{i} = 'test_vecvalder_sin';
    i = i+1; scriptnames{i} = 'test_vecvalder_sinh';
    i = i+1; scriptnames{i} = 'test_vecvalder_sqrt';
    i = i+1; scriptnames{i} = 'test_vecvalder_subsasng';
    i = i+1; scriptnames{i} = 'test_vecvalder_subsref';
    i = i+1; scriptnames{i} = 'test_vecvalder_tanh';
    i = i+1; scriptnames{i} = 'test_vecvalder_tan';
    i = i+1; scriptnames{i} = 'test_vecvalder_times';
    i = i+1; scriptnames{i} = 'test_vecvalder_uminus';
    i = i+1; scriptnames{i} = 'test_vecvalder_uplus';
    i = i+1; scriptnames{i} = 'test_vecvalder_vertcat';
    i = i+1; scriptnames{i} = 'test_sin';
    i = i+1; scriptnames{i} = 'test_cos';
    i = i+1; scriptnames{i} = 'test_tan';
    i = i+1; scriptnames{i} = 'test_asinh';
    % i = i+1; scriptnames{i} = 'test_mod'; handcoded derivatives wrong
    i = i+1; scriptnames{i} = 'test_abs';
    i = i+1; scriptnames{i} = 'test_subsref_1';
    i = i+1; scriptnames{i} = 'test_subsref_2';
    i = i+1; scriptnames{i} = 'test_subsref_3';
    i = i+1; scriptnames{i} = 'test_subsref_4';
    i = i+1; scriptnames{i} = 'test_subsasgn';
    i = i+1; scriptnames{i} = 'test_eq';
    i = i+1; scriptnames{i} = 'test_ne';
    i = i+1; scriptnames{i} = 'test_gt';
    i = i+1; scriptnames{i} = 'test_ge';
    i = i+1; scriptnames{i} = 'test_lt';
    i = i+1; scriptnames{i} = 'test_le';
    i = i+1; scriptnames{i} = 'test_and';
    i = i+1; scriptnames{i} = 'test_or';
    i = i+1; scriptnames{i} = 'test_vertcat1';
    i = i+1; scriptnames{i} = 'test_vertcat2';
    i = i+1; scriptnames{i} = 'test_cross1';
    i = i+1; scriptnames{i} = 'test_cross2';
    i = i+1; scriptnames{i} = 'test_dot';
    i = i+1; scriptnames{i} = 'test_length';
    i = i+1; scriptnames{i} = 'test_basicdiode';
    if 1 == DAEAPI_dx_ders
        i = i+1; scriptnames{i} = ...
             'test_DAEAPI_dfq_dx(''BJTdiffpair_DAEAPIv6(''''a'''')'',[],0.6)';
        % i = i+1; scriptnames{i} = ...
             'test_DAEAPI_dfq_dx(''fullWaveRectifier_DAEAPIv6(''''a'''')'',[],0.4*[1;1])';
        i = i+1; scriptnames{i} = ...
             'test_DAEAPI_dfq_dx(''diodeCapIsrc_daeAPIv6(''''a'''')'',[],0.4)';
        %i = i+1; scriptnames{i} = ...
        %     'test_DAEAPI_dfq_dx(''inverterchain_DAEAPIv6_old(''''a'''',5)'')';
        i = i+1; scriptnames{i} = ...
             'test_DAEAPI_dfq_dx(''UltraSimplePLL_DAEAPIv6(''''a'''',1e6,1)'')';
        i = i+1; scriptnames{i} = ...
             'test_DAEAPI_dfq_dx(''RClineDAEAPIv6(''''a'''',5,1000,1e-6)'')';
        %i = i+1; scriptnames{i} = ...
        %     'test_DAEAPI_dfq_dx(''TwoReactionChainDAEAPIv6_2(''''a'''')'')';
    end
    if 1 == DAEAPI_dp_ders
        i = i+1; scriptnames{i} = ...
             'test_DAEAPI_dfq_dp(''BJTdiffpair_DAEAPIv6(''''a'''')'',[],0.6)';
        %i = i+1; scriptnames{i} = ...
        %     'test_DAEAPI_dfq_dp(''fullWaveRectifier_DAEAPIv6(''''a'''')'',[],0.4*[1;1])';
        i = i+1; scriptnames{i} = ...
             'test_DAEAPI_dfq_dp(''diodeCapIsrc_daeAPIv6(''''a'''')'',[],0.4)';
        %i = i+1; scriptnames{i} = ...
        %     'test_DAEAPI_dfq_dp(''inverterchain_DAEAPIv6_old(''''a'''',5)'')';
        %i = i+1; scriptnames{i} = ...
        %     'test_DAEAPI_parmObj_inverterchain()';
        %{
        i = i+1; scriptnames{i} = ... NEEDS matvalder support + using the parms
             'test_DAEAPI_dfq_dp(''RClineDAEAPIv6(''''a'''', 5,1000,1e-6)'')';
        i = i+1; scriptnames{i} = ... NEEDS matvalder support
             'test_DAEAPI_dfq_dp(''TwoReactionChainDAEAPIv6_2(''''a'''')'')';
        i = i+1; scriptnames{i} = ... NO parameters
             'test_DAEAPI_dfq_dp(''UltraSimplePLL_DAEAPIv6(''''a'''', 1e6,1)'')';
        %}
    end
    
    success = runthem(scriptnames, j, quiet);

    % global isOctave;
    % if 1 == isOctave
    %     clear -f; % clears functions. If we don't do this,
    %         % running this script again results in a strange
    %         % error in vecvalder.times
    % end
end %of doit

function success = runthem(scriptnames, j, quiet)
    % success is 1 if all tests passed
    % ok is the success flag for each test
    if nargin < 3 || isempty(quiet)
        quiet = 0;
    end
    success = 1;
    for scriptnum = j:length(scriptnames)
        scriptname = scriptnames{scriptnum};
        [ok, funcname] = eval(scriptname);
        if  1==ok
            if 0 == quiet
                fprintf(2, 'passed vecvalder test %d: %s\n', ...
                    scriptnum, funcname);
            end
        else
            if 0 == quiet
                fprintf(2, 'FAILED vecvalder test %d: %s\n', ...
                    scriptnum, funcname);
            end
            success = 0;
        end
    end
end %of runthem

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





