function test = MAPPtest_MNA_MVS_no_int_nodes_char_curves_DCsweep()
	% Moved from test_MNAEqnEngine_MVS_no_int_nodes_char_curves.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%NFET = DAAV6ModSpec('mn');
	NFET = MVS_no_int_nodes_ModSpec('mn');
	nname = feval(NFET.name, NFET);
	ndesc = feval(NFET.description, NFET);
	%PFET = DAAV6ModSpec('mp');
	PFET = MVS_no_int_nodes_ModSpec('mp');
	pname = feval(PFET.name, PFET);
	pdesc = feval(PFET.description, PFET);
	
	% change PFET parameters from default (which is N-type)
	%.model mypmos daaV6 \
	%	tipe=p \
	PFET = feval(PFET.setparms,'tipe','p', PFET);
	%	Lg=35e-7 \
	PFET = feval(PFET.setparms,'Lg',35e-7, PFET);
	%	dLg=8.75e-7 \
	PFET = feval(PFET.setparms,'dLg',8.75e-7, PFET);
	%	Cg=1.7e-6 \
	PFET = feval(PFET.setparms,'Cg',1.7e-6, PFET);
	%	delta=0.155 \
	PFET = feval(PFET.setparms,'delta',0.155, PFET);
	%	S=0.1 \
	PFET = feval(PFET.setparms,'S',0.1, PFET);
	%	vxo=0.85e7 \
	PFET = feval(PFET.setparms,'vxo',0.85e7, PFET);
	%	mu=140 \
	PFET = feval(PFET.setparms,'mu',140, PFET);
	%	beta=1.4
	PFET = feval(PFET.setparms,'beta',1.4, PFET);
	%	#Vt0=0.543 # no longer used by daaV6
	DAE = MNAEqnEngine_MOSFET_P_N_devices(NFET, PFET); % DAEAPI script that sets up DAE


    % Circuit DAE. 
    test.DAE = DAE;
	VDSs = 0:0.05:1.2; VDSs = VDSs';
	VGSs = 0.5*ones(length(VDSs),1);
    test.args.QSSInputs = [VDSs, VDSs, VGSs, VGSs];
	test.args.initGuess = [];


    test.name='MNA_MVS_no_int_nodes_DCsweep';
    %MNAEqnEngine_vsrc_diode; test.DAE = DAE;
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'MNA_MVS_no_int_nodes_DCSweep.mat';

    % Simulation time-related parameters
    test.args.NRparms = defaultNRparms();
    test.args.NRparms.maxiter = 100;
    test.args.NRparms.reltol = 1e-5;
    test.args.NRparms.abstol = 1e-10;
    test.args.NRparms.residualtol = 1e-10;
    test.args.NRparms.dbglvl = 0; % minimal output

    test.args.comparisonAbstol = 1e-9;
    test.args.comparisonReltol = 1e-3;

   end
