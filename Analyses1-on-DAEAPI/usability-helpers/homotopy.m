function homObj = homotopy(DAE, lambdaName, inputORparm, ...
                       initguess, startLambda, lambdaStep, stopLambda, ...
                       maxLambdaStep, maxLambda, minLambda, maxArcLength)
%function homObj = homotopy(DAE, lambdaName, inputORparm, initguess, ...
%                           startLambda, lambdaStep, stopLambda, ...
%                           maxLambdaStep, maxLambda, minLambda, maxArcLength)
%
%Run a homotopy analysis to obtain a family of DC solutions of a DAE, sweeping
%with respect to an input or a parameter. The synonyms hom, dot_homotopy,
%enct, Euler_Newton_Curve_Tracing, arclength_continuation and continuation all
%just call homotopy.
%
%Homotopy is a nonlinear equation solution technique that can trace solutions
%as an input or parameter is varied. The method is capable of negotiating folds
%(turning points) and is therefore useful for parameter or input sweeps that
%involve, eg, hysteresis or "negative resistance" regions in the solution.
%Homotopy is also useful for finding DC solutions of systems which
%Newton-Raphson (used by MAPP's normal DC analysis) has difficulty with. To
%learn more about homotopy, see homotopy_concepts TODO.
%
%Arguments:
%
%  - DAE:           A DAEAPI structure/object (see help DAEAPI).
%
%  - lambdaName:    A string with the name of an input or parameter of the
%                   DAE. (You can see these using feval(DAE.inputnames, DAE)
%                   or feval(DAE.paramnames, DAE)). The homotopy sweep will be
%                   conducted with respect to this. We will refer to this
%                   input or parameter as lambda.
%
%  - inputORparm:   (optional) a string that specifies whether lambdaName is 
%                   an input or a parameter. Valid values are 'input', 'parm'
%                   and 'param'. If not specified, or set to [] or '',
%                   defaults to 'input'.
%                   
%
%  - initguess:     (optional) initial guess for solving for the DC/QSS
%                   solution with input/parameter value set to startLambda
%                   (see below).  Should be a column vector of the size of the
%                   DAE unknowns, ie, of size n = feval(DAE.nunks, DAE). It
%                   can also have the following special forms:
%
%                   - 'DC' or 'QSS': dcop() will be run first on the DAE,
%                     after setting the input or parameter value to
%                     startLambda (see below). This leverages initialization/
%                     limiting in Newton-Raphson. This is the default if
%                     initguess is not specified, or is [] or ''.
%
%                   - The scalar 0: zeros(feval(DAE.nunks, DAE), 1)
%                     will be used for the initial guess. Usually not very
%                     useful for circuit DAEs.
%                   
%                   - 'rand': random initial guess using rand(). Use only if
%                     desperate.
%
%                   - 'randn': random initial guess. using randn(). Use only
%                     if desperate.
%
%  - startLambda:   (optional) start value of lambda (ie, the input or 
%                   parameter) for the sweep. Defaults to 0 if not specified,
%                   or is '' or [].
%
%  - lambdaStep:    (optional) a target step length for lambda. Defaults to
%                   (stopLambda-startLambda)/100 if not specified or set to
%                   [] or ''.
%
%  - stopLambda:    (optional) end value of lambda (ie, the input or 
%                   parameter) for the sweep. Defaults to 1 if not specified,
%                   or is '' or [].
%
%  - maxLambdaStep: (optional) maximum limit for lambda step. Defaults to
%                   no limit if not specified or set to [] or ''. 
%                   Setting this to a conservative value sometimes
%                   helps homotopy complete successfully.
%
%  - maxLambda:     (optional) stop homotopy if lambda exceeds this value.
%                   Useful if your track seems never to reache stopLambda. 
%                   Defaults to Inf if not specified or is '' or [].
%
%  - minLambda:     (optional) stop homotopy if lambda goes below this value.
%                   Useful if your track seems never to reach stopLambda. 
%                   Defaults to -Inf if not specified or is '' or [].
%
%  - maxArcLength:  (optional) stop homotopy if the arc length exceeds this
%                   value.  Useful if your track seems never to reach 
%                   stopLambda.  Defaults to Inf if not specified or 
%                   is '' or [].
%
%Output:
%
%  - homObj: an ArcContAnalysis object containing the results of the homotopy
%            sweep, if successful.  Use:
%
%	     	 - feval(homObj.plot, homObj) to plot the sweep with respect to 
%              the lambda input or parameter.
%
%            - feval(homObj.plotVsArcLen, homObj) to plot the sweep with 
%              respect to the arc-length s of the homotopy path.
%
%            - sol = feval(homObj.getsolution, homObj) to get the solution
%              data. sol is a struct with the following fields:
%
%              - sol.spts: arc-length values at which the solution has been
%                          computed - a row of numbers starting from 0.
%
%              - sol.yvals: a matrix of solutions. Each column corresponds to
%                           the solution at the corresponding arc-length. The
%                           length of each column is the number of DAE
%                           unknowns, ie, it equals feval(DAE.nunks, DAE) + 1.
%                           If you set
%                               x_i = sol.yvals(1:(end-1), i) % and
%                               lambda_i = sol.yvals(end, i) %,
%                           for any i in [1, length(sol.spts)],
%                           then x_i is a DC solution of the DAE when the
%                           lambda input/parameter is set to lambda_i.
%
%
%Examples
%--------
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 1: hysteresis in a simple 2-terminal device %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % Create a 2-terminal ModSpec device with v = cubic polynomial in i 
% MOD = ee_model();
% MOD = add_to_ee_model(MOD, 'name', 'vEQcubicINi');
% MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
% MOD = add_to_ee_model(MOD, 'explicit_outs', {'vpn'});
% MOD = add_to_ee_model(MOD, 'params', {'A', 3, 'B', -2, 'C', 1});
% MOD = add_to_ee_model(MOD, 'params', {'I', 1});
% %% note: scaling the current to, eg, mA currently causes numerical problems
% %% in homotopy - because MAPP does not yet have proper scaling support.
% %% Replace the two lines above by the two lines below to see the problem:
% % MOD = add_to_ee_model(MOD, 'params', {'A', 3e9, 'B', -2e3, 'C', 1});
% % MOD = add_to_ee_model(MOD, 'params', {'I', 1e-3});
% fe = @(S) S.A*(S.ipn-S.I)^3 + S.B*(S.ipn-S.I) + S.C; % vpn = cubic in ipn
% MOD = add_to_ee_model(MOD, 'fe', fe);
% MOD = finish_ee_model(MOD);
%
% check_ModSpec(MOD, 0); % 2nd arg: 1 => verbose output, 0 => final result only
%
% % set up a circuit netlist for characteristic curves (vsrc across the device)
% clear ntlst;
% ntlst.cktname = 'vsrc+hys_element';
% ntlst.nodenames = {'1'};
% ntlst.groundnodename = 'gnd';
% ntlst = add_element(ntlst, vsrcModSpec(), 'vsrc', {'1', 'gnd'}, {}, ...
%                          {'DC', 0});
% ntlst = add_element(ntlst, MOD, 'hys_element', {'1', 'gnd'});
% ntlst = add_output(ntlst, 'i(vsrc)', -1); % current through voltage source
%                                            % scaled by -1
% ntlst = add_output(ntlst, 'v(1)'); % voltage at node 1
%
% % set up a DAE from the ckt netlist
% DAE = MNA_EqnEngine(ntlst);
% 
% % run homotopy on the circuit
% lambdaName = 'vsrc:::E'; % voltage of vsrc
% inputORparm = 'input';
% startLambda = 0; stopLambda = 2; lambdaStep = 0.01;
% initguess = 0;
%
% homObj = homotopy(DAE, lambdaName, inputORparm, initguess, startLambda, ...
%                        lambdaStep, stopLambda);
%
% feval(homObj.plot, homObj); % plot DAE-defined outputs wrt lambda
% feval(homObj.plotVsArcLen, homObj); % plot DAE-defined outputs wrt arc-length
% feval(homObj.plot, homObj, StateOutputs(DAE)); % plot all unknowns wrt lambda
%
% % new netlist: resistor in series with the hysteretic device to get a
% % bistable latch for a range of vsrc values
%
% clear ntlst2;
% ntlst2.cktname = 'vsrc+hys_element';
% ntlst2.nodenames = {'1', '2'};
% ntlst2.groundnodename = 'gnd';
% ntlst2 = add_element(ntlst2, vsrcModSpec(), 'vsrc', {'1', 'gnd'}, {}, ...
%                          {'DC', 0});
% ntlst2 = add_element(ntlst2, resModSpec(), 'R', {'1', '2'}, 0.5);
% ntlst2 = add_element(ntlst2, MOD, 'hys_element', {'2', 'gnd'});
% ntlst2 = add_output(ntlst2, 'i(vsrc)', -1); % current through voltage source
%                                             % scaled by -1
% ntlst2 = add_output(ntlst2, 'v(1)'); % voltage at node 1
% ntlst2 = add_output(ntlst2, 'v(2)'); % voltage at node 2
%
% % set up a DAE from the ckt netlist
% DAE2 = MNA_EqnEngine(ntlst2);
%
% % run homotopy on the circuit
% lambdaName = 'vsrc:::E'; inputORparm = 'input';
% startLambda = 0; stopLambda = 2; lambdaStep = 0.01;
% initguess = 0;
%
% homObj2 = homotopy(DAE2, lambdaName, inputORparm, initguess, startLambda, ...
%                        lambdaStep, stopLambda);
%
% feval(homObj2.plot, homObj2); % plot DAE-defined outputs wrt lambda
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 2: homotopy wrt a parameter of a BJT Schmitt Trigger circuit %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % DAE for a BJT Schmitt Trigger circuit
% DAE =  BJTschmittTrigger('BJTschmittTrigger');
% Vinval = 0.6; 
% DAE = feval(DAE.set_uQSS, 'Vin', Vinval, DAE); % fix input Vin to DC value 0.6
%
% lambdaName = 'VCC'; % VCC is a parameter of the DAE
% inputORparm = 'param';
% startLambda = 0;
% stopLambda = 5;
% lambdaStep = 0.1;
%
% % this system is very sensitive to the initial guess (this DAE does not
% % implement init/limiting to help regular DC solution)
% diodedrop = 0.7;
% initguess = [Vinval-diodedrop; ...
%              Vinval-diodedrop; ...
%              0.75*(Vinval-diodedrop); ...
%              0.75*(Vinval-diodedrop)-diodedrop];
% 
% homObj = homotopy(DAE, lambdaName, inputORparm, initguess, startLambda, ...
%                   lambdaStep, stopLambda);
% 
% feval(homObj.plot, homObj); % plot DAE-defined outputs wrt lambda
% feval(homObj.plotVsArcLen, homObj); % plot DAE-defined outputs wrt arc-length
% feval(homObj.plot, homObj, StateOutputs(DAE)); % plot all unknowns wrt lambda
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 3: homotopy wrt an input of a BJT Schmitt Trigger circuit %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % DAE for a BJT Schmitt Trigger circuit
% DAE =  BJTschmittTrigger('BJTschmittTrigger');
%
% lambdaName = 'Vin'; % Vin is an input of the DAE
% inputORparm = 'input';
% startLambda = 5; % sweeping from high to low value
% stopLambda = 0;
% lambdaStep = 0.01;
% maxLambdaStep = lambdaStep; % this is needed for this example
%
% % this system is very sensitive to the initial guess (this DAE does not
% % implement init/limiting to help regular DC solution)
% initguess = [4.3656;4.3678;3.2742;5.0000]; % had to be found by 
%                                            % continuation forward
% 
% homObj = homotopy(DAE, lambdaName, inputORparm, initguess, startLambda, ...
%                   lambdaStep, stopLambda, maxLambdaStep);
% 
% feval(homObj.plot, homObj); % plot DAE-defined outputs wrt lambda
% feval(homObj.plotVsArcLen, homObj); % plot DAE-defined outputs wrt arc-length
% feval(homObj.plot, homObj, StateOutputs(DAE)); % plot all unknowns wrt lambda
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 4: back-to-back MOS inverters (simple CMOS latch) %%%%
% %%%%            with lambda = the VDD of one of the inverters  %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% clear ntlst;
% ntlst.cktname = 'simple CMOS latch';
% ntlst.nodenames = {'1', '2', 'vdd1', 'vdd2'};
% ntlst.groundnodename = 'gnd';
% ntlst = add_element(ntlst, vsrcModSpec(), 'Vdd1', {'vdd1', 'gnd'}, {}, ...
%                          {'DC', 2});
% ntlst = add_element(ntlst, vsrcModSpec(), 'Vdd2', {'vdd2', 'gnd'}, {}, ...
%                          {'DC', 2});
% ntlst = add_element(ntlst, SH_MOS_ModSpec(), 'Minv1_N', {'2', '1', 'gnd'},...
%                      {{'Type', 'N'}, {'Beta', 1.0001e-3}});
% ntlst = add_element(ntlst, SH_MOS_ModSpec(), 'Minv1_P', {'2', '1', 'vdd1'},...
%                      {{'Type', 'P'}, {'Beta', 1e-3}});
% ntlst = add_element(ntlst, SH_MOS_ModSpec(), 'Minv2_N', {'1', '2', 'gnd'},...
%                      {{'Type', 'N'}, {'Beta', 1.000e-3}});
% ntlst = add_element(ntlst, SH_MOS_ModSpec(), 'Minv2_P', {'1', '2', 'vdd2'},...
%                      {{'Type', 'P'}, {'Beta', 1.0001e-3}});
% ntlst = add_output(ntlst, 'v(1)'); % voltage at node 1
% ntlst = add_output(ntlst, 'v(2)'); % voltage at node 2
%
% % set up a DAE from the ckt netlist
% DAE = MNA_EqnEngine(ntlst);
%
% % run homotopy on the circuit
% lambdaName = 'Vdd1:::E'; inputORparm = 'input';
% startLambda = 2; stopLambda = 0; lambdaStep = 0.01;
% homObj = homotopy(DAE, lambdaName, inputORparm, 0, ...
%                              0, lambdaStep, 3.9);
% homObj.plot(homObj); 
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 5: back-to-back MOS inverters (simple CMOS latch using  %%%%
% %%%%            the Schichman-Hodges MOS model) with lambda = VDD.   %%%%
% %%%%            sweep goes through a bifurcation.                    %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% clear ntlst;
% ntlst.cktname = 'simple CMOS latch';
% ntlst.nodenames = {'1', '2', 'vdd'};
% ntlst.groundnodename = 'gnd';
% ntlst = add_element(ntlst, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, ...
%                          {'DC', 2});
% ntlst = add_element(ntlst, SH_MOS_ModSpec(), 'Minv1_N', {'2', '1', 'gnd'},...
%                      {{'Type', 'N'}, {'Beta', 1.0001e-3}});
% ntlst = add_element(ntlst, SH_MOS_ModSpec(), 'Minv1_P', {'2', '1', 'vdd'},...
%                      {{'Type', 'P'}, {'Beta', 1e-3}});
% ntlst = add_element(ntlst, SH_MOS_ModSpec(), 'Minv2_N', {'1', '2', 'gnd'},...
%                      {{'Type', 'N'}, {'Beta', 1.000e-3}});
% ntlst = add_element(ntlst, SH_MOS_ModSpec(), 'Minv2_P', {'1', '2', 'vdd'},...
%                      {{'Type', 'P'}, {'Beta', 1.0001e-3}});
% ntlst = add_output(ntlst, 'v(1)'); % voltage at node 1
% ntlst = add_output(ntlst, 'v(2)'); % voltage at node 2
%
% % set up a DAE from the ckt netlist
% DAE = MNA_EqnEngine(ntlst);
% %dcop = op(DAE); dcop.print(dcop); % finds the middle solution (unstable)
% dcop = op(DAE, [2;0;2;0], 'init', 0); dcop.print(dcop); % latch state 1
% initguessState1 = feval(dcop.getsolution, dcop);
% dcop = op(DAE, [0;2;2;0], 'init', 0); dcop.print(dcop); % latch state 2
% initguessState2 = feval(dcop.getsolution, dcop);
%
% % run homotopy
% % Note that this circuit/homotopy features a simple bifurcation. 
% % Below a critical value of VDD, there is only 1
% % solution (the Middle solution); above this value, there are
% % 3 solutions, as expected for a bistable circuit: the Middle, State1 and
% % State2 solutions, with the Middle solution dynamically unstable. The
% % bifurcation happens at this critical value of VDD.
%
% % MAPP's homotopy currently does not handle tracking all the branches at
% % a bifurcation (though it does detect and report stepping over one). 
% % What we do below is run homotopy thrice to get the three
% % bifurcating tracks separately, then plot them together to see the the
% % complete structure of DC solutions.
% %
% lambdaName = 'Vdd:::E'; inputORparm = 'input';
% startLambda = 2; stopLambda = 0; lambdaStep = 0.01;
% %The following doesn't work because MNA_EqnEngine does not yet have
% %parameter derivative support. Should probably hack it in ArcContDAE for
% %for efficiency.
% %lambdaName = 'Minv1_N:::Beta'; inputORparm = 'param';
% %startLambda = 0; stopLambda = 1e-3; lambdaStep = 1e-5;
% maxLambda = 4; minLambda = -1;
%
% homObj1 = homotopy(DAE, lambdaName, inputORparm, initguessState1, ...
%                              startLambda, lambdaStep, stopLambda, ...
%                              [], maxLambda, minLambda);
%
% sol1 = homObj1.getsolution(homObj1); %homObj1.plot(homObj1); 
%
% homObj2 = homotopy(DAE, lambdaName, inputORparm, initguessState2, ...
%                              startLambda, lambdaStep, stopLambda, ...
%                              [], maxLambda, minLambda);
%
% sol2 = homObj2.getsolution(homObj2); % homObj2.plot(homObj2); 
%
% % this one goes over a bifurcation (watch the diagnostic output)
% homObjM = homotopy(DAE, lambdaName, inputORparm, 0, ...
%                              0, lambdaStep, 3.9, ...
%                              [], maxLambda, minLambda);
% solM = homObjM.getsolution(homObjM); % homObjM.plot(homObjM); 
%
% % plot them all together, in 2- and 3-D. Here is a situation where getting
% % the numerical data for the homotopy tracks (using homObj.getsolution())
% % is useful.
% figure(); % 2D plot
% v1idx = feval(DAE.unkidx, 'e_1', DAE); v2idx = feval(DAE.unkidx, 'e_2', DAE);
% plot(sol2.yvals(end,:), sol2.yvals(v1idx,:), 'bo-', ...
%      sol1.yvals(end,:), sol1.yvals(v1idx,:), 'b.-', ...
%      solM.yvals(end,:), solM.yvals(v1idx,:), 'c+-');
% hold on;
% plot(sol2.yvals(end,:), sol2.yvals(v2idx,:), 'go-', ...
%      sol1.yvals(end,:), sol1.yvals(v2idx,:), 'g.-', ...
%      solM.yvals(end,:), solM.yvals(v2idx,:), 'r+-');
% grid on; axis tight;
% xlabel('lambda=Vdd');
% ylabel('v1 and v2');
% legend({'v1 (State2)', 'v1 (State1)', 'v1 (Middle)', 'v2 (State2)', ...
%         'v2 (State1)', 'v2 (Middle)' });
% title('simple CMOS latch with VDD ramped: multiple homotopy tracks overlaid');
%
% figure(); % 3D plot to show the simple bifurcation better
% plot3(solM.yvals(end,:), solM.yvals(v1idx,:), solM.yvals(v2idx,:), 'r.-');
% hold on;
% plot3(sol1.yvals(end,:), sol1.yvals(v1idx,:), sol1.yvals(v2idx,:), 'b.-');
% plot3(sol2.yvals(end,:), sol2.yvals(v1idx,:), sol2.yvals(v2idx,:), 'g.-');
% xlabel('lambda=Vdd');
% ylabel('v1');
% zlabel('v2');
% grid on; axis tight;
% title('simple CMOS latch with VDD ramped: multiple homotopy tracks overlaid');
% legend({'Middle Track', 'State1 Track', 'State2 Track'});
% view(50, -10);
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 6: hysteresis/folds in cross-coupled MVS diffpair       %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DAE =  MNA_EqnEngine(MVSxCoupledDiffpairIsrc_ckt());
%
% % This ckt has DC convergence problems at Iin=-1e-3. The following initguess
% % was found by running a homotopy to -1e-3 starting from 0, as follows:
% % hom = homotopy(DAE, 'Iin:::I', 'input', [], 0, 5e-5, 1e-3, [], 1e-3, -1e-3);
% % homsol = feval(hom.getsolution, hom);
% % initguess = homsol.yvals(1:(end-1),end)
% initguess = [0.7520;5.0366;0.9634;5;-2e-3;4.1844;0.1002;0.1116;0.0998];
%
% % homotopy wrt an input (Iin)
% hom = homotopy(DAE, 'Iin:::I', 'input', initguess, -1e-3, 5e-5, 1e-3);
% feval(hom.plot, hom); souts = StateOutputs(DAE); feval(hom.plot, hom, souts);
%
% % %% homotopy wrt a parameter 
% % the following init guess (upper bistable state) obtained by 
% % hom = homotopy(DAE, 'Iin:::I', 'input', initguess, -1e-3, 5e-5, 0);
% stateUP = [1.7863;3.8817;2.1183;5;-0.0020;2.0395;0.0559;0.1879;0.1441];
%
% % lambda = 'MR:::Rs0' (from 210 up, turning point at ~213, stop back at 210)
% DAE = feval(DAE.set_uQSS, 'Iin:::I', 0, DAE);
% lstart = 210; lstep = 1e-2; lstop = 220; maxstep = 0.1; maxl = 214; minl=210;
% hom2 = homotopy(DAE, 'MR:::Rs0', 'param', stateUP, lstart, lstep, ...
%                         lstop, maxstep, maxl, minl);
% feval(hom2.plot, hom2); feval(hom2.plot, hom2, souts);
% 
% % BUG: larger lambda step => doubles back on the track - likely scaling issue
% % (because Rs is ~200, voltages are ~1, probably tangent vector inaccuracy)
% lstart = 200; lstep = 0.5; lstop = 220; maxlstep = 0.5; maxl = 214; minl=200;
% hom2 = homotopy(DAE, 'MR:::Rs0', 'param', stateUP, lstart, lstep, ...
%                         lstop, maxlstep, maxl, minl);
% feval(hom2.plot, hom2); feval(hom2.plot, hom2, souts);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Example 7: back-to-back MOS inverters (simple CMOS latch) with  %%%%
% %%%%            lambda = VDD, using the MVS 1.0.1 model. This sweep  %%%%
% %%%%            goes through a simple bifurcation.                   %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % just run this script (see within for details)
% test_ArcCont_MVS_back_to_back_inverters_bifurcation % warning: very slow
%
%Notes
%-----
%- You can run homotopy on a MATLAB function g(x, lambda) = 0 directly (ie,
%  without embedding it in a DAE). See ArcCont for details. TODO
%- homotopy() is just a wrapper around ArcContAnalysis.
%
%See also
%--------
%  homotopy_concepts [TODO], ArcContAnalysis [TODO], ArcCont [TODO], 
%  test_ArcCont_MVS_back_to_back_inverters_bifurcation, model_starter, 
%  model_exerciser
%            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2015/05/30.                                        %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 
% Debugging Example 1 above (char curve of vEQcubicINi):
% % THIS IS WHAT HAPPENS WHEN i is SCALED to mA: MPPI-NR is not accurate in
% % getting the tangent vector right, leading to convergence problems, then
% % getting the tangent vector wrong, going backwards on the track, and cutting
% % the step to very small amounts.
% % AND GOES BACKWARD AD INFINITUM.  THIS NEEDS DEBUGGING AROUND HERE (1: WHY
% % DOES NR FAIL - BAD PREDICTOR? 2: WHY DOES deltas reduce in 1 jump from 1e-4
% % to 1e-9?):
% % MLS-NR succeeded: lambda=1.62756, deltas=0.000282843
% % +...*
% % MLS-NR succeeded: lambda=1.62776, deltas=0.000282842
% % +...*
% % MLS-NR succeeded: lambda=1.62796, deltas=0.000282842
% % +...*
% % MLS-NR succeeded: lambda=1.62816, deltas=0.000282842
% % +...*
% % MLS-NR succeeded: lambda=1.62836, deltas=0.00028284
% % +...................
% % NR failed to solve nonlinear equations - reached maxiter=20
% % MPPINR_corrector failed
% % /...*
% % MLS-NR succeeded: lambda=1.62846, deltas=0.000141417
% % +...............*
% % MLS-NR succeeded: lambda=1.62854, deltas=0.000115777
% % |+...................
% % NR failed to solve nonlinear equations - reached maxiter=20
% % MPPINR_corrector failed
% % /..............*
% % MLS-NR succeeded: lambda=1.62854, deltas=2.43217e-09
% % |+.*
% % MLS-NR succeeded: lambda=1.62854, deltas=2.21092e-09
% % \+.*
% % MLS-NR succeeded: lambda=1.62854, deltas=2.32131e-09
% % \+.*
% % MLS-NR succeeded: lambda=1.62854, deltas=2.43718e-09
% % \+.*
% % MLS-NR succeeded: lambda=1.62854, deltas=2.55881e-09
% % \+.*
% % MLS-NR succeeded: lambda=1.62854, deltas=2.68649e-09
%
% % DEBUG: solution at lambda = 1.61 (by running homotopy to 1.61 and getting
% % finalSol): 
% % newinitguess = [1.610000000000000e+00; ...
% %                 -4.639521552341468e-01; ...
% %                 4.639521552341468e-01];
% homObj = homotopy(DAE, lambdaName, inputORparm, initguess, ...
%                   startLambda, 0.01, 1.61);
% % And this worked fine once, then didn't after MATLAB was restarted (!):
% newinitguess = homObj.solution.finalSol;
% homObj = homotopy(DAE, lambdaName, inputORparm, newinitguess, ...
%                   1.61, 0.01, stopLambda);
%
% 

    % default argument processing
	if nargin < 3 || isempty(inputORparm)
		inputORparm = 'input';
    end

	if nargin < 4 || isempty(initguess)
		initguess = 'DC';
    end

	if nargin < 5 || isempty(startLambda)
        startLambda = 0;
    end
    
	if nargin < 7 || isempty(stopLambda)
        stopLambda = 1;
    end

	if nargin < 6 || isempty(stopLambda)
        lambdaStep = (stopLambda-startLambda)/100.0;
    end
    % end default argument processing (maxLambdaStep and later args are 
    % handled below)

    % check that lambdaName is valid
    if strcmpi(inputORparm, 'input')
        found = find(strcmp(lambdaName, feval(DAE.inputnames, DAE)));
        if ~(length(found) == 1)
            error('homotopy: input %s not found exactly once in DAE', ...
                    lambdaName);
        end
        % set the input's DC value to startLambda 
        fprintf(2, 'homotopy: setting input %s=%g.\n', lambdaName, ...
                                                                startLambda);
        DAE = feval(DAE.set_uQSS, lambdaName, startLambda, DAE);
        inputORparam = 1; % 1 => lambda is an input (for ArcContAnalysis)
    elseif strcmpi(inputORparm, 'param') || strcmpi(inputORparm, 'parm') ...
            || strcmpi(inputORparm, 'parameter')
        found = find(strcmp(lambdaName, feval(DAE.parmnames, DAE)));
        if ~(length(found) == 1)
            error('homotopy: parameter %s not found exactly once in DAE', ...
                    lambdaName);
        end
        fprintf(2, 'homotopy: setting parameter %s=%g.\n', lambdaName, ...
                                                                startLambda);
        DAE = feval(DAE.setparms, lambdaName, startLambda, DAE);
        inputORparam = 0; % 0 => lambda is a parameter (for ArcContAnalysis)
    else
        error('homotopy: bad argument inputORparm: %s not valid', inputORparam);
    end

    % set up/check initguess
    if ischar(initguess)
        if strcmpi(initguess, 'DC') || strcmp(initguess, 'QSS')
            fprintf(2, 'homotopy: running DC analysis to find initguess...\n');
            DC = op(DAE); initguess = feval(DC.getsolution, DC);
        elseif strcmpi(initguess, 'rand')
            fprintf(2, 'homotopy: using rand() for initguess...\n');
            initguess = rand(feval(DAE.nunks, DAE), 1);
        elseif strcmpi(initguess, 'randn')
            fprintf(2, 'homotopy: using randn() for initguess...\n');
            initguess = randn(feval(DAE.nunks, DAE), 1);
        else
            error('homotopy: xinit=%s not valid.\n', initguess);
        end
    end
    if (1==length(initguess) && 0 == initguess)
        fprintf(2, 'homotopy: using zero initial guess...\n');
        initguess = zeros(feval(DAE.nunks, DAE), 1);
    end
    if length(initguess) ~= feval(DAE.nunks, DAE)
        error('homotopy: initguess is of wrong size (%g), should be %g.', ...
                length(initguess), feval(DAE.nunks, DAE));
    end


    if abs(lambdaStep) > abs(startLambda-stopLambda)
        error('homotopy: |lambdaStep|(=%g) too large: should be <= |stopLambda-startLambda|(=%g).\n', ...
                    abs(lambdaStep), abs(stopLambda-startLambda));
    end

    homObj = ArcContAnalysis(DAE, lambdaName, inputORparam);
    homObj.parms.dbglvl = 2;
    if ~(nargin < 8 || isempty(maxLambdaStep))
        homObj.parms.maxDeltaLambda = maxLambdaStep;
    end
    if ~(nargin < 9 || isempty(maxLambda))
        homObj.parms.MaxLambda = maxLambda;
    end
    if ~(nargin < 10 || isempty(minLambda))
        homObj.parms.MinLambda = minLambda;
    end
    if ~(nargin < 11 || isempty(maxArcLength))
        homObj.parms.MaxArcLength = maxArcLength;
    end
    homObj = feval(homObj.solve, homObj, initguess, startLambda, ...
             stopLambda, lambdaStep);
end % homotopy
