%Tianshi's note: this file seems obsolete as of 2014/08/02
%
%Script to run MAPPtesting system for AC analysis on all circuit DAEs.
%


%Generate transient test cases for all the circuit DAEs
alltests = generate_all_DAEAPI_tests();

%Loop through all the tests to do the MAPPtesting
for count = 1 : 1 : length(alltests)
        DAE = alltests{count}.DAE;
        update = 0;%alltests{count}.testargs.updateReference;
        MsgDisplay = 0;% alltests{count}.testargs.LogMsgDisplay; 
        ntests.n_dynamic = alltests{count}.testargs.N_dynamicTest;
        ntests.n_random = alltests{count}.testargs.N_randomTest;
        test_DAEAPI(DAE,update,MsgDisplay,ntests)

end
