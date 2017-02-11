function ok = test_SH_MOS_ModSpec(arg)
%function test_SH_MOS_ModSpec() or ('update')
% test-script for SH_MOS_ModSpec 
% Author: Tianshi Wang 2012-11-19

MOD = SH_MOS_ModSpec();

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
    % update
    [filename, is_new] = run_ModSpec_functions(MOD, 'SH_MOS_ModSpec', 'update');
    if is_new
        load(filename); % get ref in the workspace
        n_dtests = length(ref.dtests);
        % add more specific dynamic test cases for SH_MOS_ModSpec
        % add all zeros
        ref.dtests{n_dtests+1}.vecX = zeros(length(ref.oions),1); 
        ref.dtests{n_dtests+1}.vecY = zeros(length(ref.iuns),1); 
        ref.dtests{n_dtests+1}.vecU = zeros(length(ref.unames),1); 
        if 1 == MOD.support_initlimiting
            ref.dtests{n_dtests+1}.vecLim = zeros(length(ref.lvars),1); 
            ref.dtests{n_dtests+1}.vecLimOld = zeros(length(ref.lvars),1); 
        end
        % add all -1s
        ref.dtests{n_dtests+2}.vecX = -ones(length(ref.oions),1); 
        ref.dtests{n_dtests+2}.vecY = -ones(length(ref.iuns),1); 
        ref.dtests{n_dtests+2}.vecU = -ones(length(ref.unames),1); 
        if 1 == MOD.support_initlimiting
            ref.dtests{n_dtests+2}.vecLim = -ones(length(ref.lvars),1); 
            ref.dtests{n_dtests+2}.vecLimOld = -ones(length(ref.lvars),1); 
        end
        % add random test cases for SH_MOS_ModSpec
        ref.rtests{1} = 1;
        % save ref
        save(filename, 'ref');
    [filename, is_new] = run_ModSpec_functions(MOD, 'SH_MOS_ModSpec', 'update');
    end
    ok = 1;
else 
    % no update
    [filename, is_new, ok] = run_ModSpec_functions(MOD, 'SH_MOS_ModSpec');
end
