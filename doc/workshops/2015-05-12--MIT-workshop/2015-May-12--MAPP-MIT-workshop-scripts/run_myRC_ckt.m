% This script runs DC, AC and transient analyses on myRC_ckt.

echo on;
    ckt = myRC_ckt();
    DAE = MNA_EqnEngine(ckt);

    % DC
    dcop = dot_op(DAE);
    dcop.print(dcop);
    dcSol = dcop.getSolution(dcop);
    uDC = dcop.getDCinputs(dcop);

    % AC
    acObj = dot_ac(DAE, dcSol, uDC, 1, 1e6, 10, 'DEC');
    acObj.plot(acObj);

    % transient
    tstart = 0; tstep = 1e-5; tstop = 5e-3;
    tranObj = dot_transient(DAE, [], tstart, tstep, tstop);
    tranObj.plot(tranObj); 
echo off;
