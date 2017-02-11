function alltests = allMAPPtests_LTE ()
%function alltests = allMAPPtests_LTE()
%
%Introduction:
%
%    allMAPPtests_LTE() returns a cell array containing all the LTE (Local
%    truncationerror) MAPPtests. It can be used to check the correctness of the
%    LTE step control of the transient analysis.
%
%See also
%--------
%
%    defaultMAPPtests.m, MAPPtest.m, MAPPtest_transient.m, MAPPtest_DCSweep.m,
%    MAPPtest_AC.m, allMAPPtests.m, allMAPPtests_DC.m, allMAPPtests_AC.m,
%    allMAPPtests_TRAN.m, allMAPPtests_slow.m, allMAPPtests_quick.m,
%    allMAPPtests_MNAEqnEngine.m, allMAPPtests_STAEqnEngine.m, print_test_names.m
%
    alltests = allMAPPtests('LTE');
