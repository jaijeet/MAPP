%author: Bichen Wu, 2013/11/13
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%
% An ideal-ish differential pair using Ebers-Moll BJTs. The emitters of 2 N-type BJTs are
% connected at node nE (node voltage eE). An ideal current source of DC value IE
% drains node E. The collector of the BJT on the left is connected
% to node nCL (node voltage eCL); that of the one on the right to node nCR (node
% voltage eCR). Resistors rL and rR connect from VDD to nodes nCL and nCR,
% respectively; similarly with capacitors CL and CR. 
%
% The BJT on the left has its base connected to Vin; that of the one on the right 
% connects to ground. The circuit is, therefore, not perfectly symmetric. This
% lack of symmetry shows up in different DC components at the two output nodes when HB is run
% with large Vin, and exacerbated if you use an insufficient number of harmonics.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ckt name
cktname = 'BJT-diff-pair';

% nodes (names)
nodes = {'Vdd', 'CL', 'CR', 'E', 'Vin'};
ground = 'gnd';

% list of elements 
vddM= vsrcModSpec('VDD');
vinM= vsrcModSpec('VIN');
ieM = isrcModSpec('IE');
resLM= resModSpec('RESL');
resRM= resModSpec('RESR');
bjtLM = EbersMoll_BJT_With_Capacitor_ModSpec('BJTL'); 
bjtRM = EbersMoll_BJT_With_Capacitor_ModSpec('BJTR'); 

% element node connectivities
vddNodes = {'Vdd', ground}; % p, n
vinNodes = {'Vin', ground}; % p, n
ieNodes = {'E', ground}; % p, n 
resLNodes = {'Vdd', 'CL'}; % p, n
resRNodes = {'Vdd', 'CR'}; % p, n
bjtLNodes = {'CL', 'Vin', 'E'};  % c b e
bjtRNodes = {'CR', ground, 'E'};  % c b e

vddElement.name = 'vdd'; vddElement.model = vddM; 
	vddElement.nodes = vddNodes; vddElement.parms = {};

vinElement.name = 'vin'; vinElement.model = vinM; 
	vinElement.nodes = vinNodes; vinElement.parms = {};

ieElement.name = 'ie'; ieElement.model = ieM; 
	ieElement.nodes = ieNodes; ieElement.parms = {};

%.model Resistor on the Left 
%	R = 2000
resLM = feval(resLM.setparms,'R',2000, resLM);
resLElement.name = 'resL'; resLElement.model = resLM; 
	resLElement.nodes = resLNodes; 
	resLElement.parms = feval(resLM.getparms, resLM);

%.model Resistor on the Right 
%	R = 2000
resRM = feval(resRM.setparms,'R',2000, resRM);
resRElement.name = 'resR'; resRElement.model = resRM; 
	resRElement.nodes = resRNodes; 
	resRElement.parms = feval(resRM.getparms, resRM);

%.model Ebers Moll BJT on the Left
% parameters
%	IsF = 1e-12
bjtLM = feval(bjtLM.setparms,'IsF',1e-12, bjtLM);
%	VtF = 0.025
bjtLM = feval(bjtLM.setparms,'VtF',0.025, bjtLM);
%	IsR = 1e-12
bjtLM = feval(bjtLM.setparms,'IsR',1e-12, bjtLM);
%	VtR = 0.025
bjtLM = feval(bjtLM.setparms,'VtR',0.025, bjtLM);
%	alphaF = 0.99
bjtLM = feval(bjtLM.setparms,'alphaF',0.99, bjtLM);
%	alphaR = 0.5
bjtLM = feval(bjtLM.setparms,'alphaR',0.5, bjtLM);

bjtLElement.name = 'bjtL'; bjtLElement.model = bjtLM; 
	bjtLElement.nodes = bjtLNodes; 
	bjtLElement.parms = feval(bjtLM.getparms, bjtLM);

%.model Ebers Moll BJT on the Right
% parameters
%	IsF = 1e-12
bjtRM = feval(bjtRM.setparms,'IsF',1e-12, bjtRM);
%	VtF = 0.025
bjtRM = feval(bjtRM.setparms,'VtF',0.025, bjtRM);
%	IsR = 1e-12
bjtRM = feval(bjtRM.setparms,'IsR',1e-12, bjtRM);
%	VtR = 0.025
bjtRM = feval(bjtRM.setparms,'VtR',0.025, bjtRM);
%	alphaF = 0.99
bjtRM = feval(bjtRM.setparms,'alphaF',0.99, bjtRM);
%	alphaR = 0.5
bjtRM = feval(bjtRM.setparms,'alphaR',0.5, bjtRM);

bjtRElement.name = 'bjtR'; bjtRElement.model = bjtRM; 
	bjtRElement.nodes = bjtRNodes; 
	bjtRElement.parms = feval(bjtRM.getparms, bjtRM);

% set up circuitdata structure containing all the above
% contains: nodenames, groundnodename(s), elements
% each element contains: name, ModSpecModel, nodes, parms
circuitdata.cktname = cktname; 
circuitdata.nodenames = nodes; % all non-ground nodes
circuitdata.groundnodename = ground;
circuitdata.elements = {vddElement, vinElement, ieElement, resLElement, resRElement, bjtLElement, bjtRElement};

% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine(cktname, circuitdata);

