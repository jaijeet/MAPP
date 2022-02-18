function sensObj = DirectSensitivities(DAE, x0, pNom, tstep, TRmethod, tranparms)
% function sensObj =  DirectSensitivities(DAE, x0, pNom, tstep, TRmethod, tranparms)
% Returns an object/structure for computing sensitivities of a DAE via the
% direct method.
% 
% Run "help transens" for more information.
    sensObj = SensitivitiesSkeleton(DAE, x0, pNom, tstep, TRmethod, tranparms);

    % Values of M(t) computed so far, reshaped such that each column
    % of Ms corresponds to a different timepoint.
    sensObj.Ms = zeros(sensObj.n, sensObj.np);
    sensObj.Ms = reshape(sensObj.Ms, [], 1);

    sensObj.computeSensitivities = @computeSensitivities;
    sensObj.getSensitivities = @getSensitivities;
    sensObj.plotSensBar = @plotSensBar;
    sensObj.plotSens = @plotSens;

    function [sensObjOUT, success, compTime] = computeSensitivities(sensObj, T)
    % function [sensObjOUT, success, compTime] = computeSensitivities(sensObj, T)
    % Computes parameter sensitivities of sensObj.DAE in range [0, T]
    % 
    % INPUT args:
    %  - sensObj: DirectSensitivities structure object.
    % 
    %  - T:       End time.
    % 
    % OUTPUT:
    %  - sensObjOUT: sensObj with newly computed sensitivities. Call
    %                sensObjOUT.getSensitivities to get M(t) over a range of
    %                time.
    % 
    %  - success:    1 if sensitivities were successfully computed, <1 otherwise.
    % 
    %  - compTime:   Computation time of sensitivities (not including
    %                initial transient analysis of the original DAE).

        startIdx = length(sensObj.Ms(1));
        % Run transient analysis until time T.
        [sensObj, success, TIdx] = sensObj.runTransient(sensObj, T);
        compTime = 0;

        if success < 1
            fprintf(2, 'transens: transient solve of original DAE failed!\n');
            sensObjOUT = sensObj;
            success = 0;
            return;
        end
        if (TIdx < length(sensObj.ts)) && (T ~= sensObj.ts(TIdx))
            warning(1, 'transens: T <= sensObj.ts(end), so being changed to closest timestep already computed. ');
            warning(1, 'T has been changed from %0.4e to %0.4e.\n', T, sensObj.ts(idx));
            sensObjOUT = sensObj;
            return;
        end

        tic;

        % Solve the sensitivity DAE for M(t)
        sensLMSObj = DirectSensLMS(sensObj);
        [Ms, success] = sensLMSObj.solve(sensLMSObj, startIdx, length(sensObj.ts));

        if success < 1
            fprintf(2, 'transens: transient solve of sensitivity DAE failed!\n');
            sensObjOUT = sensObj;
            success = 0;
            return;
        end

        % Append Ms array with newly-computed results
        sensObj.Ms = [sensObj.Ms, Ms(:, 2:end)];
        sensObjOUT = sensObj;
        compTime = toc;
    %end computeSensitivities

    function [Ms, ts] = getSensitivities(sensObj, tstart, tstop)
    % function [Ms, ts] = getSensitivities(sensObj, tstart, tstop)
    % Returns values of M(t) between [tstart, tstop] and their corresponding
    % timepoints. 
    % 
    % INPUT args:
    %  - sensObj: DirectSensitivities object
    % 
    %  - tstart: start time
    % 
    %  - tstop: end time
    % 
    % OUTPUT:
    %  - Ms: values of M(t) in [tstart, tstop], stacked vertically for every
    %        timepoint
    % 
    %  - ts: timepoints at which M(t) is evaluated

        startIdx = find(sensObj.ts >= tstart, 1);
        stopIdx = find(sensObj.ts <= tstop, 1, 'last');
        if stopIdx < startIdx
            Ms = [];
            ts = [];
        else
            Ms = sensObj.Ms(:, startIdx:stopIdx);
            ts = sensObj.ts(startIdx:stopIdx);
        end
    %end getSensitivities

    function plotSens(sensObj, outputSelVec, parmNames, tstart, tstop, plotAbs, logScale)
    % function plotSens(sensObj, outputSelVec, parmNames, tstart, tstop, plotAbs, logScale)
    % This function plots the sensitivites of scalar DAE output 
    % y(t) = outputSelVec * x(t) for parameters specified by parmNames.
    % 
    % INPUT args:
    %  - sensObj:      DirectSensitivities structure/object.
    % 
    %  - outputSelVec: 1 x n row vector left-multiplied by the DAE state x(t) to
    %                  retrieve a scalar output.
    % 
    %  - parmNames:    parameters for which to plot sensitivities. At most 5.
    % 
    %  - tstart:       time at which to start plotting. Defaults to 0.
    % 
    %  - tstop:        time at whichj to stop plotting. Defaults to sensObj.ts(end).
    % 
    %  - plotAbs:      Pass in 1 to plot the absolute value of sensitivities.
    %                  Defaults to 0.
    % 
    %  - logScale:     Pass in 1 to plot the sensitivities on a log scale.
    %                  Automatically plots absolute values. Defaults to 0.
        if nargin < 7
            logScale = 0;
        end
        if nargin < 6
            plotAbs = 0;
        end
        if nargin < 5
            tstop = sensObj.ts(end);
        end
        if nargin < 4
            tstart = 0;
        end

        if logScale == 1
            plotAbs = 1;
        end
        if length(parmNames) > 5
            fprintf(2, 'transens: Error: attempting to plot sensitivities for more than 5 parameters.\n');
        end
        % Extract indices and values of parameters we will plot.
        pObj = sensObj.pNom.DeleteAll(sensObj.pNom);
        pObj = pObj.Add(parmNames, pObj);
        parmIdxs = pObj.ParmIndices(pObj);
        parmVals = abs(cell2mat(pObj.ParmVals(pObj, sensObj.DAE)));

        % Indices of sensObj.ts between which to plot.
        startIdx = find(sensObj.ts >= tstart, 1);
        stopIdx = find(sensObj.ts <= tstop, 1, 'last');

        % Sensitivites of the DAE output for the specified parameters,
        % over the specified timeframe
        for i=startIdx:stopIdx
            M_ti = reshape(sensObj.Ms(:, i), [sensObj.n, sensObj.np]);
            outputSens_ti = (outputSelVec * M_ti);
            outputSens(:, i-startIdx+1) = outputSens_ti(parmIdxs) .* parmVals;                
        end

        if plotAbs == 1
            outputSens = abs(outputSens);
        end
        figure();
		if logScale == 1
            set(gca, 'YScale', 'log');
        end
        % Plot the sensitivites for each parameter specified
        for i=1:length(parmNames)
            plot(sensObj.ts(startIdx:stopIdx), outputSens(i, :)', 'LineWidth', 1.5);
            hold on;
			legendNames{i} = strrep(parmNames{i}, '_', '\_');
        end
		hold off;
        legend(legendNames);
        plotTitle = '[Direct] Sens. of DAE output, times pNom';
        if plotAbs == 1
            plotTitle = sprintf('[Abs. Val.] %s', plotTitle);
        end
		title(plotTitle);
        xlabel('time');
		grid on;
		axis tight;
		shg;
    % end plotSens
    
    function plotSensBar(sensObj, outputSelVec, T, plotAbs, logScale, parmNames)
    % function plotSensBar(sensObj, outputSelVec, T, plotAbs, logScale, parmNames)
    % This function plots, as a bar chart, the sensitivities of the DAE output with
    % respect to the given parameters at time T.
    % 
    % INPUT args:
    %  - sensObj:      AdjointSensitivities structure/object.
    % 
    %  - outputSelVec: 1 x n row vector left-multiplied by the DAE state x(t) to
    %                  retrieve a scalar output.
    % 
    %  - T:            Time at which to plot sensitivities.
    % 
    %  - parmNames:    A cell array of the parameter names to include. By default,
    %                  plot all of the parameters.
    % 
    %  - plotAbs:      Pass in 1 to plot the absolute value of sensitivities.
    %                  Defaults to 0.
    % 
    %  - logScale:     Pass in 1 to plot the sensitivities on a log scale.
    %                  Automatically plots absolute values. Defaults to 0.
        if nargin < 4
            plotAbs = 0;
        end
        if nargin < 5
            logScale = 0;
        end
        if nargin < 6
            parmNames = sensObj.pNom.ParmNames(sensObj.pNom);
        end

        if logScale
            plotAbs = 1;
        end

        idx = find(sensObj.ts >= T, 1);
        if (idx > 1) && abs(T - sensObj.ts(idx - 1)) < abs(T - sensObj.ts(idx))
            idx = idx - 1;
        end
        
        for i=1:length(parmNames)
            legendNames{i} = strrep(parmNames{i}, '_', '\_');
        end
        pObj = sensObj.pNom.DeleteAll(sensObj.pNom);
        pObj = pObj.Add(parmNames, pObj);
        mH_T = outputSelVec * reshape(sensObj.Ms(:, idx), [sensObj.n, sensObj.np]);
        y = mH_T(pObj.ParmIndices(pObj));
        y = y .* abs(cell2mat(pObj.ParmVals(pObj, sensObj.DAE)));

        if plotAbs == 1
            y = abs(y);
        end

        figure();
		if logScale == 1
            set(gca, 'YScale', 'log');
        end

        bar(1:length(y), y);
		set(gca, 'XTick', 1:length(y));
		axis('label[y]');
		ylim_values = ylim();
		
		label_pos = ylim_values(1) - (ylim_values(2) - ylim_values(1)) / 50;
		for i = 1:length(y)
			text (i, label_pos, legendNames{i}, "rotation", 90, "horizontalalignment", "right");
		end

        plotTitle = sprintf('[Direct] Sens. of DAE output at T=%0.3e, times pNom', T);
        if plotAbs == 1
            plotTitle = sprintf('[Abs. Val.] %s', plotTitle);
        end
        title(plotTitle);
      	grid on;
		xlim([0 length(y) + 1]);
    %end plotSensHistogram

    function sensLMSObj = DirectSensLMS(sensObj)
    % function sensLMSObj = DirectSensLMS(sensObj)
    % Returns an object/structure that performs transient analysis on the direct
    % sensitivity DAE, d/dt (C(t) M(t) + Sq(t)) + G(t) M(t) + Sf(t) = 0
    % 
    % INPUT args:
    %  - sensObj: DirectSensitivities structure/object.
    % 
    % OUTPUT:
    %  - sensLMSObj: Object to numerically solve the sensitivity DAE.
        sensLMSObj.sensObj = sensObj;
        sensLMSObj.solve = @solve;

        function [Ms, success] = solve(sensLMSObj, startIdx, endIdx)
        % function [Ms, success] = solve(sensLMSObj, startIdx, endIdx)
        % This function solves the sensitivity DAE from t = sensObj.ts(startIdx) 
        % to t = sensObj.ts(endIdx), for every column of M(t).
        % 
        % INPUT args:
        %  - sensLMSObj: DirectSensLMS object/structure.
        % 
        %  - startIdx:   Index of sensObj.Ms at which to start transient analysis.
        %                This index will be used as the initial condition.
        % 
        %  - endIdx:     Index of sensObj.Ms at which to end transient analysis.
        % 
        % OUTPUT:
        %  - Ms:         Solution to the sensitivities DAE.
        % 
        %  - success: 1 if computation was successful, 0 otherwise.
            sensObj = sensLMSObj.sensObj;
            p = sensObj.TRmethod.order;
            sensLMSObj.Ms = sensObj.Ms(:, startIdx);
            success = 1;

            for i = startIdx+1:endIdx
                sensLMSObj.currentIdx=i;
                
                % If we don't have p previous timesteps, or there could be an inconsistent 
                % initial condition, i.e., the beta component of the LMS method uses the 
                % initial condition, run the startup LMS method first.
                possible_inconsistent_ic = false;
                if i - startIdx == p + 1
                    betas = sensObj.TRmethod.betasfunc(sensObj.ts(i:-1:i-p));
                    possible_inconsistent_ic = (betas(end) ~= 0);
                end
                if i - startIdx > p && ~possible_inconsistent_ic
                    sensLMSObj.p = p;
                    sensLMSObj.alphas = sensObj.TRmethod.alphasfunc(sensObj.ts(i:-1:i-p));
                    sensLMSObj.betas = sensObj.TRmethod.betasfunc(sensObj.ts(i:-1:i-p));
                else
                    sensLMSObj.p = 1;
                    sensLMSObj.alphas = sensObj.startupMethod.alphasfunc(sensObj.ts(i:-1:i-1));
                    sensLMSObj.betas = sensObj.startupMethod.betasfunc(sensObj.ts(i:-1:i-1));
                end

                % M(ti), flattened to be a column vector
                M_ti = [];
                % Solve for each column of M(t) separately, as a vector DAE
                for col = 1:sensObj.np
                    sensLMSObj.col = col;
                    lastM_reshaped = reshape(sensLMSObj.Ms(:, end), [sensObj.n, sensObj.np]);
                    [mnew, iters, success] = NR(@g, @dg_dm, lastM_reshaped(:, col), sensLMSObj,...
                                                sensObj.tranparms.NRparms);
                    if success < 1
                        Ms = sensLMSObj.Ms;
                        return;
                    end
                    % Stack the current column of M(ti) under the previous columns
                    M_ti = [M_ti; mnew];
                end
                sensLMSObj.Ms = [sensLMSObj.Ms, M_ti];
            end
            Ms = sensLMSObj.Ms;
        %end solve

        function gOut = g(m, sensLMSObj)
            sensObj = sensLMSObj.sensObj;
            i = sensLMSObj.currentIdx;

            p = sensLMSObj.p;
            col = sensLMSObj.col;
            alphas = sensLMSObj.alphas;
            betas = sensLMSObj.betas;

            [C, G, Sq, Sf] = sensObj.fetchAndReshapeJacobians(sensObj, i);

            gOut = alphas(1) * (C*m + Sq(:, col)) + betas(1) * (G*m+ Sf(:, col));
            for k = 1:p
                Mk = reshape(sensLMSObj.Ms(:, end-k+1), [sensObj.n, sensObj.np]);

                [Ck, Gk, Sqk, Sfk] = sensObj.fetchAndReshapeJacobians(sensObj, i - k);
                gOut = gOut + alphas(k+1) * (Ck*Mk(:, col) + Sqk(:, col)) + betas(k+1) * (Gk*Mk(:, col) + Sfk(:, col));
            end
        %end g

        function dgOut = dg_dm(m, sensLMSObj)
            sensObj = sensLMSObj.sensObj;
            i = sensLMSObj.currentIdx;
            [C, G, ~, ~] = sensObj.fetchAndReshapeJacobians(sensObj, i);

            alphas = sensLMSObj.alphas;
            betas = sensLMSObj.betas;
            dgOut = alphas(1) * C + betas(1) * G;
        %end dg_dm
    %end DirectSensLMS
            
