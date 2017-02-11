%Author: J. Roychowdhury <jr@berkeley.edu>, 2011/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






vs = -1 + 2*(0:300)/300;

% see comments inside diode1_Qdepl for more info on these parms
parms.fc = 0.5;
parms.tt = 1e-12;
parms.area = (1e-7)^2; % 0.1 micron on the side
parms.cjo = 30;
parms.phi = 0.7;
parms.m = 0.5;
parms.is = 1e-14;

Qdepl = diode1_Qdepl(vs, parms);

plot(vs, Qdepl, '.-');
xlabel 'applied junction voltage';
ylabel 'depletion charge';

grid on; %axis tight;

oof = axis;
minx = oof(1);
maxx = oof(2);
miny = oof(3);
maxy = oof(4);
hold on;
% if condition is at fc*phi
threshold = parms.fc*parms.phi;
stem(threshold, diode1_Qdepl(threshold,parms), 'r');

line([minx, maxx], [0,0]); % x axis
line([0,0], [miny, maxy]); % y axis

title 'Diode depletion charge';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





