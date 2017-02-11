%author: Tianshi Wang, 2013/02/26
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	An n-type MOS (Schichman-Hodges model) driven by VGG and VDD voltages sources
%	to generate characteristic curves.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ckt name
cktdata.cktname = 'Shichman-Hodges MOS model: characteristic-curves';

% nodes (names)
cktdata.nodenames = {'drain', 'gate'};
cktdata.groundnodename = 'gnd';

% list of elements 

% vddElem
vddElem.name = 'Vdd';
vddElem.model = vsrcModSpec('Vdd');
vddElem.nodes = {'drain', 'gnd'}; % p, n
vddElem.parms = {}; % vsrc/isrc have no parameters

cktdata.elements = {vddElem};

% vggElem
vggElem.name = 'Vgg';
vggElem.model = vsrcModSpec('Vgg');
vggElem.nodes = {'gate', 'gnd'}; % p, n
vggElem.parms = {}; % vsrc/isrc have no parameters

cktdata.elements = {cktdata.elements{:}, vggElem};

% mosElem
mosElem.name = 'NMOS';
mosElem.model = SH_MOS_ModSpec('NMOS');
mosElem.nodes = {'drain', 'gate', 'gnd'}; % d, g, s
mosElem.parms = feval(mosElem.model.getparms, mosElem.model);
	% set parameters
	%	 Beta = 1.8
	mosElem.model = feval(mosElem.model.setparms, ...
				'Beta',  1.8, mosElem.model);
	%	 VT = 0.3
	mosElem.model = feval(mosElem.model.setparms, ...
				'VT',  0.1, mosElem.model);

cktdata.elements = {cktdata.elements{:}, mosElem};

%% done setting up cktdata


% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine(cktdata);
