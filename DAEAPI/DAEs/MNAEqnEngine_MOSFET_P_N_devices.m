function DAE = MNAEqnEngine_MOSFET_P_N_devices(NFET_ModSpec, PFET_ModSpec)
%author: J. Roychowdhury, 2012/12/28
% An NFET and PFET driven by VGS and VDS voltages to generate characteristics curve.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	an NFET and a PFET (of the 4-terminal FET models passed in) driven
%	by VGS and VDS voltages sources (used to generate characteristic curves.)
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






	% ckt name
	cktname = 'NFET-PFET-characteristic-curves';

	% nodes (names)
	nodes = {'VDP', 'VDN', 'VGN', 'VGP'};
	ground = 'gnd';

	% list of elements 
	vddPM = vsrcModSpec('vddP');
	vddP_info_about_usrc1.uname = 'E';
	vddP_info_about_usrc1.QSSval = 1.2;
	%args.f = 1e3; % stuff for transient function from netlist
	%vddP_info_about_usrc1.utransientargs = args;
	%dummy = @(t,args) sin(2*pi*args.f*t);
	%vddP_info_info_about_usrc1.utransient = dummy;
	%dummy = @(t,args) [];
	%vddP_info_info_about_usrc1.uLTISSS = dummy;
	%vddP_info_info_about_usrc1.uLTISSSargs = [];
	vddPudata = {vddP_info_about_usrc1};

	% documentation for each element's udata info: (top down)
	% myelement.udata = {udata1, udata2, etc.}
	%           ^^^^^            ^^^^^^
	%   this name is important;  these names are not important - just for local use
	%
	% udata1, udata2, etc. should contain the following fields (these names are important):
	%	.uname = for example 'E' (for a voltage source), 'I' for a current source
	%	  these are exactly from uNames for the device
	%	.QSSval = for example 1.0 (DC value from spice netlist line)
	%	.utransient = handle to a matlab function ut(t, args) that returns
	%		a scalar double number
	%		- for example dummy = @(t, args) args.A*sin(2*pi*args.f*t);
	%		- .utransient = dummy;
	%	.utransientargs = the args argument that needs to be in utransient
	%		- will typically contain information needed to evaluate
	%		  utransient. Standard SPICE u functions: PWL, sffm, pulse?,
	%		  sine, cos (there are only about 5).
	%	.uLTISSS = handle to a matlab function uf(f, args) that returns
	%	.uLTISSSargs = the args argument that needs to be in uLTISSS
	%

	vddNM = vsrcModSpec('vddN');
	vddNudata1.uname = 'E';
	vddNudata1.QSSval = 1.2;
	vddNudata = {vddNudata1};

	vgsPM = vsrcModSpec('vgsP');
	vgsNM = vsrcModSpec('vgsN');
	mnM = NFET_ModSpec;
	mpM = PFET_ModSpec;

	% element node connectivities
	vddPNodes = {'VDP', ground}; % p, n


	vddNNodes = {'VDN', ground}; % p, n


	vgsPNodes = {'VDP', 'VGP'}; % p, n
	vgsNNodes = {'VGN', ground}; % p, n

	mnNodes = {'VDN', 'VGN', ground, ground};  % d g s b
	mpNodes = {ground, 'VGP', 'VDP', 'VDP'};  % d g s b

	vddPElement.name = 'vddP'; vddPElement.model = vddPM; 
		vddPElement.nodes = vddPNodes; vddPElement.parms = {};
		vddPElement.udata = vddPudata;
	vddNElement.name = 'vddN'; vddNElement.model = vddNM; 
		vddNElement.nodes = vddNNodes; vddNElement.parms = {};
		vddNElement.udata = vddNudata;
	vgsNElement.name = 'vgsN'; vgsNElement.model = vgsNM; 
		vgsNElement.nodes = vgsNNodes; vgsNElement.parms = {};
		vgsNElement.udata = {};
	vgsPElement.name = 'vgsP'; vgsPElement.model = vgsPM; 
		vgsPElement.nodes = vgsPNodes; vgsPElement.parms = {};
		vgsPElement.udata = {};
	mnElement.name = 'MN'; mnElement.model = mnM; 
		mnElement.nodes = mnNodes; 
		mnElement.parms = feval(mnM.parmdefaults, mnM);
		mnElement.udata = {};

	mpElement.name = 'MP'; mpElement.model = mpM; 
		mpElement.nodes = mpNodes; 
		mpElement.parms = feval(mpM.getparms, mpM);


	% set up circuitdata structure containing all the above
	% contains: nodenames, groundnodename(s), elements
	% each element contains: name, ModSpecModel, nodes, parms
	circuitdata.cktname = cktname; 
	circuitdata.nodenames = nodes; % all non-ground nodes
	circuitdata.groundnodename = ground;
	circuitdata.elements = {vddPElement, vddNElement, vgsNElement, vgsPElement, mnElement, mpElement};

	% set up and return a DAE of the MNA equations for the circuit
	DAE = MNA_EqnEngine(cktname, circuitdata);
end % of top level function
