function test = MAPPtest_diode_mixer_DCsweep()
% 
% Test script to run DC sweep on a BJT differential pair
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MNAEqnEngine_diode_mixer
test.DAE = DAE;% v6.2
test.name = 'diode_mixer_DCsweep';
test.analysis = 'DCSweep';
test.refFile = 'diode_mixer.mat';

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

test.args.initGuess = [];

test.args.QSSInputs = [];
end
