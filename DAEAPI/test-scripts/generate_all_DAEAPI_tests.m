function alltests = generate_all_DAEAPI_tests()
%function alltests = generate_all_DAEAPI_tests()
%
%Script to generate test cases for on the circuit DAEs
%
%narg == 0, then returns "alltests" with all the circuit DAEs included in this
%           script
%narg == 1, then returns "alltests" with the DAEs specified by
%           arg=[an-array-of-integers] 
%
%This function returns a cell array "alltests". Each element of this cell array
%is a MATLAB struct class variable with the following fields:
%
%alltests{i}.DAE         :The circuit DAE object. This object is created in the
%                         script by calling the appropriate circuit DAE
%                         generating MATLAB script. For example, to create a
%                         BJT differential pair DAE object, a call can be made
%                         to "BJTdiffpair_DAEAPIv6" function.
%
%alltests{i}.testargs    :A structure containing following test arguments 
%
%    N_dynamicTest       :No. of tests to be carried out to do a sanity
%                         check on all DAEAPI functions (f,q,df_dx,df_du,dq_dx,
%                         etc.) with the previously stored input values in the
%                         reference test data.
%
%    N_randomTest        :No. of tests to be carried out to do a sanity
%                         check on all DAEAPI functions (f,q,df_dx,df_du,dq_dx,
%                         etc.) with random input values.
%
%    updateReference     :1 (update), 0 (testing/comparison). Set the field to
%                         1 to update or generate the .mat (reference test
%                         data) file and to 0 to compare the inputs, the
%                         outputs and the parameters of the circuit DAE with
%                         that of the reference (previously saved .mat) test
%                         data.
%
%    LogMsgDisplay       :1 = verbose, 0 = non-verbose.  Set it to 1 to
%                         display "pass" or "fail" status for all the
%                         comparisons carried out. Set it to 0 to display one
%                         single pass/fail statement based on all the
%                         comparison tests. 
%
%To learn about how to add a new circuit DAE to this function, type "help
%MAPPtest-DAEAPI-new" at the MATLAB command line. 
%
      no_of_circuits = 6; % Maximum no. of circuits that the script generates 
      % parse the arguments
      if nargin ==0
              % which_circuits = 1 : 1 : no_of_circuits;
              which_circuits = [1 2 3 4]; % 4 and 6 are not working presently
      elseif nargin == 1
              oof1 = norm(double(uint8(arg))-arg);
              oof2 = ~((size(arg,1) == 1) || (size(arg,2) == 1)) ;
              if oof1 || oof2 
                      disp('Incorrect arguments');
                      disp(['The argument of the function can only be ' ...
                              'an array of integers or an empty array']);
                      fprintf(1,'\n');
                      help('generate_all_DAEAPI_tests');
              end
              which_circuits = arg;
      else 
              disp('Incorrect arguments');
              disp(['The argument of the function can only be ' ...
                      'an array of integers or an empty array']);
              fprintf(1,'\n');
              help('generate_all_DAEAPI_tests');
      end

        % Create empty return structure
        alltests = {};

        for circuit_no = which_circuits
                eval(['test = generate_circuit' num2str(circuit_no) '();']);
                % save it in the output structure
                alltests = {alltests{:}, test};
        end
end

function test = generate_circuit1()
        % Circuit DAE for BJT differential pair
        test.DAE =  BJTdiffpair_DAEAPIv6('BJT-differential-pair');
        % Update or testing/comparison
        test.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test.testargs.LogMsgDisplay =1; % 1 = verbose, 0 = non-verbose
        test.testargs.N_dynamicTest = 5; test.testargs.N_randomTest = 5;
end


function test = generate_circuit2()
        % Circuit DAE for FullWaveRectifier
        test.DAE =  fullWaveRectifier_DAEAPIv6('FullWaveReactifier_DAEAPIv6');
        % Update or testing/comparison
        test.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test.testargs.LogMsgDisplay =1; % 1 = verbose, 0 = non-verbose
        test.testargs.N_dynamicTest = 5; test.testargs.N_randomTest = 5;
end

function test = generate_circuit3()
        % Circuit DAE for Schmitt Trigger using BJT differential pair
        test.DAE =  BJTschmittTrigger('BJT-Schmitt-Trigger');
        % Update or testing/comparison
        test.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test.testargs.LogMsgDisplay =1; % 1 = verbose, 0 = non-verbose
        test.testargs.N_dynamicTest = 5; test.testargs.N_randomTest = 5;
end

function test = generate_circuit4()
        % Circuit DAE for a ring oscillator using BSIM3 model
        test.DAE =  BSIM3_ringosc('BSIM3-Ring-Oscillator');
        % Update or testing/comparison
        test.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test.testargs.LogMsgDisplay =1; % 1 = verbose, 0 = non-verbose
        test.testargs.N_dynamicTest = 5; test.testargs.N_randomTest = 5;
end
%{

        % Circuit DAE for BJT differential pair
        i = i+1; test5.DAE =  BJTdiffpair_DAEAPIv6('BJT-differential-pair');
        % Update or testing/comparison
        test5.testargs.updateReference =1; % 1 (update), 0 (testing/comparison)
        test5.testargs.LogMsgDisplay =1; % 1 = verbose, 0 = non-verbose
        test5.testargs.N_dynamicTest = 5; test5.testargs.N_randomTest = 5;
        % save it in the output structure
        alltests = {alltests{:}, test5};


        % Circuit DAE for BJT differential pair
        i = i+1; test6.DAE =  BJTdiffpair_DAEAPIv6('BJT-differential-pair');
        % Update or testing/comparison
        test6.testargs.updateReference =1; % 1 (update), 0 (testing/comparison)
        test6.testargs.LogMsgDisplay =1; % 1 = verbose, 0 = non-verbose
        test6.testargs.N_dynamicTest = 5; test6.testargs.N_randomTest = 5;
        % save it in the output structure
        alltests = {alltests{:}, test6};

        %}
