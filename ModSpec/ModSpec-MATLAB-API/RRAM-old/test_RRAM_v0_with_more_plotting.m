clear ckt; 
ckt.cktname = 'RRAM v0 test bench';
ckt.nodenames = {'in'};
ckt.groundnodename = 'gnd';
tranfunc = @(t, args) args.offset+args.A*sawtooth(2*pi/args.T*t+args.phi, 0.5)
tranargs.offset = 0; tranargs.A = 2; tranargs.T = 8e-3; tranargs.phi=0;
ckt = add_element(ckt, vsrcModSpec(), 'Vin', ...
   {'in', 'gnd'}, {}, {{'DC', 1}, {'TRAN', tranfunc, tranargs}});
ckt = add_element(ckt, RRAM_v0_ModSpec(), 'R1', {'in', 'gnd'}, {});

% set up DAE
DAE = MNA_EqnEngine(ckt);

% DC OP analysis
dcop = dot_op(DAE);
dcop.print(dcop);

% transient simulation, sweep Vin
tstart = 0; tstep = 1e-5; tstop = 8.1e-3;
xinit = [0; 0; 1.7];
LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
LMSobj.plot(LMSobj);

% plot selected state outputs
souts = StateOutputs(DAE);
souts = souts.DeleteAll(souts); souts = souts.Add({'R1:::Gap'}, souts);
feval(LMSobj.plot, LMSobj, souts);
souts = souts.DeleteAll(souts); souts = souts.Add({'Vin:::ipn'}, souts);
feval(LMSobj.plot, LMSobj, souts);

[tpts, sols] = LMSobj.getSolution(LMSobj);
figure; semilogy(sols(1,:), abs(sols(2,:)));
xlabel('Vin (V)'); ylabel('log(current) (A)'); grid on;

