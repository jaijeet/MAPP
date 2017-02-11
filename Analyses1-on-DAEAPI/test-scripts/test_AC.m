function test_AC(DAE,DCOP,initguess,ACparms,update,MsgDisplay)
%function test_AC(DAE,DCOP,initguess,ACparms,update,MsgDisplay)
%MAPP testing of AC on a circuit DAE
%
%Arguments: 
%
%DAE         A MATLAB structure in DAEAPI describing the circuit DAE on
%            which AC analysis is to be carried out 
%
%DCOP        DC operating point for AC analysis
%
%initguess   Initial guess for determining circuit unknowns for the given DCOP
%
%ACparms    A structure containing following parameters required for
%           AC analysis 
%
%                ACparms.sweeptype := Frequency sweep type {'LIN','DEC'}
%                                     'LIN' for linear and 'DEC' for decade
%                ACparms.fstart    := Start frequency
%                ACparms.fstop     := Stop frequency
%                ACparms.nsteps    := No. of steps (steps for decade for 'DEC',
%                                     total numbers of steps for 'LIN'
%update      1 (update), 0 (testing/comparison)
%
%MsgDisplay  1 (verbose mode) - results of all the tests conducted are displayed
%            0 (non-verbose mode) - only final pass message it displayed.
%                                   However, if any of the sub-tests fail, then
%                                   it displays all relevant information to the
%                                   failure test.

%                 
%
%This script 
% 1. If update == 0, then 
%        a. compares DAE parameters, AC inputs, DCOP and ACparms
%           of both the provided DAE and reference DAE. If they are same, then
%           the script runs a transient simulation on the circuit DAE; else
%           throws an error and aborts.
%
%        b. compares the output waveforom from the simulation to that of
%           previously stored reference output waveform (stored in a MATLAB file
%           named "DAE.uniqID_AC.mat"). This comparison uses function
%           compare_waveform(), to do this waveform comparison.
%
%        c. If the datafile DAE.uniqID_AC.mat is not present, then the
%           script aborts giving an error message --
%           "DAE.uniqID_AC.mat" file not found. Run the script with
%           argument with update = 1.
%
%      
%
% 2. If update == 1, then
%       a. run the AC analysis on DAE_filename and store in
%          the result 
%
%       b. IMP NOTE: If this script is run with 'update = 1' option, then the
%          DAE, the LTISSSObj created off the DAE, and associated DCOP,
%          initguess, and ACparms are saved in a .mat file, which is named as 
%          DAE.uniqID"_AC.mat". 
%       
%   TODO: Pass it to the function
abstol=1e-9; reltol=1e-6;

% TODO: 
%Provide definite information when the tests fail 
%Better argument management
%More description in terms of displaying information about what is going
%on

%Create the datafile name with path
data_filename = [ feval(DAE.uniqID,DAE) '_AC.mat'];
  
      % Compare or update
      if update == 0 
              % Compare the waveform with reference wavefor
              script_task = 'compare';
              oof= sprintf('AC MAPPtest (Comparison) :: %s',feval(DAE.uniqID,DAE));
              disp(oof);

              % But, first check if there is the required testdata file
              if ~exist(data_filename,'file')

                      error([ sprintf('File %s_AC.mat not found\n',data_filename) ...
                              ' Run the script ' ...
                              'with argument update = 1"']) 

              end
              load(data_filename);

      elseif update == 1
              script_task = 'update'; 
              oof= sprintf('AC MAPPtest (Update) :: %s',feval(DAE.uniqID,DAE));
              disp(oof);

      else
              help('test_AC');        % Usage
      end


      %---------------------------------------------------------------
      % Pre-simulation comparison/update (DCOP, input, intiguess, DAE and ACparms)
      %--------------------------------------------------------------
      % Compare/Update DAE parameters
      % if script_task == 'compare', check if this matches with saved data
      if strcmp(script_task,'compare')
              % Compare if the AC input to current DAE and ref. DAE
              % are same
              %
              % Compare the DCOP
              user_supplied_DCOP = DCOP; 
              ref_supplied_DCOP = ref.DCOP;
              pass_or_fail = (user_supplied_DCOP==ref_supplied_DCOP);
              if pass_or_fail 
                      if MsgDisplay
                              print_success('Comparing DC operating point for test and ref. AC analysis');
                      end
              else
                      print_failure('Comparing DC operating point for test and ref. AC analysis');
                      fprintf('The user supplied DCOP is %d\n',user_supplied_DCOP);
                      fprintf('The ref. DCOP  is %d\n',ref_supplied_DCOP);
                      error(['Set the DCOPs same for both testcase and ref. DAE or' ...
                              ' run with option update = 1 ']);
              end


              
              % Compare the initguess
              user_supplied_initguess = initguess;
              ref_supplied_initguess = ref.initguess;
              pass_or_fail = (user_supplied_initguess == ref_supplied_initguess);
              if pass_or_fail 
                      if MsgDisplay
                              print_success('Comparing NR initial guess for test and ref. AC analysis');
                      end
              else
                      print_failure('Comparing NR initial guess for test and ref. AC analysis');
                      fprintf('The user supplied initial point is %d\n',user_supplied_initguess);
                      fprintf('The ref. initial point  is %d\n',ref_supplied_initguess);
                      error(['Set the initial guesses same for both testcase and ref. DAE or' ...
                              ' run with option update = 1 ']);
              end


              % Compare AC params
              oof1=  strcmp(ACparms.sweeptype,ref.ACparms.sweeptype);
              oof2=  (ACparms.fstart == ref.ACparms.fstart);
              oof3=  (ACparms.nsteps == ref.ACparms.nsteps);
              oof4=  (ACparms.fstop == ref.ACparms.fstop);
              pass_or_fail = (oof1 && oof2 && oof3 && oof4); 
              if pass_or_fail 
                      if MsgDisplay 
                              print_success('Comparing AC parameters for test and ref. DAE');
                      end
              else
                      print_failure('Comparing AC parameters for test and ref. DAE');
                      error(['Set the AC parameters for testcase same as ref. or' ...
                              ' run with option update = 1 ']);
              end


              % Compare the parameters of both the DAEs
              n_parms = feval(DAE.nparms,DAE);
              parmnames = feval(DAE.parmnames,DAE);
              parms = feval(DAE.getparms,DAE);
              ref_parms = feval(ref.DAE.getparms,DAE);
              out = 1;
              for count = 1:1:n_parms
                      pass_or_fail =(parms{count} == ref_parms{count});
                      if pass_or_fail 
                              if MsgDisplay
                                      print_success(sprintf('Comparing DAE parameters %s',...
                                              parmnames{count}));
                              end
                      else
                              print_failure(sprintf('Comparing DAE parameters %s',...
                                      parmnames{count}));
                              oof = sprintf('The DAE parameter %s in the test DAE and the ref. DAE are not same',parmnames{count});
                              error(oof);
                      end
              end
      end


      % set AC analysis input as a function of frequency
      Ufargs.string = 'no args used'; % 
      Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
      DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);

      % First get the QSS solution at DCOP
      DAE = feval(DAE.set_uQSS,DCOP,DAE); 
      % Default NRparms
      NRparms = defaultNRparms();
      NRparms.dbglvl = -1;
      qss = QSS(DAE,NRparms);
      qss = feval(qss.solve, initguess, qss);
      % get the solution
      qssSol = feval(qss.getSolution, qss);

      % AC analysis @ DC operating point
      LTISSSObj = LTISSS(DAE,qssSol,DCOP);
      LTISSSObj = feval(LTISSSObj.solve, ACparms.fstart, ACparms.fstop, ACparms.nsteps, ACparms.sweeptype, LTISSSObj);

      o_names = feval(DAE.outputnames,DAE);
      C = feval(DAE.C,DAE);
      D = feval(DAE.D,DAE);

      Nfreqs = length(LTISSSObj.freqs);
      noutputs = size(C,1); % ie, no of rows of C

      for i=1:Nfreqs
              f = LTISSSObj.freqs(i);
              Ufs(:,i) = feval(LTISSSObj.U_of_f, f, LTISSSObj.U_of_f_args);
      end
      if (length( size(LTISSSObj.solution) == 3) && size(LTISSSObj.solution,2) == 1) 
              oof = squeeze(LTISSSObj.solution);
              if 1 == size(oof, 2) 
                      oof = oof.';
              end
              allHs = C*oof + D*Ufs; 
      elseif length( size(LTISSSObj.solution) == 2)
              allHs = C*LTISSSObj.solution + D*Ufs; 
      else
              fprintf(2,...
                      sprintf(' 3-D solution matrix with non-singleton second dim.\n'));
              return;
      end


      for count = 1: 1: noutputs
              % Compare the simulation output 
              mag(count,:) = log10(abs(allHs(count,:)));
              ph(count,:) = (phase(allHs(count,:)));
      end 
      % Compare output 
      if strcmp(script_task,'compare')
              pass_all_output = 1; 

              for count = 1: 1: noutputs
                      pass_or_fail_mag = compare_waveform(mag(count,:),ref.mag(count,:),abstol,reltol);
                      pass_or_fail_phase = compare_waveform(ph(count,:),ref.ph(count,:),abstol,reltol);
                      pass_or_fail = (pass_or_fail_mag && pass_or_fail_phase);
                      if pass_or_fail 
                              if MsgDisplay
                                      oof = sprintf('Comparing %s of test and ref. LMS object',o_names{count});
                                      print_success(oof);
                                      disp(sprintf('  (abstol= %g, reltol=%g)\n', abstol,reltol));
                              end
                      else
                              oof = sprintf('Comparing %s of test and ref. LMS object',o_names{count});
                              print_failure(oof);
                              disp(sprintf('  (abstol= %g, reltol=%g)\n', abstol,reltol));
                              pass_all_output = 0; 
                      end
              end
              if pass_all_output
                      oof = sprintf('  Comparison of AC analysis outputs');
                      print_success(oof);
                      disp(sprintf('  (abstol= %g, reltol=%g)\n', abstol,reltol));
              end
      fprintf('\n');
      else
              %save everything
              ref.DAE = DAE;
              ref.TransObj = LTISSSObj;
              ref.DCOP = DCOP;
              ref.ACparms = ACparms;
              ref.initguess = initguess;
              ref.mag= mag;
              ref.ph = ph;
              data_filename = [ feval(DAE.uniqID,DAE) '_AC.mat'];
              save(data_filename,'ref');
      end
end

function out = compare_waveform(waveform1,waveform2,abstol,reltol)
        % This function compares if two waveforms are equal to each other

        % Compute RMS value of waveform 1 and waveform2
        waveform = waveform1-waveform2;
        RMS_waveform_diff =sqrt(sum(waveform.*waveform)/length(waveform)); % rms(waveform1);
        if length(RMS_waveform_diff)>1
                keyboard
        end
        %RMS_waveform1 =sqrt((waveform1.*waveform1)/length(waveform1)); % rms(waveform1);
        %RMS_waveform2 =sqrt((waveform2.*waveform2)/length(waveform2)); % rms(waveform1);
        out = RMS_waveform_diff<  reltol*max([abs(waveform1),abs(waveform2)]) + abstol;
end

function out = compare_params(DAE,ref_DAE)
        % Compares parameter of two DAEs
        n_parms = feval(DAE.nparms,DAE);
        parms = feval(DAE.getparms,DAE);
        ref_parms = feval(ref_DAE.getparms,DAE);
        out = 1;
        for count = 1:1:n_parms
                if parms{count} ~= ref_parms{count}
                        out=0;
                        % TOD: More descriptive where things went wrong
                end
        end
end
% Tianshi Wang's code

function print_success(name)
        blanks = repmat('-', 1, abs(70-length(name)));
        fprintf(1, '%s %s pass \n', name, blanks);
end % print_success

function print_failure(name, test_results, reference_results)
        blanks = repmat('-', 1, 70-length(name));
        fprintf(1, '%s %s _FAIL_\n', name, blanks);
        if nargin ==  3
                % fprintf(1, 'testing results \n');
                test_results
                % fprintf(1, 'reference results \n');
                reference_results
        elseif nargin ==  2
                fprintf(1, 'testing results \n');
                test_results
        end
end % print_failure

