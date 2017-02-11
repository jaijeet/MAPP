% This script runs all tests for isrcRCL_ckt, a test circuit for
% RLC_ModSpec_wrapper device.


	i = 0;
	i = i+1; testnames{i} = 'test_isrcRLC_DC';
	i = i+1; testnames{i} = 'test_isrcRLC_AC';
	i = i+1; testnames{i} = 'test_isrcRLC_TRAN';

	T = 2;
	for i = 1:length(testnames)
		scriptname = testnames{i};
		fprintf(2,'running script %d: %s...\n', i, scriptname);
		pause off;
		eval(scriptname); 
		pause on;
		fprintf(2,'\n%s (script %d) done\n', scriptname, i);
		fprintf(2,'Pausing for %g seconds...\n', T);
		fprintf(2,'--------------------------------------------------------------------------\n\n');
		pause(T);
		close all; drawnow;
	end

	fprintf(2,'run_ALL_tests_on_simple_RLC_model completed. \n');
