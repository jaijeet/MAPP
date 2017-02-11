RRAM_Model = RRAM_ModSpec_wrapper_v0;
RRAM_Model = RRAM_ModSpec_wrapper_v1;
RRAM_Model = RRAM_ModSpec_wrapper_v2;

% set up DAE
DAE = MNA_EqnEngine(RRAM_res_ckt(RRAM_Model));

% % DC analysis
% dcop = dot_op(DAE);
% feval(dcop.print, dcop);

% run transient simulation
% xinit = feval(dcop.getsolution, dcop);
xinit = [5; 2.5; 1e-9; 0];
tstart = 0; tstep = 0.5e-7; tstop = 20e-6;
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
grid on;

%{
	DAE = DAE.set_utransient('Vdd:::E', @(t, args) 5, [], DAE);
	xinit = [5; 2.5; 1e-9; 0];
	tstart = 0; tstep = 0.2e-5; tstop = 20e-4;
	LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
	feval(LMSobj.plot, LMSobj);
%}
