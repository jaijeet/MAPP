%author: Tianshi Wang, 2012/11/12
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%
% An ideal-ish differential pair using Schichman-Hodges MOSFETs.
% An ideal current source of DC value IS drains node S.
% The drain of the MOSFET on the left is connected
% to node nDL (node voltage eDL); that of the one on the right to node nDR (node
% voltage eDR). Resistors rL and rR connect from VDD to nodes nDL and nDR,
%
% The MOSFET on the left has its gate connected to Vin; that of the one on the right 
% connects to ground. The circuit is, therefore, not perfectly symmetric. This
% lack of symmetry shows up in different DC components at the two output nodes
% with large Vin, and exacerbated if you use an insufficient number of harmonics.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ckt name
cktdata.cktname = 'MOS diffpair';

% nodes (names)
cktdata.nodenames = {'Vdd', 'DL', 'DR', 'S', 'Vin'};
cktdata.groundnodename = 'gnd';

% elements 
%vddElem
vddElem.name = 'vdd';
vddElem.model = vsrcModSpec('VDD'); % get the ModSpec model
vddElem.nodes = {'Vdd', 'gnd'}; % positive and negative nodes of the vsrc
vddElem.parms = {};

cktdata.elements = {vddElem};

%vinElem
vinElem.name = 'Vin';
vinElem.model = vsrcModSpec('Vin'); % get the ModSpec model
vinElem.nodes = {'Vin', 'gnd'}; % positive and negative nodes of the vsrc
vinElem.parms = {};

cktdata.elements = {cktdata.elements{:}, vinElem};

%isElem
isElem.name = 'IS';
isElem.model = isrcModSpec('IS'); % get the ModSpec model
isElem.nodes = {'S', 'gnd'}; % positive and negative nodes of the ssrc
isElem.parms = {};

cktdata.elements = {cktdata.elements{:}, isElem};

%resLelem
resLelem.name = 'R1';
resLelem.model = resModSpec('R1'); % get the ModSpec model
resLelem.nodes = {'Vdd', 'DL'}; % resistor nodes
resLelem.parms = {2000}; % or use feval(resLelem.model.defaultparms, resLelem.model)

cktdata.elements = {cktdata.elements{:}, resLelem};

%capLelem
capLelem.name = 'C1';
capLelem.model = capModSpec('capL'); % get the ModSpec model
capLelem.nodes = {'Vdd', 'DL'}; % cap nodes
capLelem.parms = {1e-6}; % or use feval(capLelem.model.defaultparms, capLelem.model)

cktdata.elements = {cktdata.elements{:}, capLelem};

%resRelem
resRelem.name = 'R2';
resRelem.model = resModSpec('R2'); % get the ModSpec model
resRelem.nodes = {'Vdd', 'DR'}; % resistor nodes
resRelem.parms = {2000}; % or use feval(resRelem.model.defaultparms, resRelem.model)

cktdata.elements = {cktdata.elements{:}, resRelem};

%capRelem
capRelem.name = 'C2';
capRelem.model = capModSpec('capR'); % get the ModSpec model
capRelem.nodes = {'Vdd', 'DR'}; % cap nodes
capRelem.parms = {1e-6}; % or use feval(capRelem.model.defaultparms, capRelem.model)

cktdata.elements = {cktdata.elements{:}, capRelem};


%mosLelem
mosLelem.name = 'M1';
mosLelem.model = SH_MOS_ModSpec('M1'); % get the ModSpec model
	% set parameters
	%	 Beta = 1.8
	mosLelem.model = feval(mosLelem.model.setparms, 'Beta', 0.02, ...
		mosLelem.model);
	%	 VT = 0.3
	mosLelem.model = feval(mosLelem.model.setparms, 'VT', 0.3, ...
		mosLelem.model);
mosLelem.nodes = {'DL', 'Vin', 'S'}; % d, g, s
mosLelem.parms = feval(mosLelem.model.getparms, mosLelem.model);

cktdata.elements = {cktdata.elements{:}, mosLelem};

%mosRelem
mosRelem.name = 'M2';
mosRelem.model = SH_MOS_ModSpec('M2'); % get the ModSpec model
	% set parameters
	%	 Beta = 1.8
	mosRelem.model = feval(mosRelem.model.setparms, 'Beta', 0.02, ...
		mosRelem.model);
	%	 VT = 0.3
	mosRelem.model = feval(mosRelem.model.setparms, 'VT', 0.3, ...
		mosRelem.model);
mosRelem.nodes = {'DR', 'gnd', 'S'}; % d, g, s
mosRelem.parms = feval(mosRelem.model.getparms, mosRelem.model);

cktdata.elements = {cktdata.elements{:}, mosRelem};

% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine(cktdata);

% feval(DAE.unknames, DAE):
% unks: 'e_Vdd'    'e_DL'    'e_DR'    'e_S'    'e_Vin'    'vdd:::ipn'
%	'Vin:::ipn'
%
% feval(DAE.eqnnames, DAE):
% eqns: 'KCL_Vdd'    'KCL_DL'    'KCL_DR'    'KCL_S'    'KCL_Vin' 'KVL_vdd_vpn'
%	'KVL_Vin_vpn'
% 	
% feval(DAE.inputnames, DAE):
% inputs: 'vdd:::E'    'Vin:::E'    'IS:::I'
