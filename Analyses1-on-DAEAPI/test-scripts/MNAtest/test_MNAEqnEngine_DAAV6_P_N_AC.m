%author: J. Roychowdhury, 2012/05/01-08, 2012/12/21
% Test script for running AC analyses on P and N type MVS DAAV6 MOSFET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	run AC analyses on P and N type DAAV6 MOSFETs at several
%	DC operating points
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






MNAEqnEngine_DAAV6_P_N_devices; % DAEAPI script that sets up DAE

% set up outputs for plotting: just the IDS currents for the P and N devices
stateoutputs = StateOutputs(DAE); 
stateoutputs = feval(stateoutputs.DeleteAll, stateoutputs);
stateoutputs = feval(stateoutputs.Add, {'vddN:::ipn'}, stateoutputs);
stateoutputs = feval(stateoutputs.Add, {'vddP:::ipn'}, stateoutputs);

%{
if 0 == 1
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'vgs:::E', 1.2, DAE);
	DAE = feval(DAE.set_uQSS, 'vddN:::E', 1.2, DAE);
	% run DC
	qss = QSS(DAE);
	qss = feval(qss.solve, qss);
	feval(qss.print, qss);
end 
%}

% DC sweep over vdd and vgs 
%dcsweep2 = DC(dae);
%dcsweep2 = solve2(dcsweep2, 'vgs', 0.1, 1.2, 0.1, 'vdd', 0, 1.2, 0.05);
%sol2 = getsolution(dcsweep2);

%oidxN = feval(DAE.unkidx, 'vddN:::ipn', DAE); % unknown index of the N device's output (its IDS)
%oidxP = feval(DAE.unkidx, 'vddP:::ipn', DAE); % unknown index of the P device's output (its IDS)

%i = 0; 
%IDSNs = [];
%IDSPs = [];
VGSs = [0.1, 0.6, 1.2]; % three different values of VGS.
VDSs = 1.2;
for vgs = VGSs
	% set values of VGS for the N and P transistors
	DAE = feval(DAE.set_uQSS, 'vgsN:::E', vgs, DAE);
	DAE = feval(DAE.set_uQSS, 'vgsP:::E', vgs, DAE);
	%i = i+1; j = 0;
	for vdd = VDSs
		% set values of VDS for the N and P transistors
		DAE = feval(DAE.set_uQSS, 'vddP:::E', vdd, DAE);
		DAE = feval(DAE.set_uQSS, 'vddN:::E', vdd, DAE);

		% run a DC (QSS) analysis
		qss = QSS(DAE);
		qss = feval(qss.solve, qss);
		qssSol = feval(qss.getsolution, qss);
		%j = j+1;
		%IDSNs(i,j) = sol(oidxN,1);
		%IDSPs(i,j) = sol(oidxP,1);
	
		%%%%% the AC (LTISSS) analysis

		% set up AC analysis input as a function of frequency
		Ufargs.string = 'no args used'; % 

		%DAEinputnames = feval(DAE.inputnames, DAE);
		% gives:  'vddP:::E'    'vddN:::E'    'vgsN:::E'    'vgsP:::E'
		% we want to give AC input values only to vgsN:::E and 'vgsP:::E'

		constonefuncH = @(f, args) 1;
		DAE = feval(DAE.set_uLTISSS, 'vgsN:::E', constonefuncH, [], DAE);
		DAE = feval(DAE.set_uLTISSS, 'vgsP:::E', constonefuncH, [], DAE);

		%{
		an alternative way of doing the above setting
		AC_inputs = zeros(feval(DAE.ninputs, DAE),1); % first set all AC inputs to zero
		vgsN_idx = feval(DAE.inputidx, 'vgsN:::E', DAE); % get the index of the N-transistor's VGS input 
		vgsP_idx = feval(DAE.inputidx, 'vgsP:::E', DAE); % get the index of the P-transistor's VGS input
		AC_inputs(vgsN_idx,1) = 1; % set AC input to 1
		AC_inputs(vgsP_idx,1) = 1; % set AC input to 1

		Uffunc = @(f, args) AC_inputs; % constant U(j 2 pi f) for all f
		DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);
		%}

		% set up the AC analysis @ DC operating point
		us = feval(DAE.uQSS, DAE); % get the current DC inputs (values of all indep. sources)
		ltisss = LTISSS(DAE,qssSol, us);
		ltisss.DAEname = sprintf('DAAV6 P/N FETs with VGS=%g, VDS=%g', vgs, vdd); % sets plot title string properly
		% set AC sweep parameters: 1Hz to 1000THz, decade plot with 5 freq. points/decade
		sweeptype = 'DEC'; fstart=1; fstop=1e15; nsteps=5;

		% run the AC analysis
		ltisss = feval(ltisss.solve, fstart, fstop, nsteps, sweeptype, ltisss);

		% plot frequency sweeps of state variable outputs (overlay on 1 plot)
		feval(ltisss.plot, ltisss, stateoutputs);

		fprintf(2,'\n');
	end
end
