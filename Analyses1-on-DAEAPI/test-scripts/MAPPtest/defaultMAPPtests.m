function alltests = defaultMAPPtests()
%function alltests=defaultMAPPtests()
%
%    defaultMAPPtests() defines the default list of tests that will be run by
%    MAPPtest. 
%
%See also
%
%    MAPPtest, MAPPtest_transient,
%    MAPPtest_DCSweep, MAPPtest_AC
%    allMAPPtests
%

    % Set default tests to be all the existing MAPPtests.
    alltests= allMAPPtests();
end
