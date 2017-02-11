function DAE = MNAEqnEngine_MOSFET_ringosc(NFET_model, PFET_model, VDDval)
%function DAE = MNAEqnEngine_MOSFET_ringosc(NFET_model, PFET_model, VDDval)
%author: J. Roychowdhury, 2012/05/21
% A 3-stage ring oscillator 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	a 3 stage ring oscillator made of the P/N MOSFETs supplied
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	% ckt name
	nmodname = feval(NFET_model.ModelName, NFET_model);
	pmodname = feval(PFET_model.ModelName, PFET_model);
	cktname = sprintf('3-stage ring oscillator made using %s PFETs and %s NFETs', pmodname, nmodname);

	% nodes (names)
	nodes = {'VDD', 'inv1', 'inv2', 'inv3'};
	ground = 'gnd';

	% list of elements 
	vddM = vsrcModSpec('VDD');
	vdd_udata1.uname = 'E'; % TODO for JR: uname here is redundant, vsrcModSpec already has it.
	vdd_udata1.QSSval = VDDval;

	minv1pM = PFET_model; minv1pM.uniqID = 'minv1p';
	minv1nM = NFET_model; minv1nM.uniqID = 'minv1n';
	minv2pM = PFET_model; minv2pM.uniqID = 'minv2p'; 
	minv2nM = NFET_model; minv2nM.uniqID = 'minv2n'; 
	minv3pM = PFET_model; minv3pM.uniqID = 'minv3p'; 
	minv3nM = NFET_model; minv3nM.uniqID = 'minv3n'; 

	% element node connectivities
	vddNodes = {'VDD', ground}; % p, n
	%mp1 inv1 inv3 VDD VDD mypmos
	minv1pNodes = {'inv1', 'inv3', 'VDD', 'VDD'};  % d g s b
	%mn1 inv1 inv3 0 0 mynmos
	minv1nNodes = {'inv1', 'inv3', ground, ground};  % d g s b

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
		vddElement.udata = {vdd_udata1};

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
	circuitdata.elements = {vddElement, ...
				minv1nElement, minv1pElement, ...
				minv2nElement, minv2pElement, ...
				minv3nElement, minv3pElement};

	% set up and return a DAE of the MNA equations for the circuit
	DAE = MNA_EqnEngine(cktname, circuitdata);
end % MNAEqnEngine_MOSFET_ringosc
