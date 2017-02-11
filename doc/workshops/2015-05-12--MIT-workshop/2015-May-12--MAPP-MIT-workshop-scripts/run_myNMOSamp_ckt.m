% This script runs DC, AC and transient analyses on myNMOSamp_ckt.

echo on;
    ckt = myNMOSamp_ckt();
    DAE = MNA_EqnEngine(ckt);

    % DC operating point
    dcop = dot_op(DAE);
    dcop.print(dcop);
    dcSol = dcop.getSolution(dcop);
    uDC = dcop.getDCinputs(dcop);

    % DC sweep
    swp = dot_dcsweep(DAE, [], 'Vgg:::E', 0, 2, 50);
    swp.plot(swp);

    % AC
    acObj = dot_ac(DAE, dcSol, uDC, 1, 1e6, 10, 'DEC');
    acObj.plot(acObj);

    % transient
    tstart = 0; tstep = 1e-4; tstop = 5e-2;
    tranObj = dot_transient(DAE, dcSol, tstart, tstep, tstop);
    tranObj.plot(tranObj); 
echo off;
