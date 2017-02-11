function alltests = allMAPPtests_TRAN ()
%function alltests = allMAPPtests_TRAN()
%
%Introduction:
%
%    allMAPPtests_TRAN() returns a cell array containing all the transient
%    MAPPtests.
%
%See also
%
%    defaultMAPPtests.m, MAPPtest.m, MAPPtest_transient.m, MAPPtest_DCSweep.m,
%    MAPPtest_AC.m, allMAPPtests.m, allMAPPtests_DC.m allMAPPtests_AC.m,
%    allMAPPtests_MNAEqnEngine.m, allMAPPtests_STAEqnEngine.m,
%    allMAPPtests_slow.m, allMAPPtests_quick, allMAPPtests.m, print_test_names.m
%
    alltests = allMAPPtests('TRAN');
