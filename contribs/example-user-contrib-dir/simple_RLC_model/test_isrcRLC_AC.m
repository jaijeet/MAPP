% This is a test script for isrcRCL_ckt, a test circuit for RLC_ModSpec_wrapper
% device.
% It calcualtes DC operating point, then runs AC simulation on the circuit.

	% set up DAE
	DAE = MNA_EqnEngine(isrcRLC_ckt);

	% DC analysis
    % -----------
		dcop = dot_op(DAE);
		dcop.print(dcop);
		qssSol = dcop.getsolution(dcop);

	% AC analysis
    % -----------
		% set AC analysis input as a function of frequency:
		Ufargs.string = 'no args used';; % 
		Uffunc = @(f, args) 1; % constant U(j 2 pi f) = 1
		DAE = feval(DAE.set_uLTISSS, 'i1:::I', Uffunc, Ufargs, DAE);

		% run the AC analysis
		sweeptype = 'DEC'; fstart=1e6; fstop=1e8; nsteps=30;
		uDC = feval(DAE.uQSS, DAE);
		ACobj = dot_ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
		% plot frequency sweeps of system outputs (overlay all on 1 plot)
		ACobj.plot(ACobj);
