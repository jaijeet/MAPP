do_tran = 1;
do_dc = 1;
do_hom = 1;

clear ckt; 
ckt.cktname = 'RRAM test bench';
ckt.nodenames = {'1', '2'};
ckt.groundnodename = 'gnd';
tranfunc = @(t, args) args.offset+args.A*sawtooth(2*pi/args.T*t+args.phi, 0.5);
tranargs.offset = 0; tranargs.A = 2; tranargs.T = 8e-3; tranargs.phi=0;
ckt = add_element(ckt, vsrcModSpec(), 'Vin', ...
   {'1', 'gnd'}, {}, {{'DC', 1}, {'TRAN', tranfunc, tranargs}});
ckt = add_element(ckt, resModSpec(), 'R1', {'1', '2'}, 100);
ckt = add_element(ckt, RRAM_ModSpec(), 'R2', {'2', 'gnd'}, {});

% set up DAE
DAE = MNA_EqnEngine(ckt);

% DC OP analysis
dcop = dot_op(DAE);
dcop.print(dcop); dcSol = dcop.getSolution(dcop);

if do_tran
    % transient simulation, sweep Vin
    tstart = 0; tstep = 1e-5; tstop = 8e-3;
    xinit = [0; 0; 0; 1.7];
    LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
    LMSobj.plot(LMSobj);

    % get transient data, plot current in log scale
    [tpts, sols] = LMSobj.getSolution(LMSobj);
    figure; semilogy(sols(1,:), abs(sols(2,:)));
    xlabel('Vin (V)'); ylabel('log(current) (A)'); grid on;
end

if do_dc
    swp = dcsweep(DAE, [], 'Vin:::E', -1:0.01:1);
    swp.plot(swp);
end

if do_hom
    % homotopy analysis
    startLambda = 1; stopLambda = -1; lambdaStep = -1e-1;
    hom = homotopy(DAE, 'Vin:::E', 'input', dcSol, startLambda, lambdaStep, stopLambda);
    hom.plot(hom);
end
