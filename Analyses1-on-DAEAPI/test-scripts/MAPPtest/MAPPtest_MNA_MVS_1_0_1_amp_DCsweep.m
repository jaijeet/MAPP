function test = MAPPtest_MNA_MVS_1_0_1_amp_DCsweep()


	% Moved from MAPPtest_MNA_MVS_char_curves_DCsweep
	% which is moved from test_MNAEqnEngine_MVS_char_curves.m
	% original author: Bichen Wu
	% Date: 05/06/2014
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

%Changelog:
%---------
%2014-06-19: Tianshi Wang <tianshi@berkeley.edu>: changed from MVSModSpec to
%                                                 MVS_1_0_1_amp
%2014-05-06: Bichen Wu <bichen@berkeley.edu>:
%                                       MAPPtest_MNA_MVS_char_curves_DCsweep
%

    DAE = MNA_EqnEngine(MVSamp_ckt);
	
	VINs = 0:0.1:0.5; VINs = VINs.'; %TODO: non-convergence at 0.6, debug this
	VDDs = 1*ones(length(VINs),1);
	VBIASs = 0.55*ones(length(VINs),1);

    test.args.QSSInputs = [VDDs, VBIASs, VINs];
	test.args.initGuess = [];

    test.DAE = DAE;
    test.name='MNA_MVS_1_0_1_amp_DCsweep';
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'MNA_MVS_1_0_1_amp_DCSweep.mat';

    % Simulation time-related parameters
    test.args.NRparms = defaultNRparms();
    test.args.NRparms.maxiter = 100;
    test.args.NRparms.reltol = 1e-5;
    test.args.NRparms.abstol = 1e-10;
    test.args.NRparms.residualtol = 1e-10;
    test.args.NRparms.limiting = 1;
    test.args.NRparms.init = 1;
    test.args.NRparms.dbglvl = 0; % minimal output

    test.args.comparisonAbstol = 1e-9;
    test.args.comparisonReltol = 1e-3;

   end
