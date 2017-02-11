% This is a test script for isrcRCL_ckt, a test circuit for RLC_ModSpec_wrapper device.
% It runs DC simulation on the circuit.

	% set up DAE
	DAE = MNA_EqnEngine(isrcRLC_ckt);

	% DC analysis
	% -----------
	dcop = dot_op(DAE);
	dcop.print(dcop);
