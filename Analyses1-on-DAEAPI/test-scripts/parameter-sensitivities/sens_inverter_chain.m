function out = sens_inverter_chain()
    DATA_DIR = './Analyses1-on-DAEAPI/test-scripts/parameter-sensitivities/data/inverter-chain/';

    NInv = 5; VDD = 1.2; betaN = 1e-3; betaP = 1e-3;
    VtN = 0.25; VtP = 0.25; RdsN = 1e4; RdsP = 1e4; CL = 1e-6;
    NRelevantParms = 10;
    DAE = inverterchain('sensinverterchain', NInv, VDD, betaN, betaP, VtN, VtP, RdsN, RdsP, CL);
    DAE = DAE.set_uQSS('Vin.E', 0, DAE);

    qss = QSS(DAE);
    NRparms = qss.getNRparms(qss);
    NRparms.dbglvl = -1;
    qss = qss.setNRparms(NRparms, qss);
    qss = qss.solve(qss);
    x0 = qss.getSolution(qss);

    DAE = DAE.set_utransient(@u, [], DAE);
    DAE.C = @C;

    T = 1.5e-2;
    tstep = 1e-5;

    methods = LMSmethods();
    TRmethod = methods.GEAR2;

    pNom = Parameters(DAE);

    n = DAE.nunks(DAE);
    np = pNom.numparms;
    
    dirSensObj = transens(DAE, 0, x0, pNom, tstep, TRmethod);
    [dirSensObj, success, dirTime] = dirSensObj.computeSensitivities(dirSensObj, T);
    [Ms, ts] = dirSensObj.getSensitivities(dirSensObj, 0, T);

    idxStepPrint = ceil(length(ts) / 10);
    idxStepFilePrint = ceil(length(ts) / 200);

    lastM = reshape(Ms(:, end), [n, np]);
    [~,orderedIdxs] = sort(abs(C(DAE) * lastM));
    orderedIdxs = flip(orderedIdxs);
    orderedIdxs = orderedIdxs(1:NRelevantParms);

    pnames = pNom.ParmNames(pNom);

    file = fopen(strcat(DATA_DIR, 'inverter-output.dat'),'w');
    unknames = DAE.unknames(DAE);
    fprintf(file, 't');
    fprintf(file, '\t%s', unknames{:});
    for i = 1:idxStepFilePrint:length(ts)
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d', dirSensObj.xs(:, i));
    end
    fclose(file);

    fprintf(1, 'Node Voltages vs. t\nt\t');
    fprintf(1, '%s\t', unknames{:});
    for i = 1:idxStepPrint:length(ts)
        fprintf(1, '\n%d', ts(i))
        fprintf(1, '\t%d', dirSensObj.xs(:, i));
    end
    fprintf(1, '\n\n');

    file = fopen(strcat(DATA_DIR, 'inverter-direct.dat'),'w');
    pnames = pNom.ParmNames(pNom);
    fprintf(file, 't');
    fprintf(file, '\t%s', pnames{orderedIdxs});
    for i = 1:idxStepFilePrint:length(ts)
        mH = C(DAE) * reshape(Ms(:, i), [n, np]);
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d', mH(orderedIdxs));
    end
    fclose(file);

    fprintf(1, 'Direct Sensitivities: %d', dirTime);
    fprintf(1, '\nt');
    fprintf(1, ' & %s', pnames{orderedIdxs});
    for i = 1:idxStepPrint:length(ts)
        mH = C(DAE) * reshape(Ms(:, i), [n, np]);
        fprintf(1, '\\\\\n%d', ts(i));
        fprintf(1, ' & %d',  mH(orderedIdxs));
    end
    fprintf(1, '\\\\\n\n');
    
    adjSensObj = transens(DAE, 1, x0, pNom, tstep, TRmethod);
    adjSensObj = adjSensObj.addTRAnalysisResults(adjSensObj, ts, dirSensObj.xs, dirSensObj.Cs,...
                                                 dirSensObj.Gs, dirSensObj.Sqs, dirSensObj.Sfs);

    [adjSensObj, success, lastmH, adjTime] = adjSensObj.computeSensitivities(adjSensObj, ts(end));

    file = fopen(strcat(DATA_DIR, 'inverter-adjoint.dat'),'w');
    fprintf(1, 'Adjoint Sensitivities: %d ', adjTime);
    fprintf(file, 't');
    fprintf(file, '\t%s', pnames{orderedIdxs});

    fprintf(1, '\nt');
    fprintf(1, ' & %s', pnames{orderedIdxs});
    for i = 1:idxStepPrint:length(ts)
        [adjSensObj, success, mH] = adjSensObj.computeSensitivities(adjSensObj, ts(i));
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d',  mH(orderedIdxs));

        fprintf(1, '\\\\\n%d', ts(i));
        fprintf(1, ' & %d',  mH(orderedIdxs));
    end
    fprintf(1, '\\\\\n\n');
    fclose(file);

    function out = u(t, args)
        out = [1];
    %end u

    function out = C(DAE)
        out = zeros(1, DAE.nunks(DAE));
        out(1, end-2) = 1;
    %end C

    
%sens_inverter_chain    fprintf('\n');
