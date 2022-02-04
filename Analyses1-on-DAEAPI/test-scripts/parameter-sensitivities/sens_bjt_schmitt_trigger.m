function out = sens_bjt_schmitt_triggger()
    DATA_DIR = './Analyses1-on-DAEAPI/test-scripts/parameter-sensitivities/data/schmitt-trigger/';
    NRelevantParms = 10;
    
    DAE = BJTschmittTrigger('sensbjtschmitttrigger');
    x0 = [5; 3; 3.75; 3];

    % utargs.A = 0.5; utargs.f=1e3; utargs.phi=0; 
    % utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    % DAE = DAE.set_utransient(utfunc, utargs, DAE);
    
    T = 1e-4;
    tstep = 2e-9;

    methods = LMSmethods();
    TRmethod = methods.GEAR2;

    tranparms = defaultTranParms;
    tranparms.NRparms.limiting = 1; 
    tranparms.doStepControl = 1;
    tranparms.NRparms.dbglvl = -1;
    tranparms.trandbglvl = -1;

    pNom = Parameters(DAE);
    pnames = pNom.ParmNames(pNom);

    n = DAE.nunks(DAE);
    np = pNom.numparms;

    dirSensObj = transens(DAE, 1, x0, pNom, tstep, TRmethod, tranparms);
    [dirSensObj, success, dirTime] = dirSensObj.computeSensitivities(dirSensObj, T);
    [Ms, ts] = dirSensObj.getSensitivities(dirSensObj, 0, T);
    idxStepPrint = ceil(length(ts) / 20);
    idxStepFilePrint = ceil(length(ts) / 200);

    lastM = reshape(Ms(:, end), [n, np]);
    [~,orderedIdxs] = sort(abs(DAE.C(DAE) * lastM));
    orderedIdxs = flip(orderedIdxs);
    orderedIdxs = orderedIdxs(1:NRelevantParms);

    file = fopen(strcat(DATA_DIR, 'schmitt-output.dat'),'w');
    unknames = DAE.unknames(DAE);
    fprintf(file, 't');
    fprintf(file, '\t%s', unknames{:});
    fprintf(file, '\toutput'); 
    for i = 1:idxStepFilePrint:length(ts)
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d', dirSensObj.xs(:, i));
        fprintf(file, '\t%d', DAE.C(DAE) * dirSensObj.xs(:, i));
    end
    fclose(file);

    fprintf(1, 'Node Voltages vs. t\nt\t');
    fprintf(1, '%s\t', unknames{:});
    fprintf(1, '\toutput');
    for i = 1:idxStepPrint:length(ts)
        fprintf(1, '\n%d', ts(i))
        fprintf(1, '\t%d', dirSensObj.xs(:, i));
        fprintf(1, '\t%d', DAE.C(DAE) * dirSensObj.xs(:, i));
    end
    fprintf(1, '\n\n');

    idxStepPrint = ceil(length(ts) / 10);

    file = fopen(strcat(DATA_DIR, 'schmitt-direct.dat'),'w');
    pnames = pNom.ParmNames(pNom);
    fprintf(file, 't');
    fprintf(file, '\t%s', pnames{orderedIdxs});
    for i = 1:idxStepFilePrint:length(ts)
        mH = DAE.C(DAE) * reshape(Ms(:, i), [n, np]);
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d', mH(orderedIdxs));
    end
    fclose(file);

    fprintf(1, 'Direct Sensitivities: %d', dirTime);
    fprintf(1, '\nt');
    fprintf(1, ' & %s', pnames{orderedIdxs});
    for i = 1:idxStepPrint:length(ts)
        mH = DAE.C(DAE) * reshape(Ms(:, i), [n, np]);
        fprintf(1, '\\\\\n%d', ts(i));
        fprintf(1, ' & %d',  mH(orderedIdxs));
    end
    fprintf(1, '\\\\\n\n');

    adjSensObj = transens(DAE, 1, x0, pNom, tstep, TRmethod);
    adjSensObj = adjSensObj.addTRAnalysisResults(adjSensObj, ts, dirSensObj.xs, dirSensObj.Cs,...
                                                 dirSensObj.Gs, dirSensObj.Sqs, dirSensObj.Sfs);

    [adjSensObj, success, lastmH, adjTime] = adjSensObj.computeSensitivities(adjSensObj, ts(end));

    file = fopen(strcat(DATA_DIR, 'schmitt-adjoint.dat'),'w');
    fprintf(1, 'Adjoint Sensitivities: %d ', adjTime);
    fprintf(file, 't');
    fprintf(file, '\t%s', pnames{orderedIdxs});

    fprintf(1, '\nt');
    fprintf(1, ' & %s', pnames{orderedIdxs});
    idxStepPrint = ceil(length(ts) / 20);
    for i = 1:idxStepPrint:length(ts)
        [adjSensObj, success, mH] = adjSensObj.computeSensitivities(adjSensObj, ts(i));
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d',  mH(orderedIdxs));

        if mod(i, 2) == 1
            fprintf(1, '\\\\\n%d', ts(i));
            fprintf(1, ' & %d',  mH(orderedIdxs));
        end
    end
    fprintf(1, '\\\\\n\n');
    fclose(file);

    function out = C(DAE)
        out = zeros(1, DAE.nunks(DAE));
        out(1, 2) = 1;
        out(1, 3) = -1;
    % end C
%end sens_bjt_diffpair