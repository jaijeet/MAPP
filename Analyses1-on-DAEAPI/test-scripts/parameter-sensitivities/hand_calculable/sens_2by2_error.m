function out = sens_2by2_error()
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

    tsteps = logspace(-6, -4, 20);
    methods = LMSmethods();
    TRmethods = [methods.BE, methods.GEAR2, methods.TRAP];

    % % Direct sensitivities
    % file = fopen(strcat(DATA_DIR, 'hand-calc-direct-error.dat'), 'w');
    % fprintf(1, '\nDirect Per-Timestep Error\nh\tBE\tGEAR2\tTRAP\n');
    % fprintf(file, 'h\tBE\tGEAR2\tTRAP');
    % for tstep = tsteps
    %     fprintf(file, '\n%d', tstep);
    %     fprintf(1, '\n%d', tstep);
    %     for TRmethod = TRmethods
    %         sensObj = transens(DAE, 1, x0, pNom, tstep, TRmethod);
    %         [sensObj, success, ~] = sensObj.computeSensitivities(sensObj, T);
    %         [Ms, ts] = sensObj.getSensitivities(sensObj, 0, T);

    %         analytical = analytical_sens(T, pNom, x0, DAE);
    %         mH = DAE.C(DAE) * reshape(Ms(:, end), [n, np]);
    %         err = norm((analytical - mH) ./ analytical) / (T / tstep);

    %         fprintf(file, '\t%d', err);
    %         fprintf(1, '\t%d', err);
    %     end
    % end
    % fclose(file);
    % fprintf(1, '\n');

    % Adjoint sensitivities
    file = fopen(strcat(DATA_DIR, 'hand-calc-adjoint-error.dat'), 'w');
    fprintf(1, '\nAdjoint Per-Timestep Error\nh\tBE\tGEAR2\tTRAP\n');
    fprintf(file, 'h\tBE\tGEAR2\tTRAP');
    for tstep = tsteps
        fprintf(file, '\n%d', tstep);
        fprintf(1, '\n%d', tstep);
        for TRmethod = TRmethods
            sensObj = transens(DAE, 1, x0, pNom, tstep, TRmethod);
            [sensObj, success, mH, ~] = sensObj.computeSensitivities(sensObj, T);

            analytical = analytical_sens(T, pNom, x0, DAE);
            err = norm((analytical - mH) ./ analytical) / (T / tstep);

            fprintf(file, '\t%d', err);
            fprintf(1, '\t%d', err);
        end
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
%end sens_2by2_adjoint