% run a transient simulation on diode mixer (ring modulator) DAE
% to see circuit behaviour under multi-tone excitation
% Author: Tianshi Wang  2013/06/24

MNAEqnEngine_diode_mixer; % set up DAE

% DAE:
% unk_names: 
% {'e_10', 'e_1', 'e_20', 'e_4', 'e_2', 'e_3', 'e_5', 'e_6', 'e_7',
% 'vp:::ipn', 'vrf:::ipn', 'ep1:::ipnc', 'ep2:::ipnc', 'er1:::ipnc',
% 'er2:::ipnc', 'd1:::vin', 'd2:::vin', 'd3:::vin', 'd4:::vin'};
% input_names: {'vp:::E'  'vrf:::E'}

% set up the QSS (DC) analysis
qss = QSS(DAE);
% could call functions for setting Newton parameters, etc.
%  eg, NRparms = QSSgetNRparms(qss); change; qss=QSSsetNRparms(NRparms, qss);

% run NR to do the QSS analysis
qss = feval(qss.solve, qss); % or qss = feval(qss.solve, initguess, qss);

% access/print outputs
xQSS = feval(qss.getSolution, qss); % get the entire state vector x
feval(qss.print, qss); % print the DAE's defined outputs (C * x + D * u)
