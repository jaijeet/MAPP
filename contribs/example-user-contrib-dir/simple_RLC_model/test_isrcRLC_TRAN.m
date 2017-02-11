% This is a test script for isrcRCL_ckt, a test circuit for RLC_ModSpec_wrapper
% device.
% It runs transient simulation on the circuit, starting from its zero state.


	% set up DAE
	DAE = MNA_EqnEngine(isrcRLC_ckt);

	% transient analysis
    % ------------------
		xinit = zeros(DAE.nunks(DAE), 1); % zero-state response
		tstart = 0; tstep = 1e-8; tstop = 5e-6;
		LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
		LMSobj.plot(LMSobj);
