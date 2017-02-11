function alltests = generate_all_DCsweep_tests()
%function alltests = generate_all_DCsweep_tests()
%Test script to generate DC sweep tests on all available DAEs

	i = 0;
        

        % Create empty return structure
        alltests = {};


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DC Sweep Test Case 1: BJT differential pair
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        i = i+1; 
        % Circuit DAE. 
        % The uniqID (the string argument passed to the DAE script) will be used
        % to save the reference output data.
        test1.DAE =  BJTdiffpair_DAEAPIv6('BJT-differential-pair');
        test1.type = 'DCsweep'; % Type of analysis

        % Simulation time-related parameters
        test1.testargs.NRparms = defaultNRparms();
        test1.testargs.NRparms.maxiter = 100;
        test1.testargs.NRparms.reltol = 1e-5;
        test1.testargs.NRparms.abstol = 1e-10;
        test1.testargs.NRparms.residualtol = 1e-10;
        test1.testargs.NRparms.limiting = 0;
        test1.testargs.NRparms.dbglvl = 0; % minimal output

        test1.testargs.simparms.Nsteps = 100;
        test1.testargs.simparms.inputStart = -0.2;
        test1.testargs.simparms.inputStop = 0.2;
        test1.testargs.initguess = feval(test1.DAE.QSSinitGuess, test1.DAE);


        % Update or testing/comparison
        test1.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test1.testargs.LogMsgDisplay = 1; % 1 = verbose, 0 = non-verbose

        % save it in the output structure
        alltests = {alltests{:}, test1};


