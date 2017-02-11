function test_DAEAPI(DAE,updateReference,MsgDisplay,ntest)
%This is the test function to run MAPPtest on various circuit DAEs (DAEAPI)
%
%Usage: 
%A. First find out what is the uniqIDstring of the DAEAPI. uniqIDstring.mat
%is the filename where reference data is saved (if it is run in testing/comparison
%mode) or will be saved (if the script is run in update mode).  
%
% filename = [feval(DAE.uniqID,DAE) '.mat'];
%
%B. If the script is running in update mode, then set the variable script_task to
%compare and if it is in comparison/testing mode, then set the variable to
%'update'.
%
abstol=1e-9; reltol=1e-6;
filename = [feval(DAE.uniqID,DAE) '.mat'];

if updateReference == 0 
        % Doing comparison with reference testdata
        script_task = 'compare';
        fprintf(1,'DAEAPI MAPPtest (Comparison) :: %s\n',feval(DAE.uniqID,DAE));
        % Check if the reference testdata is present in the directory
        if ~exist(filename,'file')
                fprintf(1,'Cannot find file %s\n',filename);
                error('First run the script with ''updateReference'' = 1');
        end 
        load(filename); % Load reference data in the workspace
elseif updateReference ==1
        % Create test-data
        script_task = 'update';
        fprintf(1,'DAEAPI MAPPtest (Update) :: %s\n',feval(DAE.uniqID,DAE));
else
        fprintf(1,'Wrong value for ''updateReferene'' argument\n');
        fprintf(1,'''updateReference'' can only be set to 1 or 0\n');
        help('test_DAEAPI');
end

% Set and get methods checking.
% In both mode of running (update or comparison), get and set methods are
% always run.

        % Check if get and setparms are working
        DAE_parms = feval(DAE.getparms,DAE);
        DAE_parm_names = feval(DAE.parmnames,DAE);
        for count = 1:1:length(DAE_parms)
                % Multiply the parameter value by a random number
                parm_to_set = DAE_parms{count} * rand(1,1);
                % Set the parameter to this value  by using DAE.setparms function
                temp_DAE = feval(DAE.setparms,DAE_parm_names{count}, parm_to_set, DAE);
                % Get the parameter value by using DAE.getparms function. 
                % Both of them should be same
                parm_from_get = feval(temp_DAE.getparms, DAE_parm_names{count},temp_DAE);
                pass_or_fail =  is_equal(parm_to_set,parm_from_get); % are they equal?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success(sprintf('Testing get/setparm for %s',DAE_parm_names{count}));
                        end
                else
                        print_failure(sprintf('Testing get/setparm for %s',DAE_parm_names{count}));
                        disp('Commands tried ...');
                        disp(sprintf('parm_to_set = DAE_parms{%d}* rand(1,1);,count);'));
                        disp(sprintf('temp_DAE = feval(DAE.setparms,DAE_parm_names{%d}, parm_to_set,temp_DAE);',count));
                        disp(sprintf('parm_from_get = feval(temp_DAE.getparms, DAE_parm_names{%d},temp_DAE);',count));
                        disp(sprintf('parm_to_set = %d, parm_from_get = %d',parm_to_set,parm_from_get));
                        error(sprintf('Check get/setparm for %s',DAE_parm_names{count}));
                end
                parmslist_to_set{count} = parm_to_set;
        end 

        % Now try to get and set methods for parm by passing the complete the parameter list
        temp_DAE = feval(DAE.setparms,parmslist_to_set,DAE);
        % Get the parameter list by using DAE.getparms function. 
        % Both of them should be same
        parmslist_from_get = feval(temp_DAE.getparms,temp_DAE);
        pass_or_fail = 1;
        for count = 1:1:length(parmslist_from_get)
                if parmslist_from_get{count} ~= parmslist_to_set{count}
                        pass_or_fail = 0;
                end
        end
        if pass_or_fail 
                if MsgDisplay 
                        print_success(sprintf('Testing get/setparm for all DAE parms'));
                end
        else
                print_failure(sprintf('Testing get/setparm for all DAE parms'));
                disp('Commands tried...')
                disp('temp_DAE = feval(DAE.setparms,parmslist_to_set,DAE);');
                disp('parmslist_from_get = feval(temp_DAE.getparms,temp_DAE)'); 
                disp(sprintf('parmslist_to_set='))
                disp(parmslist_to_set);
                disp(sprintf('parmslist_from_get='))
                disp(parmslist_from_get);
                error(sprintf('Check get/setparm methods'));
        end

        % Check if get and set methods are working for different input functions
        % First find out ninputs
        n_inputs = feval(DAE.ninputs,DAE);

        % Check if get and access methods are working for utransient (set them all at once)
        utargs.A = 0.5; utargs.f=1e1; utargs.phi=0; 
        % Output size of this function should be (n_inputs,:)
        utfunc = @(t, args) ones(n_inputs,1)*args.A*sin(2*pi*args.f*t + args.phi);
        % Create a tempDAE with a new utfunc
        outDAE = feval(DAE.set_utransient,utfunc, utargs,DAE);
        % Define a time vector
        tt = 0:0.0001:0.2;
        waveform_1 = utfunc(tt,utargs);
        waveform_2 = feval(outDAE.utransient,tt,outDAE);
        % For all inputs, compare_waveform() between waveform_1 and waveform_2
        for count = 1:1:n_inputs
                pass_or_fail = compare_waveform(waveform_1(count,:), waveform_2(count,:));
                if pass_or_fail 
                        if MsgDisplay 
                                print_success(sprintf('Testing group set/access function for utransient (input %d)', count));
                        end
                else
                        print_failure(sprintf('Testing group set/access function for utransient (input %d)', count));
                        fprintf(1,'get/access function for utransient (input %d) did not work properly\n');
                        disp('Gist of commands executed')
                        disp('n_inputs = feval(DEA.ninputs,DAE);');
                        disp('utargs.A = 0.5; utargs.f=1e1; utargs.phi=0;');
                        disp('utfunc = @(t, args) ones*(n_inputs,1)*args.A*sin(2*pi*args.f*t + args.phi);');
                        disp('outDAE = feval(DAE.set_utransient,utfunc, utargs,DAE);');
                        disp('tt = 0:0.0001:0.2;');
                        disp('waveform_1 = utfunc(tt,utargs); waveform_2 = feval(outDAE.utransient,tt,outDAE);');
                        disp(sprintf('pass_or_fail = compare_waveform(waveform_1(count,:), waveform_2(count,:)',count,count))
                        error('Aborting');
                end
        end

        % Check if get and access methods are working for utransient (set them one by one)
        % Get the inputnames list
        inputname_list = feval(DAE.inputnames,DAE);
        for count = 1:1:n_inputs
                utargs.A = 0.5; utargs.f=1e1; utargs.phi=0; 
                % Output size of this function should be (1,:)
                utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
                % Create a tempDAE with a new utfunc
                clear outDAE; % Just to be safe clear the previous version
                outDAE = feval(DAE.set_utransient,inputname_list{count}, utfunc, utargs,DAE);
                % Define a time vector
                tt = 0:0.0001:0.2;
                waveform_1 = utfunc(tt,utargs);
                waveform_2 = feval(outDAE.utransient,tt,outDAE); % This returns transient input functions for all inputs
                % For all inputs, compare_waveform() between waveform_1 and waveform_2
                pass_or_fail = compare_waveform(waveform_1, waveform_2(count,:));
                if pass_or_fail 
                        if MsgDisplay 
                                print_success(sprintf('Testing individual set/access function for utransient (input %d)', count));
                        end
                else
                        print_failure(sprintf('Testing individual set/access function for utransient (input %d)', count));
                        fprintf(1,'get/access function for utransient (input %d) did not work properly\n');
                        disp('Gist of commands executed')
                        disp('utargs.A = 0.5; utargs.f=1e1; utargs.phi=0;');
                        disp('utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);');
                        disp(sprintf('outDAE = feval(DAE.set_utransient,''%s'',utfunc, utargs,DAE);',inputname_list{count}));
                        disp('tt = 0:0.0001:0.2;');
                        disp('waveform_1 = utfunc(tt,utargs); waveform_2 = feval(outDAE.utransient,tt,outDAE);');
                        disp(sprintf('pass_or_fail = compare_waveform(waveform_1, waveform_2(count,:)',count,count))
                        error('Aborting'); 
                end
        end 


        % Check if get and access methods are working for uQSS
        % Create a tempDAE with a new uQSSvec
        clear outDAE; % Clear it just to be safe
        uQSSvec = rand(n_inputs,1);
        outDAE = feval(DAE.set_uQSS,uQSSvec,DAE);
        uQSSvec_2 = feval(outDAE.uQSS,outDAE);
        % For all inputs, compare
        for count = 1:1:n_inputs
                pass_or_fail = is_equal(uQSSvec(count,1), uQSSvec_2(count,1));
                if pass_or_fail 
                        if MsgDisplay 
                                print_success(sprintf('Testing group set/access function for uQSS(input %d)', count));
                        end
                else
                        print_failure(sprintf('Testing group set/access function for uQSS(input %d)', count));
                        fprintf(1,'get/access function for uQSS (input %d) did not work properly\n');
                        disp('Gist of commands executed')
                        disp('n_inputs = feval(DEA.ninputs,DAE);');
                        disp('uQSSvec = rand(n_inputs,1);');
                        disp('outDAE = feval(DAE.set_uQSS,uQSSvec,DAE);');
                        disp('uQSSvec_2 = feval(outDAE.uQSS,outDAE);');
                        disp(sprintf('pass_or_fail = is_equal(uQSSvec(count,:), uQSSvec_2(count,:))',count,count));
                        error('Aborting');
                end
        end

        % Check if get and access methods are working for uQSS (set them one by one)
        % Get the inputnames list
        for count = 1:1:n_inputs
                uQSSvec = rand(1,1);
                clear outDAE; % Just to be safe clear the previous version
                outDAE = feval(DAE.set_uQSS,inputname_list{count},uQSSvec,DAE);
                uQSSvec_2 = feval(outDAE.uQSS,outDAE);
                pass_or_fail = is_equal(uQSSvec,uQSSvec_2(count));
                if pass_or_fail 
                        if MsgDisplay 
                                print_success(sprintf('Testing individual set/access function for uQSSvec (input %d)', count));
                        end
                else
                        print_failure(sprintf('Testing individual set/access function for uQSS (input %d)', count));
                        fprintf(1,'get/access function for uQSS (input %d) did not work properly\n');
                        disp('Gist of commands executed')
                        disp('n_inputs = feval(DEA.ninputs,DAE);');
                        disp('uQSSvec = rand(1,1);');
                        disp('outDAE = feval(DAE.set_uQSS,uQSSvec,DAE);');
                        disp('uQSSvec_2 = feval(outDAE.uQSS,outDAE);');
                        disp(sprintf('pass_or_fail = is_equal(uQSSvec, uQSSvec_2(count,1))',count));
                        error('Aborting'); 
                end
        end 

        % No support for uHB testing yet
        %{
        %}

        % Check if get and access methods are working for uLITSSS (set them all at once)
        % Output size of this function should be (n_inputs,:)
        Ufargs.string = 'no args used'; % 
        Uffunc = @(f, args) ones(n_inputs,1); % constant U(j 2 pi f) \equiv 1
        % Create a tempDAE with a new uLTISSS
        outDAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);
        fin = 1;
        uLTISSS_1 = Uffunc(fin,Ufargs);
        uLTISSS_2 = feval(outDAE.uLTISSS,fin,outDAE);
        % For all inputs, compare
        for count = 1:1:n_inputs
                pass_or_fail = is_equal(uLTISSS_1,uLTISSS_2(count));
                if pass_or_fail 
                        if MsgDisplay 
                                print_success(sprintf('Testing group set/access function for uLTISSS (input %d)', count));
                        end
                else
                        print_failure(sprintf('Testing group set/access function for uLTISSS (input %d)', count));
                        fprintf(1,'get/access function for uLTISSS (input %d) did not work properly\n');
                        disp('Gist of commands executed')
                        disp('n_inputs = feval(DEA.ninputs,DAE);');
                        disp('Ufargs.string = ''no args used'';');
                        disp('Uffunc = @(f, args) ones(n_inputs,1); % constant U(j 2 pi f) \equiv 1');
                        disp('outDAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);');
                        disp('uLTISSS_1 = Uffunc(Ufargs);');
                        disp('uLTISSS_2 = feval(outDAE.uLTISSS,outDAE);');
                        disp(sprintf('pass_or_fail = is_equal(uLTISSS_1,uLTISSS_2(count));',count));
                        error('Aborting');
                end
        end

        % Check if get and access methods are working for uLTISSS(set them one by one)
        % Get the inputnames list
        for count = 1:1:n_inputs
                Ufargs.string = 'no args used'; % 
                Uffunc = @(f, args) ones(1,1); % constant U(j 2 pi f) \equiv 1
                % Create a tempDAE with a new uLTISSS
                clear outDAE; % Just to be safe clear the previous version
                outDAE = feval(DAE.set_uLTISSS,inputname_list{count}, Uffunc, Ufargs, DAE);
                uLTISSS_1 = Uffunc(fin,Ufargs);
                uLTISSS_2 = feval(outDAE.uLTISSS,fin,outDAE);
                % For all inputs, compare
                pass_or_fail = is_equal(uLTISSS_1,uLTISSS_2(count));
                if pass_or_fail 
                        if MsgDisplay 
                                print_success(sprintf('Testing individual set/access function for uLTISSS (input %d)', count));
                        end
                else
                        print_failure(sprintf('Testing individual set/access function for uLTISSS (input %d)', count));
                        fprintf(1,'get/access function for uLTISSS (input %d) did not work properly\n');
                        disp('Gist of commands executed')
                        disp('n_inputs = feval(DEA.ninputs,DAE);');
                        disp('Ufargs.string = ''no args used'';');
                        disp('Uffunc = @(f, args) ones(n_inputs,1); % constant U(j 2 pi f) \equiv 1');
                        disp('outDAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);');
                        disp('uLTISSS_1 = Uffunc(Ufargs);');
                        disp('uLTISSS_2 = feval(outDAE.uLTISSS,outDAE);');
                        disp(sprintf('pass_or_fail = is_equal(uLTISSS_1,uLTISSS_2(count));',count));
                        error('Aborting');
                end
        end 

        if strcmp(script_task,'compare')

                % Check if number of unknowns are same
                test.DAE_nunks = feval(DAE.nunks,DAE); % no of unks in test DAE
                ref_DAE_nunks = feval(ref.DAE.nunks,ref.DAE); % no of unks in ref DAE


                % Check if number of equations are same
                test.DAE_neqns = feval(DAE.neqns,DAE); % no of equns in test DAE
                ref_DAE_neqns = feval(ref.DAE.neqns,ref.DAE); % no of equns in ref DAE
                pass_or_fail = (test.DAE_neqns == ref_DAE_neqns); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing no. of equations');
                        end
                else
                        print_failure('Comparing no. of equations');
                        fprintf(1,'No. of equations in test DAE = %d\n',test.DAE_neqns);
                        fprintf(1,'No. of equations in ref DAE = %d\n',ref_DAE_neqns);
                        error('No. of equations are not same. Aborting');
                end

                % Check if number of inputs are same
                test.DAE_ninputs = feval(DAE.ninputs,DAE); % no of inputs in test DAE
                ref_DAE_ninputs = feval(ref.DAE.ninputs,ref.DAE); % no of inputs in ref DAE
                pass_or_fail = (test.DAE_ninputs == ref_DAE_ninputs); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing no. of inputs');
                        end
                else
                        print_failure('Comparing no. of inputs');
                        fprintf(1,'No. of inputs in test DAE = %d\n',test.DAE_ninputs);
                        fprintf(1,'No. of inputs in ref DAE = %d\n',ref_DAE_ninputs);
                        error('No. of inputs are not same. Aborting');
                end

                % Check if number of outputs are same
                test.DAE_noutputs = feval(DAE.noutputs,DAE); % no of outputs in test DAE
                ref_DAE_noutputs = feval(ref.DAE.noutputs,ref.DAE); % no of outputs in ref DAE
                pass_or_fail = (test.DAE_noutputs == ref_DAE_noutputs); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing no. of outputs');
                        end
                else
                        print_failure('Comparing no. of outputs');
                        fprintf(1,'No. of outputs in test DAE = %d\n',test.DAE_noutputs);
                        fprintf(1,'No. of outputs in ref DAE = %d\n',ref_DAE_noutputs);
                        error('No. of outputs are not same. Aborting');
                end


                % Check if number of parameters are same
                test.DAE_nparms = feval(DAE.nparms,DAE); % no of parms in test DAE
                ref_DAE_nparms = feval(ref.DAE.nparms,ref.DAE); % no of parms in ref DAE
                pass_or_fail = (test.DAE_nparms == ref_DAE_nparms); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing no. of parms');
                        end
                else
                        print_failure('Comparing no. of parms');
                        fprintf(1,'No. of parms in test DAE = %d\n',test.DAE_nparms);
                        fprintf(1,'No. of parms in ref DAE = %d\n',ref_DAE_nparms);
                        error('No. of parms are not same. Aborting');
                end

                % Check if f_takes_inputs are same
                test.f_takes_inputs = DAE.f_takes_inputs; % f_takes_inputs in test DAE
                ref_f_takes_inputs = ref.DAE.f_takes_inputs; % f_takes_inputs in ref DAE
                pass_or_fail = (test.f_takes_inputs == ref_f_takes_inputs); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing f_takes_inputs');
                        end
                else
                        print_failure('Comparing f_takes_inputs');
                        fprintf(1,'testDAE.f_takes_inputs is %d\n',test.f_takes_inputs);
                        fprintf(1,'refDAE.f_takes_inputs is %d\n',ref_f_takes_inputs);
                        error('f_takes_inputs  are not same. Aborting');
                end

                % Check if uniqIDs are same
                test.uniqID = feval(DAE.uniqID,DAE); % uniqID string in test DAE
                ref_uniqID = feval(ref.DAE.uniqID,ref.DAE); %uniqID string  in ref DAE
                pass_or_fail = strcmp(test.uniqID,ref_uniqID); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing uniqID');
                        end
                else
                        print_failure('Comparing uniqID');
                        fprintf(1,'testDAE.uniqID is %d\n',test.uniqID);
                        fprintf(1,'refDAE.uniqID is %d\n',ref_uniqID);
                        error('uniqIDs  are not same. Aborting');
                end

                % Check if daenames are same
                test.daename = feval(DAE.daename,DAE); % daename string in test DAE
                ref_daename = feval(ref.DAE.daename,ref.DAE); %daename string  in ref DAE
                pass_or_fail = strcmp(test.daename,ref_daename); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing daename');
                        end
                else
                        print_failure('Comparing daename');
                        fprintf(1,'testDAE.daename is %d\n',test.daename);
                        fprintf(1,'refDAE.daename is %d\n',ref_daename);
                        error('daenames  are not same. Aborting');
                end

                % Check if unknames are same
                test.unknames = feval(DAE.unknames,DAE); % unknames cell array in test DAE
                ref_unknames = feval(ref.DAE.unknames,ref.DAE); %unknames cell array  in ref DAE
                % Need to pass through a loop
                for count = 1:1:test.DAE_nunks
                        pass_or_fail = strcmp(test.unknames{count},ref_unknames{count}); % are they same?
                        if pass_or_fail 
                                if MsgDisplay 
                                        print_success(sprintf('Comparing unknames{%d}',count));
                                end
                        else
                                print_failure(sprintf('Comparing unknames{%d}',count));
                                fprintf(1,'testDAE.unknames{%d} is %d\n',count,test.unknames{count});
                                fprintf(1,'refDAE.unknames{%d} is %d\n',count,ref_unknames{count});
                                error(sprintf('unknames{%d} are not same. Aborting',count));
                        end
                end

                % Check if eqnnames are same
                test.eqnnames = feval(DAE.eqnnames,DAE); % eqnnames cell array in test DAE
                ref_eqnnames = feval(ref.DAE.eqnnames,ref.DAE); %eqnnames cell array  in ref DAE
                % Need to pass through a loop
                for count = 1:1:test.DAE_neqns
                        pass_or_fail = strcmp(test.eqnnames{count},ref_eqnnames{count}); % are they same?
                        if pass_or_fail 
                                if MsgDisplay 
                                        print_success(sprintf('Comparing eqnnames{%d}',count));
                                end
                        else
                                print_failure(sprintf('Comparing eqnnames{%d}',count));
                                fprintf(1,'testDAE.eqnnames{%d} is %d\n',count,test.eqnnames{count});
                                fprintf(1,'refDAE.eqnnames{%d} is %d\n',count,ref_eqnnames{count});
                                error(sprintf('eqnnames{%d}  are not same. Aborting',count));
                        end
                end

                % Check if inputnames are same
                test.inputnames = feval(DAE.inputnames,DAE); % inputnames cell array in test DAE
                ref_inputnames = feval(ref.DAE.inputnames,ref.DAE); %inputnames cell array  in ref DAE
                % Need to pass through a loop
                for count = 1:1:test.DAE_ninputs
                        pass_or_fail = strcmp(test.inputnames{count},ref_inputnames{count}); % are they same?
                        if pass_or_fail 
                                if MsgDisplay 
                                        print_success(sprintf('Comparing inputnames{%d}',count));
                                end
                        else
                                print_failure(sprintf('Comparing inputnames{%d}',count));
                                fprintf(1,'testDAE.inputnames{%d} is %d\n',count,test.inputnames{count});
                                fprintf(1,'refDAE.inputnames{%d} is %d\n',count,ref_inputnames{count});
                                error(sprintf('inputnames{%d}  are not same. Aborting',count));
                        end
                end

                % Check if outputnames are same
                test.outputnames = feval(DAE.outputnames,DAE); % outputnames cell array in test DAE
                ref_outputnames = feval(ref.DAE.outputnames,ref.DAE); %outputnames cell array  in ref DAE
                % Need to pass through a loop
                for count = 1:1:test.DAE_noutputs
                        pass_or_fail = strcmp(test.outputnames{count},ref_outputnames{count}); % are they same?
                        if pass_or_fail 
                                if MsgDisplay 
                                        print_success(sprintf('Comparing outputnames{%d}',count));
                                end
                        else
                                print_failure(sprintf('Comparing outputnames{%d}',count));
                                fprintf(1,'testDAE.outputnames{%d} is %d\n',count,test.outputnames{count});
                                fprintf(1,'refDAE.outputnames{%d} is %d\n',count,ref_outputnames{count});
                                error(sprintf('outputnames{%d}  are not same. Aborting',count));
                        end
                end

                % Check if parmnames are same
                test.parmnames = feval(DAE.parmnames,DAE); % parmnames cell array in test DAE
                ref_parmnames = feval(ref.DAE.parmnames,ref.DAE); %parmnames cell array  in ref DAE
                % Need to pass through a loop
                for count = 1:1:test.DAE_nparms
                        pass_or_fail = strcmp(test.parmnames{count},ref_parmnames{count}); % are they same?
                        if pass_or_fail 
                                if MsgDisplay 
                                        print_success(sprintf('Comparing parmnames{%d}',count));
                                end
                        else
                                print_failure(sprintf('Comparing parmnames{%d}',count));
                                fprintf(1,'testDAE.parmnames{%d} is %d\n',count,test.parmnames{count});
                                fprintf(1,'refDAE.parmnames{%d} is %d\n',count,ref_parmnames{count});
                                error(sprintf('parmnames{%d}  are not same. Aborting',count));
                        end
                end


                % Check if parm default values are same
                test.parmdefaults = feval(DAE.parmdefaults,DAE); % parmdefaults cell array in test DAE
                ref_parmdefaults = feval(ref.DAE.parmdefaults,ref.DAE); %parmdefaults cell array  in ref DAE
                % Need to pass through a loop
                for count = 1:1:test.DAE_nparms
                        pass_or_fail = (test.parmdefaults{count} == ref_parmdefaults{count}); % are they same?
                        if pass_or_fail 
                                if MsgDisplay 
                                        print_success(sprintf('Comparing parmdefaults{%d}',count));
                                end
                        else
                                print_failure(sprintf('Comparing parmdefaults{%d}',count));
                                fprintf(1,'testDAE.parmdefaults{%d} is %d\n',count,test.parmdefaults{count});
                                fprintf(1,'refDAE.parmdefaults{%d} is %d\n',count,ref_parmdefaults{count});
                                error(sprintf('parmdefaults{%d}  are not same. Aborting',count));
                        end
                end

                % Compare B (Assume it to be constant, not function of x,u)
                % First check if f_takes_inputs == 1 or 0
                if test.f_takes_inputs ==1
                        %{
                        pass_or_fail = (isempty(feval(DAE.B,DAE)) && isempty(feval(ref.DAE.B,ref.DAE))); % are they same?
                        if pass_or_fail 
                                if MsgDisplay 
                                        print_success(sprintf('Comparing B'));
                                        disp('Both are empty as they should be');
                                end
                        else
                                print_failure('Comparing B');
                                fprintf(1,'test.DAE.B=\n');
                                disp(feval(DAE.B,DAE))
                                fprintf(1,'ref.DAE.B=\n');
                                disp(feval(ref.DAE.B,ref.DAE))
                                error('Both the B matrices should be empty as f_takes_inputs =1');
                        end
                        %}
                        %DO NOT DO ANYTHING 
                else
                        test.B = feval(DAE.B, DAE);
                        ref_B = feval(ref.DAE.B,ref.DAE);
                        % Need to pass through a loop
                        for count1 = 1:1:test.DAE_nunks
                                for count2 = 1:1:test.DAE_nparms
                                        pass_or_fail = (test.B(count1,count2) == ref_B(count1,count2)); % are they same?
                                        if pass_or_fail 
                                                if MsgDisplay 
                                                        print_success(sprintf('Comparing B(%d,%d)',count1,count2));
                                                end
                                        else
                                                print_failure(sprintf('Comparing B(%d,%d)',count1,count2));
                                                fprintf(1,'testDAE.B(%d,%d) is %d\n',count1,count2,test.B(count1,count2));
                                                fprintf(1,'refDAE.B(%d,%d) is %d\n',count1,count2,ref_B(count1,count2));
                                                error(sprintf('B(%d,%d) are not same. Aborting',count1,count2));
                                        end
                                end
                        end
                end

                % Compare C
                test.C = feval(DAE.C, DAE);
                ref_C = feval(ref.DAE.C,ref.DAE);
                % Need to pass through a loop
                for count1 = 1:1:test.DAE_ninputs
                        for count2 = 1:1:test.DAE_nunks
                                pass_or_fail = (test.C(count1,count2) == ref_C(count1,count2)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing C(%d,%d)',count1,count2));
                                        end
                                else
                                        print_failure(sprintf('Comparing C(%d,%d)',count1,count2));
                                        fprintf(1,'testDAE.C(%d,%d) is %d\n',count1,count2,test.C(count1,count2));
                                        fprintf(1,'refDAE.C(%d,%d) is %d\n',count1,count2,ref_C(count1,count2));
                                        error(sprintf('C(%d,%d) are not same. Aborting',count1,count2));
                                end
                        end
                end

                % Compare D 
                test.D = feval(DAE.D, DAE);
                ref_D = feval(ref.DAE.D,ref.DAE);
                % Need to pass through a loop
                for count1 = 1:1:test.DAE_noutputs
                        for count2 = 1:1:test.DAE_ninputs
                                pass_or_fail = (test.D(count1,count2) == ref_D(count1,count2)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing D(%d,%d)',count1,count2));
                                        end
                                else
                                        print_failure(sprintf('Comparing D(%d,%d)',count1,count2));
                                        fprintf(1,'testDAE.D(%d,%d) is %d\n',count1,count2,test.D(count1,count2));
                                        fprintf(1,'refDAE.D(%d,%d) is %d\n',count1,count2,ref_D(count1,count2));
                                        error(sprintf('D(%d,%d) are not same. Aborting',count1,count2));
                                end
                        end
                end



                % Check if time units are same
                test.time_unit = DAE.time_units; % time unit in test DAE
                ref_time_unit = ref.DAE.time_units; %time unit in ref DAE
                pass_or_fail = strcmp(test.time_unit,ref_time_unit); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing time unit');
                        end
                else
                        print_failure('Comparing time unit');
                        fprintf(1,'testDAE.time unit is %d\n',test.time_unit);
                        fprintf(1,'refDAE.time unit is %d\n',ref_time_unit);
                        error('time units  are not same. Aborting');
                end

                % Check if number of noise sources are same 
                test.nNoiseSources = feval(DAE.nNoiseSources,DAE); % no. of noise sources in test DAE
                ref_nNoiseSources = feval(ref.DAE.nNoiseSources,ref.DAE); % no. of noise sources in ref DAE
                pass_or_fail = (test.nNoiseSources == ref_nNoiseSources); % are they same?
                if pass_or_fail 
                        if MsgDisplay 
                                print_success('Comparing no. of noise sources');
                        end
                else
                        print_failure('Comparing of. noise sources');
                        fprintf(1,'testDAE.nNoiseSoruces is %d\n',test.nNoiseSources);
                        fprintf(1,'refDAE.nNoiseSoruces is %d\n',ref_nNoiseSources);
                        error('No. of noise sources are not same. Aborting');
                end


                % Compare uQSSvec_default 
                test.uQSSvec_default = feval(DAE.uQSSvec_default, DAE);
                ref_uQSSvec_default = feval(ref.DAE.uQSSvec_default,ref.DAE);
                for count = 1:1:test.DAE_ninputs
                        pass_or_fail = (test.uQSSvec_default(count,1) == ref_uQSSvec_default(count,1)); % are they same?
                        if pass_or_fail 
                                if MsgDisplay 
                                        print_success(sprintf('Comparing uQSSvec_default(%d,1)',count));
                                end
                        else
                                print_failure(sprintf('Comparing uQSSvec_default(%d,1)',count));
                                fprintf(1,'testDAE.uQSSvec_default(%d) is %d\n',count,test.uQSSvec_default(count,1));
                                fprintf(1,'refDAE.uQSSvec_default(%d) is %d\n',count,ref_uQSSvec_default(count,1));
                                error(sprintf('uQSSvec_default(%d) are not same. Aborting',count));
                        end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %DYNAMIC TESTING
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                %===========================================================
                %   dynamic tests: test fe, qe, fi, qi on different cases
                %		   test init/limiting
                %   random  tests: test fe, qe, fi, qi on random cases
                %		   test init/limiting
                %===========================================================
                random_check = 0; 
                for count = 1:1: (ntest.n_dynamic+ntest.n_random)
                        if count > ntest.n_dynamic
                                random_check =1;
                        end
                        if random_check == 0
                                if MsgDisplay 
                                        fprintf(1, '--------------------------------------------\n');
                                        fprintf(1, '      dynamic testing on case %d            \n', count);
                                        fprintf(1, '--------------------------------------------\n');
                                end
                                %set the vecX and vecU to that saved in ref data
                                vecX = ref.vecX(:,count);
                                vecU = ref.vecU(:,count);
                                % vecXold for NRlimiting
                                vecXold = ref.vecXold(:,count);
                                tt = ref.tt(:,count); % random time sample for utfunc_default
                                fff = ref.fff(:,count); % random freq for Uffunc_default
                                ffHB = ref.ffHB(:,count); % random freq samples for uHBfunc_default
                        else
                                rand('seed',  etime(clock, [1900, 1, 1, 0, 0, 0]));
                                if MsgDisplay 
                                        fprintf(1, '--------------------------------------------\n');
                                        fprintf(1, '      Random dynamic testing on case %d            \n', count-ntest.n_dynamic);
                                        fprintf(1, '--------------------------------------------\n');
                                end
                                vecX = rand(test.DAE_nunks,1);
                                vecU = rand(test.DAE_ninputs,1);
                                % old for NRlimiting
                                vecXold = rand(test.DAE_nunks,1);
                                tt = rand(1,1); % random time for utfunc
                                fff = rand(1,1); % random freq for Uffunc 
                                ffHB = rand(1,1);% random freq. for uHBfunc
                        end

                        % Compare utfunc_default
                        test.utfunc_default = feval(DAE.utfunc_default, tt,DAE);
                        ref_utfunc_default = feval(ref.DAE.utfunc_default,tt,ref.DAE);
                        for count = 1:1:test.DAE_ninputs
                                pass_or_fail = (test.utfunc_default(count,1) == ref_utfunc_default(count,1)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing utfunc_default(%d,1)',count));
                                        end
                                else
                                        print_failure(sprintf('Comparing utfunc_default(%d,1)',count));
                                        fprintf(1,'t =%d\n',tt);
                                        fprintf(1,'testDAE.utfunc_default(%d) is %d\n',count,test.utfunc_default(count,1));
                                        fprintf(1,'refDAE.utfunc_default(%d) is %d\n',count,ref_utfunc_default(count,1));
                                        error(sprintf('utfunc_default(%d) are not same. Aborting',count));
                                end
                        end

                        % Compare Uffunc_default
                        test.Uffunc_default = feval(DAE.Uffunc_default, fff, DAE);
                        ref_Uffunc_default = feval(ref.DAE.Uffunc_default,fff,ref.DAE);
                        for count = 1:1:test.DAE_ninputs
                                pass_or_fail = (test.Uffunc_default(count,1) == ref_Uffunc_default(count,1)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing Uffunc_default(%d,1)',count));
                                        end
                                else
                                        print_failure(sprintf('Comparing Uffunc_default(%d,1)',count));
                                        fprintf(1,'f =%d\n',fff);
                                        fprintf(1,'testDAE.Uffunc_default(%d) is %d\n',count,test.Uffunc_default(count,1));
                                        fprintf(1,'refDAE.Uffunc_default(%d) is %d\n',count,ref_Uffunc_default(count,1));
                                        error(sprintf('Uffunc_default(%d) are not same. Aborting',count));
                                end
                        end

                        % Compare uHBfunc_default
                        test.uHBfunc_default = feval(DAE.uHBfunc_default, fff, DAE);
                        ref_uHBfunc_default = feval(ref.DAE.uHBfunc_default,fff,ref.DAE);
                        for count = 1:1:test.DAE_ninputs
                                pass_or_fail = (test.uHBfunc_default(count,1) == ref_uHBfunc_default(count,1)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing uHBfunc_default(%d,1)',count));
                                        end
                                else
                                        print_failure(sprintf('Comparing uHBfunc_default(%d,1)',count));
                                        fprintf(1,'f =%d\n',fff);
                                        fprintf(1,'testDAE.uHBfunc_default(%d) is %d\n',count,test.uHBfunc_default(count,1));
                                        fprintf(1,'refDAE.uHBfunc_default(%d) is %d\n',count,ref_uHBfunc_default(count,1));
                                        error(sprintf('uHBfunc_default(%d) are not same. Aborting',count));
                                end
                        end


                        % Compare QSSinitGuess function (function of vecU)
                        test.QSSinitGuess_out = feval(DAE.QSSinitGuess,vecU,DAE);
                        ref_QSSinitGuess_out = feval(ref.DAE.QSSinitGuess,vecU,ref.DAE);
                        % Need to pass through a loop
                        for count = 1:1:test.DAE_nunks
                                pass_or_fail = (test.QSSinitGuess_out(count,1) == ref_QSSinitGuess_out(count,1)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing QSSinitGuess_out(%d,1)',count));
                                        end
                                else
                                        print_failure(sprintf('Comparing QSSinitGuess_out(%d,1)',count));
                                        fprintf(1,'vecU=\n');
                                        disp(vecU)
                                        fprintf(1,'testDAE.QSSinitGuess_out(%d,1) is %d\n',count,test.QSSinitGuess_out(count));
                                        fprintf(1,'refDAE.QSSinitGuess_out(%d,1) is %d\n',count,ref_QSSinitGuess_out(count));
                                        error(sprintf('QSSinitGuess_out(%d,1) are not same. Aborting',count));
                                end
                        end

                        % Compare NRlimiting function (function of dvecX, vecXold,and
                        % vecU)
                        test.NRlimiting_out = feval(DAE.NRlimiting,vecX-vecXold,vecXold,vecU,DAE);
                        ref_NRlimiting_out = feval(ref.DAE.NRlimiting,vecX-vecXold,vecXold,vecU,ref.DAE);
                        % Need to pass through a loop
                        for count = 1:1:test.DAE_nunks
                                pass_or_fail = (test.NRlimiting_out(count,1) == ref_NRlimiting_out(count,1)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing NRlimiting_out(%d,1)',count));
                                        end
                                else
                                        print_failure(sprintf('Comparing NRlimiting_out(%d,1)',count));
                                        fprintf(1,'vecX=\n');
                                        disp(vecX)
                                        fprintf(1,'vecXold=\n');
                                        disp(vecXold)
                                        fprintf(1,'vecU=\n');
                                        disp(vecU)
                                        fprintf(1,'testDAE.NRlimiting_out(%d,1) is %d\n',count,test.NRlimiting_out(count));
                                        fprintf(1,'refDAE.NRlimiting_out(%d,1) is %d\n',count,ref_NRlimiting_out(count));
                                        error(sprintf('NRlimiting_out(%d,1) are not same. Aborting',count));
                                end
                        end


                        % Compare f(x,u)
                        test.f = feval(DAE.f, vecX, vecU, DAE);
                        ref_f = feval(ref.DAE.f, vecX, vecU, ref.DAE);
                        % Need to pass through a loop
                        for count = 1:1:test.DAE_nunks
                                pass_or_fail = (test.f(count,1) == ref_f(count,1)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing f(%d,1)',count));
                                        end
                                else
                                        print_failure(sprintf('Comparing f(%d,1)',count));
                                        fprintf(1,'vecX=\n');
                                        disp(vecX)
                                        fprintf(1,'vecU=\n');
                                        disp(vecU)
                                        fprintf(1,'testDAE.f(%d,1) is %d\n',count,test.f(count));
                                        fprintf(1,'refDAE.f(%d,1) is %d\n',count,ref_f(count));
                                        error(sprintf('f(%d,1) are not same. Aborting',count));
                                end
                        end

                        % Compare q(x) 
                        test.q = feval(DAE.q, vecX, DAE);
                        ref_q = feval(ref.DAE.q, vecX, ref.DAE);
                        % Need to pass through a loop
                        for count = 1:1:test.DAE_nunks
                                pass_or_fail = (test.q(count,1) == ref_q(count,1)); % are they same?
                                if pass_or_fail 
                                        if MsgDisplay 
                                                print_success(sprintf('Comparing q(%d,1)',count));
                                        end
                                else
                                        print_failure(sprintf('Comparing q(%d,1)',count));
                                        fprintf(1,'vecX=\n');
                                        disp(vecX)
                                        fprintf(1,'vecU=\n');
                                        disp(vecU)
                                        fprintf(1,'testDAE.q_out(%d) is %d\n',count,test.q(count));
                                        fprintf(1,'refDAE.q_out(%d) is %d\n',count,ref_q(count));
                                        error(sprintf('q(%d) are not same. Aborting',count));
                                end
                        end

                        % Compare df_dx(x,u)
                        test.df_dx = feval(DAE.df_dx, vecX, vecU, DAE);
                        ref_df_dx = feval(ref.DAE.df_dx, vecX, vecU, ref.DAE);
                        % Need to pass through a loop
                        for count1 = 1:1:test.DAE_nunks
                                for count2 = 1:1:test.DAE_nunks
                                        pass_or_fail = (test.df_dx(count1,count2) == ref_df_dx(count1,count2)); % are they same?
                                        if pass_or_fail 
                                                if MsgDisplay 
                                                        print_success(sprintf('Comparing df_dx(%d,%d)',count1,count2));
                                                end
                                        else
                                                print_failure(sprintf('Comparing df_dx(%d,%d)',count1,count2));
                                                fprintf(1,'vecX=\n');
                                                disp(vecX)
                                                fprintf(1,'vecU=\n');
                                                disp(vecU)
                                                fprintf(1,'testDAE.df_dx_out(%d,%d) is %d\n',count1,count2,test.df_dx(count1,count2));
                                                fprintf(1,'refDAE.df_dx_out(%d,%d) is %d\n',count1,count2,ref_df_dx(count1,count2));
                                                error(sprintf('df_dx(%d,%d) are not same. Aborting',count1,count2));
                                        end
                                end
                        end

                        % Compare df_du(x,u)
                        test.df_du = feval(DAE.df_du, vecX, vecU, DAE);
                        ref_df_du = feval(ref.DAE.df_du, vecX, vecU, ref.DAE);
                        % Need to pass through a loop
                        for count1 = 1:1:test.DAE_nunks
                                for count2 = 1:1:test.DAE_ninputs
                                        pass_or_fail = (test.df_du(count1,count2) == ref_df_du(count1,count2)); % are they same?
                                        if pass_or_fail 
                                                if MsgDisplay 
                                                        print_success(sprintf('Comparing df_du(%d,%d)',count1,count2));
                                                end
                                        else
                                                print_failure(sprintf('Comparing df_du(%d,%d)',count1,count2));
                                                fprintf(1,'vecX=\n');
                                                disp(vecX)
                                                fprintf(1,'vecU=\n');
                                                disp(vecU)
                                                fprintf(1,'testDAE.df_du(%d,%d) is %d\n',count1,count2,test.df_du(count1,count2));
                                                fprintf(1,'refDAE.df_du(%d,%d) is %d\n',count1,count2,ref_df_du(count1,count2));
                                                error(sprintf('df_du(%d,%d) are not same. Aborting',count1,count2));
                                        end
                                end
                        end

                        % Compare dq_dx(x)
                        test.dq_dx = feval(DAE.dq_dx, vecX, DAE);
                        ref_dq_dx = feval(ref.DAE.dq_dx, vecX, ref.DAE);
                        % Need to pass through a loop
                        for count1 = 1:1:test.DAE_nunks
                                for count2 = 1:1:test.DAE_nunks
                                        pass_or_fail = (test.dq_dx(count1,count2) == ref_dq_dx(count1,count2)); % are they same?
                                        if pass_or_fail 
                                                if MsgDisplay 
                                                        print_success(sprintf('Comparing dq_dx(%d,%d)',count1,count2));
                                                end
                                        else
                                                print_failure(sprintf('Comparing dq_dx(%d,%d)',count1,count2));
                                                fprintf(1,'vecX=\n');
                                                disp(vecX)
                                                fprintf(1,'vecU=\n');
                                                disp(vecU)
                                                fprintf(1,'testDAE.dq_dx(%d,%d) is %d\n',count1,count2,test.dq_dx(count1,count2));
                                                fprintf(1,'refDAE.dq_dx_out(%d,%d) is %d\n',count1,count2,ref_dq_dx(count1,count2));
                                                error(sprintf('dq_dx(%d,%d) are not same. Aborting',count1,count2));
                                        end
                                end
                        end
%{
                        % Compare df_dp(x,u)
                        test.df_dp = feval(DAE.df_dp, vecX, DAE);
                        ref_df_dp = feval(ref.DAE.df_dp, vecX, ref.DAE);
                        % Need to pass through a loop
                        for count1 = 1:1:test.DAE_nunks
                                for count2 = 1:1:test.DAE_nparms
                                        pass_or_fail = (test.df_dp(count1,count2) == ref_df_dp(count1,count2)); % are they same?
                                        if pass_or_fail 
                                                if MsgDisplay 
                                                        print_success(sprintf('Comparing df_dp(%d,%d)',count1,count2));
                                                end
                                        else
                                                print_failure(sprintf('Comparing df_dp(%d,%d)',count1,count2));
                                                fprintf(1,'vecX=\n');
                                                disp(vecX)
                                                fprintf(1,'vecU=\n');
                                                disp(vecU)
                                                fprintf(1,'testDAE.df_dp(%d,%d) is %d\n',count1,count2,test.df_dp(count1,count2));
                                                fprintf(1,'refDAE.df_dp_out(%d,%d) is %d\n',count1,count2,ref_df_dp(count1,count2));
                                                error(sprintf('df_dp(%d,%d) are not same. Aborting',count1,count2));
                                        end
                                end
                        end

                        % Compare dq_dp(x,u)
                        test.dq_dp = feval(DAE.dq_dp, vecX, DAE);
                        ref_dq_dp = feval(ref.DAE.dq_dp, vecX, ref.DAE);
                        % Need to pass through a loop
                        for count1 = 1:1:test.DAE_nunks
                                for count2 = 1:1:test.DAE_nparms
                                        pass_or_fail = (test.dq_dp(count1,count2) == ref_dq_dp(count1,count2)); % are they same?
                                        if pass_or_fail 
                                                if MsgDisplay 
                                                        print_success(sprintf('Comparing dq_dp(%d,%d)',count1,count2));
                                                end
                                        else
                                                print_failure(sprintf('Comparing dq_dp(%d,%d)',count1,count2));
                                                fprintf(1,'vecX=\n');
                                                disp(vecX)
                                                fprintf(1,'vecU=\n');
                                                disp(vecU)
                                                fprintf(1,'testDAE.dq_dp(%d,%d) is %d\n',count1,count2,test.dq_dp(count1,count2));
                                                fprintf(1,'refDAE.dq_dp_out(%d,%d) is %d\n',count1,count2,ref_dq_dp(count1,count2));
                                                error(sprintf('dq_dp(%d,%d) are not same. Aborting',count1,count2));
                                        end
                                end
                        end
                        %}

                        % NO NEED TO COMPARE dfq_dp 

                end
                   oof = sprintf('Comparison of DAEAPI test data and ref.data');
                   print_success(oof);
        else
                % Check all the functions by making a call to it
                % <TODO> :Error try/exception here??
                test.DAE_nunks = feval(DAE.nunks,DAE); % no of unks in test DAE
                test.DAE_neqns = feval(DAE.neqns,DAE); % no of equns in test DAE
                test.DAE_ninputs = feval(DAE.ninputs,DAE); % no of inputs in test DAE
                test.DAE_noutputs = feval(DAE.noutputs,DAE); % no of outputs in test DAE
                test.DAE_nparms = feval(DAE.nparms,DAE); % no of parms in test DAE
                test.f_takes_inputs = DAE.f_takes_inputs; % f_takes_inputs in test DAE
                test.uniqID = feval(DAE.uniqID,DAE); % uniqID string in test DAE
                test.daename = feval(DAE.daename,DAE); % daename string in test DAE
                test.unknames = feval(DAE.unknames,DAE); % unknames cell array in test DAE
                test.eqnnames = feval(DAE.eqnnames,DAE); % eqnnames cell array in test DAE
                test.inputnames = feval(DAE.inputnames,DAE); % inputnames cell array in test DAE
                test.outputnames = feval(DAE.outputnames,DAE); % outputnames cell array in test DAE
                test.parmnames = feval(DAE.parmnames,DAE); % parmnames cell array in test DAE
                test.parmdefaults = feval(DAE.parmdefaults,DAE); % parmdefaults cell array in test DAE
                test.B = feval(DAE.B, DAE);
                test.C = feval(DAE.C, DAE);
                test.D = feval(DAE.D, DAE);
                test.time_unit = DAE.time_units; % time unit in test DAE
                test.nNoiseSources = feval(DAE.nNoiseSources,DAE); % no. of noise sources in test DAE
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %DYNAMIC TESTING
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                %===========================================================
                %   dynamic tests: test fe, qe, fi, qi on different cases
                %         test init/limiting
                %   random  tests: test fe, qe, fi, qi on random cases
                %         test init/limiting
                %===========================================================
                random_check = 0;

                for count = 1:1: (ntest.n_dynamic+ntest.n_random)
                        if count > ntest.n_dynamic
                                random_check =1;
                        end
                        if random_check == 0
                                rand('seed',  etime(clock, [1900, 1, 1, 0, 0, 0]));
                                %fprintf(1, '--------------------------------------------\n');
                                %fprintf(1, '      random testing on case %d             \n', count);
                                vecX = rand(test.DAE_nunks,1);
                                vecU = rand(test.DAE_ninputs,1);
                                % old for NRlimiting
                                vecXold = rand(test.DAE_nunks,1);
                                tt = rand(1,1); % random time for utfunc
                                fff = rand(1,1); % random freq for Uffunc 
                                ffHB = rand(1,1);% random freq. for uHBfunc
                                ref.vecX(:,count) = vecX;
                                ref.vecU(:,count) = vecU;
                                % vecXold for NRlimiting
                                ref.vecXold(:,count) = vecXold;
                                ref.tt(:,count) = tt; % random time sample for utfunc_default
                                ref.fff(:,count) = fff; % random freq for Uffunc_default
                                ref.ffHB(:,count) = ffHB; % random freq samples for uHBfunc_default
                        else
                                rand('seed',  etime(clock, [1900, 1, 1, 0, 0, 0]));
                                %fprintf(1, '--------------------------------------------\n');
                                %fprintf(1, '      random testing on case %d             \n', count);
                                vecX = rand(test.DAE_nunks,1);
                                vecU = rand(test.DAE_ninputs,1);
                                % old for NRlimiting
                                vecXold = rand(test.DAE_nunks,1);
                                tt = rand(1,1); % random time for utfunc
                                fff = rand(1,1); % random freq for Uffunc 
                                ffHB = rand(1,1);% random freq. for uHBfunc
                        end

                        test.utfunc_default = feval(DAE.utfunc_default, tt,DAE);
                        test.Uffunc_default = feval(DAE.Uffunc_default, fff, DAE);
                        test.uHBfunc_default = feval(DAE.uHBfunc_default, fff, DAE);
                        test.QSSinitGuess_out = feval(DAE.QSSinitGuess,vecU,DAE);
                        test.NRlimiting_out = feval(DAE.NRlimiting,vecX-vecXold,vecXold,vecU,DAE);
                        test.f = feval(DAE.f, vecX, vecU, DAE);
                        test.q = feval(DAE.q, vecX, DAE);
                        test.df_dx = feval(DAE.df_dx, vecX, vecU, DAE);
                        test.df_du = feval(DAE.df_du, vecX, vecU, DAE);
                        test.dq_dx = feval(DAE.dq_dx, vecX, DAE);
                        %test.df_dp = feval(DAE.df_dp, vecX,vecU, [],DAE);
                        %test.dq_dp = feval(DAE.dq_dp, vecX,[],DAE);
                        % Save ref here
                        % No need to save the computed outputs. They will be recalcualted when doing testing
                        % The input data (vecX,vecXold, vecU,tt,ffHB,fff) are already saved
                end
                        ref.DAE = DAE;
                        save(filename,'ref');
                   oof = sprintf('Updated DAEAPI reference test data');
                   print_success(oof);
        end
end


function out = is_equal(a,b)
% Just equals for time being
out = (a==b);
end

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

function out = compare_waveform(waveform1,waveform2); %,abstol,reltol)
        %TODO: pass reltol and abstol
abstol=1e-9; reltol=1e-6;
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
