function test = MAPPtest_reducedRRE_QSS()
% 
% Test script to run DC sweep on a BJT differential pair
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseDAE = TwoReactionChainDAEAPIv6_2('twoReactionChain');
initconcs = [0.9; 0.8; 0.7; 0.6; 0.5];
DAE = ReduceRREapplyingConservationv6_2('towReactionChain', baseDAE, initconcs);
test.DAE = TwoReactionChainDAEAPIv6_2('twoReactionChain');
%test.DAE = DAE;

test.name = 'TwoReactionChainQSS';
test.analysis = 'DCSweep';
test.refFile = 'reducedRRE_QSS.mat';

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

n = feval(DAE.nunks, DAE);
initguess = -ones(n,1);
test.args.initGuess = initguess;

test.args.QSSInputs = [];
end
