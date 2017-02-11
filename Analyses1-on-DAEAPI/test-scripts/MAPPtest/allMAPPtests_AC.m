function alltests = allMAPPtests_AC()
%function alltests = allMAPPtests_AC()
%
%Introduction:
%
%    allMAPPtests_AC() returns a cell array containing all the AC MAPPtest
%    structs.
%
%See also
%
%    defaultMAPPtests.m, MAPPtest.m, MAPPtest_transient.m, MAPPtest_DCSweep.m,
%    MAPPtest_AC.m, allMAPPtests.m, allMAPPtests_DC.m allMAPPtests_TRAN.m,
%    allMAPPtests_MNAEqnEngine.m, allMAPPtests_STAEqnEngine.m,
%    allMAPPtests_slow.m, allMAPPtests_quick, allMAPPtests.m, print_test_names.m
%

    alltests = allMAPPtests('AC');
