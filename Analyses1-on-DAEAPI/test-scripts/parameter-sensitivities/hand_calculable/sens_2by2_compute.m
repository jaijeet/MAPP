function out = sens_2by2_compute()
    DATA_DIR = './Analyses1-on-DAEAPI/test-scripts/parameter-sensitivities/data/hand-calc/';

    DAE = DAE_RCPlusAE();
    T = 1e-3;
    uNom = @uFunc;
    DAE = DAE.set_utransient(uNom, [], DAE);

    pNom = Parameters(DAE);
    parms = pNom.ParmVals(pNom, DAE);
    R = parms{1};
    C = parms{2};
    x0 = [1/2; 0];

    n = 2; np = 2;

    tstep = 1e-5;
    numTs = 20;
    idxPrintStep = 5;
    methods = LMSmethods();
    TRmethod = .TRAP;

    % Analytical sensitivities
    file = fopen(strcat(DATA_DIR, 'hand-calc-analytical.dat'), 'w');
    fprintf(file, 't\tR\tC\n');
    for t = linspace(0, T, 100)
        mH = analytical_sens(t, pNom, x0, DAE);
        fprintf(file, '%d\t%d\t%d\n', t, mH(1, 1), mH(1, 2));
    end
    fclose(file);

    fprintf(1, '\nAnalytical Sensitivities\nt\tR\tC\n');
    for t = linspace(0, T, numTs)
        mH = analytical_sens(t, pNom, x0, DAE);
        fprintf(1, '%d\t%d\t%d\n', t, mH(1, 1), mH(1, 2));
    end
    fprintf(1, '\n');

    % Direct sensitivities
    sensObj = transens(DAE, 0, x0, pNom, tstep, TRmethod);
    [sensObj, success, ~] = sensObj.computeSensitivities(sensObj, T);
    [Ms, ts] = sensObj.getSensitivities(sensObj, 0, T);

    file = fopen(strcat(DATA_DIR, 'hand-calc-direct.dat'), 'w');
    fprintf(file, 't\tR\tC\n');
    for i=1:length(ts)
        t = ts(i);
        mH = DAE.C(DAE) * reshape(Ms(:, i), [n, np]);
        fprintf(file, '%d\t%d\t%d\n', t, mH(1, 1), mH(1, 2));
    end
    fclose(file);

    fprintf(1, '\nDirect Sensitivities\nt\tR\tC\n');
    for i = 1:idxPrintStep:length(ts)
        t = ts(i);
        mH = DAE.C(DAE) * reshape(Ms(:, i), [n, np]);
        fprintf(1, '%d\t%d\t%d\n', t, mH(1, 1), mH(1, 2));
    end
    fprintf(1, '\n');

    % Adjoint sensitivities
    sensObj = transens(DAE, 1, x0, pNom, tstep, TRmethod);

    file = fopen(strcat(DATA_DIR, 'hand-calc-adjoint.dat'), 'w');
    fprintf(file, 't\tR\tC\n');
    fprintf(1, '\nAdjoint Sensitivities\nt\tR\tC\n');
    for t = linspace(0, T, numTs)
        [sensObj, success, mH, ~] = sensObj.computeSensitivities(sensObj, t);
        fprintf(file, '%d\t%d\t%d\n', t, mH(1, 1), mH(1, 2));
        fprintf(1, '%d\t%d\t%d\n', t, mH(1, 1), mH(1, 2));
    end
    fclose(file);
    fprintf(1, '\n');

    function out = uFunc(t, args)
        out = [1; t];
    %end uFunc

    function out = analytical_sens(t, pNom, x0, DAE)
        parms = pNom.ParmVals(pNom, DAE);
        R = parms{1};
        C = parms{2};
        ic = x0(1, 1);
        out = DAE.C(DAE) *...
            [t/(R.^2 * C) * (ic - 1) * exp(-1/(R*C) * t),...
            t/(R * C.^2) * (ic - 1) * exp(-1/(R*C) * t);...
            -t/(R.^2 * C), -t/(R * C.^2)];
    %end analytical_sens
%end sens_2by2_compute