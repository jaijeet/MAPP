echo on;
    ckt = myR_Hys_ckt;
    DAE = MNA_EqnEngine(ckt);

    % DC operating point
    dcop = dot_op(DAE);
    dcop.print(dcop);

    % print out DAE's input name
    DAE.inputnames(DAE)

    % DC sweep: Vdd from 1 to 2
    swp1 = dot_dcsweep(DAE, [], 'Vdd:::E', 1, 2, 50);
    swp1.plot(swp1);
    % DC sweep: Vdd from 2 to 1
    swp2 = dot_dcsweep(DAE, [], 'Vdd:::E', 2, 1, 50);
    swp2.plot(swp2);
    % overlay the results 
    figure;
    [pts1, vals1] = swp1.getSolution(swp1);
    plot(pts1, vals1(2,:), '.-b'); hold on;
    [pts2, vals2] = swp2.getSolution(swp2);
    plot(pts2, vals2(2,:), '.-b');
    grid on; xlabel('Vdd'); ylabel('e\_2'); title('DC sweep: Vdd 1V--2V--1V.');

    % transient
    tstart = 0; tstep = 5e-6; tstop = 3e-3;                
    tranObj = dot_transient(DAE, [], tstart, tstep, tstop);
    tranObj.plot(tranObj);                                 

    % get transient solutions and plot hysteresis curve
    [tpts, sols] = tranObj.getSolution(tranObj);
    figure; plot(sols(1,2:end), sols(2,2:end), '.-b');
    grid on; xlabel('Vdd'); ylabel('e\_2'); title('Transient results: Vdd vs. e\_2.');
echo off;
