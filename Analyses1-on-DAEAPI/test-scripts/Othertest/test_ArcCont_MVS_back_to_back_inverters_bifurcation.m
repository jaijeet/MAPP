%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Example 5: back-to-back MOS inverters (simple CMOS latch) with  %%%%
%%%%            lambda = VDD. This sweep goes through a bifurcation. %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
clear ntlst;
ntlst.cktname = 'simple CMOS latch';
ntlst.nodenames = {'1', '2', 'vdd'};
ntlst.groundnodename = 'gnd';
ntlst = add_element(ntlst, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, ...
                         {'DC', 2});
NMOD = MVS_1_0_1_ModSpec_vv4();
%NMOD = MVS_1_0_1_ModSpec_vv4_directly_from_aadithya_branch();
%NMOD = MVS_1_0_1_ModSpec();
%NMOD = MVS_1_0_1_ModSpec_wrapper();
NMOD = feval(NMOD.setparms, {{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, ...
                             {'dLg', 9e-7}, {'Cg', 2.57e-6}, ...
                             {'Beta', 1.8}, {'Alpha', 3.5}, {'Tjun', 300}, ...
                             {'Cif', 1.38e-12}, {'Cof', 1.47e-12}, ...
                             {'phib', 1.2}, {'Gamma', 0.1}, ...
                             {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100}, ...
                             {'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, ...
                             {'vxo', 1.2e7}, {'Mu', 200}, {'Vt0', 0.4}, ...
                             {'delta', 0.15}
                            }, NMOD);
PMOD = NMOD;
PMOD = feval(PMOD.setparms, {{'Type', -1}, {'W', 1.0e-4}, {'Lgdr', 32e-7}, ...
                             {'dLg', 8e-7}, {'Cg', 2.57e-6}, {'Beta', 1.8}, ...
                             {'Alpha', 3.5}, {'Tjun', 300}, ...
                             {'Cif', 1.38e-12}, {'Cof', 1.47e-12}, ...
                             {'phib', 1.2}, {'Gamma', 0.1}, {'mc', 0.2}, ...
                             {'CTM_select', 1}, {'Rs0', 100}, ...
                             {'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, ...
                             {'vxo', 7542204}, {'Mu', 165}, ...
                             {'Vt0', 0.5535}, {'delta', 0.15}...
                            }, PMOD);

ntlst = add_element(ntlst, NMOD, 'Minv1_N', {'2', '1', 'gnd', 'gnd'}, ...
                                                            {{'Type', 1}});
ntlst = add_element(ntlst, PMOD, 'Minv1_P', {'2', '1', 'vdd', 'vdd'}, ...
                                                            {{'Type', -1}});
ntlst = add_element(ntlst, NMOD, 'Minv2_N', {'1', '2', 'gnd', 'gnd'}, ...
                                                            {{'Type', 1}});
ntlst = add_element(ntlst, PMOD, 'Minv2_P', {'1', '2', 'vdd', 'vdd'}, ...
                                                            {{'Type', -1}});
ntlst = add_output(ntlst, 'v(1)'); % voltage at node 1
ntlst = add_output(ntlst, 'v(2)'); % voltage at node 2
 
% set up a DAE from the ckt netlist
DAE = MNA_EqnEngine(ntlst);
dcop = op(DAE); dcop.print(dcop); % finds the middle solution (unstable)

dcop = op(DAE, [2;0;2;0;2;0;0;0;0;0;2;0], 'init', 0); dcop.print(dcop); 
initguessState1 = feval(dcop.getsolution, dcop);
dcop = op(DAE, [0;2;2;0;0;0;2;0;2;0;0;0], 'init', 0); dcop.print(dcop);
initguessState2 = feval(dcop.getsolution, dcop);
 
% run homotopy
% Note that this circuit/homotopy features a simple bifurcation. 
% Below a critical value of VDD, there is only 1
% solution (the Middle solution); above this value, there are
% 3 solutions, as expected for a bistable circuit: the Middle, State1 and
% State2 solutions, with the Middle solution dynamically unstable. The
% bifurcation happens at this critical value of VDD.
 
% MAPP's homotopy currently does not handle tracking all the branches at
% a bifurcation (though it does detect and report stepping over one). 
% What we do below is run homotopy thrice to get the three
% bifurcating tracks separately, then plot them together to see the the
% complete structure of DC solutions.
%
lambdaName = 'Vdd:::E'; inputORparm = 'input';
startLambda = 0.3; stopLambda = 0; lambdaStep = 0.005;
%The following doesn't work because MNA_EqnEngine does not yet have
%parameter derivative support. Should probably hack it in ArcContDAE for
%for efficiency.
%lambdaName = 'Minv1_N:::Beta'; inputORparm = 'param';
%startLambda = 0; stopLambda = 1e-3; lambdaStep = 1e-5;
maxLambdaStep = lambdaStep; maxLambda = 0.31; minLambda = -1;
 
homObj1 = homotopy(DAE, lambdaName, inputORparm, initguessState1, ...
                             startLambda, lambdaStep, stopLambda, ...
                             maxLambdaStep, maxLambda, minLambda);
 
sol1 = homObj1.getsolution(homObj1); %homObj1.plot(homObj1); 
 
%{
NOT NEEDED - homObj1 gets this, too, if the stepping is done carefully
homObj2 = homotopy(DAE, lambdaName, inputORparm, initguessState2, ...
                             startLambda, lambdaStep, stopLambda, ...
                             maxLambdaStep, maxLambda, minLambda);
 
sol2 = homObj2.getsolution(homObj2); % homObj2.plot(homObj2); 
%}
 
% this one goes over a bifurcation (watch the diagnostic output)
homObjM = homotopy(DAE, lambdaName, inputORparm, 0, ...
                             stopLambda, lambdaStep, startLambda, ...
                             [], maxLambda, minLambda);
solM = homObjM.getsolution(homObjM); % homObjM.plot(homObjM); 
 % plot them all together, in 2- and 3-D. Here is a situation where getting
% the numerical data for the homotopy tracks (using homObj.getsolution())
% is useful.
figure(); % 2D plot
v1idx = feval(DAE.unkidx, 'e_1', DAE); v2idx = feval(DAE.unkidx, 'e_2', DAE);
plot(sol1.yvals(end,:), sol1.yvals(v1idx,:), 'bo-', ...
     solM.yvals(end,:), solM.yvals(v1idx,:), 'c+-');
hold on;
plot(sol1.yvals(end,:), sol1.yvals(v2idx,:), 'go-', ...
     solM.yvals(end,:), solM.yvals(v2idx,:), 'r+-');
grid on; axis tight;
xlabel('lambda=Vdd');
ylabel('v1 and v2');
legend({'v1 (State1)', 'v1 (Middle)', 'v2 (State1)', 'v2 (Middle)' });
title('simple CMOS latch with VDD ramped: multiple homotopy tracks overlaid');
 
figure(); % 3D plot to show the simple bifurcation better
plot3(solM.yvals(end,:), solM.yvals(v1idx,:), solM.yvals(v2idx,:), 'r.-');
hold on;
plot3(sol1.yvals(end,:), sol1.yvals(v1idx,:), sol1.yvals(v2idx,:), 'b.-');
%plot3(sol2.yvals(end,:), sol2.yvals(v1idx,:), sol2.yvals(v2idx,:), 'g.-');
xlabel('lambda=Vdd');
ylabel('v1');
zlabel('v2');
grid on; axis tight;
title('simple CMOS latch with VDD ramped: multiple homotopy tracks overlaid');
legend({'Middle Track', 'State1 Track'});
view(50, -10);
 

