% RRAM_Model = RRAM_tianshi_v0;
% RRAM_Model = rram_VAPP;
RRAM_Model = RRAM_tianshi_v1;

% set up DAE
DAE = MNA_EqnEngine(RRAM_tianshi_res_ckt(RRAM_Model));

% % DC analysis
% DAE = set_uQSS(0, DAE);
% dcop = dot_op(DAE);
% feval(dcop.print, dcop);

% run transient simulation
tranargs.offset = 0; tranargs.A = 5; tranargs.T = 2e-2; tranargs.phi = pi/2;
tranfunc = @(t, args) args.offset+args.A*sawtooth(2*pi/args.T*t + args.phi, 0.5);
DAE = set_utransient(tranfunc, tranargs, DAE);

% xinit = feval(dcop.getsolution, dcop);
xinit = [0; 0; 0; 0];

tstart = 0; tstep = 1e-4; tstop = 2e-2;
LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);

% plot DAE outputs (defined using add_output inside vsrcRCL_ckt.m)
feval(LMSobj.plot, LMSobj);

% plot selected state outputs
souts = StateOutputs(DAE);
souts = souts.DeleteAll(souts);
souts = souts.Add({'RRAM1:::l'}, souts);
feval(LMSobj.plot, LMSobj, souts);
souts = souts.DeleteAll(souts);
souts = souts.Add({'Vdd:::ipn'}, souts);
feval(LMSobj.plot, LMSobj, souts);

[tpts, sols] = LMSobj.getSolution(LMSobj);
% DAE.unknames(DAE): 'e_n1' 'e_n2' 'RRAM1:::l' 'Vdd:::ipn'
figure; semilogy(sols(1,:), abs(sols(4,:))); % negative data?
xlabel('V1 (V)');
ylabel('current (A)');
grid on;

%{
	DAE = DAE.set_utransient('Vdd:::E', @(t, args) 5, [], DAE);
	xinit = [5; 2.5; 1e-9; 0];
	tstart = 0; tstep = 0.2e-5; tstop = 20e-4;
	LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
	feval(LMSobj.plot, LMSobj);
%}
