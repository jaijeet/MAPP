function test_DCSweep(DAE,NRparms,simparms,initguess,update,MsgDisplay)
%   TODO: Pass it to the function
abstol=1e-9; reltol=1e-6;

% TODO: 
%Provide definite information when the tests fail 
%Better argument management
%More description in terms of displaying information about what is going
%on

%Create the datafile name with path
data_filename = [ feval(DAE.uniqID,DAE) '_DCsweep.mat'];
  
      % Compare or update
      if update == 0 
              % Compare the waveform with reference wavefor
              script_task = 'compare';
              oof= sprintf('MAPPtesting (DC sweep/ Testing) :: %s',feval(DAE.uniqID,DAE));
              disp(oof);

              % But, first check if there is the required testdata file
              if ~exist(data_filename,'file')

                      error([ sprintf('File %s_DCsweep.mat not found\n',data_filename) ...
                              ' Run the script ' ...
                              'with argument update = 1"']) 

              end
              load(data_filename);

      elseif update == 1
              script_task = 'update'; 
              oof= sprintf('MAPPtesting (DC sweep/ Update) :: %s',feval(DAE.uniqID,DAE));
              disp(oof);

      else
              help('test_DCsweep');        % Usage
      end


      %---------------------------------------------------------------
      % Pre-simulation comparison/update 
      %--------------------------------------------------------------
      % Compare/Update DAE parameters
      if strcmp(script_task,'compare')
              
              % Compare  Nsteps, inputStart, inputStop
              oof1 = (simparms.inputStart == ref.simparms.inputStart);
              oof2 = (simparms.inputStop == ref.simparms.inputStop);
              oof3 = (simparms.Nsteps == ref.simparms.Nsteps);
              pass_or_fail = (oof1 && oof2 && oof3); 
              if pass_or_fail 
                      if MsgDisplay 
                              print_success('Comparing sweep  parameters for test and ref. DAE');
                      end
              else
                      print_failure('Comparing sweep parameters for test and ref. DAE');
                      error(['Set the sweep parameters for testcase same as ref. or' ...
                              ' run with option update = 1 ']);
              end

              % Compare the initguess 
              user_supplied_initguess = initguess;
              ref_supplied_initguess = ref.initguess;
              pass_or_fail = (user_supplied_initguess == ref_supplied_initguess);
              if pass_or_fail 
                      if MsgDisplay
                              print_success('Comparing NR initial guess for test and ref. DCsweep');
                      end
              else
                      print_failure('Comparing NR initial guess for test and ref. DCsweep');
                      fprintf('The user supplied initial point is %d\n',user_supplied_initguess);
                      fprintf('The ref initguess is %d\n',ref_supplied_initguess);
                      error(['Set the initial guesses same for both testcase and ref. DAE or' ...
                              ' run with option update = 1 ']);
              end


              % Compare NRparams
              oof1 = (NRparms.maxiter == ref.NRparms.maxiter);
              oof2 = (NRparms.abstol == ref.NRparms.abstol);
              oof3 = (NRparms.reltol == ref.NRparms.reltol);
              oof4 = (NRparms.residualtol == ref.NRparms.residualtol);
              oof5 = (NRparms.limiting == ref.NRparms.limiting);
              pass_or_fail = (oof1 && oof2 && oof3 && oof4 && oof5); 
              if pass_or_fail 
                      if MsgDisplay 
                              print_success('Comparing NRparms for test and ref. DAE');
                      end
              else
                      print_failure('Comparing NRparms for test and ref. DAE');
                      error(['Set the NRparms for testcase same as ref. or' ...
                              ' run with option update = 1 ']);
              end


              % Compare the parameters of both the DAEs
              pass_or_fail = compare_params(DAE,ref.DAE);
              if pass_or_fail 
                      if MsgDisplay
                              print_success('Comparing parameters of test and ref. DAE');
                      end
              else
                      print_failure('Comparing parameters of test and ref. DAE');
                      error(['The parameters of the DAE set in this ' ...
                              'script is not same as the parameters of ' ...
                              'the DAE in the ref. testdata']);
              end
      end

  
      N = simparms.Nsteps;
      INs = simparms.inputStart : (simparms.inputStop-simparms.inputStart)/(N-1): simparms.inputStop;
      OUTs = [];
      initguess_intd = initguess;
      for i = 1:length(INs)
              IN = INs(i);
              DAE = feval(DAE.set_uQSS, IN, DAE);
              QSSobj = QSS(DAE, NRparms);
              QSSobj = feval(QSSobj.solve, initguess_intd, QSSobj);
              [sol, iters, success] = feval(QSSobj.getSolution, QSSobj);
              if ((success <= 0) || sum(NaN == sol))
                      fprintf(1, 'QSS failed  at IN=%g\nre-running with NR progress enabled\n', IN);
                      NRparms.dbglvl = 2;
                      QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
                      QSSobj = feval(QSSobj.solve,initguess_intd,QSSobj);
                      fprintf(1, '\naborting QSS sweep\n');
                      return;
              else
                      OUTs(i,:) = feval(DAE.C, DAE)*sol;
                      initguess_intd = sol;
              end
      end

      C = feval(DAE.C,DAE);
      noutputs = size(C,1); % ie, no of rows of C
      o_names = feval(DAE.outputnames,DAE);

      % Compare output 
      if strcmp(script_task,'compare')
              pass_all_output = 1; 

              for count = 1: 1: noutputs
                      pass_or_fail =compare_waveform(OUTs(count,:),ref.OUTs(count,:),abstol,reltol);
                      if pass_or_fail 
                              if MsgDisplay
                                      oof = sprintf('Comparing %s of test and ref. DAE (abstol= %g, reltol=%g)',...
                                              o_names{count},abstol,reltol);
                                      print_success(oof);
                              end
                      else
                              oof = sprintf('Comparing %s of test and ref. DAE (abstol= %g, reltol=%g)',...
                                      o_names{count},abstol,reltol);
                              print_failure(oof);
                              pass_all_output = 0; 
                      end
              end
              if pass_all_output
                      oof = sprintf('Comparison between test and ref. DAE (%s) output (abstol= %g, reltol=%g)',...
                              feval(DAE.uniqID,DAE),abstol,reltol);
                      print_success(oof);
              end
      else
              %save everything
              ref.DAE = DAE;
              ref.NRparms = NRparms;
              ref.initguess = initguess;
              ref.simparms = simparms; 
              ref.OUTs = OUTs; 
              data_filename = [ feval(DAE.uniqID,DAE) '_DCsweep.mat'];
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

