function ok = test_parallelLC(arg)
% test-script for parallelLC() or ('update') 
% Author: Tianshi Wang 2012-11-20

DAE = parallelLC();

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
	% update
	[filename, is_new] = run_DAEAPI_functions(DAE, 'parallelLC', 'update');
	if is_new
		load(filename); % get ref in the workspace
		n_dtests = length(ref.dtests);
		% add more specific dynamic test cases for parallelLC
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
		% add random test cases for parallelLC
		ref.rtests{1} = 1;
		% save ref
		save(filename, 'ref');
	[filename, is_new] = run_DAEAPI_functions(DAE, 'parallelLC', 'update');
	end
    ok = 1;
else 
	% no update
	[filename, is_new, ok] = run_DAEAPI_functions(DAE, 'parallelLC');
end
