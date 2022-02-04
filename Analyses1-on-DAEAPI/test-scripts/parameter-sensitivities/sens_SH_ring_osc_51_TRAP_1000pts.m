function out = sens_ring_osc()
%function out = sens_ring_osc()


%NOT IMPLEMENTED
%Runs DAE transient sensitivity analysis on SHringosc51_ckt.
%optional argument whattorun can be one of 'adjoint', 'direct', or 'both'
%if not specified, runs both.


    % runadjoint = 1;
    % rundirect = 1;
    % if (nargin == 1) 
    %     if strcmp(whattorun, 'adjoint') == 1
    %         rundirect = 0;
    %     end
    %     if strcmp(whattorun, 'direct') == 1
    %         runadjoint = 0;
    %     end
    % end
    

    %DATA_DIR = './Analyses1-on-DAEAPI/test-scripts/parameter-sensitivities/data/ring-osc/';
    DATA_DIR = './data/ring-osc/';
    NRelevantParms = 10;
    
    DAE = MNA_EqnEngine(SHringosc51_ckt);
    load('SHringosc51_ckt_xinit_GEAR2_tstep5e-6.mat');
    x0 = xinit;
    DAE.C = @C;

    % utargs.A = 0.5; utargs.f=1e1; utargs.phi=0; 
    % utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    % DAE = DAE.set_utransient(utfunc, utargs, DAE);

    T=2.448e-3; % excellent periodicity with 1000 steps/period, ie, tstep ~= 2.448e-6, and TRAP
    pts_per_cycle = 1000;
    tstep = T/pts_per_cycle;

    theMethods = LMSmethods();
    %transientDirectTRmethod = theMethods.GEAR2;
    transientDirectTRmethod = theMethods.TRAP;

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

    dirSensObj = transens(DAE, 1, x0, pNom, tstep, transientDirectTRmethod, tranparms);
    [dirSensObj, success, dirTime] = dirSensObj.computeSensitivities(dirSensObj, T);
    [Ms, ts] = dirSensObj.getSensitivities(dirSensObj, 0, T);
    idxStepPrint = ceil(length(ts) / 20);
    idxStepFilePrint = ceil(length(ts) / 200);

    lastM = reshape(Ms(:, end), [n, np]);
    [~,orderedIdxs] = sort(abs(DAE.C(DAE) * lastM));
    orderedIdxs = flip(orderedIdxs);
    orderedIdxs = orderedIdxs(1:NRelevantParms);

    file = fopen(strcat(DATA_DIR, 'SHosc51-output-TRAP-1000pts.dat'),'w');
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

    file = fopen(strcat(DATA_DIR, 'SHosc51-direct-TRAP-1000pts.dat'),'w');
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

    adjTRmethod = transientDirectTRmethod;
    adjSensObj = transens(DAE, 1, x0, pNom, tstep, adjTRmethod);
    adjSensObj = adjSensObj.addTRAnalysisResults(adjSensObj, ts, dirSensObj.xs, dirSensObj.Cs,...
                                                 dirSensObj.Gs, dirSensObj.Sqs, dirSensObj.Sfs);

    [adjSensObj, success, lastmH, adjTime] = adjSensObj.computeSensitivities(adjSensObj, ts(end));

    file = fopen(strcat(DATA_DIR, 'SHosc51-adjoint-TRAP-1000pts.dat'),'w');
    fprintf(1, 'Adjoint Sensitivities: %d ', adjTime);
    fprintf(file, 't');
    fprintf(file, '\t%s', pnames{orderedIdxs});

    fprintf(1, '\nt');
    fprintf(1, ' & %s', pnames{orderedIdxs});
    for i = 1:idxStepPrint:length(ts)
        [adjSensObj, mH, success] = adjSensObj.computeSensitivities(adjSensObj, ts(i));
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
