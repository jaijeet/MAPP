%author: Tianshi Wang, 2013/09/17
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
% from https://nanohub.org/resources/19223
% mvs_model_si_1_0_0_verilog_test_bench/Hspice/dc_inverter.sp
% uses JR's MVSModSpec.m translation instead
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ckt name
cktdata.cktname = 'DC Inverter';

% nodes (names)
cktdata.nodenames = {'sup', 'in', 'out'};
cktdata.groundnodename = 'gnd';

% list of elements 

% vsupElem
vsupElem.name = 'Vsup';
vsupElem.model = vsrcModSpec('Vsup');
vsupElem.nodes = {'sup', 'gnd'}; % p, n
vsupElem.parms = {}; % vsrc/isrc have no parameters

cktdata.elements = {vsupElem};

% vinElem
vinElem.name = 'Vin';
vinElem.model = vsrcModSpec('Vin');
vinElem.nodes = {'in', 'gnd'}; % p, n
vinElem.parms = {}; % vsrc/isrc have no parameters

cktdata.elements = {cktdata.elements{:}, vinElem};

% pmosElem
pmosElem.name = 'PMOS';
pmosElem.model = MVSModSpec('PMOS');
pmosElem.nodes = {'sup', 'in', 'out', 'sup'}; % d, g, s, b
pmosElem.parms = feval(pmosElem.model.getparms, pmosElem.model);
	 % set parameters
	 %    tipe = -1
	 pmosElem.model = feval(pmosElem.model.setparms, 'tipe', -1, pmosElem.model);
	 %    W = 1.0e-4
	 pmosElem.model = feval(pmosElem.model.setparms, 'W', 1.0e-4, pmosElem.model);
	 %    Lgdr = 32e-7
	 pmosElem.model = feval(pmosElem.model.setparms, 'Lgdr', 32e-7, pmosElem.model);
	 %    dLg = 8e-7
	 pmosElem.model = feval(pmosElem.model.setparms, 'dLg', 8e-7, pmosElem.model);
	 %    Cg = 2.57e-6
	 pmosElem.model = feval(pmosElem.model.setparms, 'Cg', 2.57e-6, pmosElem.model);
	 %    beta = 1.8
	 pmosElem.model = feval(pmosElem.model.setparms, 'parm_beta', 1.8, pmosElem.model);
	 %    alpha = 3.5
	 pmosElem.model = feval(pmosElem.model.setparms, 'parm_alpha', 3.5, pmosElem.model);
	 %    Cif = 1.38e-12
	 pmosElem.model = feval(pmosElem.model.setparms, 'Cif', 1.38e-12, pmosElem.model);
	 %    Cof = 1.47e-12
	 pmosElem.model = feval(pmosElem.model.setparms, 'Cof', 1.47e-12, pmosElem.model);
	 %    phib = 1.2
	 pmosElem.model = feval(pmosElem.model.setparms, 'phib', 1.2, pmosElem.model);
	 %    gamma = 0.1
	 pmosElem.model = feval(pmosElem.model.setparms, 'parm_gamma', 0.1, pmosElem.model);
	 %    mc = 0.2
	 pmosElem.model = feval(pmosElem.model.setparms, 'mc', 0.2, pmosElem.model);
	 %    CTM_select = 1
	 pmosElem.model = feval(pmosElem.model.setparms, 'CTM_select', 1, pmosElem.model);
	 %    Rs0 = 100
	 pmosElem.model = feval(pmosElem.model.setparms, 'Rs0', 100, pmosElem.model);
	 %    Rd0 = 100
	 pmosElem.model = feval(pmosElem.model.setparms, 'Rd0', 100, pmosElem.model);
	 %    n0 = 1.68
	 pmosElem.model = feval(pmosElem.model.setparms, 'n0', 1.68, pmosElem.model);
	 %    nd = 0.1
	 pmosElem.model = feval(pmosElem.model.setparms, 'nd', 0.1, pmosElem.model);
	 %    vxo = 7542204
	 pmosElem.model = feval(pmosElem.model.setparms, 'vxo', 7542204, pmosElem.model);
	 %    mu = 165
	 pmosElem.model = feval(pmosElem.model.setparms, 'parm_mu', 165, pmosElem.model);
	 %    Vt0 = 0.5535
	 pmosElem.model = feval(pmosElem.model.setparms, 'Vt0', 0.5535, pmosElem.model);
	 %    delta = 0.15
	 pmosElem.model = feval(pmosElem.model.setparms, 'delta', 0.15, pmosElem.model);

cktdata.elements = {cktdata.elements{:}, pmosElem};

% nmosElem
nmosElem.name = 'NMOS';
nmosElem.model = MVS_1_0_ModSpec('NMOS');
nmosElem.nodes = {'out', 'in', 'gnd', 'gnd'}; % d, g, s, b
nmosElem.parms = feval(nmosElem.model.getparms, nmosElem.model);
	 % set parameters
	 %    tipe = 1
	 nmosElem.model = feval(nmosElem.model.setparms, 'tipe', 1, nmosElem.model);
	 %    W = 1e-4
	 nmosElem.model = feval(nmosElem.model.setparms, 'W', 1e-4, nmosElem.model);
	 %    Lgdr = 32e-7
	 nmosElem.model = feval(nmosElem.model.setparms, 'Lgdr', 32e-7, nmosElem.model);
	 %    dLg = 9e-7
	 nmosElem.model = feval(nmosElem.model.setparms, 'dLg', 9e-7, nmosElem.model);
	 %    Cg = 2.57e-6
	 nmosElem.model = feval(nmosElem.model.setparms, 'Cg', 2.57e-6, nmosElem.model);
	 %    beta = 1.8
	 nmosElem.model = feval(nmosElem.model.setparms, 'parm_beta', 1.8, nmosElem.model);
	 %    alpha = 3.5
	 nmosElem.model = feval(nmosElem.model.setparms, 'parm_alpha', 3.5, nmosElem.model);
	 %    Cif = 1.38e-12
	 nmosElem.model = feval(nmosElem.model.setparms, 'Cif', 1.38e-12, nmosElem.model);
	 %    Cof = 1.47e-12
	 nmosElem.model = feval(nmosElem.model.setparms, 'Cof', 1.47e-12, nmosElem.model);
	 %    phib = 1.2
	 nmosElem.model = feval(nmosElem.model.setparms, 'phib', 1.2, nmosElem.model);
	 %    gamma = 0.1
	 nmosElem.model = feval(nmosElem.model.setparms, 'parm_gamma', 0.1, nmosElem.model);
	 %    mc = 0.2
	 nmosElem.model = feval(nmosElem.model.setparms, 'mc', 0.2, nmosElem.model);
	 %    CTM_select = 1
	 nmosElem.model = feval(nmosElem.model.setparms, 'CTM_select', 1, nmosElem.model);
	 %    Rs0 = 100
	 nmosElem.model = feval(nmosElem.model.setparms, 'Rs0', 100, nmosElem.model);
	 %    Rd0 = 100
	 nmosElem.model = feval(nmosElem.model.setparms, 'Rd0', 100, nmosElem.model);
	 %    n0 = 1.68
	 nmosElem.model = feval(nmosElem.model.setparms, 'n0', 1.68, nmosElem.model);
	 %    nd = 0.1
	 nmosElem.model = feval(nmosElem.model.setparms, 'nd', 0.1, nmosElem.model);
	 %    vxo = 1.2e7
	 nmosElem.model = feval(nmosElem.model.setparms, 'vxo', 1.2e7, nmosElem.model);
	 %    mu = 200
	 nmosElem.model = feval(nmosElem.model.setparms, 'parm_mu', 200, nmosElem.model);
	 %    Vt0 = 0.4
	 nmosElem.model = feval(nmosElem.model.setparms, 'Vt0', 0.4, nmosElem.model);
	 %    delta = 0.15
	 nmosElem.model = feval(nmosElem.model.setparms, 'delta', 0.15, nmosElem.model);


cktdata.elements = {cktdata.elements{:}, nmosElem};
%% done setting up cktdata


% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine(cktdata);

if 1 == 0
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'Vsup:::E', 1, DAE);
	DAE = feval(DAE.set_uQSS, 'Vin:::E', 0.9, DAE);
	% run DC
	qss = QSS(DAE);
	qss = feval(qss.solve, qss);
	feval(qss.print, qss);
else
	oidx = unkidx_DAEAPI('e_out', DAE);
	i = 0; 
	OUTs = [];
	DAE = feval(DAE.set_uQSS, 'Vsup:::E', 1, DAE);
	VINs = 0:0.1:1;
	for vin = VINs
		DAE = feval(DAE.set_uQSS, 'Vin:::E', vin, DAE);
		i = i+1;
		qss = QSS(DAE);
		qss = feval(qss.solve, qss);
		sol = feval(qss.getsolution, qss);
		OUTs(i) = sol(oidx,1);
	end

	% 1st plot, wrt VDS
	figure;
	hold on;
	xlabel 'Vin';
	ylabel 'Vout';
	title 'MVS inverter';
	hold on;
	plot(VINs, OUTs, '-r');
	grid on; axis tight;
	return;
end
