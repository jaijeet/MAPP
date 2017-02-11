echo on;
    ckt = Hys_osc;
    DAE = MNA_EqnEngine(ckt); 

    % transient
    tranObj = dot_transient(DAE, [], 0, 1e-7, 2.5e-5);
    tranObj.plot(tranObj);

    % get transient solutions, plot limit cycle
    [tpts, sols] = tranObj.getSolution(tranObj);
    figure; plot(sols(4,2:end), sols(2,2:end), '.-b');
    grid on; xlabel('I(H1)'); ylabel('V(H1) or (e\_2)'); title('Transient results: I(H1) vs. V(H1).');
echo off;
