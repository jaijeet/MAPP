%author: Tianshi Wang, 2013/09/17
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	An n-type MVS MOS driven by VGG and VDD voltages sources
%	to generate characteristic curves.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ckt name
cktdata.cktname = 'MVS MOS model: characteristic-curves';

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
mosElem.model = MVS_1_0_ModSpec('NMOS');
mosElem.nodes = {'drain', 'gate', 'gnd', 'gnd'}; % d, g, s, b
mosElem.parms = feval(mosElem.model.getparms, mosElem.model);
	 %    Rs0 = 1
	 mosElem.model = feval(mosElem.model.setparms, 'Rs0', 1, mosElem.model);
	 %    Rd0 = 1
	 mosElem.model = feval(mosElem.model.setparms, 'Rd0', 1, mosElem.model);

cktdata.elements = {cktdata.elements{:}, mosElem};

%% done setting up cktdata


% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine(cktdata);

if 1 == 0
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'Vdd:::E', 0.8, DAE);
	DAE = feval(DAE.set_uQSS, 'Vgg:::E', 0.1, DAE);
	% run DC
	qss = QSS(DAE);
	qss = feval(qss.solve, qss);
	feval(qss.print, qss);
else
	% DC sweep over vdd and vgg 

	oidx = unkidx_DAEAPI('Vdd:::ipn', DAE);
	i = 0; 
	IDs = [];
	%VGGs = 0.1:0.1:1;
	VGGs = 0.1:0.1111:0.8;
	%VDDs = -1.2:0.05:1.2;
	VDDs = -0.4:0.09:1.2;
	for vgg = VGGs
		DAE = feval(DAE.set_uQSS, 'Vgg:::E', vgg, DAE);
		i = i+1; j = 0;
		for vdd = VDDs
			DAE = feval(DAE.set_uQSS, 'Vdd:::E', vdd, DAE);
			qss = QSS(DAE);
			% qss.NRparms.dbglvl = 2;
			% qss.NRparms.maxiter = 100;
			% qss.NRparms.do_limiting = 0;
			% qss.NRparms.do_initializing = 0;
			qss = feval(qss.solve, qss);
			sol = feval(qss.getsolution, qss);
			j = j+1;
			IDs(i,j) = sol(oidx,1);
		end
	end

	% 1st plot, wrt VDS
	figure;
	hold on;
	xlabel 'VDS';
	ylabel 'ID';
	title 'MVS (NMOS) characteristic curves';
	hold on;
	i = 0; legends = {};
	for vgg = VGGs
		i = i+1;
		col = getcolorfromindex(gca(), i);
		marker = getmarkerfromindex(i);
		plot(VDDs, -IDs(i,:), sprintf('%s-', marker), 'Color', col);
		legends{i} = sprintf('VGS=%0.2g', vgg);
	end
	legend(legends, 'Location', 'SouthEast');
	
	grid on; axis tight;

	return;

	% 2nd plot, wrt VGS
	figure;
	hold on;
	xlabel 'VGS';
	ylabel 'ID';
	title 'MVS (NMOS) characteristic curves';
	hold on;
	j = 0; legends = {};
	for vdd = VDDs
		j = j+1;
		col = getcolorfromindex(gca(), j);
		plot(VGGs, -IDs(:,j), '.-', 'Color', col);
		legends{j} = sprintf('VDS=%0.2g', vdd);
	end
	legend(legends, 'Location', 'SouthEast');
	
	grid on; axis tight;

end
