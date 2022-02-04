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
    

    % DATA_DIR = './Analyses1-on-DAEAPI/test-scripts/parameter-sensitivities/data/ring-osc/';
    DATA_DIR = './data/ring-osc/';
    NRelevantParms = 10;
    
    DAE = MNA_EqnEngine(SHringosc51_ckt);
    load('SHringosc51_ckt_xinit_GEAR2_tstep5e-6.mat');
    x0 = xinit;
    DAE.C = @C;

    % utargs.A = 0.5; utargs.f=1e1; utargs.phi=0; 
    % utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
    % DAE = DAE.set_utransient(utfunc, utargs, DAE);

    T=2.446675e-3; % good periodicity witn 3000 tpts/cycle
    pts_per_cycle = 3000;
    % pts_per_cycle = 30;
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
    pvals = cell2mat(pNom.ParmVals(pNom, DAE));

    n = DAE.nunks(DAE);
    np = pNom.numparms;

    dirSensObj = transens(DAE, 0, x0, pNom, tstep, transientDirectTRmethod, tranparms);
    [dirSensObj, success, dirTime] = dirSensObj.computeSensitivities(dirSensObj, T);
    [Ms, ts] = dirSensObj.getSensitivities(dirSensObj, 0, T);
    idxStepPrint = ceil(length(ts) / 20);
    idxStepFilePrint = ceil(length(ts) / 200);

    lastM = reshape(Ms(:, end), [n, np]);
    [~,orderedIdxs] = sort(abs(DAE.C(DAE) * lastM) .* pvals);
    orderedIdxs = flip(orderedIdxs);
    orderedIdxs = orderedIdxs(1:NRelevantParms);

    file = fopen(strcat(DATA_DIR, 'SHosc51-output-TRAP-3000pts.dat'),'w');
    unknames = DAE.unknames(DAE);
    fprintf(file, 't\toutput'); 
    for i = 1:idxStepFilePrint:length(ts)
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d', DAE.C(DAE) * dirSensObj.xs(:, i));
    end
    fprintf(file, '\n%d', ts(end));
    fprintf(file, '\t%d', DAE.C(DAE) * dirSensObj.xs(:, end));
    fclose(file);

    fprintf(1, 'Node Voltages vs. t\nt\t\toutput');
    for i = 1:idxStepPrint:length(ts)
        fprintf(1, '\n%0.3e', ts(i))
        fprintf(1, '\t%0.5e', DAE.C(DAE) * dirSensObj.xs(:, i));
    end
    fprintf(1, '\n%0.3e', ts(end))
    fprintf(1, '\t%0.5e', DAE.C(DAE) * dirSensObj.xs(:, end));
    fprintf(1, '\n\n');

    idxStepPrint = ceil(length(ts) / 10);

    file = fopen(strcat(DATA_DIR, 'SHosc51-direct-TRAP-3000pts.dat'),'w');
    all_parm_file = fopen(strcat(DATA_DIR, 'SHosc51-direct-TRAP-3000pts-all-parms.dat'),'w');
    pnames = pNom.ParmNames(pNom);
    fprintf(file, 't');
    fprintf(file, '\t%s', pnames{orderedIdxs});

    pnames = pNom.ParmNames(pNom);
    fprintf(all_parm_file, 't');
    fprintf(all_parm_file, '\t%s', pnames{:});
    for i = 1:idxStepFilePrint:length(ts)
        mH = DAE.C(DAE) * reshape(Ms(:, i), [n, np]) .* pvals;
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d', mH(orderedIdxs));

        fprintf(all_parm_file, '\n%d', ts(i));
        fprintf(all_parm_file, '\t%d', mH);
    end
    mH = DAE.C(DAE) * reshape(Ms(:, end), [n, np]) .* pvals;
    fprintf(file, '\n%d', ts(end));
    fprintf(file, '\t%d', mH(orderedIdxs));
    fclose(file);

    fprintf(all_parm_file, '\n%d', ts(end));
    fprintf(all_parm_file, '\t%d', mH);
    fclose(all_parm_file);

    fprintf(1, 'Direct Sensitivities: %d', dirTime);
    fprintf(1, '\nt');
    fprintf(1, ' & %s', pnames{orderedIdxs});
    for i = 1:idxStepPrint:length(ts)
        mH = DAE.C(DAE) * reshape(Ms(:, i), [n, np]) .* pvals;
        fprintf(1, '\\\\\n%0.3e', ts(i));
        fprintf(1, ' & %0.5e',  mH(orderedIdxs));
    end
    mH = DAE.C(DAE) * reshape(Ms(:, end), [n, np]) .* pvals;
    fprintf(1, '\\\\\n%0.3e', ts(end));
    fprintf(1, ' & %0.5e',  mH(orderedIdxs));
    fprintf(1, '\\\\\n\n');

    adjTRmethod = transientDirectTRmethod;
    adjSensObj = transens(DAE, 1, x0, pNom, tstep, adjTRmethod);
    adjSensObj = adjSensObj.addTRAnalysisResults(adjSensObj, ts, dirSensObj.xs, dirSensObj.Cs,...
                                                 dirSensObj.Gs, dirSensObj.Sqs, dirSensObj.Sfs);

    [adjSensObj, success, lastmH, adjTime] = adjSensObj.computeSensitivities(adjSensObj, ts(end));
    lastmH = lastmH .* pvals;

    file = fopen(strcat(DATA_DIR, 'SHosc51-adjoint-TRAP-3000pts.dat'),'w');
    all_parm_file = fopen(strcat(DATA_DIR, 'SHosc51-adjoint-TRAP-3000pts-all-parms.dat'),'w');
    fprintf(1, 'Adjoint Sensitivities: %d ', adjTime);
    fprintf(file, 't');
    fprintf(file, '\t%s', pnames{orderedIdxs});

    fprintf(all_parm_file, 't');
    fprintf(all_parm_file, '\t%s', pnames{:});

    fprintf(1, '\nt');
    fprintf(1, ' & %s', pnames{orderedIdxs});
    for i = 1:idxStepPrint:length(ts)
        [adjSensObj, success, mH] = adjSensObj.computeSensitivities(adjSensObj, ts(i));
        mH = mH .* pvals;
        fprintf(file, '\n%d', ts(i));
        fprintf(file, '\t%d',  mH(orderedIdxs));

        fprintf(all_parm_file, '\n%d', ts(i));
        fprintf(all_parm_file, '\t%d',  mH);

        fprintf(1, '\\\\\n%0.3e', ts(i));
        fprintf(1, ' & %0.5e',  mH(orderedIdxs));
    end
    fprintf(file, '\n%d', ts(end));
    fprintf(file, '\t%d',  lastmH(orderedIdxs));

    fprintf(all_parm_file, '\n%d', ts(end));
    fprintf(all_parm_file, '\t%d',  lastmH);

    fprintf(1, '\\\\\n%0.3e', ts(end));
    fprintf(1, ' & %0.5e',  lastmH(orderedIdxs));
    fprintf(1, '\\\\\n\n');
    fclose(file);
    fclose(all_parm_file);

    function out = C(DAE)
        out = zeros(1, DAE.nunks(DAE));
        out(1, 2) = 1;
    % end C
%end sens_bjt_diffpair
