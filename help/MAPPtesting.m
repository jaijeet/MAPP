%This is a gentle introduction to MAPPtest that covers its basic concepts and
%usage. For a detailed introduction, please see MAPPtest.m.
%
%Why MAPPtest
%------------
%
%   MAPP is an open source software. As a user or developer, you are able to
%   make changes to MAPP according to your own needs. However, it is common
%   for changes, even seemingly minor ones, to inadvertently break MAPP.
%
%What is MAPPtest
%----------------
%
%   To mitigate this risk, we designed MAPPtest, a testing system that checks
%   whether MAPP is working correctly and reports warnings if errors are
%   detected. After committing changes to MAPP, running MAPPtest can help you
%   isolate and fix the changes causing malfunctions.
%
%How MAPPtest works
%------------------
%
%   MAPPtest works by running several test simulations and comparing their
%   results with previously stored reference data which have been checked
%   manually and certified to be correct. It will return PASS if simulation
%   results match reference data. Otherwise, it will return FAIL, together with
%   an error report. Comparisons of simulation and reference numerical data are
%   performed using a reltol-abstol criterion to skip over numerical differences
%   in very low-order bits.
%
%Examples
%--------
%
%   - Run MAPPtest on all the available tests and report a pass/fail summary: 
%
%       MAPPtest();
%       % Or you can also do:
%       alltests = allMAPPtests();
%       MAPPtest(alltests);
%
%   - Run MAPPtest on some of the tests:
%
%       alltests = allMAPPtests();
%       MAPPtest(alltests(5:10));
%
%   - Run MAPPtest on some tests and show the results (plots, printed values):
%
%       alltests = allMAPPtests();
%       MAPPtest(alltests(5:10), 'showresults');
%
%   - Run MAPPtest on a certain test group (report pass/fail summaries):
%
%       % Obtain test group
%       alltests = allMAPPtests('TRAN');
%       % print names of each test
%       print_test_names(alltests);
%       % Run MAPPtest
%       MAPPtest(alltests);
%
%   - Run MAPPtest on several groups:
%
%       % Obtain test group
%       alltests = allMAPPtests({'AC','DC'});
%       % print names of each test
%       print_test_names(alltests);
%       % Run MAPPtest
%       MAPPtest(alltests);
%
%Further reading
%---------------
%
%   The above is a basic introduction to MAPPtest. For more detail, please
%   run "help MAPPtest", which contains information about:
%   - the MAPPtest API
%   - how to add new tests/Update reference data
%   - how to organize tests in groups
%
%See also
%--------
%   MAPPtest, MAPPtest_quick, allMAPPtests, newMAPPtest_example [TODO]
%

