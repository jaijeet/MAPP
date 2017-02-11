echo on;
    ckt = myR_diodeC_ckt();
    % ckt = myR_diodeC_Rd_ckt();
    % ckt = myR_diodeC_Rd_implicit_ckt();
    % ckt = myR_diodeC_Rd_initlimiting_ckt();
    DAE = MNA_EqnEngine(ckt);

    % DC operating point
    dcop = dot_op(DAE);
    dcop.print(dcop);

    % print out DAE's input name
    DAE.inputnames(DAE)

    % DC sweep
    swp = dot_dcsweep(DAE, [], 'V1:::E', 0, 10, 50);
    swp.plot(swp);
echo off;
