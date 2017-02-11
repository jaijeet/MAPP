%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	% ckt name
	cktname = 'gnd-vsrc-n1-R-n2-C-n3-L-gnd';

	% nodes (names)
	nodes = {'1', '2', '3'};
	ground = 'gnd';

	% list of elements 
	vM = vsrcModSpec('vsrc');
	v_udata1.uname = 'E';
	v_udata1.QSSval = 1.0;
	utargs.A = 1; utargs.f=1e3; utargs.phi=0;
	utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
	v_udata1.utransient = utfunc;
	v_udata1.utransientargs = utargs;

	r1M = resModSpec('r1'); 
	c1M = capModSpec('c1'); 
	l1M = indModSpec('l1'); 

	% element node connectivities
	vnodes = {'1', ground}; % p, n
	r1nodes = {'1', '2'}; % p, n
	c1nodes = {'3', '2'}; % p, n
	l1nodes = {'3', ground}; % p, n

	vElement.name = 'v1'; vElement.model = vM; 
		vElement.nodes = {'1', ground}; vElement.parms = {};
		vElement.udata = {v_udata1};
	r1Element.name = 'r1'; r1Element.model = r1M; 
		r1Element.nodes = r1nodes; r1Element.parms = {1000};
	c1Element.name = 'c1'; c1Element.model = c1M; 
		c1Element.nodes = c1nodes; c1Element.parms = {1e-6};
	l1Element.name = 'l1'; l1Element.model = l1M; 
		l1Element.nodes = l1nodes; l1Element.parms = {5e-2};


	% set up circuitdata structure containing all the above
	% contains: nodenames, groundnodename(s), elements
	% each element contains: name, ModSpecModel, nodes, parms
	circuitdata.cktname = cktname; % all non-ground nodes
	circuitdata.nodenames = nodes; % all non-ground nodes
	circuitdata.groundnodename = ground;
	circuitdata.elements = {vElement, r1Element, c1Element, l1Element};

	% set up and return a DAE of the MNA equations for the circuit
	DAE = STA_EqnEngine('vsrc-R-C-L', circuitdata);

