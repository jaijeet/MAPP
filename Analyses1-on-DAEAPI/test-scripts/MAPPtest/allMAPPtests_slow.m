function alltests = allMAPPtests_slow()
%function alltests = allMAPPtests_slow()
%
%Introduction:
%
%    allMAPPtests_slow() returns a cell array of tests that take very long time
%    to run but check almost every aspects of MAPP.
%
%See also
%
%    defaultMAPPtests.m, MAPPtest.m, MAPPtest_transient.m, MAPPtest_DCSweep.m,
%    MAPPtest_AC.m, allMAPPtests.m, allMAPPtests_DC.m, allMAPPtests_AC.m,
%    allMAPPtests_TRAN.m, allMAPPtests_MNAEqnEngine.m,
%    allMAPPtests_STAEqnEngine.m allMAPPtests_quick.m, allMAPPtests.m
%

    alltests = allMAPPtests('slow');
