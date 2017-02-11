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
	 % set parameters
	 %    tipe = 1
	 mosElem.model = feval(mosElem.model.setparms, 'tipe', 1, mosElem.model);
	 %    W = 1e-4
	 mosElem.model = feval(mosElem.model.setparms, 'W', 1e-4, mosElem.model);
	 %    Lgdr = 32e-7
	 mosElem.model = feval(mosElem.model.setparms, 'Lgdr', 32e-7, mosElem.model);
	 %    dLg = 9e-7
	 mosElem.model = feval(mosElem.model.setparms, 'dLg', 9e-7, mosElem.model);
	 %    Cg = 2.57e-6
	 mosElem.model = feval(mosElem.model.setparms, 'Cg', 2.57e-6, mosElem.model);
	 %    beta = 1.8
	 mosElem.model = feval(mosElem.model.setparms, 'parm_beta', 1.8, mosElem.model);
	 %    alpha = 3.5
	 mosElem.model = feval(mosElem.model.setparms, 'parm_alpha', 3.5, mosElem.model);
	 %    Cif = 1.38e-12
	 mosElem.model = feval(mosElem.model.setparms, 'Cif', 1.38e-12, mosElem.model);
	 %    Cof = 1.47e-12
	 mosElem.model = feval(mosElem.model.setparms, 'Cof', 1.47e-12, mosElem.model);
	 %    phib = 1.2
	 mosElem.model = feval(mosElem.model.setparms, 'phib', 1.2, mosElem.model);
	 %    gamma = 0.1
	 mosElem.model = feval(mosElem.model.setparms, 'parm_gamma', 0.1, mosElem.model);
	 %    mc = 0.2
	 mosElem.model = feval(mosElem.model.setparms, 'mc', 0.2, mosElem.model);
	 %    CTM_select = 1
	 mosElem.model = feval(mosElem.model.setparms, 'CTM_select', 1, mosElem.model);
	 %    Rs0 = 100
	 mosElem.model = feval(mosElem.model.setparms, 'Rs0', 100, mosElem.model);
	 %    Rd0 = 100
	 mosElem.model = feval(mosElem.model.setparms, 'Rd0', 100, mosElem.model);
	 %    n0 = 1.68
	 mosElem.model = feval(mosElem.model.setparms, 'n0', 1.68, mosElem.model);
	 %    nd = 0.1
	 mosElem.model = feval(mosElem.model.setparms, 'nd', 0.1, mosElem.model);
	 %    vxo = 1.2e7
	 mosElem.model = feval(mosElem.model.setparms, 'vxo', 1.2e7, mosElem.model);
	 %    mu = 200
	 mosElem.model = feval(mosElem.model.setparms, 'parm_mu', 200, mosElem.model);
	 %    Vt0 = 0.4
	 mosElem.model = feval(mosElem.model.setparms, 'Vt0', 0.4, mosElem.model);
	 %    delta = 0.15
	 mosElem.model = feval(mosElem.model.setparms, 'delta', 0.15, mosElem.model);

cktdata.elements = {cktdata.elements{:}, mosElem};

%% done setting up cktdata


% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine(cktdata);

if 1 == 1
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'Vdd:::E', 0.02, DAE);
	DAE = feval(DAE.set_uQSS, 'Vgg:::E', 0.1, DAE);
	% run DC
	NRparms = defaultNRparms;
	NRparms.method = 1;
	NRparms.dbglvl = 2;
	qss = QSS(DAE, NRparms);
	qss = feval(qss.solve, qss);
	feval(qss.print, qss);
else
	% DC sweep over vdd and vgg 

	oidx = unkidx_DAEAPI('Vdd:::ipn', DAE);
	i = 0; 
	IDs = [];
	%VGGs = 0.1:0.1:1;
	VGGs = 0.1:0.1:0.8;
	% VDDs = -0:4.1:1.2;
	% VDDs = 0:0.1:1.2;
	VDDs = -0.4:0.1:0;
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
