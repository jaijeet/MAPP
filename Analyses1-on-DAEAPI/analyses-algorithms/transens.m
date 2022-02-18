function sensObj = transens(DAE, useAdjoint, x0, pNom, tstep, TRmethod, tranparms)
% function sensObj = transens(DAE, directOrAdjoint, x0, pNom, tstep, TRmethod,
% tranparms) Compute transient parameter sensitivities of the solution of a DAE
% as a function of time, using direct or adjoint methods. The synonym TADsens
% (transient adjoint DAE sensitivities) calls transens with useAdjoint set to 1.
% 
% For more information on the adjoint method, see the following paper:
%    N. Sagan and J. Roychowdhury, "Transient Adjoint DAE Sensitivities: 
%    a Complete, Rigorous, and Numerically Accurate Formulation", 
%    Forthcoming at Asia South-Pacific Design Automation Conference, Jan. 2022.
% 
% Transient sensitivities are defined as M(t) = dx(t)/dp, evaluated at xNom(t),
% pNom. pNom is a vector of the nominal values for each parameter, and xNom(t)
% is the solution to the DAE with parameters pNom and initial condition x0. M(t)
% is a n x np matrix, where n is the dimension of the DAE state and np is the
% number of parameters.
% 
% Direct sensitivitiy analysis computes the full matrix M(t) over a range of time
% values, but is very slow for DAEs with large numbers of parameters.
% 
% Adjoint sensitivity analysis computes the sensitivities of a system output at a
% timepoint, or a row of the matrix M(T), for timepoint T: m'(T) = c' M(t), where
% the (scalar) output of the system is defined as c'x(t).
% (Note: Sensitivities for a circuit DAE will be real. If the system was complex,
% the above equation would be m*(T) = c* M(t), where "*" represents the conjugate
% transpose.)
% 
% Arguments:
% 
%  - DAE:             A DAEAPI structure/object (see help DAEAPI). NOTE: if you
%                     are computing adjoint sensitivities, then DAE.C must be a
%                     row vector (1 x n matrix) such that the desired system
%                     output is y(t) = DAE.C * x(t).
% 
%  - useAdjoint:      1 to use the adjoint method, 0 for direct.
% 
%  - x0:              A vector with the initial condition for the initial
%                     transient analysis of the provided DAE. 
% 
%  - pNom:            A Parameters structure/object (see help Parameters) that
%                     stores the nominal values of the parameters of interest. It
%                     usually suffices to define pNom as Parameters(DAE).
% 
%  - tstep:           The transient timestep used for solving the DAE for
%                     xNom(t).
% 
%  - TRmethod:        An integration method structure defined by LMSmethods().
%                     For example: methods = LMSmethods(); TRmethod =
%                     methods.TRAP; help LMSmethods for more information.
%   
%  - tranparms:       A transient parameters structure as defined by
%                     defaultTranParms(). Many important capabilities of LMS can
%                     be utilized by appropriate settings in tranparms. help
%                     defaultTranParms for more information.
% 
% Output
% 
%  - sensObj: a DirectSensitivities or AdjointSensitivities object, from which
%  you can compute sensitivities at specified time or retrieve computed
%  sensitivites.
% 
%             Functions common to direct and adjoint: .runTransient (function
%             handle). Runs transient timestepping (LMS) up until the specified
%             end time. help SensitivitiesSkeleton::runTransient for more
%             information and usage details.
% 
%                 .addTRAnalysisResults (function handle). Adds transient
%                 solution of the original DAE, as well as Jacobian matrices, to
%                 sensObj. This is useful if the DAE state and Jacobians were
%                 pre-computed separately from the sensitivity computation. help
%                 SensitivitiesSkeleton::addTRAnalysisResults for more
%                 information and usage details.
% 
%                 .computeJacobians (function handle). Computes Jacobian matrices
%                 at the given index of sensObj.ts. help
%                 SensitivitiesSkeleton::computeJacobians for more information
%                 and usage details.
% 
%                 .fetchAndReshapeJacobians (function handle). Returns Jacobian
%                 matrices at specified index of sensObj.ts, given such matrices
%                 have already been computed. Reshapes Jacobians from a column
%                 vector to an n x n or n x np matrix. help
%                 SensitivitiesSkeleton::fetchAndReshapeJacobians for more
%                 information and usage details.
% 
%                 .computeSensitivities (function handle). For direct, computes
%                 sensitivities up until end time T. For adjoint, computes
%                 sensitivities at time T. help
%                 DirectSensitivities::computeJacobians or help
%                 AdjointSensitivities::computeJacobians for more information and
%                 usage details. Note that usage of differs slightly between
%                 direct and adjoint.
% 
%                 .plotSensBar (function handle). Plots a bar chart of
%                 sensitivity values at a specified time. help
%                 DirectSensitivities::plotSensBar or help
%                 AdjointSensitivities::plotSensBar for more information and
%                 usage details.
% 
%             Direct sensitivity functions: .getSensitivities (function handle).
%             Fetches already-computed sensitivities within a range of time
%             values. help DirectSensitivities::getSensitivities for more
%             information and usage details.
% 
%                 .getSensitivities (function handle). Fetches already-computed
%                 sensitivities within a range of time values. help
%                 DirectSensitivities::getSensitivities for more information and
%                 usage details.
% 
%                 .plotSens (function handle). Plots sensitivities of a specified
%                 DAE output as a function of time. help
%                 DirectSensitivities::plotSens for more information and usage
%                 details.
% 
%             Adjoint sensitivity functions: .plotASFIdx (function handle). Plots
%             specified index of the adjoint sensitivity function as a function
%             of time. help AdjointSensitivities::plotASFIdx for more
%             information and usage details.
% 
% Examples
% --------------
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 1: Sensitivities of size-two system consisting of %%%%
% %%%%            the RC circuit ODE and an algebraic equation.  %%%%
% %%%%            From Section III.A in the paper cited earlier  %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DAE = DAE_RCPlusAE();
% % Input to DAE
% ufunc = @(t, args) [1; t];
% DAE = DAE.set_utransient(ufunc, [], DAE);
% pNom = Parameters(DAE);
% T = 1e-3;
% tstep = 1e-5;
% methods = LMSmethods();
% TRmethod = methods.TRAP;
% x0 = [1/2; 0];   
%                         
% dirSens = transens(DAE, 0, x0, pNom, tstep, TRmethod);
% [dirSens, success, compTime] = dirSens.computeSensitivities(dirSens, T);
% [Ms, ts] = dirSens.getSensitivities(dirSens, 0, T);
% % Each column of Ms is the matrix M(t) at a different timepoint, 
% % flattened to be a column vector. Use reshape to get the matrix.
% M_T = reshape(Ms(:, end), [dirSens.n, dirSens.np]);
% fprintf(1, 'Sensitivity of x1 to R=%0.4e, to C=%0.4e\n', M_T(1, 1), M_T(1, 2));
% fprintf(1, 'Sensitivity of x2 to R=%0.4e, to C=%0.4e\n', M_T(2, 1), M_T(2, 2));
% 
% % Plot sensitivities of x1 (voltage across capacitor) to R over time
% dirSens.plotSens(dirSens, [1, 0], {'R'}, 0, T);
% % Plot bar graph of sensitivities of x1 + x2 at time T
% dirSens.plotSensBar(dirSens, [1, 1], T);
% 
% adjSens = transens(DAE, 1, x0, pNom, tstep, TRmethod);
% [adjSens, success, mH, compTime] =...
%                adjSens.computeSensitivities(adjSens, T);
% fprintf(1, 'Sensitivity of output to R: %0.4e', mH(1));
% fprintf(1, 'Sensitivity of output to C: %0.4e\n', mH(2));
% 
% adjSens.plotSensBar(adjSens, 1, 1);
% % Plot the first index of the ASF (adjoint sensitivity function).
% % For this example, the impulsive component should be 0.
% adjSens.plotASFIdx(adjSens, 1);
% % Plot the second index of the ASF. This time, only the impulsive component
% % should be present.
% adjSens.plotASFIdx(adjSens, 2);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 2: Sensitivities of bipolar Schmitt trigger.     %%%%
% %%%%            From Section III.B in the paper.              %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % WARNING: this example may take several minutes to run.
% 
% DAE = BJTschmittTrigger('sensbjtschmitttrigger');
% x0 = [5; 3; 3.75; 3];
% T = 1e-4;
% tstep = 5e-9;
% methods = LMSmethods();
% TRmethod = methods.GEAR2;
% 
% tranparms = defaultTranParms;
% tranparms.NRparms.limiting = 1; 
% tranparms.doStepControl = 1;
% tranparms.NRparms.dbglvl = -1;
% tranparms.trandbglvl = -1;
% pNom = Parameters(DAE);
% % The DAE output is the differential voltage, Collector(Q1) - Collector(Q2).
% C = [0, 1, -1, 0];
% 
% dirSens = transens(DAE, 0, x0, pNom, tstep, TRmethod, tranparms);
% [dirSens, success, compTime] = dirSens.computeSensitivities(dirSens, T);
% % Plot sensitivities over time of up to 5 parameters
% dirSens.plotSens(dirSens, C, {'Q1_alphaF', 'Q1_IsF', 'Q2_alphaF', 'Q2_IsF'},... 
%                  0, T);
% % Plot absolute values of sensitivities on a log scale
% dirSens.plotSens(dirSens, C, {'Q1_alphaF', 'Q1_IsF', 'VCC', 'RE', 'C1'},...
%                  0, T, 1, 1);
% % Sensitivity bar plot for all parameters, in log scale
% dirSens.plotSensBar(dirSens, C, T, 1, 1);
% 
% adjSens = transens(DAE, 1, x0, pNom, tstep, TRmethod, tranparms);
% % To save time, transfer over transient results from dirSens
% adjSens = adjSens.addTRAnalysisResults(adjSens, dirSens.ts, dirSens.xs,... 
%                         dirSens.Cs, dirSens.Gs, dirSens.Sqs, dirSens.Sfs);
% [adjSens, success, mH, compTime] = adjSens.computeSensitivities(adjSens, T);
% % Sensitivity bar plot for all parameters, in log scale
% adjSens.plotSensBar(adjSens, 1, 1);
% adjSens.plotASFIdx(adjSens, 1);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 3: Sensitivities of a MOS inverter chain.   %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% NInv = 5; VDD = 1.2; betaN = 1e-3; betaP = 1e-3;
% VtN = 0.25; VtP = 0.25; RdsN = 1e4; RdsP = 1e4; CL = 1e-6;
% 
% DAE = inverterchain('sensinverterchain', NInv, VDD, betaN, betaP, VtN,... 
%                     VtP, RdsN, RdsP, CL);
% DAE = DAE.set_uQSS('Vin.E', 0, DAE);
% 
% % Set the initial condition to the DAE's steady state under no input
% qss = QSS(DAE);
% NRparms = qss.getNRparms(qss);
% NRparms.dbglvl = -1;
% qss = qss.setNRparms(NRparms, qss);
% qss = qss.solve(qss);
% x0 = qss.getSolution(qss);
% 
% DAE = DAE.set_utransient(@ (t, args) [1], [], DAE);
% % The output is the voltage at the gate of the final inverter.
% DAE.C = @ (DAE) [zeros(1, DAE.nunks(DAE)-3), 1, zeros(1, 2)];
% 
% T = 1.5e-2;
% tstep = 1e-5;
% methods = LMSmethods();
% TRmethod = methods.GEAR2;
% pNom = Parameters(DAE);
% 
% dirSens = transens(DAE, 0, x0, pNom, tstep, TRmethod);
% [dirSens, success, compTime] = dirSens.computeSensitivities(dirSens, T);
% dirSens.plotSens(dirSens, DAE.C(DAE), {'CL1', 'CL2', 'CL3', 'CL4', 'CL5'});
% % Compare sensitivities at time T, in log scale
% dirSens.plotSensBar(dirSens, DAE.C(DAE), T, 1, 1);
% 
% adjSens = transens(DAE, 1, x0, pNom, tstep, TRmethod);
% % To save time, transfer over transient results from dirSens
% adjSens = adjSens.addTRAnalysisResults(adjSens, dirSens.ts, dirSens.xs,...
%                         dirSens.Cs, dirSens.Gs, dirSens.Sqs, dirSens.Sfs);
% [adjSens, success, mH, compTime] = adjSens.computeSensitivities(adjSens, T);
% adjSens.plotSensBar(adjSens, 1, 1);
% adjSens.plotASFIdx(adjSens, 3);
%
    if nargin > 7 || nargin < 5
        fprintf(2,'DAESens: error: too many or too few arguments.\n');
        help('transens');
        return;
    elseif nargin < 6
        methods = LMSmethods();
        TRmethod = methods.GEAR2;
    elseif nargin < 7
        tranparms = defaultTranParms();
        tranparms.trandbglvl = -1;
        tranparms.NRparms.dbglvl = -1;
    end

    if useAdjoint == 0
        sensObj = DirectSensitivities(DAE, x0, pNom, tstep, TRmethod, tranparms);
    else
        sensObj = AdjointSensitivities(DAE, x0, pNom, tstep, TRmethod, tranparms);
    end
%end transens
