function ok = test_BSIM3_ringosc(arg)
% test-script for BSIM3_ringosc() or ('update') 
% Author: Tianshi Wang 2012-11-19

DAE = BSIM3_ringosc();

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
	% update
	[filename, is_new] = run_DAEAPI_functions(DAE, 'BSIM3_ringosc', 'update');
	if is_new
		load(filename); % get ref in the workspace
		n_dtests = length(ref.dtests);
		% add more specific dynamic test cases for BSIM3_ringosc
		% add all zeros
		ref.dtests{n_dtests+1}.x = zeros(ref.nunks,1); 
		ref.dtests{n_dtests+1}.xlim = zeros(ref.nlimitedvars,1); 
		ref.dtests{n_dtests+1}.xlimOld = -ones(ref.nlimitedvars,1); 
		ref.dtests{n_dtests+1}.u = zeros(ref.ninputs,1); 
		% add all -1s
		ref.dtests{n_dtests+2}.x = -ones(ref.nunks,1); 
		ref.dtests{n_dtests+2}.xlim = ones(ref.nlimitedvars,1); 
		ref.dtests{n_dtests+2}.xlimOld = -ones(ref.nlimitedvars,1); 
		ref.dtests{n_dtests+2}.u = -ones(ref.ninputs,1); 
		% add random test cases for BSIM3_ringosc
		ref.rtests{1} = 1;
		% save ref
		save(filename, 'ref');
	[filename, is_new] = run_DAEAPI_functions(DAE, 'BSIM3_ringosc', 'update');
	end
    ok = 1;
else 
	% no update
	[filename, is_new, ok] = run_DAEAPI_functions(DAE, 'BSIM3_ringosc');
end

