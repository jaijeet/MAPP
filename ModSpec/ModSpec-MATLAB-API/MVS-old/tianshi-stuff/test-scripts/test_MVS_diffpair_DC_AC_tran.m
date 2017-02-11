%author: Tianshi Wang, 2012/09/17
%
% TODO: help strings obsolete.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%
% An ideal-ish differential pair using MVS MOSFETs.
% The emitters of 2 N-type MOSFETs are connected at node nS.
% An ideal current source of DC value IS drains node S.
% The drain of the MOSFET on the left is connected
% to node nDL (node voltage eDL); that of the one on the right to node nDR (node
% voltage eDR). Resistors rL and rR connect from VDD to nodes nDL and nDR,
%
% The MOSFET on the left has its gate connected to Vin; that of the one on the right 
% connects to ground. The circuit is, therefore, not perfectly symmetric. This
% lack of symmetry shows up in different DC components at the two output nodes
% with large Vin, and exacerbated if you use an insufficient number of harmonics.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cktdata = MVS_diffpair_ckt;

% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine(cktdata);

doOP = 1;
doDCsweep = 0;
doAC = 0;
doTran = 0;

outputs = StateOutputs(DAE); %to plot all state vars
% outputs = feval(outputs.DeleteAll, outputs);
% outputs = feval(outputs.Add, {'e_DL', 'e_DR', 'e_S'}, outputs);

if 1 == doOP
	fprintf(2, 'Running an operating point analysis:\n');
	% x0 = rand(feval(DAE.nunks, DAE),1);
	% qss = dot_op(DAE, x0);
	qss = dot_op(DAE);
	feval(qss.print, qss);
	qssSol = feval(qss.getsolution, qss);

	fprintf(2, '\nOperating point analysis done, hit Return to continue:\n'); pause;
end

if 1 == doDCsweep
	fprintf(2, 'Running a DC sweep analysis:\n');
	swp = dot_dcsweep(DAE, [], 'Vin:::E', -1, 1, 20);
	% print and plot
	feval(swp.plot, swp);
	% feval(swp.print, swp); % not implemented yet

	fprintf(2, '\nDC sweep analysis done, hit Return to continue:\n'); pause;
end

if 1 == doAC
	fprintf(2, 'Running AC analyses at %d different operating points:\n', nops);

    % set AC analysis input as a function of frequency
    Ufargs.string = 'no args used';; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    DAE = feval(DAE.set_uLTISSS, 'Vin:::E', Uffunc, Ufargs, DAE);
   
    % run the AC analysis
    sweeptype = 'DEC'; fstart=1e3; fstop=1e9; nsteps=10;
	uDC = feval(DAE.uQSS, DAE);

    acobj = dot_ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
   
    % plot frequency sweeps of system outputs (overlay all on 1 plot)
    feval(acobj.plot, acobj);

	fprintf(2, '\nAC analyses done, hit Return to continue:\n'); pause;
end

if 1 == doTran
	fprintf(2, 'Running transient analysis\n');

	% set transient inputs
	args.f = 1e8;
	args.A = 0.5;
	sinfunc = @(t, args) args.A*sin(args.f*2*pi*t);
	DAE = feval(DAE.set_utransient, 'Vin:::E', sinfunc, args, DAE);

	% DAE = feval(DAE.set_utransient, 'vdd:::E', @(t,a) 5, [], DAE);
	% DAE = feval(DAE.set_utransient, 'IS:::I', @(t,a) 2e-3, [], DAE);
	tstart=0; tstep=0.05e-8; tstop=3e-8;
	TransObj = dot_tran(DAE, qssSol, tstart, tstep, tstop);
	feval(TransObj.plot, TransObj);

	fprintf(2, '\nTransient analyses done.');
end
