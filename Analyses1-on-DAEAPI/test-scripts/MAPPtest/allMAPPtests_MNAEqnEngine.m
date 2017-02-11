function alltests = allMAPPtests_MNAEqnEngine()
%function alltests = allMAPPtests_MNAEqnEngine()
%
%Introduction:
%
%    allMAPPtests_MNAEqnEngine() returns a cell array of MAPPtests using the
%    MNAEqnEngine. It can be used to check the correctness of the MNAEqnEngine.
%
%See also
%
%    defaultMAPPtests.m, MAPPtest.m, MAPPtest_transient.m, MAPPtest_DCSweep.m,
%    MAPPtest_AC.m, allMAPPtests.m, allMAPPtests_DC.m, allMAPPtests_AC.m,
%    allMAPPtests_TRAN.m, allMAPPtests_STAEqnEngine.m allMAPPtests_slow.m,
%    allMAPPtests_quick.m, allMAPPtests.m, print_test_names.m
%
    alltests = allMAPPtests('MNA');
