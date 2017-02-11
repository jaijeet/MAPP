echo on;
    ckt = Rdivider_ckt();
    DAE = MNA_EqnEngine(ckt);

    % print out DAE's input name
    DAE.inputnames(DAE)

    % DC sweep
    swp = dot_dcsweep(DAE, [], 'V1:::E', 0, 10, 50);
    swp.plot(swp);
echo off;
