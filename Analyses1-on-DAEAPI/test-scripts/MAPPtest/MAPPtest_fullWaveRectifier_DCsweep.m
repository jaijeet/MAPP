function test = MAPPtest_fullWaveRectifier_DCsweep()
% 
% Test script to run DC sweep on a BJT differential pair
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test.DAE = fullWaveRectifier_DAEAPIv6('fullWaveRectifier');;% v6.2
test.name = 'fullWaveRectifire_DCsweep';
test.analysis = 'DCSweep';
test.refFile = 'fullWaveRectifire.mat';

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

test.args.initGuess = [-0.7; 9.3];
N = 50; % note: 
	% N = 300 works without limiting.
	% N = 100 does not work without limiting; works fine with limiting.
	% N = 50 does not work without limiting; works fine with limiting.
	% N = 20 works with limiting, but there are singular matrix warnings; however, NR recovers.
Vins = -10 + (0:N)/N*20; % sweeping Vin = -10:10 in N steps
test.args.QSSInputs = Vins;
end
