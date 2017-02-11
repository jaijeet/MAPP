function ok = test_MVS_1_0_1_ModSpec_wrapper_no_v2struct(arg)
%function test_MVS_1_0_1_ModSpec_wrapper_no_v2struct() or ('update')
% test-script for MVS_1_0_1_ModSpec_wrapper_no_v2struct
% Author: Jaijeet Roychowdhury 2014/06/24

MOD = MVS_1_0_1_ModSpec_wrapper_no_v2struct();

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
	% update
	[filename, is_new] = run_ModSpec_functions(MOD, ...
                            'MVS_1_0_1_ModSpec_wrapper_no_v2struct', 'update');
	if is_new
		load(filename); % get ref in the workspace
		n_dtests = length(ref.dtests);
		% add more specific dynamic test cases for 
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
		% add random test cases for MVS_1_0_1_ModSpec_wrapper_no_v2struct
		ref.rtests{1} = 1;
		% save ref
		save(filename, 'ref');
	[filename, is_new] = run_ModSpec_functions(MOD, ...
                         'MVS_1_0_1_ModSpec_wrapper_no_v2struct', 'update');
	end
    ok = 1;
else 
	% no update
	[filename, is_new, ok] = run_ModSpec_functions(MOD, 'MVS_1_0_1_ModSpec_wrapper_no_v2struct');
end
