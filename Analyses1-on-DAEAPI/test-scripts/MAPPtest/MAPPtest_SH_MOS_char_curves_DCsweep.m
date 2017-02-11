function test = MAPPtest_SH_MOS_char_curves_DCsweep()
% 
% Test script to run DC sweep on a BJT differential pair
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MNAEqnEngine_SH_MOS_char_curves;
test.DAE = DAE;% v6.2
test.name = 'SH_MOS_char_curves';
test.analysis = 'DCSweep';
test.refFile = 'SH_MOS_char_curves.mat';

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

VGGs = -0.8:0.1:0.8;
VDDs = -0.4:0.1:1.2;
test.args.QSSInputs = [VGGs',VDDs'];
end
