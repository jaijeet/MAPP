function alltests = allMAPPtests_STAEqnEngine()
%function alltests = allMAPPtests_STAEqnEngine()
%
%Introduction:
%
%    allMAPPtests_STAEqnEngine() returns a cell array of MAPPtests using the
%    STAEqnEngine. It can be used to check the correctness of the STAEqnEngine.
%
%See also
%
%    defaultMAPPtests.m, MAPPtest.m, MAPPtest_transient.m, MAPPtest_DCSweep.m,
%    MAPPtest_AC.m, allMAPPtests.m, allMAPPtests_DC.m, allMAPPtests_AC.m,
%    allMAPPtests_TRAN.m, allMAPPtests_MNAEqnEngine.m allMAPPtests_slow.m,
%    allMAPPtests_quick.m, allMAPPtests.m, print_test_names.m
%
    alltests = allMAPPtests('STA');
