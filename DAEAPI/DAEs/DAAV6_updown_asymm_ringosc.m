function DAE = DAAV6_updown_asymm_ringosc()
%function DAE = DAAV6_updown_asymm_ringosc()
% A 3-stage ring oscillator made with DAAv6 MOSFETs
%author: J. Roychowdhury, 2012/05/21
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	a 3 stage ring oscillator made with DAAv6 MOSFETs
%	the N MOSFETs are 10x wider than the P ones, leading
%	to up-down asymmetric waveforms and a PPV with a significant
%	second harmonic component.
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






	% ckt name
	cktname = 'DAAV6-updown-asymm-ringosc';

	% nodes (names)
	nodes = {'VDD', 'inv1', 'inv2', 'inv3'};
	ground = 'gnd';

	% list of elements 
	vddM = vsrcModSpec('VDD');
	iInj1M = isrcModSpec('iInj1');
	minv1pM = DAAV6ModSpec('Minv1p'); 
	minv1nM = DAAV6ModSpec('Minv1n'); 
	c1M = capModSpec('c1');
	minv2pM = DAAV6ModSpec('Minv2p'); 
	minv2nM = DAAV6ModSpec('Minv2n'); 
	minv3pM = DAAV6ModSpec('Minv3p'); 
	minv3nM = DAAV6ModSpec('Minv3n'); 

	% element node connectivities
	vddNodes = {'VDD', ground}; % p, n
	iInj1Nodes = {'inv1', ground}; % p, n
	%mp1 inv1 inv3 VDD VDD mypmos
	minv1pNodes = {'inv1', 'inv3', 'VDD', 'VDD'};  % d g s b
	%mn1 inv1 inv3 0 0 mynmos
	minv1nNodes = {'inv1', 'inv3', ground, ground};  % d g s b
	%c1  inv1 0 1e-19
	c1Nodes = {'inv1', ground};  % d g s b

	%mp2 inv2 inv1 VDD VDD mypmos
	minv2pNodes = {'inv2', 'inv1', 'VDD', 'VDD'};  % d g s b
	%mn2 inv2 inv1 0 0 mynmos
	minv2nNodes = {'inv2', 'inv1', ground, ground};  % d g s b

	%mp3 inv3 inv2 VDD VDD mypmos
	minv3pNodes = {'inv3', 'inv2', 'VDD', 'VDD'};  % d g s b
	%mn3 inv3 inv2 0 0 mynmos
	minv3nNodes = {'inv3', 'inv2', ground, ground};  % d g s b

	vddElement.name = 'vdd'; vddElement.model = vddM; 
		vddElement.nodes = vddNodes; vddElement.parms = {};

	iInj1Element.name = 'iInj1'; iInj1Element.model = iInj1M; 
		iInj1Element.nodes = iInj1Nodes; iInj1Element.parms = {};

	%.model mynmos daaV6 \
	%        type=n \
	minv1nM = feval(minv1nM.setparms, 'tipe','n', minv1nM);
	%        W=1.0e-4 \
	minv1nM = feval(minv1nM.setparms,'W', 1.0e-4, minv1nM);
	%        smoothing=1e-30 \
	minv1nM = feval(minv1nM.setparms,'smoothing', 1.0e-30, minv1nM);
	%        expMaxslope=1e60
	minv1nM = feval(minv1nM.setparms,'expMaxslope', 1e60, minv1nM);

	n_parms = feval(minv1nM.getparms, minv1nM);

	minv1nElement.name = 'mn1'; minv1nElement.model = minv1nM; 
		minv1nElement.nodes = minv1nNodes; 
		minv1nElement.parms = n_parms;

	minv2nElement.name = 'mn2'; minv2nElement.model = minv2nM; 
		minv2nElement.nodes = minv2nNodes; 
		minv2nElement.parms = n_parms;

	minv3nElement.name = 'mn3'; minv3nElement.model = minv3nM; 
		minv3nElement.nodes = minv3nNodes; 
		minv3nElement.parms = n_parms;

	%.model mypmos daaV6 \
	%	tipe=p \
	minv1pM = feval(minv1pM.setparms,'tipe','p', minv1pM);
	% 	W=1.0e-4 \
	minv1pM = feval(minv1pM.setparms,'W', 0.1e-4, minv1pM);
	%	Lg=35e-7 \
	minv1pM = feval(minv1pM.setparms,'Lg',35e-7, minv1pM);
	%	dLg=8.75e-7 \
	minv1pM = feval(minv1pM.setparms,'dLg',8.75e-7, minv1pM);
	%	Cg=1.7e-6 \
	minv1pM = feval(minv1pM.setparms,'Cg',1.7e-6, minv1pM);
	%	delta=0.155 \
	minv1pM = feval(minv1pM.setparms,'delta',0.155, minv1pM);
	%	S=0.1 \
	minv1pM = feval(minv1pM.setparms,'S',0.1, minv1pM);
	%	Rs=130 \
	minv1pM = feval(minv1pM.setparms,'Rs',130, minv1pM);
	%	Rd=130 \
	minv1pM = feval(minv1pM.setparms,'Rd',130, minv1pM);
	%	vxo=0.85e7 \
	minv1pM = feval(minv1pM.setparms,'vxo',0.85e7, minv1pM);
	%	mu=140 \
	minv1pM = feval(minv1pM.setparms,'mu',140, minv1pM);
	%	beta=1.4
	minv1pM = feval(minv1pM.setparms,'beta',1.4, minv1pM);
	%       smoothing=1e-30 \
	minv1pM = feval(minv1pM.setparms,'smoothing',1e-30, minv1pM);
	%       expMaxslope=1e60
	minv1pM = feval(minv1pM.setparms,'expMaxslope',1e60, minv1pM);
	%	#Vt0=0.543 # no longer used by daaV6

	p_parms = feval(minv1pM.getparms, minv1pM);

	minv1pElement.name = 'mp1'; minv1pElement.model = minv1pM; 
		minv1pElement.nodes = minv1pNodes; 
		minv1pElement.parms = p_parms;

	minv2pElement.name = 'mp2'; minv2pElement.model = minv2pM; 
		minv2pElement.nodes = minv2pNodes; 
		minv2pElement.parms = p_parms;

	minv3pElement.name = 'mp3'; minv3pElement.model = minv3pM; 
		minv3pElement.nodes = minv3pNodes; 
		minv3pElement.parms = p_parms;


	% set up circuitdata structure containing all the above
	% contains: nodenames, groundnodename(s), elements
	% each element contains: name, ModSpecModel, nodes, parms
	circuitdata.cktname = cktname; 
	circuitdata.nodenames = nodes; % all non-ground nodes
	circuitdata.groundnodename = ground;
	circuitdata.elements = {vddElement, iInj1Element, ...
				minv1nElement, minv1pElement, ...
				minv2nElement, minv2pElement, ...
				minv3nElement, minv3pElement};

	% set up and return a DAE of the MNA equations for the circuit
	DAE = MNA_EqnEngine(cktname, circuitdata); % 2016/02/18: equally
          % inexplicably, it works perfectly now; whereas MNA_EqnEngine_older
          % failed!
	% DAE = MNA_EqnEngine_older(cktname, circuitdata); % 2012/07/23: for 
          % some inexplicable reason, transient and HB behave differently if
          % MNA_EqnEngine is used (transient seems to take different
          % timesteps, HB NR fails outright), even though tests of
          % MNA_EqnEngine using compare_MNAEqnEngine_w_older show identical
          % functions and Jacobians! This needs to be debugged. Until then, we
          % use MNA_EqnEngine_older so that the HB/PPV tests work.
end
