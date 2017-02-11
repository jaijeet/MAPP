DAE = SH_NMOS_cap_DAEAPI('my NMOS');

disp(DAE.version)
disp(feval(DAE.uniqID,DAE))

disp(sprintf('nunks = %d', feval(DAE.nunks,DAE)));
disp(sprintf('neqns = %d', feval(DAE.neqns,DAE)));
disp(sprintf('ninputs = %d', feval(DAE.ninputs,DAE)));
disp(sprintf('noutputs = %d', feval(DAE.noutputs,DAE)));
disp(sprintf('nparms = %d', feval(DAE.nparms,DAE)));
disp(sprintf('nNoiseSources = %d', feval(DAE.nNoiseSources,DAE)));

disp(sprintf('uniqID = %s', feval(DAE.uniqID,DAE)));
disp(sprintf('daename = %s', feval(DAE.daename,DAE)));
disp(sprintf('unknames = %s', cell2str(feval(DAE.unknames,DAE))));
disp(sprintf('uniqID = %s', feval(DAE.uniqID,DAE)));
