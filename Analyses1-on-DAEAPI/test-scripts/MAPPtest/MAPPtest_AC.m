function [successOrFailure, testOutcome] = MAPPtest_AC(test,updateCompareOrShowresults)
%MAPPtest_AC(test,updateCompareOrShowresults)
%  
%Introduction
%------------
%    MAPPtest_AC performs AC simulation tests.
%
%Input arguments
%---------------
%    testsToRun: (optional)              
%
%    updateCompareOrShowresultscompareOrUpdate: (optional). This can be:
%    - 'compare' (default) - compares against stored reference results.
%    - 'showresults' - prints/plots the results. Useful for checking that
%                      everything is correct before running 'update'.
%    - 'update' - updates the stored test results.
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
%             data.
%
%See Also
%--------
%
%    MAPPtest, MAPPtest_DCSweep,
%    MAPPtest_transient, defaultMAPPtests
%   

%Changelog:
%- 2015/01/14: added support for 'showresults'; updated help and fixed errors - JR.
%- original written by Bichen Wu (presumably) - he did not bother to include an
%  Author line.

    successOrFailure = 0;
    testOutcome.msgDetailed = '';
    testOutcome.msgSummary = '';

    dataFileName = test.refFile;
    whereToSaveData=[];
    errfile = ['FAILED-MAPPtest-AC-', dataFileName];

    % define fields locally
    DAE = test.DAE;
    initGuess = test.args.initGuess;
    sweeptype = test.args.sweeptype;
    fstart = test.args.fstart;
    fstop = test.args.fstop;
    nsteps = test.args.nsteps;

    if strcmp (updateCompareOrShowresults, 'compare')

        script_task = 'compare';

        % check whether reference data file is present
        if ~exist(dataFileName,'file')
            testOutcome.msgSummary = sprintf('ERROR: Reference file %s not found', dataFileName);
            testOutcome.msgDetailed = sprintf('Did you run this test successfully in ''update'' mode first?');
            return;
        end

        % load variable ref from reference data file
        load(dataFileName);

        if isfield (test.args, 'comparisonAbstol')
            compareParms.abstol = test.args.comparisonAbstol;
        else
            compareParms.abstol = 1e-9;
        end

        if isfield (test.args, 'comparisonReltol')
            compareParms.reltol = test.args.comparisonReltol;
        else
            compareParms.reltol = 1e-3;
        end

    elseif strcmp(updateCompareOrShowresults,'update')
        if isfield(test,'whereToSaveData')
            whereToSaveData=strcat(test.whereToSaveData,'/');
        end
        script_task = 'update';

    elseif strcmp(updateCompareOrShowresults,'showresults')
        script_task = 'showresults';
    else
        testOutcome.msgSummary = 'ERROR: Illegal mode. Should be ''compare'', ''update'' or ''showresults''.'
        testOutcome.msgDetailed = '';
        return;

    end % if strcmp (updateCompareOrShowresults, 'compare')

    if strcmp(script_task,'compare')
        % Compare DAEs
        [DAEsMatch, cinfo] = compareDAEs (DAE, ref.DAE);
        if DAEsMatch <= 0.5 
            testOutcome.msgSummary = ['ERROR: ', cinfo.msg];
            testOutcome.msgDetailed = '';
            return;
        end

        % compare init guesses
        %user_supplied_initGuess = initGuess;
        %ref_supplied_initGuess = ref.initGuess;
        %n_unks = feval ( DAE.nunks, DAE );
        %
        %% if size(user_supplied_initGuess, 1) ~= n_unks || size(user_supplied_initGuess, 2) ~= 1
        %    testOutcome.msgSummary = 'ERROR: initial guess should be a column vector of size feval(DAE.nunks, DAE)';
        %    testOutcome.msgDetailed = '';
        %    return;
        %end
        
        %if size(ref_supplied_initGuess, 1) ~= n_unks || size(ref_supplied_initGuess, 2) ~= 1
        %    testOutcome.msgSummary = 'ERROR: reference initial guess should be a column vector of size feval(DAE.nunks, DAE)';
        %    testOutcome.msgDetailed = '';
        %    return;
        %end

        %for count = 1 : 1 : n_unks;
        %    passOrFail = abs(user_supplied_initGuess(count) - ref_supplied_initGuess(count)) <= 1e-9; 
        %    if passOrFail < 0.5
        %        testOutcome.msgSummary = ['ERROR: init. guesses for NR don''t match at index ', num2str(count)];
        %        testOutcome.msgDetailed = [ sprintf('init. guess (user supplied): %d\n', user_supplied_initGuess(count)), sprintf('init. guess (reference): %d\n',ref_supplied_initGuess(count))];
        %        return;
        %    end
        %end
        %
        % compare sweeptypes
        passOrFail = strcmpi(sweeptype, ref.sweeptype);
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: AC sweeptypes don''t match.';
            testOutcome.msgDetailed = [sprintf('The user supplied AC sweeptype is %s\n',sweeptype), sprintf('The reference AC sweeptype is %d\n',ref.sweeptype)];
            return;
        end
        
        % compare fstarts
        passOrFail = abs(fstart-ref.fstart) <= 1e-9;
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: fstarts don''t match.';
            testOutcome.msgDetailed = [sprintf('The user supplied fstart is %d\n',fstart), sprintf('The reference fstart is %d\n',ref.fstart)]; 
            return;
        end
        
        % compare fstops
        passOrFail = abs(fstop-ref.fstop) <= 1e-9;
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: fstops don''t match.';
            testOutcome.msgDetailed = [sprintf('The user supplied fstop is %d\n',fstop), sprintf('The reference fstop is %d\n',ref.fstop)]; 
            return;
        end

        % compare nsteps
        passOrFail = abs(nsteps-ref.nsteps) <= 1e-9;
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: nsteps don''t match.';
            testOutcome.msgDetailed = [sprintf('The user supplied nsteps is %d\n',nsteps), sprintf('The reference nsteps is %d\n',ref.nsteps)];
            return;
        end

        % compare AC sweep inputs
        % there are two inputs to consider
            % 1. the operating point given by feval(DAE.uQSS, DAE), and
            % 2. the input U(f) used for AC analysis, given by feval(DAE.uLTISSS, f, DAE)
        % both the above should match, between the ref DAE and the test DAE
        
        % compare uQSS
        uqss_test = feval (DAE.uQSS, DAE);
        %uqss_ref = feval (ref.DAE.uQSS, ref.DAE);
        uqss_ref = ref.DAE.uQSS;
        input_names = feval(DAE.inputnames,DAE);
        n_inputs = feval (DAE.ninputs, DAE);

        if size(uqss_test, 1) ~= n_inputs || size(uqss_test, 2) ~= 1
            testOutcome.msgSummary = 'ERROR: uQSS_test should be a column vector of size feval(DAE.ninputs, DAE)';
            testOutcome.msgDetailed = '';
            return;
        end
        
        if size(uqss_ref, 1) ~= n_inputs || size(uqss_ref, 2) ~= 1
            testOutcome.msgSummary = 'ERROR: uQSS_ref should be a column vector of size feval(DAE.ninputs, DAE)';
            testOutcome.msgDetailed = '';
            return;
        end

        for count = 1 : 1 : n_inputs;
            passOrFail = abs(uqss_test(count) - uqss_ref(count)) <= 1e-9;
            if passOrFail < 0.5
                testOutcome.msgSummary = ['ERROR: QSS inputs (', char(input_names{count}), ') don''t match at index ', num2str(count)];
                testOutcome.msgDetailed = ['test: ', num2str(uqss_test(count)), ', ref: ', num2str(uqss_ref(count))];
                return;
            end
        end
        
        % compare U(f)s

        if strcmpi(sweeptype,'LIN')
            stepsize = (fstop-fstart)/(nsteps-1);
            ff = (fstart+[0:nsteps-1]*stepsize); 
        elseif strcmpi(sweeptype,'DEC')
            nsteps2 = ceil((log10(fstop)-log10(fstart))*nsteps);
            stepsize = (log10(fstop)-log10(fstart))/nsteps2;
            ff = 10.^(log10(fstart) + (0:nsteps2)*stepsize);
        else
            testOutcome.msgSummary = 'ERROR: sweeptype should be LIN or DEC';
            testOutcome.msgDetailed = '';
            return;
        end
        
        nff = size(ff,2);
        n_inputs = feval(DAE.ninputs,DAE);
        input_names = feval(DAE.inputnames,DAE);

        for idx = 1:1:nff
            
            uf_test = DAE.uLTISSS(ff(1,idx), DAE);
            uf_ref = ref.DAE.uLTISSS(:,idx);

            if strcmpi(sweeptype, 'DEC')
                if uf_test ~= 0 
                    uf_test = log10(uf_test);
                end
                if uf_ref ~=0
                    uf_ref = log10(uf_ref);
                end
            end

            for count = 1 : 1 : n_inputs

                passOrFail = abs(uf_test(count,1) - uf_ref(count,1)) <= 1e-9;

                if passOrFail < 0.5
                    testOutcome.msgSummary = ['ERROR: LTISSS inputs (', char(input_names{count}), ') don''t match at frequency ', num2str(ff(1,idx))];
                    testOutcome.msgDetailed = ['test: ', num2str(uf_test(count)), ', ref: ', num2str(uf_ref(count))];
                    return;
                end

            end

        end

    end % if strcmp(script_task,'compare')

    % do the AC analysis

    % first get the QSS solution
    NRparms = defaultNRparms();
    NRparms.dbglvl = -1;

    qssObj = QSS(DAE, NRparms);
    qssObj = feval(qssObj.solve, initGuess, qssObj);
    % JR: successorfailure should have been set here!
    qssSol = feval(qssObj.getSolution, qssObj);

    % do AC analysis by linearizing around QSS
    % LTISSSObj = LTISSS(DAE, qssSol, qssObj.u);
    LTISSSObj = LTISSS(DAE, qssSol, feval(DAE.uQSS, DAE));
    LTISSSObj = feval(LTISSSObj.solve, fstart, fstop, nsteps, sweeptype, LTISSSObj);
    % JR: successorfailure should (perhaps) have been set here, too

    o_names = feval(DAE.outputnames,DAE);
    C = feval(DAE.C,DAE);
    D = feval(DAE.D,DAE);

    Nfreqs = length(LTISSSObj.freqs);
    noutputs = size(C,1);

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

        testOutcome.msgSummary = 'ERROR in AC analysis: 3-D solution matrix with non-singleton second dim.';
        testOutcome.msgDetailed = '';
        return;

    end

    for count = 1 : 1 : noutputs
        % Bichen: Previous implementation compares the magnitude and the phase
        % of a complex number. However, the phase() function is not very
        % reliable, because, for example, phase(-1+j*epsilon) returns pi while
        % phase(-1-j*epsilon) returns -pi. epsilon can be caused by numerical
        % deviation between different computers, and the discontinuity of
        % phase() function can cause big trouble for MAPPtest. Now try to solve
        % this problem by comparing the real and imag part the two complex
        % number.  collect mag and phase of the simulation outputs

        % mag(count,:) = abs(allHs(count,:));
        % ph(count,:) = (phase(allHs(count,:)));

        real_part(count,:) = real(allHs(count,:));
        imag_part(count,:) = imag(allHs(count,:));
    end 

    % compare outputs
    if strcmp (script_task, 'compare')

        for count = 1 : 1 : noutputs

            % compare magnitudes

            % Change log by Bichen: 01/28/2014
            % As mag(count,:) is not guaranteed to be nonzero, 
            % log operation on mag could be problematic. 
                
            % if strcmpi(sweeptype, 'LIN')
            %    x1 = LTISSSObj.freqs;
            %    y1 = mag(count,:);
            %    x2 = ref.LTISSSObj.freqs;
            %    y2 = ref.mag(count,:);
            % else
            %    x1 = log10(LTISSSObj.freqs);
            %    y1 = log10(mag(count,:));
            %    x2 = log10(ref.LTISSSObj.freqs);
            %    y2 = log10(ref.mag(count,:));
            % end

            % compare real part
             x1 = LTISSSObj.freqs;
            % y1 = mag(count,:);
            y1 = real_part(count,:);
            x2 = ref.LTISSSObj.freqs;
            % y2 = ref.mag(count,:);
            y2 = ref.real_part(count,:);

            [passOrFail, comparisonInfo] = compare_waveforms ( [x1; y1], [x2; y2], compareParms );

            if passOrFail < 0.5
                
                testOutcome.msgSummary = ['ERROR: AC analysis outputs ', o_names{count}, ' (real part) don''t match'];

                if passOrFail < - 0.5
                    % compare_waveforms did not successfully complete
                    oof = '\tERROR running compare_waveforms()';
                else
                    testInfo.msg = testOutcome.msgSummary;
                    testInfo.comparisonInfo = comparisonInfo;
                    save (errfile, 'testInfo');

                    oof = ['\tSee testInfo in file ', errfile, ' for details'];
                end

                testOutcome.msgDetailed = oof;
                return;

            end

            % compare imag part
            y1 = imag_part(count,:);
            y2 = ref.imag_part(count,:);
            [passOrFail, comparisonInfo] = compare_waveforms ( [x1; y1], [x2; y2], compareParms );

            if passOrFail < 0.5
                
                testOutcome.msgSummary = ['ERROR: AC analysis outputs ' , o_names{count}, ' (imag part) don''t match'];

                if passOrFail < - 0.5
                    % compare_waveforms did not successfully complete
                    oof = '\tERROR running compare_waveforms()';
                else
                    testInfo.msg = testOutcome.msgSummary;
                    testInfo.comparisonInfo = comparisonInfo;
                    save(errfile,'testInfo');

                    oof = ['\tSee testInfo in file ', errfile, ' for details'];
                end

                testOutCome.msgDetailed = oof;
                return;

            end

        end

        successOrFailure = 1;

    elseif strcmp(script_task, 'showresults')
        feval(qssObj.print, qssObj); % print QSS results, DAE defined outputs
        souts = StateOutputs(DAE); 
        feval(qssObj.print, souts, qssObj); % print QSS results, all state outputs
        feval(LTISSSObj.plot, LTISSSObj); % plot DAE-defined outputs
        feval(LTISSSObj.plot, LTISSSObj, souts); % plot all state outputs
        successOrFailure = 1;
    else % 'update'

        %save everything
        newDAE.Nunks = feval(DAE.nunks, DAE);
        newDAE.UnkNames = feval(DAE.unknames, DAE);
        newDAE.Ninputs = feval(DAE.ninputs, DAE);
        newDAE.InputNames = feval(DAE.inputnames, DAE);
        newDAE.Nparms = feval(DAE.nparms, DAE);
        newDAE.ParmNames = feval(DAE.parmnames, DAE);
        newDAE.Parms = feval(DAE.getparms, DAE);
        newDAE.uQSS = feval (DAE.uQSS, DAE);
        %newDAE.uLTISSS = DAE.uLTISSS(ff(1,idx), DAE);
        %DAE.uLTISSS(ff(1,idx), DAE);
        if strcmpi(sweeptype,'LIN')
            stepsize = (fstop-fstart)/(nsteps-1);
            ff = (fstart+[0:nsteps-1]*stepsize); 
        elseif strcmpi(sweeptype,'DEC')
            nsteps2 = ceil((log10(fstop)-log10(fstart))*nsteps);
            stepsize = (log10(fstop)-log10(fstart))/nsteps2;
            ff = 10.^(log10(fstart) + (0:nsteps2)*stepsize);
        end
        nff = size(ff,2);
        for idx=1:nff
            newDAE.uLTISSS(:,idx) =  DAE.uLTISSS(ff(1,idx), DAE);
        end
        ref.DAE = newDAE;
        ref.LTISSSObj.freqs = LTISSSObj.freqs;
        ref.sweeptype = sweeptype;
        ref.initGuess = initGuess;
        ref.fstart = fstart;
        ref.fstop = fstop; 
        ref.nsteps = nsteps;
        ref.real_part= real_part;
        ref.imag_part = imag_part;
        dataFileName=strcat(whereToSaveData,dataFileName);
        save (dataFileName, 'ref');
    if isempty(whereToSaveData)
            fprintf('Updated Data saved under current path \n%s\n\n', dataFileName);
    else
            fprintf('Updated Data saved as \n%s\nPlease commit svn to backup.\n\n', dataFileName);
    end
        successOrFailure = 1;
    end
end
