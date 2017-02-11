function test = MAPPtest_inverter_DCsweep()

% 
% Test script to run DC sweep on a BJT differential pair
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test.DAE = SH_CMOS_inverter_DAEAPIv6('somename'); % v6.2
test.name = 'inverter_DCsweep';
test.analysis = 'DCSweep';
test.refFile = 'inverter_DCsweep.mat';

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

test.args.initGuess = [1.2  1.1937    1.1936    1.1936    1.1935 ...
1.1934    1.1933    1.1932    1.1931    1.1930    1.1929    1.1928 ...
1.1927    1.1926    1.1925    1.1924    1.1923    1.1921    1.1920 ...
1.1919	  1.1918    1.1916    1.1915    1.1912    1.1907    1.1899 ...
1.1889    1.1877    1.1861    1.1843    1.1821    1.1796    1.1767 ...
1.1734    1.1696    1.1654    1.1607    1.1554    1.1494    1.1427 ...
1.1352    1.1268    1.1173    1.1065    1.0942    1.0800    1.0634 ...
1.0435    1.0190    0.9868    0.9382    0.6000    0.2618    0.2132 ...
0.1810    0.1565    0.1366    0.1200    0.1058    0.0935    0.0827 ...
0.0732    0.0648    0.0573    0.0506    0.0446    0.0393    0.0346 ...
0.0304    0.0266    0.0233    0.0204    0.0179    0.0157    0.0139 ...
0.0123    0.0111    0.0101    0.0093    0.0088    0.0085    0.0084 ...
0.0082    0.0081    0.0080    0.0079    0.0077    0.0076    0.0075 ...
0.0074    0.0073    0.0072    0.0071    0.0070    0.0069    0.0068 ...
0.0067    0.0066    0.0065    0.0064    0.0064];

N = 100;
Vins = (0:N)/N*1.2; % sweeping Vin = 0:1.2 in N steps

test.args.QSSInputs = Vins';
end
