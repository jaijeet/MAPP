% script that test the switch to turn on/off the LMS speedup implementation
% 2014/06/30 Bichen Wu <bichen@berkeley.edu>

	test = allMAPPtests_TRAN;
	for i=1:length(test)
		test{i}.args.tranparms.doSpeedup = 0;
	end
	MAPPtest(test);
