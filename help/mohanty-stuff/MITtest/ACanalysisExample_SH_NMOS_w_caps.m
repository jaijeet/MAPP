 %
    DAE = MNAEqnEngine_SH_NMOS_w_caps(); 
    %DAE = SH_NMOS_cap_DAEAPI('my NMOS');
	stateoutputs = StateOutputs(DAE); 
    Uffunc = @(f, args) 1; 
    udcop = [2;2];
    DAE = feval(DAE.set_uQSS, udcop, DAE);
    DAE = feval(DAE.set_uLTISSS,'Vgs', Uffunc, [], DAE);

    initGuess=feval(DAE.QSSinitGuess, udcop, DAE);
    sweeptype = 'DEC'; 
    fstart = 1;
    fstop = 1e5; 
    nsteps = 10;

    NRparms = defaultNRparms();
    NRparms.dbglvl = -1;

    qssObj = QSS(DAE, NRparms);
    qssObj = feval(qssObj.solve, initGuess, qssObj);
    qssSol = feval(qssObj.getSolution, qssObj);

    LTISSSObj = LTISSS(DAE, qssSol, qssObj.u);
    LTISSSObj = feval(LTISSSObj.solve, fstart, fstop, nsteps, sweeptype, LTISSSObj);
	feval(LTISSSObj.plot, LTISSSObj,stateoutputs);
