function [successOrFailure,testOutcome] = MAPPtest_DCSweep(test,updateCompareOrShowresults)
%MAPPtest_DCSweep(test,updateCompareOrShowresults)
%  
%Introduction
%------------
%    MAPPtest_DCSweep performs DCSweep tests.
%
%Input argument
%--------------
%    testsToRun: (optional) [TODO] documentation
%    
%    compareUpdateOrShowresults: (optional) [TODO] documentation
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
%    MAPPtest, MAPPtest_transient, MAPPtest_AC, defaultMAPPtests
%

%Changelog:
%- 2015/01/14: JR: added showresults support.
%- original presumably by Bichen - he did not bother to put in an Author line.

    successOrFailure = 0;
    testOutcome.msgSummary = '';
    testOutcome.msgDetailed = '';
    testOutcome.comparisonInfo = [];


    dataFileName = test.refFile; 

    %Define all the fields locally
    DAE = test.DAE;
    NRparms = test.args.NRparms;
    initGuess = test.args.initGuess;
    QSSInputs = test.args.QSSInputs;
    whereToSaveData=[];

    if strcmp(updateCompareOrShowresults,'compare')
        script_task = 'compare';
        % But, first check if there is the required testdata file
        if ~exist(dataFileName,'file')
            testOutcome.msgSummary = sprintf('ERROR: Reference file %s not found.',dataFileName);
            testOutcome.msgDetailed = 'Did you run this test in ''update'' mode first?';
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

    elseif strcmp(updateCompareOrShowresults,'update')
        if isfield(test,'whereToSaveData')
            whereToSaveData=strcat(test.whereToSaveData,'/');
        end
        script_task = 'update'; 

    elseif strcmp(updateCompareOrShowresults,'showresults')
        script_task = 'showresults'; 
    else
        testOutcome.msgSummary = 'Illegal mode: This script should be run only in ''compare'', ''showresults'' or ''update'' mode.\n';
        testOutcome.msgDetailed = testOutcome.msgSummary;
        return;
    end % if strcmp(updateCompareOrShowresults,'compare')

    if strcmp(script_task,'compare')

        % compare DAEs
        [DAEsMatch, cinfo] = compareDAEs(DAE, ref.DAE);
        if DAEsMatch <= 0.5
            testOutcome.msgSummary = ['ERROR: ', cinfo.msg];
            testOutcome.msgDetailed = '';
            return;
        end

        % Compare the QSSInputs sizes (rows, i.e. no. of sweep steps)
        QSSInput_size = size(QSSInputs,1);
        ref_QSSInput_size = size(ref.QSSInputs,1);
        passOrFail = abs(QSSInput_size - ref_QSSInput_size) <= 1e-9;
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: QSS input sizes don''t match';
            testOutcome.msgDetailed = '';
            return;
        end

        % Determine the QSSInputs 
        n_inputs = feval(DAE.ninputs,DAE);
        input_names = feval(DAE.inputnames,DAE);

        for count1 = 1: 1: QSSInput_size
            for count2 = 1 : 1 : n_inputs 
                passOrFail = abs(QSSInputs(count1,count2) - ref.QSSInputs(count1,count2)) <= 1e-9; 
                if passOrFail < 0.5
                    testOutcome.msgSummary = sprintf('ERROR: QSSInputs don''t match at idx (%d,%d)',count1,count2);
                    testOutcome.msgDetailed = [sprintf('test QSSInputs(%d,%d): %d\n',count1,count2,QSSInputs(count1,count2)), sprintf('ref QSSInputs(%d,%d): %d',count1,count2,ref.QSSInputs(count1,count2))];
                    return;
                end
            end
        end % Loop End: pass through all QSSInput


    %{
        % Compare the initGuess 
        for count = 1 : 1 : length(initGuess)
            passOrFail = abs(initGuess(count) - ref.initGuess(count)) <= 1e-9;
            if passOrFail < 0.5
                testOutcome.msgSummary = 'ERROR: initGuesses don''t match';
                testOutcome.msgDetailed = [sprintf('test initGuess(%d): %d\n',count,initGuess(count)), sprintf('ref initGuess(%d): %d',count,ref.initGuess(count))] ;
                return;
            end
        end
    %}

        % Compare NRparams.maxiter 
        passOrFail = abs(NRparms.maxiter - ref.NRparms.maxiter) <= 1e-9; 
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: NRparms.maxiters don''t match';
            testOutcome.msgDetailed = [sprintf('test NRparms.maxiter: %d\n',NRparms.maxiter), sprintf('ref NRparms.maxiter: %d\n',ref.NRparms.maxiter)];
            return;
        end

        % Compare NRparams.abstol
        passOrFail = abs(NRparms.abstol - ref.NRparms.abstol) <= 1e-15; 
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: NRparms.abstols don''t match';
            testOutcome.msgDetailed = [sprintf('test NRparms.abstol: %d\n',NRparms.abstol), sprintf('ref NRparms.abstol: %d\n',ref.NRparms.abstol)];
            return;
        end

        % Compare NRparams.reltol 
        passOrFail = abs(NRparms.reltol - ref.NRparms.reltol) <= 1e-15; 
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: NRparms.reltols don''t match';
            testOutcome.msgDetailed = [sprintf('test NRparms.reltol: %d\n',NRparms.reltol), sprintf('ref NRparms.reltol: %d\n',ref.NRparms.reltol)];
            return;
        end

        % Compare NRparams.residualtol 
        passOrFail = abs(NRparms.residualtol - ref.NRparms.residualtol) <= 1e-15; 
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: NRparms.residualtols don''t match';
            testOutcome.msgDetailed = [sprintf('test NRparms.residualtol: %d\n',NRparms.residualtol), sprintf('ref NRparms.residualtol: %d\n',ref.NRparms.residualtol)];
            return;
        end

        % Compare NRparams.limiting 
        passOrFail = abs(NRparms.limiting - ref.NRparms.limiting) < 1e-9; 
        if passOrFail < 0.5
            testOutcome.msgSummary = 'ERROR: NRparms.limitings don''t match';
            testOutcome.msgDetailed = [sprintf('test NRparms.limiting: %d\n',NRparms.limiting), sprintf('ref NRparms.limiting: %d\n',ref.NRparms.limiting)];
            return;
        end

    end % if strcmp(script_task,'compare')

    % TODO : Remove later
    %{ 
    n_inputs = feval(DAE.ninputs,DAE);
    if abs(n_inputs,1) <=1e-9 
        % Assumes that there is atleast on QSSInputs{1} field present in
        % test.args
        INs = QSSInputs{1};
    else
        INs = QSSInput{n_input};
        for count = n_input: (-1): 2 %1: 1: n_input-1 %BEGIN: Build the input grid
            INs = createOrderedMatrix(QSSInput{count-1},INs);
        end % END: Build the input grid
    end
    %}

    % The actual DC sweep code 
    %try 

    OUTs = []; OUTsState = [];
    initGuess_loop = initGuess; % Init guess for each pass through the DC sweep 'for' loop
    for count = 1:size(QSSInputs,1)
        IN = QSSInputs(count,:);
        DAE = feval(DAE.set_uQSS, IN.', DAE);
        QSSobj = QSS(DAE, NRparms);
        QSSobj = feval(QSSobj.solve, initGuess_loop, QSSobj); % JR: more more initguess needed
        % QSSobj = feval(QSSobj.solve, QSSobj); % JR: more more initguess needed
        [sol, iters, success] = feval(QSSobj.getSolution, QSSobj);
        if ((success <= 0) || sum(NaN == sol))
            % fprintf(1, 'QSS failed  at IN=%g\nre-running with NR progress enabled\n', IN);
            % NRparms.dbglvl = 2;
            % QSSobj = feval(QSSobj.setNRparms, NRparms, QSSobj);
            % QSSobj = feval(QSSobj.solve,initGuess_intd,QSSobj);
            testOutcome.msgSummary = sprintf('QSS failed at IN=%g', IN);
            testOutcome.msgDetailed = testOutcome.msgSummary; 
            return;
        else
            % TODO: Could compare unknowns instead of outputs
            % OUTs(count,:) = sol;
            OUTs(count,:) = feval(DAE.C, DAE)*sol + feval(DAE.D, DAE)*IN.'; % DAE-defined outputs
            OUTsState(count,:) = sol; % all state outputs
            initGuess_loop = sol;
        end
    end

    %catch err
    %        fprintf(2, 'heere2\n')

    %    testOutcome.msgSummary = 'ERROR in running DC analysis';
    %    testOutcome.msgDetailed = err.message;
    %    return;

    %end % try/catch

    %C = feval(DAE.C,DAE);
    %noutputs = size(C,1); % ie, no of rows of C
    o_names = feval(DAE.outputnames,DAE);
    noutputs = length(o_names); % DAE-defined outputs

    % Compare output 
    if strcmp(script_task,'compare')

        for count1 = 1: 1: size(OUTs,1)
            for count2 = 1 : 1 : noutputs
                [passOrFail,comparisonInfo] = isEqual(OUTs(count1,count2),ref.OUTs(count1,count2), compareParms.abstol,compareParms.reltol);
                if passOrFail < 0.5
                    testOutcome.msgSummary = sprintf('ERROR: outputs (%s) don''t match at sweep step %d', o_names{count2}, count1);
                    testOutcome.msgDetailed = [ sprintf('test DAE output: %d\n', OUTs(count1,count2)), sprintf('ref DAE output : %d\n', ref.OUTs(count1,count2)), 'inputs: [' sprintf('%g',QSSInputs(count1,:))  ']' ];
                    return;
                end
            end
        end

        successOrFailure = 1;

    elseif strcmp(script_task,'showresults') % if strcmp(script_task,'compare')

        onames = feval(DAE.outputnames, DAE);
        unknames = feval(DAE.unknames, DAE);
        DAEname = feval(DAE.daename, DAE);
        inames = feval(DAE.inputnames, DAE);

        % print all DAE-defined and state outputs
        for count = 1:size(QSSInputs, 1)
            fprintf(2, 'input set %d:\n', count)
            for inputidx=1:length(inames)
                fprintf('\t%s: %0.16g\n', inames{inputidx}, ...
                            QSSInputs(count, inputidx));
            end
            fprintf(2, 'DAE-defined outputs for input set %d:\n', count)
            for idx=1:length(onames)
                fprintf('\t%s: %0.16g\n', onames{idx}, ...
                                        OUTs(count, idx));
            end
            fprintf(2, 'All state outputs for input set %d:\n', count)
            for idx=1:length(unknames)
                fprintf('\t%s: %0.16g\n', unknames{idx}, OUTsState(count, idx));
            end
            fprintf(2, '--------------------------------------------------------\n\n');
        end

        if size(QSSInputs, 1) > 1
            % plot all DAE-defined outputs as a function of the count index
            figure(); hold on;
            xlabel('index of input set');
            ylabel('output values');

                format long e
                QSSInputs
                OUTs
            for i = 1:length(onames)
                col = getcolorfromindex(gca, i);
                plot(1:size(QSSInputs,1), OUTs(:,i), '.-', 'Color', col);
            end
            legend(onames);
            grid on; axis tight;
            title(sprintf('%s: DC sweep: DAE outputs vs input set index', DAEname));
            drawnow;

            % plot all sate outputs as a function of the count index
            figure(); hold on;
            xlabel('index of input set');
            ylabel('output values');

            for i = 1:length(unknames)
                col = getcolorfromindex(gca, i);
                plot(1:size(QSSInputs,1), OUTsState(:,i), '.-', 'Color', col);
            end
            legend(unknames);
            grid on; axis tight;
            title(sprintf('%s: DC sweep: all state outputs vs input set index', DAEname));
            drawnow;
        end % if size(QSSInputs, 1) > 1

    else % 'update': if strcmp(script_task,'compare')
        %save everything
        newDAE.Nunks = feval(DAE.nunks, DAE);
        newDAE.UnkNames = feval(DAE.unknames, DAE);
        newDAE.Ninputs = feval(DAE.ninputs, DAE);
        newDAE.InputNames = feval(DAE.inputnames, DAE);
        newDAE.Nparms = feval(DAE.nparms, DAE);
        newDAE.ParmNames = feval(DAE.parmnames, DAE);
        newDAE.Parms = feval(DAE.getparms, DAE);
        ref.DAE = newDAE;
        ref.NRparms = NRparms;
        ref.initGuess = initGuess;
        ref.QSSInputs = QSSInputs;
        ref.OUTs = OUTs;
        updateDataFileName=strcat(whereToSaveData,dataFileName); 
        save(updateDataFileName,'ref');
    if isempty(whereToSaveData)
            fprintf('Updated Data saved under current path \n%s\n\n',updateDataFileName);
    else
            fprintf('Updated Data saved as \n%s\nPlease commit to git to backup.\n\n',updateDataFileName);
    end
        successOrFailure = 1;
    end
end

