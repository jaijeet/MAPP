function test = MAPPtest_charge_pump_DCsweep()
% 
% Test script to run DC sweep on a BJT differential pair
%Author: Bichen Wu <bichen@berkeley.edu> 2014/01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DAE = MNA_EqnEngine(charge_pump_ckt());
DAE = feval(DAE.set_uQSS, 'Vup:::E', 2, DAE);
DAE = feval(DAE.set_uQSS, 'Vdown:::E', 0, DAE);

test.DAE = DAE;
test.name = 'charge_pump_DCsweep';
test.analysis = 'DCSweep';
test.refFile = 'charge_pump_DCsweep.mat';

NRparms = defaultNRparms();
NRparms.maxiter = 100;
NRparms.reltol = 1e-5;
NRparms.abstol = 1e-10;
NRparms.residualtol = 1e-10;
NRparms.limiting = 0;
NRparms.dbglvl = 0; % minimal output
test.args.NRparms = NRparms;

test.args.comparisonAbstol = 1e-9;
test.args.comparisonReltol = 1e-3;

n = feval(test.DAE.nunks, test.DAE);
initguess = -ones(n,1);
test.args.initGuess = initguess;

test.args.QSSInputs = [];


end
