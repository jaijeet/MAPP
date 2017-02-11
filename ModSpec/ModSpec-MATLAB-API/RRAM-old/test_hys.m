clear ckt;
ckt.cktname = 'hys_ckt';
ckt.nodenames = {'1'};
ckt.groundnodename = 'gnd';
mysinfunc = @(t, args) 0.7 * sin(2*pi*1e3*t);
ckt = add_element(ckt, vsrcModSpec(), 'V1', ...
   {'1', 'gnd'}, {}, {{'DC', 0}, {'TRAN', mysinfunc, []}});
ckt = add_element(ckt, hys_ModSpec(), 'H1', {'1', 'gnd'});

% create DAE
DAE = MNA_EqnEngine(ckt); 

% forward DC sweep
swp1 = dcsweep(DAE, [], 'V1:::E', -1:0.015:1);
[pts1, sols1] = swp1.getSolution(swp1);
figure; plot(pts1(1,:), -sols1(2,:), '.-r'); drawnow; % V1::ipn

% backward DC sweep
swp2 = dcsweep(DAE, [], 'V1:::E', 1:-0.015:-1);
[pts2, sols2] = swp2.getSolution(swp2);
hold on; plot(pts2(1,:), -sols2(2,:), '.-b'); drawnow; % V1::ipn

% run transient simulation
tran = dot_transient(DAE, [], 0, 5e-6, 2.5e-3);
[tpts, sols] = tran.getSolution(tran);

% plot transient
hold on; plot(sols(1,:), -sols(2,:), '.-k'); % e_1, V1::ipn
xlabel('V1:::E (V)'); ylabel('-V1:::ipn (A)'); grid on;
legend('forward DC sweep', 'backward DC sweep', 'transient');

figure; plot(pts1(1,:), sols1(3,:), '.-r'); % H1:::s
hold on; plot(pts2(1,:), sols2(3,:), '.-b'); % H1:::s
hold on; plot(sols(1,:), sols(3,:), '.-k'); % H1:::s
legend('forward DC sweep', 'backward DC sweep', 'transient');
xlabel('V1:::E (V)'); ylabel('H1:::s'); grid on;

% run homotopy analysis
startLambda = -1; stopLambda = 1; lambdaStep = 1e-1; initguess = [-1;0;-1];
hom = homotopy(DAE, 'V1:::E', 'input', initguess, startLambda, lambdaStep, stopLambda);
hom.plot(hom);

souts = StateOutputs(DAE); souts = souts.DeleteAll(souts);
souts = souts.Add({'V1:::ipn'}, souts); hom.plot(hom, souts);

sols = hom.getsolution(hom);
figure; plot3(sols.yvals(1,:), sols.yvals(2,:), sols.yvals(3,:));
unk_names = DAE.unknames(DAE);
xlabel(unk_names{1}); ylabel(unk_names{2}); zlabel(unk_names{3});
grid on; box on;
