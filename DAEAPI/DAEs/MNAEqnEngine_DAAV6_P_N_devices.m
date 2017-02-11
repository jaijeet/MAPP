%author: J. Roychowdhury, 2012/05/01-08
%
%DAAv6 NFET driven by VGS and VDS voltage sources
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	a DAAV6 NFET driven by VGS and VDS voltages sources
%	(used to generate characteristic curves.)
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
cktname = 'DAAV6-characteristic-curves';

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
mnM = DAAV6ModSpec('mn'); 
mpM = DAAV6ModSpec('mp'); 

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

%.model mypmos daaV6 \
%	tipe=p \
mpM = feval(mpM.setparms,'tipe','p', mpM);
%	Lg=35e-7 \
mpM = feval(mpM.setparms,'Lg',35e-7, mpM);
%	dLg=8.75e-7 \
mpM = feval(mpM.setparms,'dLg',8.75e-7, mpM);
%	Cg=1.7e-6 \
mpM = feval(mpM.setparms,'Cg',1.7e-6, mpM);
%	delta=0.155 \
mpM = feval(mpM.setparms,'delta',0.155, mpM);
%	S=0.1 \
mpM = feval(mpM.setparms,'S',0.1, mpM);
%	Rs=130 \
mpM = feval(mpM.setparms,'Rs',130, mpM);
%	Rd=130 \
mpM = feval(mpM.setparms,'Rd',130, mpM);
%	vxo=0.85e7 \
mpM = feval(mpM.setparms,'vxo',0.85e7, mpM);
%	mu=140 \
mpM = feval(mpM.setparms,'mu',140, mpM);
%	beta=1.4
mpM = feval(mpM.setparms,'beta',1.4, mpM);
%	#Vt0=0.543 # no longer used by daaV6

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
