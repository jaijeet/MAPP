function sensObj = TADsens(DAE, x0, pNom, tstep, TRmethod, tranparms)
% function sensObj = TADsens(DAE, x0, pNom, tstep, TRmethod, tranparms)
% A synonym of transens, with useAdjoint set to 1. help transens for more
% information ad usage details.
    if nargin > 6 || nargin < 4
        fprintf(2,'DAESens: error: too many or too few arguments.\n');
        help('transens');
        return;
    elseif nargin < 5
        methods = LMSmethods();
        TRmethod = methods.GEAR2;
    elseif nargin < 6
        tranparms = defaultTranParms();
        tranparms.trandbglvl = -1;
        tranparms.NRparms.dbglvl = -1;
    end

    sensObj = AdjointSensitivities(DAE, x0, pNom, tstep, TRmethod, tranparms);
%end transens
