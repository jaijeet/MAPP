function out = sens_ring_osc()
    DATA_DIR = './Analyses1-on-DAEAPI/test-scripts/parameter-sensitivities/data/ring-osc/';
    NRelevantParms = 10;
    
    DAE = MNA_EqnEngine(SHringosc101_ckt);
    load('SHringosc101_ckt_xinit.mat');
    x0 = xinit;
    DAE.C = @C;

    % utargs.A = 0.5; utargs.f=1e1; utargs.phi=0; 
    % utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    % DAE = DAE.set_utransient(utfunc, utargs, DAE);
    
    T=4.92e-3;
    tstep = 5e-4;

    methods = LMSmethods();
    TRmethod = methods.GEAR2;

    tranparms = defaultTranParms;
    tranparms.NRparms.limiting = 1; 
    tranparms.doStepControl = 1;
    tranparms.NRparms.dbglvl = -1;
    tranparms.trandbglvl = -1;

    pNom = Parameters(DAE);
    pnames = pNom.ParmNames(pNom);
    pvals = pNom.ParmVals(pNom, DAE);
    for i=1:length(pnames)
        if ~isnumeric(pvals{i})
            pNom = pNom.Delete({pnames{i}}, pNom);
        end
    end
    pnames = pNom.ParmNames(pNom);

    n = DAE.nunks(DAE);
    np = pNom.numparms;

    dirSensObj = transens(DAE, 0, x0, pNom, tstep, TRmethod, tranparms);
    [dirSensObj, success, dirTime] = dirSensObj.computeSensitivities(dirSensObj, T);
    [Ms, ts] = dirSensObj.getSensitivities(dirSensObj, 0, T);
    idxStepPrint = ceil(length(ts) / 20);
    idxStepFilePrint = ceil(length(ts) / 200);

    lastM = reshape(Ms(:, end), [n, np]);
    [~,orderedIdxs] = sort(abs(DAE.C(DAE) * lastM));
    orderedIdxs = flip(orderedIdxs);
    orderedIdxs = orderedIdxs(1:NRelevantParms);

    file = fopen(strcat(DATA_DIR, 'osc-output.dat'),'w');
    unknames = DAE.unknames(DAE);
    fprintf(file, 't\toutput'); 
    for i = 1:idxStepFilePrint:length(ts)
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d', DAE.C(DAE) * dirSensObj.xs(:, i));
    end
    fclose(file);

    fprintf(1, 'Node Voltages vs. t\nt\t\toutput');
    for i = 1:idxStepPrint:length(ts)
        fprintf(1, '\n%0.3e', ts(i))
        fprintf(1, '\t%0.5e', DAE.C(DAE) * dirSensObj.xs(:, i));
    end
    fprintf(1, '\n\n');

    idxStepPrint = ceil(length(ts) / 10);

    file = fopen(strcat(DATA_DIR, 'osc-direct.dat'),'w');
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
        fprintf(1, '\\\\\n%0.3e', ts(i));
        fprintf(1, ' & %0.5e',  mH(orderedIdxs));
    end
    fprintf(1, '\\\\\n\n');

    methods = LMSmethods();
    TRmethod = methods.TRAP;
    adjSensObj = AdjointSensitivities(DAE, x0, pNom, tstep, TRmethod);
    adjSensObj = adjSensObj.addTRAnalysisResults(adjSensObj, ts, dirSensObj.xs, dirSensObj.Cs,...
                                                 dirSensObj.Gs, dirSensObj.Sqs, dirSensObj.Sfs);

    [adjSensObj, success, lastmH, adjTime] = adjSensObj.computeSensitivities(adjSensObj, ts(end));

    file = fopen(strcat(DATA_DIR, 'osc-adjoint.dat'),'w');
    fprintf(1, 'Adjoint Sensitivities: %d ', adjTime);
    fprintf(file, 't');
    fprintf(file, '\t%s', pnames{orderedIdxs});

    fprintf(1, '\nt');
    fprintf(1, ' & %s', pnames{orderedIdxs});
    for i = 1:idxStepPrint:length(ts)
        [adjSensObj, success, mH] = adjSensObj.computeSensitivities(adjSensObj, ts(i));
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d',  mH(orderedIdxs));

        fprintf(1, '\\\\\n%0.3e', ts(i));
        fprintf(1, ' & %0.5e',  mH(orderedIdxs));
    end
    fprintf(1, '\\\\\n\n');
    fclose(file);

    function out = C(DAE)
        out = zeros(1, DAE.nunks(DAE));
        out(1, 2) = 1;
    % end C
%end sens_bjt_diffpair