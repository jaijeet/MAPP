function test = MAPPtest_ALL_ModSpec_tests()
%Author: Tianshi Wang <tianshi@berkeley.edu> 2014/08/02
% "external" test for MAPPtest, creates MAPPtest structure for
% run_ALL_ModSpec_tests

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	test.analysis = 'external';
	test.name  = 'all ModSpec tests';
	test.scriptname = 'run_ALL_ModSpec_tests_silent';
end % MAPPtest_ALL_ModSpec_tests
