function sensObj = AdjointSensitivities(DAE, x0, pNom, tstep, TRmethod, tranparms)
% function sensObj =  AdjointSensitivities(DAE, x0, pNom, tstep, TRmethod,
% tranparms) Returns an object/structure for computing sensitivities of a DAE
% output via the adjoint method.
% 
%  Run "help transens" for more information.
    sensObj = SensitivitiesSkeleton(DAE, x0, pNom, tstep, TRmethod, tranparms);
    sensObj.computeSensitivities = @computeSensitivities;
    sensObj.last_z1_t = zeros(sensObj.n, 1);
    sensObj.last_k = zeros(sensObj.n);
    sensObj.last_mH = zeros(sensObj.np);
    sensObj.last_T = 0;

    % Plotting functions
    sensObj.plotASFIdx = @plotASFIdx;
    sensObj.plotSensBar = @plotSensBar;

    function [sensObjOUT, success, mH, compTime] = computeSensitivities(sensObj, T)
    % function [sensObjOUT, success, compTime] = computeSensitivities(sensObj, T)
    % This function computes sensitivities of the DAE output at time T.
    % 
    % INPUT args:
    %  - sensObj: AdjointSensitivities structure/object.
    % 
    %  - T:       Time at which to compute sensitivities.
    % 
    % OUTPUT:
    %  - sensObjOUT: Sensitivities object, with latest transient results, as well
    %                the latest ASF (adjoint sensitivity function).
    %               
    %  - success:    1 if computation was successful, <1 otherwise.
    % 
    %  - mH:         Sensitivities of the DAE output at time T.
    % 
    %  - compTime:   Computation time of sensitivities (not including initial
    %                transient analysis of the original DAE).
        compTime = 0;
        
        if T <= 0
            success = 1;
            mH = zeros(sensObj.np);
            sensObjOUT = sensObj;
            return;
        end
        % Run transient analysis up until T
        [sensObj, success, idx] = sensObj.runTransient(sensObj, T);
        if success < 1
            fprintf(2, 'transens: transient solve of original DAE failed!\n');
            sensObjOUT = sensObj;
            return;
        end

        if (idx < length(sensObj.ts)) && (T ~= sensObj.ts(idx))
            warning(1, 'transens: T <= sensObj.ts(end), so being changed to closest timestep already computed. ');
            warning(1, 'T has been changed from %0.4e to %0.4e.\n', T, sensObj.ts(idx));
        end
        sensObj.last_T = sensObj.ts(idx);

        % Record computation time after initial transient analysis of DAE.
        tic;

        % For estimating time derivatives for the last timestep
        last_h = sensObj.ts(idx) - sensObj.ts(idx-1);

        % Calculate latest C = dq/dx, G = df/dx, S = d/dt(dq/dp) + df/dp
        [C_T, G_T, Sq_T, Sf_T] = sensObj.fetchAndReshapeJacobians(sensObj, idx);
        [C_prevT,~, Sq_prevT,~] = sensObj.fetchAndReshapeJacobians(sensObj, idx-1);
        S_T = Sf_T + (Sq_T - Sq_prevT) / last_h;

        %% Computing the ASF, i.e., the solution of the
        %% adjoint DAE with input c' delta(t - T).
        %% The ASF is of the form z(t) = z1(t) + k delta(t - T).

        % Efficiently compute the nullspace of C.
        LUNullC = LUNullspace(C_T);
        C_null = LUNullC.computeNullspace(LUNullC);
        ddt_C_T = (C_T - C_prevT) / last_h;

        % Find the projection of c onto the nullspace of C'(T).
        c = sensObj.DAE.C(sensObj.DAE)';
        r = LUNullC.rank;
        if r < sensObj.n
            c_N = C_null * (C_null' * c);
        else
            c_N = zeros(sensObj.n);
        end

        % Find k = (G'(T) + d/dt C'(T))^-1 c_N
        X_T = G_T' + ddt_C_T';
        k = X_T\c_N;
        sensObj.last_k = k;
        
        % Find initial condition z1(T^-) by solving 
        % C'(T)z1(T^-) = c - X(T) k, where X(T) is as defined above.
        c_R = c - c_N;

        LUNullC_H = LUNullspace(C_T');
        z1_T_minus =  LUNullC_H.solve(c_R, LUNullC_H);
        
        % If C(T) is not full-rank, compute a consistent final condition for z1(t)
        % such that the first timestep of transient analysis on the adjoint DAE
        % is continuous.
        if r < sensObj.n
            V = LUNullC_H.computeNullspace(LUNullC_H);
            Wtilde = (G_T * C_null)';
            z1_T_minus = z1_T_minus - V * inv(Wtilde * V) * Wtilde * z1_T_minus; 
        end

        % Solve the adjoint DAE, -C'(t) d/dt z1(t) + G'(t)z1(t) = 0, from T- to 0.
        sensLMSObj = AdjointSensLMS(sensObj);
        [z1_t, success] = sensLMSObj.solve(sensLMSObj, idx, z1_T_minus);
        sensObj.last_z1_t = z1_t;

        if success < 1
            fprintf(2, 'transens: transient solve of adjoint DAE failed!\n');
            sensObjOUT = sensObj;
            return;
        end
        %% End ASF computation

        %% Compute sensitivities via m'(T) = -k' S(T) - int_0^T (z1(t)' S(t) dt)
        % Compute integral in above equation
        integrand = [z1_T_minus' * S_T];
        Sq_tiplus1 = Sq_T;
        for i = idx-1:-1:1
            [~,~,Sq_ti, Sf_ti] = sensObj.fetchAndReshapeJacobians(sensObj, i);
            % Current transient timestep
            h = sensObj.ts(:, i+1) - sensObj.ts(:, i);

            % Compute S(ti) = d/dt Sq(ti) + Sf(ti)
            S_ti = (Sq_tiplus1 - Sq_ti) / h + Sf_ti;
            integrand = [z1_t(:, i)' * S_ti; integrand];
            Sq_tiplus1 = Sq_ti; 
        end
        integral = trapz(sensObj.ts(1:idx), integrand);

        mH = -k' * S_T - integral;
        sensObj.last_mH = mH;
        sensObjOUT = sensObj;
        
        compTime = toc;
    %end computeSensitivities

    function plotASFIdx(sensObj, idx)
    %function plotASFIdx(sensObj, idx)
    %This function plots the given index of the adjoint sensitivity function, both
    %finite and impulsive components, from the latest sensitivity computation.
    %
    %INPUT args:
    % - sensObj:   AdjointSensitivities structure/object.
    %
    % - idx:       Index of the ASF to plot.
        figure()
        % hold on
        grid on
        axis tight
        TIdx = length(sensObj.last_z1_t);
        T = sensObj.ts(TIdx);
        plot(sensObj.ts(1:TIdx), sensObj.last_z1_t(idx, :), 'LineWidth', 1.5);
        if sensObj.last_k(idx) ~= 0
            stem([T], [sensObj.last_k(idx)], 'Marker', '^', 'LineWidth', 1.5);
        end
        plotTitle = sprintf('[Adjoint] Index %d of the ASF for T=%0.4e', idx, T);
        title(plotTitle);
        xlabel('time');
        % hold off
    % end plotASFIdx

    function plotSensBar(sensObj, plotAbs, logScale, parmNames)
    %function plotSensBar(sensObj, plotAbs, logScale, parmNames)
    %This function plots, as a bar chart, the sensitivities of the given parameters
    %from the latest sensitivity computation.
    %
    %INPUT args:
    % - sensObj:   AdjointSensitivities structure/object.
    %
    % - plotAbs:   Pass in 1 to plot the absolute value of sensitivities. Defaults
    %              to 0.
    %
    % - logScale:  Pass in 1 to plot the sensitivities on a log scale.
    %              Automatically plots absolute values. Defaults to 0.
    %
    % - parmNames: A cell array of the parameter names to include. By default,
    %              plot all of the parameters.
        if nargin < 2
            plotAbs = 0;
        end
        if nargin < 3
            logScale = 0;
        end
        if nargin < 4
            parmNames = sensObj.pNom.ParmNames(sensObj.pNom);
        end
        
        if logScale
            plotAbs = 1;
        end
        
        for i=1:length(parmNames)
            legendNames{i} = strrep(parmNames{i}, '_', '\_');
        end
        pObj = sensObj.pNom.DeleteAll(sensObj.pNom);
        pObj = pObj.Add(parmNames, pObj);
        y = sensObj.last_mH(pObj.ParmIndices(pObj));
        y = y .* abs(cell2mat(pObj.ParmVals(pObj, sensObj.DAE)));

        if plotAbs == 1
            y = abs(y);
        end

        figure();
        % hold on
        grid on
        axis tight
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
        plotTitle = sprintf('[Adjoint] Sens. of DAE output at T=%0.3e, times pNom',...
                             sensObj.last_T);
        if plotAbs == 1
            plotTitle = sprintf('[Abs. Val.] %s', plotTitle);
        end
        title(plotTitle);
        
        % hold off
    %end plotSensBar

    function sensLMSObj = AdjointSensLMS(sensObj)
    %function sensLMSObj = AdjointSensLMS(sensObj)
    %Returns an object/structure that performs transient analysis on the adjoint
    %DAE, -C'(t) d/dt z(t) + G'(t) z(t) = 0.
    %
    %INPUT args:
    % - sensObj: AdjointSensitivities structure/object.
    %
    %OUTPUT:
    % - sensLMSObj: Object to numerically solve the adjoint DAE.
        sensLMSObj.sensObj = sensObj;
        sensLMSObj.solve = @solve;
        
        function [z1_t, success] = solve(sensLMSObj, Tidx, z1_T_minus)
        %function [z1_t, success] = solve(sensLMSObj, Tidx, z1_T_minus)
        %This function solves the adjoint DAE from t = sensObj.ts(Tidx) to t=0,
        %with final condition z1_T_minus.
        %
        %INPUT args:
        % - sensLMSObj: AdjointSensLMS object/structure.
        %
        % - Tidx:       Index of T in sensObb.ts.
        %
        % - z1_T_minus: Final condition for the adjoint DAE.
        %
        %OUTPUT:
        % - z1_t:    Solution to the adjoint DAE.
        %
        % - success: 1 if computation was successful, 0 otherwise.
            sensObj = sensLMSObj.sensObj;
            sensLMSObj.z1_t = z1_T_minus;

            success = 1;
            
            for i = Tidx-1:-1:1
                sensLMSObj.currentIdx = i;
                p = sensObj.TRmethod.order;
                % If the number of timesteps that have been computed is less than the
                % order of the LMS method, use a first-order method instead.
                if Tidx - i > p
                    sensLMSObj.p = p;
                    sensLMSObj.alphas = sensObj.TRmethod.alphasfunc(sensObj.ts(i:i+p));
                    sensLMSObj.betas = sensObj.TRmethod.betasfunc(sensObj.ts(i:i+p));
                else
                    sensLMSObj.p = 1;
                    sensLMSObj.alphas = sensObj.startupMethod.alphasfunc(sensObj.ts(i:i+1));
                    sensLMSObj.betas = sensObj.startupMethod.betasfunc(sensObj.ts(i:i+1));
                end

                % Use LMS methods to compute z1(ts(i))
                initNRguess = sensLMSObj.z1_t(:, 1);
                [znew, iters, success] = NR(@LMSfuncToSolve, @dLMSfuncToSolve, initNRguess,...
                                            sensLMSObj, sensObj.tranparms.NRparms);
                if success < 1
                    z1_t = sensLMSObj.z1_t;
                    return;
                end
                sensLMSObj.z1_t = [znew, sensLMSObj.z1_t];
            end
            z1_t = sensLMSObj.z1_t;
        %end solve


        function gOut = LMSfuncToSolve(z, sensLMSObj)
            sensObj = sensLMSObj.sensObj;
            i = sensLMSObj.currentIdx;

            p = sensLMSObj.p;

            [C, G, ~, ~] = sensObj.fetchAndReshapeJacobians(sensObj, i);
            
            alphas = sensLMSObj.alphas;
            betas = sensLMSObj.betas;

            qTerm = alphas(1) * z;
            fTerm = betas(1) * G' * z;
            CTerm = -betas(1) * C';

            for k = 1:p
                zk = sensLMSObj.z1_t(:, k);
                [Ck, Gk, ~, ~] = sensObj.fetchAndReshapeJacobians(sensObj, i+k);

                qTerm = qTerm + alphas(k+1) * zk;
                fTerm = fTerm + betas(k+1) * Gk' * zk;
                CTerm = CTerm - betas(k+1) * Ck';
            end
            CTerm = CTerm ./ sum(betas);
            gOut = CTerm * qTerm + fTerm;
        %end gOut

        function dgOut = dLMSfuncToSolve(z, sensLMSObj)
            sensObj = sensLMSObj.sensObj;
            i = sensLMSObj.currentIdx;

            p = sensLMSObj.p;

            [C, G, ~, ~] = sensObj.fetchAndReshapeJacobians(sensObj, i);

            alphas = sensLMSObj.alphas;
            betas = sensLMSObj.betas;

            CTerm = -betas(1) * C';

            for k = 1:p
                [Ck, ~, ~, ~] = sensObj.fetchAndReshapeJacobians(sensObj, i+k);
                CTerm = CTerm - betas(k+1) * Ck';
            end
            CTerm = CTerm ./ sum(betas);
            dgOut = alphas(1) * CTerm + betas(1) * G';
        %end dg_dz
    %end AdjointSensLMS
%end AdjointSensitivities
