function ok = test_BJTdiffpairRelaxationOsc(arg)
% test-script for BJTdiffpairRelaxationOsc() or ('update')
% Author: Tianshi Wang 2012-11-19

DAE = BJTdiffpairRelaxationOsc();

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
	% update
	[filename, is_new] = run_DAEAPI_functions(DAE, 'BJTdiffpairRelaxationOsc', 'update');
	if is_new
		load(filename); % get ref in the workspace
		n_dtests = length(ref.dtests);
		% add more specific dynamic test cases for BJTdiffpairRelaxationOsc
		% add all zeros
		ref.dtests{n_dtests+1}.x = zeros(ref.nunks,1); 
		ref.dtests{n_dtests+1}.xold = zeros(ref.nunks,1); 
		ref.dtests{n_dtests+1}.u = zeros(ref.ninputs,1); 
		% add all -1s
		ref.dtests{n_dtests+2}.x = -ones(ref.nunks,1); 
		ref.dtests{n_dtests+2}.xold = -ones(ref.nunks,1); 
		ref.dtests{n_dtests+2}.u = -ones(ref.ninputs,1); 
		% add random test cases for BJTdiffpairRelaxationOsc
		ref.rtests{1} = 1;
		% save ref
		save(filename, 'ref');
	[filename, is_new] = run_DAEAPI_functions(DAE, 'BJTdiffpairRelaxationOsc', 'update');
	end
    ok = 1;
else 
	% no update
	[filename, is_new, ok] = run_DAEAPI_functions(DAE, 'BJTdiffpairRelaxationOsc');
end

