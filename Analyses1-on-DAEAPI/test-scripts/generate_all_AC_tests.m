function alltests = generate_all_AC_tests(arg)
%function alltests = generate_all_AC_tests(arg)
%Script to generate AC analysis tests on the available circuit DAEs
%
%narg == 0, then returns "alltests" with the available circuit DAEs
%narg == 1, then returns "alltests" with the ciruit DAEs specified by
%           arg=[an-array-of-integers]
%
%This function returns a cell array "alltests". Each element of this cell array
%is a MATLAB struct class variable with the following fields:
%
%alltests{i}.DAE         :The circuit DAE object. This object is created in the
%                         script by calling the appropriate circuit DAE
%                         generating MATLAB script. For example, to create a
%                         BJT differential pair DAE object, a call can be made
%                         to "BJTdiffpair_DAEAPIv6()" function.
%
%alltests{i}.type        :Type of analysis ("AC" in this case) 
%alltests{i}.testargs    :A structure containing the following test arguments 
%    DCOP                :DC operating point for AC analysis 
%    intiguess           :Init. condition for solving NR at DCOP
%    ACparms.sweeptype   :(String) Frequency sweeptype for AC analysis.
%                         Allowable string values {'DEC','LIN'}. 
%
%    ACparms.fstart      :Start frequency for AC analysis
%    ACparms.fstop       :Stop frequency for AC analysis
%    ACparms.nsteps      :No. of frequency steps during AC analysis
%    updateReference     :1 (update), 0 (testing/comparison). Set the field to
%                         1 to update or generate the .mat (reference test
%                         data) file and to 0 to compare the inputs, the
%                         outputs and the parameters of the AC analysis test
%                         with that of the reference (previously saved .mat)
%                         test data.
%
%    LogMsgDisplay       :1 = verbose, 0 = non-verbose. Set it to 1 to display
%                         "pass" or "fail" status for all the comparisons
%                         carried out (DAE parameters, DCOP, DCOP initial guess
%                         for NR, AC analysis parameters, output waveform
%                         comparison). Set it to 0 to display one single
%                         pass/fail statement based on all the comparison
%                         tests. 
%
%To learn about how to add a new circuit to this function, type "help
%MAPPtest-AC-new" at the MATLAB command line. 
%
      no_of_circuits = 4; % Maximum no. of circuits that the script generates 
      % parse the arguments
      if nargin ==0
              % which_circuits = 1:1:no_of_circuit;
              which_circuits = 1:1:no_of_circuits;
      elseif nargin == 1
              oof1 = norm(double(uint8(arg))-arg);
              oof2 = ~((size(arg,1) == 1) || (size(arg,2) == 1)) ;
              if oof1 || oof2 
                      disp('Incorrect arguments');
                      disp(['The argument of the function can only be ' ...
                              'an array of integers or an empty array']);
                      fprintf(1,'\n');
                      help('generate_all_AC_tests');
              end
              which_circuits = arg;
      else 
              disp('Incorrect arguments');
              disp(['The argument of the function can only be ' ...
                      'an array of integers or an empty array']);
              fprintf(1,'\n');
              help('generate_all_AC_tests');
      end


      % Create empty return structure
      alltests = {};

      for circuit_no = which_circuits
              eval(['test = generate_circuit' num2str(circuit_no) '();']);
              % save it in the output structure
              alltests = {alltests{:},test};
      end
end

function test = generate_circuit1()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %AC Test Case 1: BJT differential pair
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Circuit DAE. 
        % The uniqID (the string argument passed to the DAE script) will be used
        % to save the reference output data.
        test.DAE =  BJTdiffpair_DAEAPIv6('BJT-differential-pair');
        test.type = 'AC'; % Type of analysis
        % If the analysis is AC, then setup the uLTISSS for the
        % circuit DAE
	Ufargs.string = 'no args used'; % 
	Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
	test.DAE = feval(test.DAE.set_uLTISSS, Uffunc, Ufargs, test.DAE);

        % Simulation-related parameters
        test.testargs.DCOP = 0.2; % DC operating point
        test.testargs.initguess=feval(test.DAE.QSSinitGuess, ...
                test.testargs.DCOP, test.DAE);
        test.testargs.ACparms.sweeptype = 'DEC'; % Sweeptype 
        test.testargs.ACparms.fstart = 1; % Start frequency
        test.testargs.ACparms.fstop = 1e5; % Stop frequency 
        test.testargs.ACparms.nsteps = 10; % No. of steps

        % Update or testing/comparison
        test.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test.testargs.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

function test = generate_circuit2()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %AC Test Case 2: fullWave Rectifier
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Circuit DAE. 
        % The uniqID (the string argument passed to the DAE script) will be used
        % to save the reference output data.
        test.DAE = fullWaveRectifier_DAEAPIv6('fullWaveReactifier');
        test.type = 'AC'; % Type of analysis
        % If the analysis is AC, then setup the uLTISSS for the
        % circuit DAE
	Ufargs.string = 'no args used'; % 
	Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
	test.DAE = feval(test.DAE.set_uLTISSS, Uffunc, Ufargs, test.DAE);

        % Simulation-related parameters
        test.testargs.DCOP = 0.1; % DC operating point
        test.testargs.initguess=feval(test.DAE.QSSinitGuess,...
                test.testargs.DCOP, test.DAE);
        test.testargs.ACparms.sweeptype = 'DEC'; % Sweeptype 
        test.testargs.ACparms.fstart = 1; % Start frequency
        test.testargs.ACparms.fstop = 1e5; % Stop frequency 
        test.testargs.ACparms.nsteps = 10; % No. of steps

        % Update or testing/comparison
        test.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test.testargs.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end 

function test = generate_circuit3()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %AC Test Case 3: RC line
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Circuit DAE. 
        % The uniqID (the string argument passed to the DAE script) will be used
        % to save the reference output data.
        nsegs = 3; R = 1000; C = 1e-6;
        test.DAE =  RClineDAEAPIv6('RCLine',nsegs, R, C); 
        test.type = 'AC'; % Type of analysis
        % If the analysis is AC, then setup the uLTISSS for the
        % circuit DAE
	Ufargs.string = 'no args used'; % 
	Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
	test.DAE = feval(test.DAE.set_uLTISSS, Uffunc, Ufargs, test.DAE);

        % Simulation-related parameters
        test.testargs.DCOP = 0; % DC operating point
        test.testargs.initguess=feval(test.DAE.QSSinitGuess, ...
                test.testargs.DCOP, test.DAE);
        test.testargs.ACparms.sweeptype = 'DEC'; % Sweeptype 
        test.testargs.ACparms.fstart = 1; % Start frequency
        test.testargs.ACparms.fstop = 1e5; % Stop frequency 
        test.testargs.ACparms.nsteps = 10; % No. of steps

        % Update or testing/comparison
        test.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test.testargs.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

function test = generate_circuit4()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %AC Test Case 4: vsrc-diode
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Circuit DAE. 
        % The uniqID (the string argument passed to the DAE script) will be used
        % to save the reference output data.
        MNAEqnEngine_vsrc_diode;
        test.DAE =  DAE;
        test.type = 'AC'; % Type of analysis
        % If the analysis is AC, then setup the uLTISSS for the
        % circuit DAE
	Ufargs.string = 'no args used'; % 
	Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
	test.DAE = feval(test.DAE.set_uLTISSS, 'v1:::E', Uffunc, ...
                Ufargs, test.DAE);

        % Simulation-related parameters
        test.testargs.DCOP = 1; % DC operating point
        test.testargs.initguess=[1;0;0.6];
        test.testargs.ACparms.sweeptype = 'DEC'; % Sweeptype 
        test.testargs.ACparms.fstart = 1; % Start frequency
        test.testargs.ACparms.fstop = 1e12; % Stop frequency 
        test.testargs.ACparms.nsteps = 5; % No. of steps

        % Update or testing/comparison
        test.testargs.updateReference = 0; % 1 (update), 0 (testing/comparison)
        test.testargs.LogMsgDisplay = 0; % 1 = verbose, 0 = non-verbose
end

%%%%%%%%%--------------------------------------------%%%%%%%%%%%%%%%%%%%%%%
%   MAPP code ends here.                             %%%%%%%%%%%%%%%%%%%%%%
%   Do not edit/remove anything above this.          %%%%%%%%%%%%%%%%%%%%%%
%   Add a new circuit after this line.               %%%%%%%%%%%%%%%%%%%%%%
