function out = ALL_ArcCont_tests(j)
	
	if nargin < 1
		j = 1;
	end

	i = 0;
	i = i+1; scriptnames{i} = 'test_ArcCont_nofolds_scalar';
	i = i+1; scriptnames{i} = 'test_ArcCont_folds_scalar';
	i = i+1; scriptnames{i} = 'test_ArcCont_folds_nested';
	i = i+1; scriptnames{i} = 'test_nestedFoldsDAE_arccont';
	i = i+1; scriptnames{i} = 'test_BJTdiffpairSchmittTrigger_arccont';
	i = i+1; scriptnames{i} = 'test_BJTschmittTrigger_arccont_wrt_VCC';
	i = i+1; scriptnames{i} = 'test_BJTschmittTrigger_arccont';
	% test_BJTschmittTrigger_arccont takes a bit longer to run, but is a good 
    % test case - very sharp bends.
	out = {scriptnames{j:end}};

%end of ALL_ArcCont_tests

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
