function [successOrFailure, testOutcome] = MAPPtest_transient (test, updateCompareOrShowresults)
%MAPPtest_transient(test,updateCompareOrShowresults)
%  
%Introduction
%------------
%    MAPPtest_transient performs transient simulation tests. 
%
%Input arguments
%---------------
%    testsToRun: (optional)               [TODO]
%    
%    compareUpdateOrShowresults: (optional) [TODO]
%
%Outputs
%-------
%    -successOrFailure   - 1 or 0.
%
%       In update mode, the function returns 1 if it successfully creates
%       reference data, or 0 otherwise.
%       
%       In compare mode, the function returns 1 if simulation result matches
%       reference data, else returns 0.
%
%    -testOutcome        
%       A struct containing the test result. It includes the following fields:
%           - msgSummary: brief summary of the test result
%           - msgDetailed: detailed summary whenever applicable
%           - comparisonInfo: results of comparing the simulation and reference
%             waveforms.
%
%See Also
%--------
%    MAPPtest, MAPPtest_DCSweep, MAPPtest_AC, defaultMAPPtests
%

%Changelog:
%- 2015/01/14: JR: added showresults support.
%- original presumably by Bichen - he did not bother to put in an Author line.

    successOrFailure = 0;
    testOutcome.msgDetailed = '';
    testOutcome.msgSummary = '';

    dataFileName = test.refFile;
    whereToSaveData=[];
    errfile = ['FAILED-MAPPtest-transient-', dataFileName];

    % define fields locally
    DAE = test.DAE;
    if isfield (test.args, 'LMSMethod')
        LMSMethod = test.args.LMSMethod;
    else
        LMSMethod = 'BE';
    end
    xinit = test.args.xinit;
    tstart = test.args.tstart;
    tstep = test.args.tstep;
    tstop = test.args.tstop;
    tranparms = test.args.tranparms;
    
    if strcmp (updateCompareOrShowresults, 'compare')
        
        script_task = 'compare';
        
        % check if there is the required testdata file
        if ~exist(dataFileName,'file')
            testOutcome.msgSummary = sprintf('ERROR: Reference file %s not found for comparison.', dataFileName);
            testOutcome.msgDetailed = sprintf('Did you run this test successfully in ''update'' mode first?');
            return;
        end

        load(dataFileName);

        if isfield(test.args,'comparisonAbstol')
            compareParms.abstol = test.args.comparisonAbstol;
        else
            compareParms.abstol=1e-9;
        end

        if isfield(test.args,'comparisonReltol')
            compareParms.reltol = test.args.comparisonReltol;
        else
            compareParms.reltol=1e-3;
        end

    elseif strcmp (updateCompareOrShowresults, 'update')
        if isfield(test,'whereToSaveData')
            whereToSaveData=strcat(test.whereToSaveData,'/');
        end
        script_task = 'update';

    elseif strcmp (updateCompareOrShowresults, 'showresults')
        script_task = 'showresults';

    else % strcmp (updateCompareOrShowresults, 'compare')
        
        testOutcome.msgSummary = 'ERROR: Illegal mode: Should be ''update'' or ''compare''.';
        testOutcome.msgDetailed = '';
        return;

    end
    
    % check if LMS method supplied is valid
    TRmethods = LMSmethods();
    try 
        eval(['TRmethod = TRmethods.', LMSMethod, ';']);
    catch err
        testOutcome.msgSummary = 'ERROR: Illegal LMS method.';
        testOutcome.msgDetailed = testOutcome.msgSummary;
        return;
    end

    % Create transient object
    TransObj = LMS(DAE,TRmethod,tranparms);
    
    if strcmp (script_task, 'compare')
        
        % compare DAEs
        [DAEsMatch, cinfo] = compareDAEs(DAE, ref.DAE);
        if DAEsMatch <= 0.5
            testOutcome.msgSummary = ['ERROR: ', cinfo.msg];
            testOutcome.msgDetailed = '';
            return;
        end

        % compare tran inputs
        tt = tstart:tstep:tstop;

        n_inputs = feval(DAE.ninputs,DAE);
        input_names = feval(DAE.inputnames,DAE);
        utrans = feval(DAE.utransient,tt,DAE);
        %ref_utrans = feval(ref.DAE.utransient,tt,ref.DAE);
        ref_utrans = ref.DAE.uTrans;

        for count = 1 : 1 : n_inputs

            [passOrFail, comparisonInfo] = compare_waveforms ( [tt;utrans(count,:)], [tt;ref_utrans(count,:)], compareParms );

            if passOrFail < 0.5
                % DAE transient inputs did not match
                testOutcome.msgSummary = 'ERROR: DAE transient inputs don''t match';
                
                oof = sprintf('\tu_transient: %s', input_names{count});

                if passOrFail < - 0.5
                    % compare_waveforms did not successfully complete
                    oof = [oof, '\n', sprintf('\tERROR running compare_waveforms()')];
                else
                    testInfo.msg = testOutcome.msgSummary;
                    testInfo.comparisonInfo = comparisonInfo;
                    save(errfile, 'testInfo');

                    oof = [oof, '\n', '\tSee testInfo in file ', errfile, ' for details'];
                end

                testOutcome.msgDetailed = oof;
                return;

            end

        end

        % compare LMS methods 
        user_supplied_TRmethod = TransObj.TRmethod.name;
        ref_supplied_TRmethod = ref.TransObj.TRmethod.name;
        passOrFail = strcmp (user_supplied_TRmethod, ref_supplied_TRmethod);

        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: DAE Tran LMS methods don''t match';
            testOutcome.msgDetailed =  [sprintf('The user supplied LMS method is %s\n', user_supplied_TRmethod), sprintf('The reference LMS method is %s', ref_supplied_TRmethod)];
            return;
        end
    
        % compare tranparms
        [passOrFail, msg] = compare_tranparms (TransObj.tranparms, ref.TransObj.tranparms);
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: tranparms don''t match';
            testOutcome.msgDetailed = msg;
            return;
        end

        % compare xinits
        for count = 1 : 1 : length(xinit)
            if abs(xinit(count) -  ref.xinit(count)) >= 1e-9
                testOutcome.msgSummary = 'ERROR: tran initial conditions don''t match';
                testOutcome.msgDetailed = ['Mismatch in xinit(', count, '): test = ', num2str(xinit(count)), ', ref = ', num2str(ref.xinit(count))];
                return;
            end
        end
        
        % compare tstarts
        passOrFail = (abs(tstart - ref.tstart) <= 1e-12);
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: tran tstarts don''t match';
            testOutcome.msgDetailed = ['Mismatch in tstart: test = ', num2str(tstart), ', ref = ', num2str(ref.tstart)];
            return;
        end
 
        % compare tsteps
        passOrFail = (abs(tstep - ref.tstep) <= 1e-12);
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: tran tsteps don''t match';
            testOutcome.msgDetailed = ['Mismatch in tstep: test = ', num2str(tstep), ', ref = ', num2str(ref.tstep)];
            return;
        end

        % compare tstops
        passOrFail = (abs(tstop - ref.tstop) <= 1e-12);
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: tran tstops don''t match';
            testOutcome.msgDetailed = ['Mismatch in tstop: test = ', num2str(tstop), ', ref = ', num2str(ref.tstop)];
            return;
        end

    end % if strcmp (script_task, 'compare')

    % do the transient simulation
    TransObj = feval ( TransObj.solve, TransObj, xinit, tstart, tstep, tstop );
    
    if strcmp (script_task, 'compare')
        
        % compare tran outputs
        unk_names = feval (DAE.unknames, DAE);
        no_of_unknowns = feval (DAE.nunks, DAE);

        for count = 1 : 1 : no_of_unknowns
              
            % Compare simulation outputs
            [passOrFail, comparisonInfo] = compare_waveforms([TransObj.tpts; TransObj.vals(count,:)], [ref.TransObj.tpts; ref.TransObj.vals(count,:) ],compareParms);

            if passOrFail < 0.5
                % DAE outputs did not match
                testOutcome.msgSummary = ['ERROR: DAE transient outputs ', unk_names{count}, ' don''t match'];
                
                if passOrFail < - 0.5
                    % compare_waveforms did not successfully complete
                    oof = sprintf('\tERROR running compare_waveforms()');
                else
                    testInfo.msg = testOutcome.msgSummary;
                    testInfo.comparisonInfo = comparisonInfo;
                    save (errfile, 'testInfo');

                    oof = ['\tSee testInfo in file ', errfile, ' for details'];
                end

                testOutcome.msgDetailed = oof;
                return;

            end

        end

        successOrFailure = 1;

    elseif strcmp(script_task, 'showresults')

        % plot DAE-defined outputs
        feval(TransObj.plot, TransObj);

        % plot all state outputs
        souts = StateOutputs(DAE);
        feval(TransObj.plot, TransObj, souts);
        successOrFailure = 1;

    else % 'update' if strcmp (script_task, 'compare')

        %save everything
        newDAE.Nunks = feval(DAE.nunks, DAE);
        newDAE.UnkNames = feval(DAE.unknames, DAE);
        newDAE.Ninputs = feval(DAE.ninputs, DAE);
        newDAE.InputNames = feval(DAE.inputnames, DAE);
        newDAE.Nparms = feval(DAE.nparms, DAE);
        newDAE.ParmNames = feval(DAE.parmnames, DAE);
        newDAE.Parms = feval(DAE.getparms, DAE);
        tt = tstart:tstep:tstop;
        newDAE.uTrans = feval(DAE.utransient,tt,DAE);
        ref.DAE = newDAE;
        newTransObj.TRmethod.name = TransObj.TRmethod.name;
        newTransObj.tranparms = TransObj.tranparms;
        newTransObj.tpts = TransObj.tpts;
        newTransObj.vals = TransObj.vals;
        ref.TransObj = newTransObj;
        ref.LMSMethod = LMSMethod;
        ref.xinit = test.args.xinit;
        ref.tstart = test.args.tstart;
        ref.tstep = test.args.tstep;
        ref.tstop = test.args.tstop;
        dataFileName=strcat(whereToSaveData,dataFileName);
        save(dataFileName,'ref');
        if isempty(whereToSaveData)
                fprintf('Updated Data saved under current path \n%s\n\n',dataFileName);
        else
                fprintf('Updated Data saved as \n%s\nPlease commit svn to backup.\n\n',dataFileName);
        end
        successOrFailure = 1;

    end

end

function [out, msg] = compare_two_things (testthing, refthing, abstol, reltol, thingname)
    
    [out, cinfo] = isEqual(testthing, refthing, abstol, reltol);
    
    if out < 0.5
        msg = ['Mismatch in ', thingname, '(test: ', str(testthing), ', ref: ', str(refthing), ')'];
    else
        msg = '';
    end

end

function [out, msg] = compare_tranparms (tranparms, ref_tranparms, compareParms)
    
    % Comparison of two tranparms objects
    % The tranparms object (a MATLAB structure is assumed to have 13
    % fields/sub-fields.
    thingname = 'NRparms.maxiter';
    [out,msg] = compare_two_things(tranparms.NRparms.maxiter, ref_tranparms.NRparms.maxiter, 0.01, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'NRparms.reltol';
    [out,msg] = compare_two_things(tranparms.NRparms.reltol, ref_tranparms.NRparms.reltol, 1e-6, 0, thingname);
 
    if out < 0.5
        return;
    end   

    thingname = 'NRparms.abstol';
    [out,msg] = compare_two_things(tranparms.NRparms.abstol, ref_tranparms.NRparms.abstol, 1e-12, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'NRparms.residualtol';
    [out,msg] = compare_two_things(tranparms.NRparms.residualtol, ref_tranparms.NRparms.residualtol, 1e-6, 0, thingname);
    
    if out < 0.5
        return;
    end

    thingname = 'NRparms.MPPINR_use_pinv';
    [out,msg] = compare_two_things(tranparms.NRparms.MPPINR_use_pinv, ref_tranparms.NRparms.MPPINR_use_pinv, 0.01, 0, thingname);
    
    if out < 0.5
        return;
    end

    thingname = 'NRparms.limiting';
    [out,msg] = compare_two_things(tranparms.NRparms.limiting, ref_tranparms.NRparms.limiting, 0.01, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'stepControlParms.doStepControl';
    [out,msg] = compare_two_things(tranparms.stepControlParms.doStepControl, ref_tranparms.stepControlParms.doStepControl, 0.01, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'stepControlParms.NRiterRange(1)';
    [out,msg] = compare_two_things(tranparms.stepControlParms.NRiterRange(1), ref_tranparms.stepControlParms.NRiterRange(1), 0.01, 0, thingname);
    
    if out < 0.5
        return;
    end

    thingname = 'stepControlParms.NRiterRange(2)';
    [out,msg] = compare_two_things(tranparms.stepControlParms.NRiterRange(2), ref_tranparms.stepControlParms.NRiterRange(2), 0.01, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'stepControlParms.absMinStep';
    [out,msg] = compare_two_things(tranparms.stepControlParms.absMinStep, ref_tranparms.stepControlParms.absMinStep, 1e-12, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'stepControlParms.MaxStepFactor';
    [out,msg] = compare_two_things(tranparms.stepControlParms.MaxStepFactor, ref_tranparms.stepControlParms.MaxStepFactor, 1e-6, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'stepControlParms.increaseFactor';
    [out,msg] = compare_two_things(tranparms.stepControlParms.increaseFactor, ref_tranparms.stepControlParms.increaseFactor, 1e-9, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'stepControlParms.cutFactor';
    [out,msg] = compare_two_things(tranparms.stepControlParms.cutFactor, ref_tranparms.stepControlParms.cutFactor, 1e-6, 0, thingname);

    if out < 0.5
        return;
    end

    thingname = 'stepControlParms.NRfailCutFactor';
    [out,msg] = compare_two_things(tranparms.stepControlParms.NRfailCutFactor, ref_tranparms.stepControlParms.NRfailCutFactor, 1e-6, 0, thingname);

    if out < 0.5
        return;
    end

end

