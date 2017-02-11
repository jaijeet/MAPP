%author: J. Roychowdhury, 2013/01/06
% Test script for running transient analysis on a ring oscillator using  MVS model (no internal node)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	run a transient on a 3 stage ring oscillator made with MVS core
%	(no d/s resistor) MOSFETs
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






NFET = MVS_no_int_nodes_ModSpec('MVS_noRsRd_N');
nname = feval(NFET.name, NFET);
ndesc = feval(NFET.description, NFET);

PFET = MVS_no_int_nodes_ModSpec('MVS_noRsRd_P');
pname = feval(PFET.name, PFET);
pdesc = feval(PFET.description, PFET);

% change PFET parameters from default (which is N-type)
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

VDDval = 1.2;
DAE = MNAEqnEngine_MOSFET_ringosc(NFET, PFET, VDDval); % DAEAPI script that sets up DAE

if 0 == 1
	fprintf(2,'running a DC analysis...\n');
	% run DC
	qss = QSS(DAE);
	qss = feval(qss.solve, qss);
	%feval(qss.print, qss);
	DCsol = feval(qss.getsolution, qss);
	fprintf(2,'\n...done\n');
end

% run transient

% set up LMS object
TransObjBE = LMS(DAE); % default method is BE, 
LMStranparms = TransObjBE.tranparms; % has, eg, tranparms.NRparms
TRmethods = LMSmethods(); % defines FE, BE, TRAP, GEAR2 and 
TransObjGEAR2 = LMS(DAE, TRmethods.GEAR2, LMStranparms);

% run transient and plot
%xinit = 0*DCsol; % ignore DC solution; use a random init condition - helps start it much faster
xinit = rand(feval(DAE.nunks,DAE),1);
%tstart = 0; tstep = 0.4e-14; tstop =  7e-12; % takes a very long time
%tstart = 0; tstep = 0.4e-14; tstop =  1e-13; % tstop too small to build up oscillations
%tstart = 0; tstep = 1e-13; tstop =  7e-12; % still takes long
tstart = 0; tstep = 5e-13; tstop =  15e-12; % crude, but enough to test
fprintf(2,'running a transient analysis using GEAR2...\n');
TransObjGEAR2 = feval(TransObjGEAR2.solve, TransObjGEAR2, ...
      xinit, tstart, tstep, tstop);
fprintf(2,'\n...done\n');

outs = StateOutputs(DAE);
outs = feval(outs.DeleteAll, outs);
outs = feval(outs.Add, {'e_inv1', 'e_inv2', 'e_inv3'}, outs);

[thefig, legends] = feval(TransObjGEAR2.plot, TransObjGEAR2, outs);
drawnow;
