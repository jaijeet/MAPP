%author: J. Roychowdhury, 2012/12/28
%Test script for generating characteristic curves on an MVS MOSFET (no internal node)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	generate characteristic curves on a MOSFET
%	by VGS and VDS voltages sources
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%NFET = DAAV6ModSpec('mn');
NFET = MVS_no_int_nodes_ModSpec('mn');
nname = feval(NFET.name, NFET);
ndesc = feval(NFET.description, NFET);
%PFET = DAAV6ModSpec('mp');
PFET = MVS_no_int_nodes_ModSpec('mp');
pname = feval(PFET.name, PFET);
pdesc = feval(PFET.description, PFET);

% change PFET parameters from default (which is N-type)
%.model mypmos daaV6 \
%	tipe=p \
PFET = feval(PFET.setparms,'tipe','p', PFET);
%	Lg=35e-7 \
PFET = feval(PFET.setparms,'Lg',35e-7, PFET);
%	dLg=8.75e-7 \
PFET = feval(PFET.setparms,'dLg',8.75e-7, PFET);
%	Cg=1.7e-6 \
PFET = feval(PFET.setparms,'Cg',1.7e-6, PFET);
%	delta=0.155 \
PFET = feval(PFET.setparms,'delta',0.155, PFET);
%	S=0.1 \
PFET = feval(PFET.setparms,'S',0.1, PFET);
%	vxo=0.85e7 \
PFET = feval(PFET.setparms,'vxo',0.85e7, PFET);
%	mu=140 \
PFET = feval(PFET.setparms,'mu',140, PFET);
%	beta=1.4
PFET = feval(PFET.setparms,'beta',1.4, PFET);
%	#Vt0=0.543 # no longer used by daaV6


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you are only changing the model/parameters, don't change anything after this
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DAE = MNAEqnEngine_MOSFET_P_N_devices(NFET, PFET); % DAEAPI script that sets up DAE

if 0 == 1
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'vgs:::E', 1.2, DAE);
	DAE = feval(DAE.set_uQSS, 'vddN:::E', 1.2, DAE);
	% run DC
	qss = QSS(DAE);
	qss = feval(qss.solve, qss);
	feval(qss.print, qss);
end 

% DC sweep over vdd and vgs 
%dcsweep2 = DC(dae);
%dcsweep2 = solve2(dcsweep2, 'vgs', 0.1, 1.2, 0.1, 'vdd', 0, 1.2, 0.05);
%sol2 = getsolution(dcsweep2);

oidxN = feval(DAE.unkidx, 'vddN:::ipn', DAE);
oidxP = feval(DAE.unkidx, 'vddP:::ipn', DAE);
i = 0; 
IDSNs = [];
IDSPs = [];
VGSs = 0.1:0.1:1.2;
VDSs = 0:0.05:1.2;
for vgs = VGSs
	DAE = feval(DAE.set_uQSS, 'vgsN:::E', vgs, DAE);
	DAE = feval(DAE.set_uQSS, 'vgsP:::E', vgs, DAE);
	i = i+1; j = 0;
	for vdd = VDSs
		DAE = feval(DAE.set_uQSS, 'vddP:::E', vdd, DAE);
		DAE = feval(DAE.set_uQSS, 'vddN:::E', vdd, DAE);
		qss = QSS(DAE);
		qss = feval(qss.solve, qss);
		%fprintf(1, ': i=%d, j=%d, vgs=%d, vdd=%d\n', i, j, vgs, vdd);
		sol = feval(qss.getsolution, qss);
		j = j+1;
		IDSNs(i,j) = sol(oidxN,1);
		IDSPs(i,j) = sol(oidxP,1);
	end
end

figure;
hold on;
xlabel 'Vds';
ylabel 'Ids';
for i=1:length(VGSs) % step vgs
      toplot = -1000*IDSNs(i,:); % mA
      plot(VDSs, toplot, 'b.-');
end
grid on; axis tight;
title(sprintf('%s NFET (%s) w/ no d/s resistors -- char curves', nname, ndesc));


% PFET plots
figure;
hold on;
xlabel 'Vds';
ylabel 'Ids';
for i=1:length(VGSs) % step vgs
      toplot = -1000*IDSPs(i,:); % mA
      plot(-VDSs, toplot, 'b.-');
end
grid on; axis tight;


grid on; axis tight;
title(sprintf('%s PFET (%s) w/ no d/s resistors -- char curves', pname, pdesc));
