function alltests = allMAPPtests_realquick()
%function alltests = allMAPPtests_realquick()
%
%Introduction:
%
%    allMAPPtests_realquick() returns a cell array containing the tests that take
%    shorter time to run while still cover a wide range of different aspects of
%    MAPP. It can be used as a quick check of the correctness of MAPP.
%
%See also
%
%    defaultMAPPtests.m, MAPPtest.m, MAPPtest_transient.m, MAPPtest_DCSweep.m,
%    MAPPtest_AC.m, allMAPPtests.m, allMAPPtests_DC.m, allMAPPtests_AC.m,
%    allMAPPtests_TRAN.m, allMAPPtests_MNAEqnEngine.m,
%    allMAPPtests_STAEqnEngine.m allMAPPtests_slow.m, allMAPPtests_quick.m,
%    allMAPPtests.m
%

    alltests = allMAPPtests('realquick');
