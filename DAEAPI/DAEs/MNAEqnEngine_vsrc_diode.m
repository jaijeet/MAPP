% Voltage source and diode circuit reprsented using MNA Equation Engine 
% author: J. Roychowdhury, 2012/05/01-08
% Voltage source and diode circuit (with MNA Equation Engine)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	- vsrc-diode
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


clear circuitdata;



	%{ 
	SPICE netlist for this circuit
	------------------------------
	gnd-vsrc-n1-diode-gnd

	vsrc 1 0 1V
	d1 1 0 d1

	.model d1 diode
	------------------------------
	%}

	% ckt name
	cktname = 'gnd-vsrc-n1-diode-gnd';

	% nodes (names)
	nodes = {'1'};
	ground = '0';

	% list of elements 
	vM = vsrcModSpec('vsrc');
	v_udata1.uname = 'E';
	v_udata1.QSSval = 10;
	utargs.A = 1; utargs.f=1e3; utargs.phi=0;
	utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
	v_udata1.utransient = utfunc;
	v_udata1.utransientargs = utargs;


	dM = diodeModSpec('d1'); 

	% element node connectivities
	vnodes = {'1', ground}; % p, n
	dnodes = {'1', ground}; % p, n

	vElement.name = 'v1'; vElement.model = vM; 
		vElement.nodes = vnodes; vElement.parms = {};
		vElement.udata = {v_udata1};
	dElement.name = 'd1'; dElement.model = dM; 
		dElement.nodes = dnodes; dElement.parms = feval(dM.parmdefaults, dM);

	% set up circuitdata structure containing all the above
	% contains: nodenames, groundnodename(s), elements
	% each element contains: name, ModSpecModel, nodes, parms
	circuitdata.cktname = cktname; % all non-ground nodes
	circuitdata.nodenames = nodes; % all non-ground nodes
	circuitdata.groundnodename = ground;
	circuitdata.elements = {vElement, dElement};

	% set up and return a DAE of the MNA equations for the circuit
	DAE = MNA_EqnEngine('vsrc-diode', circuitdata);
