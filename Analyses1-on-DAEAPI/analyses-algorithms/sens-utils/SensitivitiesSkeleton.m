function sensObj = SensitivitiesSkeleton(DAE, x0, pNom, tstep, TRmethod, tranparms)
%function sensObj = SensitivitiesSkeleton(DAE, x0, pNom, tstep, TRmethod,
%tranparms) Skeleton ("parent") class for computing transient sensitivities.
%Includes fields and methods common to Adjoint and Direct sensitivities.
%
% Run "help transens" for more information.
    % DAE and parameters
    sensObj.DAE = DAE;
    sensObj.pNom = pNom;

    % Transient analysis settings
    sensObj.tstep = tstep;
    sensObj.TRmethod = TRmethod;
    tranMethods = LMSmethods();
    sensObj.startupMethod = tranMethods.BE;
    sensObj.tranparms = tranparms;
    sensObj.LMSObj = LMS(DAE, TRmethod, tranparms);

    % n = size of DAE system, np = number of parameters
    sensObj.n = DAE.nunks(DAE);
    sensObj.np = pNom.numparms;

    % DAE state over time. xs is a matrix where each column, i, is 
    % x(t) at t = ts(i).
    sensObj.xs = x0;
    sensObj.ts = [0];

    % Jacobian matrices over time: for DAE dq(x(t))/dt + f(x) = 0,
    % C(t) = dq/dx, G(t) = df/dx, Sq(t) = dq/dp, Sf(t) = df/dp.
    % Each column, i, of the following matrices is the corresponding Jacobian
    % at t = ts(i), reshaped to be a column vector.
    [sensObj.Cs, sensObj.Gs, sensObj.Sqs, sensObj.Sfs] = computeJacobians(sensObj, 1, 'CGSqSf', 1);

    % Functions
    sensObj.runTransient = @runTransient;
    sensObj.addTRAnalysisResults = @addTRAnalysisResults;
    sensObj.computeJacobians = @computeJacobians;
    sensObj.fetchAndReshapeJacobians = @fetchAndReshapeJacobians;

    % Will be defined by the "child class", DirectSensitivities or AdjointSensitivities
    sensObj.computeSensitivities = 'undefined';

    function [sensObjOUT] = addTRAnalysisResults(sensObj, ts, xs, Cs, Gs, Sqs, Sfs)
    %function sensObjOUT = addTRAnalysisResults(sensObj, ts, xs, Cs, Gs, Sqs, Sfs)
    %This function adds the output (state and Jacobian matrices) of a transient
    %analysis run to the sensitivities object.
    %INPUT args:
    % - sensObj: AdjointSensitivities or DirectSensitivities structure/object.
    %
    % - ts:      vector of timepoints at which x(t) and the Jacobian matrices
    %            were evaluated. Must be sorted, and ts(1) must be after the last
    %            timestep in sensObj.ts.
    %
    % - xs:      DAE state outputted by transient simulation.
    %
    % - Cs:      Jacobian matrix of dq/dx over time.  Each column Cs(i) is the C(t)
    %             evaluated at t = ts(i), reshaped to be a column vector.
    %
    % - Gs:      Jacobian matrix of df/dx, formatted like Cs.
    %
    % - Sqs:     Jacobian matrix of dq/dp, formatted like Cs.
    %
    % - Sfs:     Jacobian matrix of df/dp, formatted like Cs.
    %
    %OUTPUT:
    %   sensObjOUT: sensitivities object, with added transient analysis results.
        startIdx = 1;
        if ~issorted(ts)
            fprintf(1, 'transens: error adding transient analysis results. ts must be an ordered array.\n');
            return;
        end
        if ts(1) <= sensObj.ts(end)
            fprintf(1, 'transens: warning: discarding timepoints before sensObj.ts(end)\n');
            startIdx = find(ts > sensObj.ts(end), 1);
        end

        sensObj.xs = [sensObj.xs, xs(:, startIdx:end)];
        sensObj.ts = [sensObj.ts, ts(startIdx:end)];

        sensObj.Cs = [sensObj.Cs, Cs(:, startIdx:end)];
        sensObj.Gs = [sensObj.Gs, Gs(:, startIdx:end)];
        sensObj.Sqs = [sensObj.Sqs, Sqs(:, startIdx:end)];
        sensObj.Sfs = [sensObj.Sfs, Sfs(:, startIdx:end)];
        sensObjOUT = sensObj;
    %end addTRAnalysisResults

    function [sensObjOUT, success, TIdx] = runTransient(sensObj, T)
    %function [sensObjOUT, success, TIdx] = runTransient(sensObj, T)
    %This function runs transient analysis on sensObj.DAE up until time T.
    %INPUT args:
    % - sensObj: AdjointSensitivities or DirectSensitivities structure/object.
    %
    % - T:       End time of transient analysis. If T <= sensObj.ts(end), transient
    %            analysis is not run, and TIdx is set to the index of sensObj.ts
    %            that is closest to T.
    %
    %OUTPUT:
    % - sensObjOUT: Sensitivities object, with added transient analysis results.
    %
    % - success:    1 if transient analysis was successful, 0 if not.
    %
    % - TIdx:       The index of sensObj.ts corresponding to T.
        success = 1;
        % Compute values of xnom and Jacobians up until T, if necessary
        if T <= sensObj.ts(end)
            % Set TIdx to the closest index of sensObj.ts
            TIdx = find(sensObj.ts >= T, 1);
            if (TIdx > 1) && abs(T - sensObj.ts(TIdx - 1)) < abs(T - sensObj.ts(TIdx))
                TIdx = TIdx - 1;
            end
        else
            % Run transient analysis from sensObj.ts(end) to T
            insertIdx = length(sensObj.ts) + 1;
            sensObj.LMSObj = sensObj.LMSObj.solve(sensObj.LMSObj, sensObj.xs(:, end),...
                                                  sensObj.ts(end), sensObj.tstep, T);
            if sensObj.LMSObj.solvalid < 1
                fprintf(2, 'transens: transient solve failed!\n');
                sensObjOUT = sensObj;
                success = 0;
                return;
            end
            [tpts, xvals] = sensObj.LMSObj.getSolution(sensObj.LMSObj);            
            % Append the transient results to sensObj.
            sensObj.xs = [sensObj.xs, xvals(:, 2:end)];
            sensObj.ts = [sensObj.ts, tpts(2:end)];
            TIdx = length(sensObj.ts);

            % Compute Jacobian matrices
            for i=insertIdx:length(sensObj.ts);
                [C, G, Sq, Sf] = computeJacobians(sensObj, i, 'CGSqSf', 1);
                sensObj.Cs = [sensObj.Cs, C];
                sensObj.Gs = [sensObj.Gs, G];
                sensObj.Sqs = [sensObj.Sqs, Sq];
                sensObj.Sfs = [sensObj.Sfs, Sf];
            end
        end
        sensObjOUT = sensObj;
    %end runTransient

    function [C, G, Sq, Sf] = computeJacobians(sensObj, idx, C_G_Sq_or_Sf, reshapeArrays)
    %function [C, G, Sq, Sf] = computeJacobians(sensObj, idx, C_G_Sq_or_Sf, reshapeArrays)
    %This function computes the Jacobian matrices C = dq/dx, G = df/dx, Sq = dq/dp,
    %and/or Sf = df/dp for the given index of sensObj.ts.
    %INPUT args:
    % - sensObj:       AdjointSensitivities or DirectSensitivities structure/object.
    %
    % - idx:           Index of sensObj.ts for which we will compute the Jacobians.
    %
    % - C_G_Sq_or_Sf:  A string determining which Jacobians to compute. To compute
    %                  all, pass in 'CGSqSf'.
    %
    % - reshapeArrays: Pass in 1 to reshape the output arrays into column vectors.
    %
    %OUTPUT:
    % - C:  dq/dx, evaluated at t = sensObj.ts(idx). All zeros if C_G_Sq_or_Sf does
    %       not include 'C'.
    %
    % - G:  df/dx.
    %
    % - Sq: dq/dp.
    %
    % - Sf: df/dp.
        t = sensObj.ts(idx);
        x = sensObj.xs(:, idx);
        if sensObj.DAE.f_takes_inputs == 1
            u = sensObj.DAE.utransient(t, sensObj.DAE);
        end

        n = sensObj.n;
        np = sensObj.np;

        C = zeros(n, n); G = zeros(n, n);
        Sq = zeros(n, np); Sf = zeros(n, np);

        if strfind(C_G_Sq_or_Sf, 'C')
            C = sensObj.DAE.dq_dx(x, sensObj.DAE);
        end
        if strfind(C_G_Sq_or_Sf, 'G')
            if sensObj.DAE.f_takes_inputs == 1
                G = sensObj.DAE.df_dx(x, u, sensObj.DAE);
            else
                G = sensObj.DAE.df_dx(x, sensObj.DAE);
            end
        end
        if strfind(C_G_Sq_or_Sf, 'Sq')  & strfind(C_G_Sq_or_Sf, 'Sf')
            if sensObj.DAE.f_takes_inputs == 1
                [Sf, Sq] = dfq_dp_DAEAPI_auto(x, u, sensObj.pNom, 'fq', sensObj.DAE);
            else
                [Sf, Sq] = dfq_dp_DAEAPI_auto(x, sensObj.pNom, 'fq', sensObj.DAE);
            end
        else
            if strfind(C_G_Sq_or_Sf, 'Sq')
                if sensObj.DAE.f_takes_inputs == 1
                    [~, Sq] = dfq_dp_DAEAPI_auto(x, u, sensObj.pNom, 'q', sensObj.DAE);
                else
                    [~, Sq] = dfq_dp_DAEAPI_auto(x, sensObj.pNom, 'q', sensObj.DAE);
                end
            end
            if strfind(C_G_Sq_or_Sf, 'Sf')
                if sensObj.DAE.f_takes_inputs == 1
                    [Sf,~] = dfq_dp_DAEAPI_auto(x, u, sensObj.pNom, 'f', sensObj.DAE);
                else
                    [Sf,~] = dfq_dp_DAEAPI_auto(x, sensObj.pNom, 'f', sensObj.DAE);
                end
            end
        end
        if reshapeArrays == 1
            C = reshape(C, [], 1);
            G = reshape(G, [], 1);
            Sf = reshape(Sf, [], 1);
            Sq = reshape(Sq, [], 1);
        end
    %end computeJacobians

    function [C, G, Sq, Sf] = fetchAndReshapeJacobians(sensObj, idx)
    %function [C, G, Sq, Sf] = fetchAndReshapeJacobians(sensObj, idx)
    %This function retrieves Jacobian matrices from sensObj.Cs, sensObj.Gs, etc.
    %and reshapes them from column vectors to n x n (C, G) or n x np (Sq, Sf)
    %matrices.
    %
    %INPUT args:
    % - sensObj:       AdjointSensitivities or DirectSensitivities structure/object.
    %
    % - idx:           Index of sensObj.ts for which we will retrieve the Jacobians.
    %
    %OUTPUT:
    % - C:  dq/dx, evaluated at t = sensObj.ts(idx).
    %
    % - G:  df/dx.
    %
    % - Sq: dq/dp.
    %
    % - Sf: df/dp.
        C = reshape(sensObj.Cs(:, idx), [sensObj.n, sensObj.n]); 
        G = reshape(sensObj.Gs(:, idx), [sensObj.n, sensObj.n]);
        Sq = reshape(sensObj.Sqs(:, idx), [sensObj.n, sensObj.np]); 
        Sf = reshape(sensObj.Sfs(:, idx), [sensObj.n, sensObj.np]);
    %end getAndReshapeJacobians
%end SensitivitiesSkeleton
